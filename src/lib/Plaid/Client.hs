{-# LANGUAGE DataKinds #-}
module Plaid.Client 
  ( mkPlaidClient
  , PlaidClient(..)
  )
where

import Control.Lens
import Control.Monad.Reader
import Data.Bifunctor
import Data.Proxy
import qualified Data.Text as T
import Servant.Client
import Servant

import Plaid.Types

type PlaidApi = 
  "item" :> "public_token" :> "exchange" :> ReqBody '[JSON] ExchangeAccessTokenRequest :> Post '[JSON] ExchangeAccessTokenResponse

exchangeAccessTokenCM :: ExchangeAccessTokenRequest -> ClientM ExchangeAccessTokenResponse

exchangeAccessTokenCM = client (Proxy @PlaidApi)

type PlaidResult = Either PlaidError

data PlaidClient m  = PlaidClient
  { exchangeAccessToken :: PublicToken -> m (PlaidResult ExchangeAccessTokenResponse)
  }

mkPlaidClient :: forall m r.
  (MonadIO m, MonadReader r m, HasPlaidClientEnv r, HasPlaidConfig r) =>
  PlaidClient m
mkPlaidClient = PlaidClient 
  { exchangeAccessToken = \public_token -> 
      view plaidConfig >>= \PlaidConfig {..} ->
        let client_id = fromPSClientId _configClientId
            secret = fromPSSecretKey _configSecretKey
        -- put `when` in logging when using katip `first (handleClientError "exchange public token for access token")`
        in  callClient (exchangeAccessTokenCM ExchangeAccessTokenRequest {..}) <&>
            first handleClientError
  }
  where
    callClient :: ClientM a -> m (Either ClientError a)
    callClient clientM = view plaidClientEnv >>= liftIO . runClientM clientM . (.unPlaidClientEnv)
        
handleClientError :: ClientError -> PlaidError
handleClientError (FailureResponse _ Response {..}) = 
  ApiErrorResponse responseStatusCode responseBody
handleClientError (UnsupportedContentType mediaType _) = 
  HttpError { errorMsg = T.pack ("Unsupported mediaType: " <> show mediaType) }
handleClientError (InvalidContentTypeHeader _) = 
  HttpError { errorMsg = "InvalidContentTypeHeader" }
handleClientError (ConnectionError someException) = 
  NetworkError { errorMsg = T.pack $ show someException}
handleClientError (DecodeFailure msg Response {responseBody = jsonString} ) = 
  DeserializationError { errorMsg = msg, jsonString }
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
  { exchangeAccessToken = \publicToken -> mkCred >>= \cred ->
        let req = uncurry ExchangeAccessTokenRequest cred publicToken
        in  callClient (exchangeAccessTokenCM req) <&> first handleClientError
  }
  where
    mkCred :: m (ClientId, SecretKey)
    mkCred = view plaidConfig <&> \PlaidConfig {..} -> (fromPSClientId _configClientId, fromPSSecretKey _configSecretKey)

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
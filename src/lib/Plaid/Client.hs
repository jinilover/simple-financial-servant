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
import Plaid.PlaidEnv
import Plaid.PlaidConfig

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
      do
        PlaidConfig {..} <- view plaidConfig
        let client_id = fromPSClientId _configClientId
            secret = fromPSSecretKey _configSecretKey
            req = ExchangeAccessTokenRequest {..}
        callClient (exchangeAccessTokenCM req) <&> 
          first (handleClientError "exchange public token for access token")
  }
  where
    callClient :: ClientM a -> m (Either ClientError a)
    callClient clientM =
      do
        view plaidClientEnv <&> (.unPlaidClientEnv) >>= 
          liftIO . runClientM clientM
        
handleClientError :: T.Text -> ClientError -> PlaidError
handleClientError when_ (FailureResponse _ Response {responseStatusCode = status}) = 
  HttpError { when_, status, errorMsg = "Got FailureResponse" } 
handleClientError when_ (UnsupportedContentType mediaType Response {responseStatusCode = status}) = 
  HttpError { when_, status, errorMsg = T.pack ("Unsupported mediaType: " <> show mediaType) }
handleClientError when_ (InvalidContentTypeHeader Response {responseStatusCode = status}) = 
  HttpError { when_, status, errorMsg = "InvalidContentTypeHeader"}
handleClientError when_ (ConnectionError someException) = 
  NetworkError { when_, errorMsg = T.pack $ show someException}
handleClientError when_ (DecodeFailure msg Response {responseBody = jsonString} ) = 
  DeserializationError { when_, errorMsg = msg, jsonString }
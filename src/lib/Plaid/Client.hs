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
import Data.String.Conv
import Servant.Client
import Servant

import Plaid.Types

type PlaidApi = 
        "item" :> "public_token" :> "exchange" :> ReqBody '[JSON] ExchangeAccessTokenRequest :> Post '[JSON] ExchangeAccessTokenResponse
  :<|>  "sandbox" :> "public_token" :> "create" :> ReqBody '[JSON] CreatePublicTokenRequest :> Post '[JSON] CreatePublicTokenResponse

exchangeAccessTokenCM :: ExchangeAccessTokenRequest -> ClientM ExchangeAccessTokenResponse
createPublicTokenCM :: CreatePublicTokenRequest -> ClientM CreatePublicTokenResponse

exchangeAccessTokenCM :<|> createPublicTokenCM = client (Proxy @PlaidApi)

type PlaidResult = Either PlaidError

data PlaidClient m  = PlaidClient
  { exchangeAccessToken :: PublicToken -> m (PlaidResult ExchangeAccessTokenResponse)
  , createPublicToken :: m (PlaidResult CreatePublicTokenResponse)
  }

mkPlaidClient :: forall m r.
  (MonadIO m, MonadReader r m, HasPlaidClientEnv r, HasPlaidConfig r) =>
  PlaidClient m
mkPlaidClient = PlaidClient 
  { exchangeAccessToken = \publicToken -> mkCred >>= \cred ->
      let req = uncurry ExchangeAccessTokenRequest cred publicToken
      in  callClient (exchangeAccessTokenCM req) <&> first handleClientError
  , createPublicToken = mkCred >>= \(client_id, secret) ->
      let institution_id = Institution3
          initial_products = [Auth]
      in  callClient (createPublicTokenCM CreatePublicTokenRequest {..}) <&> first handleClientError
  }
  where
    mkCred :: m (ClientId, SecretKey)
    mkCred = (,) . fromPSClientId <$> 
      view configClientId <*> 
      (fromPSSecretKey <$> view configSecretKey)

    callClient :: ClientM a -> m (Either ClientError a)
    callClient clientM = view plaidClientEnv >>= liftIO . runClientM clientM . (.unPlaidClientEnv)
        
handleClientError :: ClientError -> PlaidError
handleClientError (FailureResponse _ Response {..}) = 
  ApiErrorResponse responseStatusCode responseBody
handleClientError (UnsupportedContentType mediaType _) = 
  HttpError { errorMsg = "Unsupported mediaType: " <> toS (show mediaType) }
handleClientError (InvalidContentTypeHeader _) = 
  HttpError { errorMsg = "InvalidContentTypeHeader" }
handleClientError (ConnectionError someException) = 
  NetworkError { errorMsg = toS $ show someException}
handleClientError (DecodeFailure msg Response {responseBody = jsonString} ) = 
  DeserializationError { errorMsg = msg, jsonString }
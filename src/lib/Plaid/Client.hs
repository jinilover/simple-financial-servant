{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}
module Plaid.Client 
  ( mkPlaidClient
  , PlaidClient(..)
  )
where

import Common.Utils
import Control.Lens
import Control.Monad.Reader
import Data.Aeson
import Data.Bifunctor
import Data.Proxy
import Data.String.Conv
import Data.Text
import Servant.Client
import Servant

import Plaid.Types
import Katip

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
  (MonadReader r m, HasPlaidClientEnv r, HasPlaidConfig r, KatipContext m) =>
  PlaidClient m
mkPlaidClient = PlaidClient 
  { exchangeAccessToken = \publicToken -> mkCred >>= \cred ->
      let req = uncurry ExchangeAccessTokenRequest cred publicToken
      in  callClient "Exchanging access token" (exchangeAccessTokenCM req) <&> first handleClientError
  , createPublicToken = mkCred >>= \(client_id, secret) ->
      let institution_id = Institution3
          initial_products = [Auth]
      in  callClient "Creating public token" (createPublicTokenCM CreatePublicTokenRequest {..}) <&> first handleClientError
  }
  where
    mkCred :: m (ClientId, SecretKey)
    mkCred = (,)
        <$> fmap fromPSClientId (view configClientId)
        <*> fmap fromPSSecretKey (view configSecretKey)

    callClient :: Text -> ClientM a -> m (Either ClientError a)
    callClient action clientM = katipAddNamespace "client-plaid" $
      do
        logFM InfoS $ logStr action 
        clientEnv <- (.unPlaidClientEnv) <$> view plaidClientEnv
        flip tap (liftIO $ runClientM clientM clientEnv) $ \case
          Right _ -> logFM InfoS "Successfully received response from plaid"
          Left err -> logFM ErrorS $ "Fail to receive response from plaid, cause: " <> logStr (show err)
        
handleClientError :: ClientError -> PlaidError
handleClientError (FailureResponse _ Response {..}) = 
  let status = responseStatusCode
      errorBody = either (const $ Payload responseBody) StructuredResp $ eitherDecode responseBody
  in ApiErrorResponse {..}
handleClientError (UnsupportedContentType mediaType _) = 
  HttpError { errorMsg = "Unsupported mediaType: " <> toS (show mediaType) }
handleClientError (InvalidContentTypeHeader _) = 
  HttpError { errorMsg = "InvalidContentTypeHeader" }
handleClientError (ConnectionError someException) = 
  NetworkError { errorMsg = toS $ show someException}
handleClientError (DecodeFailure msg Response {responseBody = jsonString} ) = 
  DeserializationError { errorMsg = msg, jsonString }
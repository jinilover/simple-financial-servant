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

type PlaidApi = LinkingApi :<|> AccountApi

type LinkingApi = 
  (     "item" :> "public_token" :> "exchange" :> ReqBody '[JSON] ExchangeAccessTokenRequest :> Post '[JSON] ExchangeAccessTokenResponse
  :<|>  "sandbox" :> "public_token" :> "create" :> ReqBody '[JSON] CreatePublicTokenRequest :> Post '[JSON] CreatePublicTokenResponse
  )

exchangeAccessTokenCM :: ExchangeAccessTokenRequest -> ClientM ExchangeAccessTokenResponse
createPublicTokenCM :: CreatePublicTokenRequest -> ClientM CreatePublicTokenResponse

type AccountApi =
        "accounts" :> "get" :> ReqBody '[JSON] AccountRequest :> Post '[JSON] AccountListResponse

getAccountsCM :: AccountRequest -> ClientM AccountListResponse

(exchangeAccessTokenCM :<|> createPublicTokenCM) :<|> getAccountsCM = client (Proxy @PlaidApi)

data PlaidClient m  = PlaidClient
  { exchangeAccessToken :: PublicToken -> m (Either PlaidError ExchangeAccessTokenResponse)
  , createPublicToken :: m (Either PlaidError CreatePublicTokenResponse)
  , getAccounts :: AccessToken -> m (Either PlaidError AccountListResponse)
  }

mkPlaidClient :: forall m r.
  (MonadReader r m, HasPlaidClientEnv r, HasPlaidConfig r, KatipContext m) =>
  PlaidClient m
mkPlaidClient = PlaidClient 
  { exchangeAccessToken = \publicToken -> mkCred >>= \cred ->
      let req = uncurry ExchangeAccessTokenRequest cred publicToken
      in  callClient "Exchanging access token" (exchangeAccessTokenCM req)
  , createPublicToken = mkCred >>= \(client_id, secret) ->
      let institution_id = Institution3
          initial_products = [Auth]
      in  callClient "Creating public token" (createPublicTokenCM CreatePublicTokenRequest {..})
  , getAccounts = \accessToken -> mkCred >>= \cred ->
      let req = uncurry AccountRequest cred accessToken 
      in  callClient "Requesting account information" (getAccountsCM req)
  }
  where
    mkCred :: m (ClientId, SecretKey)
    mkCred = (,)
        <$> fmap fromPSClientId (view configClientId)
        <*> fmap fromPSSecretKey (view configSecretKey)

    callClient :: Text -> ClientM a -> m (Either PlaidError a)
    callClient action clientM = katipAddNamespace "client-plaid" $
      do
        logFM InfoS $ logStr action 
        clientEnv <- (.unPlaidClientEnv) <$> view plaidClientEnv
        tap (\case
            Right _ -> logFM InfoS "Successfully received response from plaid"
            Left err -> logFM ErrorS $ "Fail to receive response from plaid, cause: " <> logStr (show err)
          ) (liftIO $ runClientM clientM clientEnv) <&> first toPlaidError
        
        
toPlaidError :: ClientError -> PlaidError
toPlaidError (FailureResponse _ Response {..}) = 
  let status = responseStatusCode
      errorBody = either (const $ Payload responseBody) StructuredResp $ eitherDecode responseBody
  in ApiErrorResponse {..}
toPlaidError (UnsupportedContentType mediaType _) = 
  HttpError { errorMsg = "Unsupported mediaType: " <> toS (show mediaType) }
toPlaidError (InvalidContentTypeHeader _) = 
  HttpError { errorMsg = "InvalidContentTypeHeader" }
toPlaidError (ConnectionError someException) = 
  NetworkError { errorMsg = toS $ show someException}
toPlaidError (DecodeFailure msg Response {responseBody = jsonString} ) = 
  DeserializationError { errorMsg = msg, jsonString }
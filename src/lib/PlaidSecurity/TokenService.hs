{-# LANGUAGE LambdaCase #-}
module PlaidSecurity.TokenService 
  ( TokenService(..) 
  , mkTokenService
  )
where

import Control.Monad.IO.Class
import Data.Time.Clock
  
import Common.Utils
import Domain.Types  
import Plaid.Client
import Plaid.Types ( PlaidError(..), ExchangeAccessTokenResponse(..), fromPSPublicToken )
import PlaidSecurity.AccessTokenStore
import PlaidSecurity.Types 
import Store.Types

newtype TokenService m = TokenService 
  { exchangeToken :: UserId -> PublicToken -> m (Either TokenServiceError TokenExchangeResponse) 
  }

mkTokenService :: 
  MonadIO m =>
  PlaidClient m ->
  AccessTokenStore m ->
  TokenService m 
mkTokenService plaidClient tokenStore = 
  TokenService
  { exchangeToken = \userId publicToken -> 
      plaidClient.exchangeAccessToken (fromPSPublicToken publicToken) >>= \case
        Right resp -> saveAccessToken resp userId
        Left err -> pureLeft . TokenServiceError . mapClientError $ err
  }
  where
    saveAccessToken ExchangeAccessTokenResponse {..} userId = 
      do
        now <- liftIO getCurrentTime
        let
          accessTokenDataUserUuid = userId
          accessTokenDataItemId = fromPLItemId item_id
          accessTokenDataAccessToken = fromPLAccessToken access_token
          accessTokenDataCreatedAt = CreatedAt now
          accessTokenDataUpdatedAt = UpdatedAt now
          accessTokenData = AccessTokenData {..}
        _ <- tokenStore.saveAccessTokenData accessTokenData
        pureRight TokenExchangeResponse { itemId = accessTokenDataItemId}

mapClientError :: PlaidError -> PlaidApiError
mapClientError DeserializationError {..} = DecodeFailure errorMsg jsonString
mapClientError HttpError {..} = CommsError errorMsg
mapClientError NetworkError {..} = CommsError errorMsg
mapClientError ApiErrorResponse {..} = PlaidErrorResponse status errorBody

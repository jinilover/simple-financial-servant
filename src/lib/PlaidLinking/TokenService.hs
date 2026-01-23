{-# LANGUAGE LambdaCase #-}
module PlaidLinking.TokenService 
  ( TokenService(..) 
  , TokenServiceError(..)
  , mkTokenService
  )
where

import Control.Lens
import Control.Monad.IO.Class
import Control.Monad.Reader
import Data.Functor
import qualified Data.Text as T
import Data.Time.Clock
  
import Common.Utils
import Common.Types    hiding (StructuredResp, ErrorResponse)
import Plaid.Client
import Plaid.Types as PL
import PlaidLinking.AccessTokenStore
import PlaidLinking.Types as PLK
import Store.Types
import Katip

newtype TokenService m = TokenService 
  { exchangeToken :: UserId -> PLK.PublicToken -> m (Either TokenServiceError TokenExchangeResponse) 
  }

mkTokenService :: forall r m.
  (MonadReader r m, HasPlaidLinkingConfig r, KatipContext m) =>
  PlaidClient m ->
  AccessTokenStore m ->
  TokenService m 
mkTokenService plaidClient tokenStore = 
  TokenService
  { exchangeToken = \userId publicToken -> 
      do 
        createPublicTokenConfigs <- view (plaidLinkingConfig . configCreatePublicTokens)
        addNameSpace . callForAccessToken 0 createPublicTokenConfigs userId . fromPSPublicToken $ publicToken
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

    callForAccessToken :: Int -> [CreatePublicTokenConfig] -> UserId -> PL.PublicToken -> m (Either TokenServiceError TokenExchangeResponse)
    callForAccessToken count createPublicTokenConfigs userId publicToken = 
      plaidClient.exchangeAccessToken publicToken >>= \case
        Right accessTokenResp -> 
          saveAccessToken accessTokenResp userId
        Left accessTokenErr ->
          case (count, createPublicTokenRequired accessTokenErr createPublicTokenConfigs) of
            (0, True) -> 
              logFM WarningS "Fail to exchange an access token, try creating public token first" *>
              plaidClient.createPublicToken >>= \case 
                Right CreatePublicTokenResponse {..} -> 
                  logFM InfoS "Created a new public token, trying to exchange an access token again" *>
                  callForAccessToken (count + 1) createPublicTokenConfigs userId public_token
                Left publicTokenErr -> 
                  logFM ErrorS "Fails to create a new public token, cannot proceed to exchange an access token" $>
                  clientToServiceError publicTokenErr
            (0, False) -> 
              pure $ clientToServiceError accessTokenErr
            (_, _) -> 
              logFM ErrorS "It has re-created the public token but still fails to exchange an access token" $> 
              clientToServiceError accessTokenErr

    clientToServiceError = Left . TokenServiceError . mapPlaidError

    createPublicTokenRequired (ApiErrorResponse _ (StructuredResp errResp)) configs =
      flip any configs $ \CreatePublicTokenConfig {..} ->
        let respErrorCode = T.toLower errResp.error_code.unErrorCode
            matchedErrorCode = T.toLower _configMatchedErrorCode.unMatchedErrorCode
            respErrorMsg = T.toLower errResp.error_message.unErrorMessage
            matchedErrorWords = map (T.toLower . (.unMatchedErrorWord)) _configMatchedErrorWords
        in  respErrorCode == matchedErrorCode &&
            all (`T.isInfixOf` respErrorMsg) matchedErrorWords
    createPublicTokenRequired _ _ = False

    addNameSpace = katipAddNamespace "token-service"

newtype TokenServiceError = 
  TokenServiceError PlaidApiError
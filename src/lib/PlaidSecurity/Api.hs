{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}
module PlaidSecurity.Api 
  ( PlaidSecurityApi
  , apiServer 
  )
where

import Control.Monad.Error.Class
import qualified Data.Text as T
import Servant

import Domain.Types
import PlaidSecurity.Types
import PlaidSecurity.TokenService

type PlaidSecurityApi = "v1" :> 
  (   "token" :> "exchange" :> Capture "user_id" UserId :> Capture "public_token" PublicToken :> Get '[JSON] TokenExchangeResponse
  )

apiServer ::
  MonadError ServerError m =>
  TokenService m -> ServerT PlaidSecurityApi m
apiServer tokenService = exchangeToken
  where
    exchangeToken userId publicToken = tokenService.exchangeToken userId publicToken >>= \case
      Right resp -> pure resp
      Left (TokenServiceError apiError) -> handlePlaidApiError apiError

handlePlaidApiError :: 
  MonadError ServerError m =>
  PlaidApiError -> m a
handlePlaidApiError (PlaidApiError msg) = 
  throwError $ err500 { errReasonPhrase = T.unpack msg }
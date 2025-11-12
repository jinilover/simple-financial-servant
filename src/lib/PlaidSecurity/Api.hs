{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}
module PlaidSecurity.Api 
  ( PlaidSecurityApi
  , apiServer 
  )
where

import Control.Monad.Error.Class
import qualified Data.Text as T
import Network.HTTP.Types
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
handlePlaidApiError (DecodeFailure errorMsg jsonString) = 
  throwError err500 { errReasonPhrase = T.unpack errorMsg, errBody = jsonString }
handlePlaidApiError (CommsError errorMsg) = 
  throwError err500 { errReasonPhrase = T.unpack errorMsg }
handlePlaidApiError (PlaidErrorResponse status errorResponse) = 
  throwError err422 
    { errReasonPhrase = "Plaid returns status code: " <> show status.statusCode
    , errBody = errorResponse 
    }
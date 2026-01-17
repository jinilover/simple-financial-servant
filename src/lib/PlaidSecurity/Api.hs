{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}
module PlaidSecurity.Api 
  ( PlaidSecurityApi
  , apiServer 
  )
where

import Control.Monad.Error.Class
import Data.String.Conv
import Katip
import Network.HTTP.Types
import Servant

import Domain.Types
import PlaidSecurity.Types
import PlaidSecurity.TokenService

type PlaidSecurityApi = "v1" :> 
  (   "token" :> "exchange" :> Capture "user_id" UserId :> Capture "public_token" PublicToken :> Get '[JSON] TokenExchangeResponse
  )

apiServer ::
  (MonadError ServerError m, KatipContext m) =>
  TokenService m -> ServerT PlaidSecurityApi m
apiServer tokenService = exchangeToken
  where
    exchangeToken userId publicToken = addNameSpace . addUserIdToContext userId $ 
        logFM InfoS ("Exchanging token for userId: " <> logStr (show userId)) *>
          tokenService.exchangeToken userId publicToken >>= \case
            Right resp -> pure resp
            Left (TokenServiceError apiError) -> 
              let errMsg = "Fail to exhange token for userId: " <> logStr (show userId) <> ", cause: " <> logStr (show apiError)
              in  logFM ErrorS errMsg *> handlePlaidApiError apiError

    addNameSpace = katipAddNamespace "rest-api"

    addUserIdToContext userId = katipAddContext (sl "user_id" userId)

handlePlaidApiError :: 
  MonadError ServerError m =>
  PlaidApiError -> m a
handlePlaidApiError (DecodeFailure errorMsg jsonString) = 
  throwError err500 { errReasonPhrase = toS errorMsg, errBody = jsonString }
handlePlaidApiError (CommsError errorMsg) = 
  throwError err500 { errReasonPhrase = toS errorMsg }
handlePlaidApiError (PlaidErrorResponse status errorResponse) = 
  throwError err422 
    { errReasonPhrase = "Plaid returns status code: " <> show status.statusCode
    , errBody = errorResponse 
    }
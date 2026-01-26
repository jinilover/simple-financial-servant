{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}
module PlaidLinking.Api where

import Control.Monad.Except
import Katip
import Servant

import Common.Katip
import Common.Types
import PlaidLinking.Types.PublicToken ( PublicToken )
import PlaidLinking.Types.TokenExchangeResponse
    ( TokenExchangeResponse )
import PlaidLinking.TokenService

type PlaidLinkingApi = 
  (   "token" :> "exchange" :> Capture "user_id" UserId :> Capture "public_token" PublicToken :> Get '[JSON] TokenExchangeResponse
  )

exchangeToken :: 
  (MonadError ServerError m, KatipContext m) =>
  TokenService m -> UserId -> PublicToken -> m TokenExchangeResponse
exchangeToken tokenService userId publicToken = addNameSpace . addUserIdToContext userId $
  logFM InfoS ("Exchanging access token for userId: " <> logStr (show userId)) *>
  tokenService.exchangeToken userId publicToken >>= \case
    Right resp -> pure resp
    Left apiError -> 
      let errMsg = "Fail to exhange access token for userId: " <> logStr (show userId) <> ", cause: " <> logStr (show apiError)
      in  logFM ErrorS errMsg *> throwError (toServerError apiError)

addNameSpace :: KatipContext m => m a -> m a
addNameSpace = katipAddNamespace "plaid-linking-api"
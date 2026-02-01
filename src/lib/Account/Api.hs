{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}
module Account.Api where

import Control.Monad.Error.Class
import Data.String.Conv
import Katip
import Servant

import Account.AccountService
import Account.Types
import Common.Katip
import Common.Types

type AccountApi = 
  ( "accounts" :> "summary" :> Capture "user_id" UserId :> Get '[JSON] AccountSummaryResponse
  )

accountSummary :: 
  (MonadError ServerError m, KatipContext m) =>
  AccountService m -> UserId -> m AccountSummaryResponse
accountSummary accountService userId = addNameSpace . addUserIdToContext userId $ 
  logFM InfoS ("Requesting account summary for " <> logStr (show userId)) *>
  accountService.accountSummary userId >>= 
    either (\case 
      PlaidClientError apiError -> 
        throwError $ toServerError apiError
      PlaidLinkingError accessTokenNotFound -> 
        throwError $ err400 { errReasonPhrase = show accessTokenNotFound }
      InvalidAccountData errMsg ->
        throwError $ err422 { errReasonPhrase = toS errMsg }
    )
    pure

addNameSpace :: KatipContext m => m a -> m a
addNameSpace = katipAddNamespace "account-api"
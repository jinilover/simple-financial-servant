{-# LANGUAGE LambdaCase #-}
module Account.AccountService where

import Data.Functor
import Katip

import Account.Types.AccountSummaryError
import Common.Types
import Common.Utils
import qualified Plaid.Types as PL
import Plaid.Client
import PlaidLinking.Types 
import PlaidLinking.TokenService

data AccountService m = AccountService
  { accountSummary :: UserId -> m (Either AccountSummaryError PL.AccountResponse)
  }

mkAccountService :: 
  KatipContext m =>
  PlaidClient m ->
  TokenService m ->
  AccountService m
mkAccountService plaidClient tokenService = AccountService
  { accountSummary = \userId -> 
      addNameSpace $
      logFM InfoS ("Requesting account summary for " <> logStr (show userId)) *> 
      tokenService.fetchAccessTokenData userId >>= \case
        Left tokenNotFound -> 
          logFM ErrorS (logStr $ show tokenNotFound) $> Left (PlaidLinkingError tokenNotFound)
        Right accessToken -> 
          (plaidClient.accountSummary . PL.AccessToken . (.unAccessToken) $ accessToken) >>= \case 
            Left plaidError -> logFM ErrorS (logStr $ show plaidError) $> Left (PlaidClientError . fromPlaidError $ plaidError)
            Right resp -> pureRight resp
  }
  where
    addNameSpace = katipAddNamespace "account-service"

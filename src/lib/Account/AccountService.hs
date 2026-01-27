module Account.AccountService where

import Control.Monad.Except
import Data.Bifunctor
import Katip

import Account.Types.AccountSummaryError
import Common.Types
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
      logFM InfoS "Accessing account summary" *> 
      runExceptT
        (do
          accessToken <- ExceptT . fmap (first PlaidLinkingError) $ tokenService.fetchAccessTokenData userId
          ExceptT . 
            fmap (first (PlaidClientError . fromPlaidError)) . 
            plaidClient.accountSummary . 
            PL.AccessToken . (.unAccessToken) 
            $ accessToken
        )
  }
  where
    addNameSpace = katipAddNamespace "account-service"

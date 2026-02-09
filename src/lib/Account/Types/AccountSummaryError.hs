module Account.Types.AccountSummaryError where

import Account.Types.Account
import Common.Types
import PlaidLinking.Types

data AccountSummaryError = 
    PlaidClientError PlaidApiError
  | PlaidLinkingError AccessTokenNotFound
  | InvalidAccountData { accountErrors :: [AccountValidationError] }
  deriving (Eq, Show)
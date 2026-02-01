module Account.Types.AccountSummaryError where

import Data.Text

import Common.Types
import PlaidLinking.Types

data AccountSummaryError = 
    PlaidClientError PlaidApiError
  | PlaidLinkingError AccessTokenNotFound
  | InvalidAccountData Text
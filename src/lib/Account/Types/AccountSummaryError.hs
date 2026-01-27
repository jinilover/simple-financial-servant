module Account.Types.AccountSummaryError where

import Common.Types
import PlaidLinking.Types

data AccountSummaryError = 
    PlaidClientError PlaidApiError
  | PlaidLinkingError AccessTokenNotFound
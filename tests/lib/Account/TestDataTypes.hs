module Account.TestDataTypes where

import Account.Types
import Plaid.Types.PlaidError ( PlaidError )

data TestAccountSummaryPlaidError = TestAccountSummaryPlaidError
  { mockPlaidError :: PlaidError
  , expectedServiceError :: AccountSummaryError
  }
  deriving Show
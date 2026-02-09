module Account.TestDataTypes where

import Data.Text

import Account.Types
import Plaid.Types

data TestAccountSummaryPlaidError = TestAccountSummaryPlaidError
  { mockPlaidError :: PlaidError
  , expectedOutput :: AccountSummaryError
  }
  deriving Show

data TestAccountSummary = TestAccountSummary
  { purpose :: Text
  , mockPlaidData :: AccountListResponse
  , expectedOutput :: Either AccountSummaryError AccountSummaryResponse
  }
  deriving Show
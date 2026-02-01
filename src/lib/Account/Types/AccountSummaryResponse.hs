{-# LANGUAGE DeriveAnyClass #-}
module Account.Types.AccountSummaryResponse where

import Data.Aeson
import Data.List.NonEmpty
import Data.Text
import Data.Validation
import GHC.Generics

import Account.Types.Account
import qualified Plaid.Types as PL

data AccountSummaryResponse = AccountSummaryResponse
  { accounts :: [Account]
  }
  deriving (Generic, ToJSON)

validatePLAccountResponse :: PL.AccountResponse -> Validation (NonEmpty Text) AccountSummaryResponse
validatePLAccountResponse = fmap AccountSummaryResponse . traverse validatePLAccount . (.accounts)
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingStrategies #-}
module Account.Types.AccountSummaryResponse where

import Data.Aeson
import GHC.Generics

import Account.Types.Account

type TotalAmount = AvailableBalance

data AccountSummaryResponse = AccountSummaryResponse
  { summaryByCurrencies :: [SummaryByCurrency]
  , accounts :: [Account]
  }
  deriving (Generic, Show, ToJSON)

data SummaryByCurrency = SummaryByCurrency
  { currency :: CurrencyCode
  , total :: TotalAmount
  , summaryByAccountTypes :: [SummaryByAccountType]
  }
  deriving (Generic, Show, ToJSON)

data SummaryByAccountType = SummaryByAccountType
  { accountType :: AccountType
  , total :: TotalAmount
  , summaryBySubtypes :: [SummaryBySubtype]
  }
  deriving (Generic, Show, ToJSON)

data SummaryBySubtype = SummaryBySubtype
  { subtype :: Subtype
  , total :: TotalAmount
  }
  deriving (Generic, Show, ToJSON)

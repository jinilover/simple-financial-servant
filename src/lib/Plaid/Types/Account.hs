{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE LambdaCase #-}
module Plaid.Types.Account where

import Data.Aeson
import Data.Text
import GHC.Generics

data Account = Account 
  { account_id :: AccountId
  , balances :: Balances
  , mask :: Maybe Mask
  , name :: AccountName
  , official_name :: Maybe OfficialName
  , subtype :: Maybe AccountSubtype
  , account_type :: AccountType
  }
  deriving (Generic, Show)

instance FromJSON Account where
  parseJSON = genericParseJSON defaultOptions
    { fieldLabelModifier = \case "account_type" -> "type"; s -> s }

newtype AccountId = AccountId
  { unAccountId :: Text }
  deriving Show
  deriving newtype FromJSON

newtype Mask = Mask
  { unMask :: Text }
  deriving Show
  deriving newtype FromJSON

newtype AccountName = AccountName
  { unAccountName :: Text }
  deriving Show
  deriving newtype FromJSON

newtype OfficialName = OfficialName
  { unOfficialName :: Text }
  deriving Show
  deriving newtype FromJSON

newtype AccountSubtype = AccountSubtype
  { unAccountSubtype :: Text }
  deriving Show
  deriving newtype FromJSON

newtype AccountType = AccountType
  { unAccountType :: Text }
  deriving Show
  deriving newtype FromJSON

data Balances = Balances 
  { available :: Maybe AvailableBalance
  , current :: Maybe CurrentBalance
  , iso_currency_code :: Maybe IsoCurrencyCode
  , limit :: Maybe Limit
  , unofficial_currency_code :: Maybe UnofficialCurrencyCode
  }
  deriving (Generic, Show, FromJSON)

newtype AvailableBalance = AvailableBalance
  { unAvailableBalance :: Double }
  deriving Show
  deriving newtype FromJSON

newtype CurrentBalance = CurrentBalance
  { unCurrentBalance :: Double }
  deriving Show
  deriving newtype FromJSON

newtype Limit = Limit
  { unLimit :: Double }
  deriving Show
  deriving newtype FromJSON

newtype IsoCurrencyCode = IsoCurrencyCode
  { unIsoCurrencyCode :: Text }
  deriving Show
  deriving newtype FromJSON

newtype UnofficialCurrencyCode = UnofficialCurrencyCode
  { unUnofficialCurrencyCode :: Text }
  deriving Show
  deriving newtype FromJSON
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE LambdaCase #-}
module Plaid.Types.AccountResponse where

import Data.Aeson
import Data.Text
import GHC.Generics

-- TODO remove ToJSON
data AccountResponse = AccountResponse
  { accounts :: [Account] }
  deriving (Generic, FromJSON, ToJSON)

data Account = Account 
  { account_id :: AccountId
  , balances :: Balances
  , mask :: Mask
  , name :: AccountName
  , official_name :: Maybe OfficialName
  , subtype :: AccountSubtype
  , account_type :: AccountType
  }
  deriving Generic

instance FromJSON Account where
  parseJSON = genericParseJSON defaultOptions
    { fieldLabelModifier = \case "account_type" -> "type"; s -> s }

instance ToJSON Account where
  toJSON = genericToJSON defaultOptions
    { fieldLabelModifier = \case "account_type" -> "type"; s -> s }
newtype AccountId = AccountId
  { unAccountId :: Text }
  deriving newtype (ToJSON, FromJSON)

newtype Mask = Mask
  { unMask :: Text }
  deriving newtype (ToJSON, FromJSON)

newtype AccountName = AccountName
  { unAccountName :: Text }
  deriving newtype (ToJSON, FromJSON)

newtype OfficialName = OfficialName
  { unOfficialName :: Text }
  deriving newtype (ToJSON, FromJSON)

newtype AccountSubtype = AccountSubtype
  { unAccountSubtype :: Text }
  deriving newtype (ToJSON, FromJSON)

newtype AccountType = AccountType
  { unAccountType :: Text }
  deriving newtype (ToJSON, FromJSON)

data Balances = Balances 
  { available :: Maybe AvailableBalance
  , current :: Maybe CurrentBalance
  , iso_currency_code :: IsoCurrencyCode
  , limit :: Maybe Limit
  , unofficial_currency_code :: Maybe UnofficialCurrencyCode
  }
  deriving (Generic, ToJSON, FromJSON)

newtype AvailableBalance = AvailableBalance
  { unAvailableBalance :: Double }
  deriving newtype (ToJSON, FromJSON)

newtype CurrentBalance = CurrentBalance
  { unCurrentBalance :: Double }
  deriving newtype (ToJSON, FromJSON)

newtype Limit = Limit
  { unLimit :: Double }
  deriving newtype (ToJSON, FromJSON)

newtype IsoCurrencyCode = IsoCurrencyCode
  { unIsoCurrencyCode :: Text }
  deriving newtype (ToJSON, FromJSON)

newtype UnofficialCurrencyCode = UnofficialCurrencyCode
  { unUnofficialCurrencyCode :: Text }
  deriving newtype (ToJSON, FromJSON)
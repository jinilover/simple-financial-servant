module Plaid.Types.Product where

import Data.Aeson

import Common.Utils (stringToJson)

data Product = Auth | Transactions

instance ToJSON Product where
  toJSON Auth = stringToJson "auth"
  toJSON Transactions = stringToJson "transactions"

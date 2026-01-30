module Plaid.Types.Product where

import Data.Aeson

import Aeson.Utils

data Product = Auth | Transactions

instance ToJSON Product where
  toJSON Auth = textToJSON "auth"
  toJSON Transactions = textToJSON "transactions"

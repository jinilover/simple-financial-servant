module Plaid.Types.Product where

import Data.Aeson


data Product = Auth | Transactions

instance ToJSON Product where
  toJSON Auth = toJSON ("auth" :: String)
  toJSON Transactions = toJSON ("transactions" :: String)

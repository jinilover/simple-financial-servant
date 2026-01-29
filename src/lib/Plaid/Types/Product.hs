module Plaid.Types.Product where

import Data.Aeson
import Data.Text

data Product = Auth | Transactions

instance ToJSON Product where
  toJSON Auth = toJSON ("auth" :: Text)
  toJSON Transactions = toJSON ("transactions" :: Text)

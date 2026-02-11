module Plaid.Types.ItemId where

import Data.Aeson
import Data.Text

newtype ItemId = ItemId
  { unItemId :: Text }
  deriving (Show, FromJSON)
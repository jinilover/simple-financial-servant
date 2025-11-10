{-# LANGUAGE DerivingVia #-}
module Item.Types.ItemId where

import Data.Aeson
import Data.Text

import qualified Plaid.Types.ItemId as PL

newtype ItemId = ItemId
  { unItemId :: Text }
  deriving ToJSON via Text

fromPLItemId :: PL.ItemId -> ItemId
fromPLItemId = ItemId . (.unItemId)  
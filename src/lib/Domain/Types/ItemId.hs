module Domain.Types.ItemId where

import Data.Aeson
import Database.Persist.Sql
import Data.Text

import qualified Plaid.Types.ItemId as PL

newtype ItemId = ItemId
  { unItemId :: Text }
  deriving (Eq, FromJSON, Ord, PersistField, PersistFieldSql, Read, Show, ToJSON)

fromPLItemId :: PL.ItemId -> ItemId
fromPLItemId = ItemId . (.unItemId)  
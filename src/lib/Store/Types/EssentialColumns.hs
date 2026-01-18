module Store.Types.EssentialColumns where

import Data.Time.Clock
import Database.Persist
import Database.Persist.Postgresql

newtype CreatedAt = CreatedAt 
  { unCreatedAt :: UTCTime }
  deriving (Show, PersistField, PersistFieldSql)

newtype UpdatedAt = UpdatedAt 
  { unUpdatedAt :: UTCTime }
  deriving (Show, PersistField, PersistFieldSql)
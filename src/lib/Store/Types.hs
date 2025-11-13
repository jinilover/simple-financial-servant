module Store.Types 
  ( CreatedAt(..)
  , UpdatedAt(..)
  , module Store.Types.DbConfig
  , module Store.Types.StoreEnv
  )
where

import Data.Time.Clock
import Database.Persist
import Database.Persist.Postgresql

import Store.Types.DbConfig
import Store.Types.StoreEnv

newtype CreatedAt = CreatedAt 
  { unCreatedAt :: UTCTime }
  deriving (Show, PersistField, PersistFieldSql)

newtype UpdatedAt = UpdatedAt 
  { unUpdatedAt :: UTCTime }
  deriving (Show, PersistField, PersistFieldSql)
{-# OPTIONS_GHC -Wno-orphans #-}

module Database.Persist.Instances.UUID where

import Database.Persist
import Database.Persist.Sql
import Data.UUID

instance PersistField UUID where
  toPersistValue = toPersistValue . toText
  fromPersistValue (PersistText t) = maybe (Left "Invalid UUID format") Right $ fromText t
  fromPersistValue _ = Left "Expected PersistText for UUID"

instance PersistFieldSql UUID where
  sqlType _ = SqlString
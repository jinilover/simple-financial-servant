{-# LANGUAGE DerivingVia #-}
module Common.Types.UserId where

import Data.Aeson
import Data.UUID
import Database.Persist.Sql
import Servant

import Database.Persist.Instances.UUID ()

newtype UserId = UserId
  { unUserId :: UUID }
  deriving (Eq, Ord, Read, Show) via UUID
  deriving (FromHttpApiData, FromJSON, ToJSON, PersistField, PersistFieldSql)
{-# LANGUAGE DerivingVia #-}
module Domain.Types.UserId where

import Data.Aeson
import Data.UUID
import Database.Persist.Sql
import Servant

import Database.Persist.Instances.UUID ()

newtype UserId = UserId
  { unUserId :: UUID }
  deriving (Eq, FromHttpApiData, FromJSON, ToJSON, Ord, PersistField, PersistFieldSql, Read, Show) via UUID
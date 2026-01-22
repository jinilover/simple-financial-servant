{-# LANGUAGE DerivingVia #-}
module Common.Types.UserId where

-- NOTE: Persistent Quirk - Web Framework Instances Required for Persistence
--
-- When a type is used as a single-column primary key in Persistent, the Key type
-- becomes that type directly (e.g., Key AccessTokenData = UserId). Persistent
-- then requires ToHttpApiData and PathPiece instances for the key type, even
-- though these are web framework concerns (from servant and path-pieces packages).
--
-- This is a design trade-off in Persistent: it assumes you're building a web app
-- and wants keys to be usable directly in routes. However, this creates a
-- coupling between the persistence layer and web framework concerns.
--
-- Composite keys don't have this requirement because they use tuple types which
-- are handled differently. Only single-column primary keys trigger this.
--
-- See: https://hackage.haskell.org/package/persistent

import Data.Aeson
import Data.UUID
import Database.Persist.Sql
import Servant
import Web.PathPieces

import Database.Persist.Instances.UUID ()
import PathPiece.Instances.UUID ()

newtype UserId = UserId
  { unUserId :: UUID }
  deriving (Eq, Ord, Read, Show) via UUID
  deriving (FromHttpApiData, ToHttpApiData, FromJSON, ToJSON, PathPiece, PersistField, PersistFieldSql)
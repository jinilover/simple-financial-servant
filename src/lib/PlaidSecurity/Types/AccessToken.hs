{-# LANGUAGE DerivingVia #-}
module PlaidSecurity.Types.AccessToken where

import Data.Text
import Database.Persist.Sql

import qualified Plaid.Types.AccessToken as PL

newtype AccessToken = AccessToken
  { unAccessToken :: Text }
  deriving (PersistField, PersistFieldSql, Show) via Text

fromPLAccessToken :: PL.AccessToken -> AccessToken
fromPLAccessToken = AccessToken . (.unAccessToken)

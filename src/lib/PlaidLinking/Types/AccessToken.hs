module PlaidLinking.Types.AccessToken where

import Data.Text
import Database.Persist.Sql

import qualified Plaid.Types.AccessToken as PL

newtype AccessToken = AccessToken
  { unAccessToken :: Text }
  deriving (PersistField, PersistFieldSql, Show)

fromPLAccessToken :: PL.AccessToken -> AccessToken
fromPLAccessToken = AccessToken . (.unAccessToken)

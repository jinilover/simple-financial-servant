module PlaidLinking.Types.AccessToken where

import Data.Text
import Database.Persist.Sql

import qualified Plaid.Types.AccessToken as PL

newtype AccessToken = AccessToken
  { unAccessToken :: Text }
  deriving (Eq, PersistField, PersistFieldSql, Show)

fromPLAccessToken :: PL.AccessToken -> AccessToken
fromPLAccessToken = AccessToken . (.unAccessToken)

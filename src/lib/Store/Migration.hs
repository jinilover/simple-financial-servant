module Store.Migration where

import Control.Monad.IO.Class
import Data.Foldable
import Data.Pool
import qualified Data.Text as T
import Database.Persist.Postgresql

import PlaidSecurity.AccessTokenStore
import Store.Types

migrateDb :: 
  MonadIO m =>
  DbSchema -> Pool SqlBackend -> m ()
migrateDb DbSchema {..} pool = 
  let createSchema = rawExecute (T.append "CREATE SCHEMA IF NOT EXISTS " unDbSchema) []
  in 
    liftIO $ traverse_ (`runSqlPool` pool) 
      [ createSchema
      , runMigration migrateAccessToken
      ]
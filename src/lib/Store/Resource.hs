module Store.Resource where

import Control.Monad.IO.Class
import Control.Monad.Logger
import Data.Pool
import Database.Persist.Postgresql
import Refined

import Common.Types
import Store.Migration
import Store.Types

mkStoreBackendPoolEnv :: 
  MonadIO m =>
  DbConfig -> m StoreBackendPoolEnv
mkStoreBackendPoolEnv DbConfig {..} =
  do
    let poolSize = unrefine _configDbConnPoolSize.unDbConnPoolSize.unPosInt
    pool <- liftIO . runNoLoggingT $ createPostgresqlPool _configDbConnString.unDbConnString poolSize
    migrateDb _configDbSchema pool
    pure $ StoreBackendPoolEnv pool

closeStoreBackendPoolEnv :: StoreBackendPoolEnv -> IO ()
closeStoreBackendPoolEnv StoreBackendPoolEnv {..} = 
  destroyAllResources unStoreBackendPoolEnv
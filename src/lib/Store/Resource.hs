module Store.Resource where

import Control.Monad.IO.Class
import Control.Monad.Logger
import qualified Data.ByteString.Char8 as BS
import Data.Pool
import Data.String.Conv
import Database.Persist.Postgresql
import Refined

import Common.Types
import Store.Migration
import Store.Types

mkStoreDbPoolEnv :: 
  MonadIO m =>
  StoreConfig -> m StoreDbPoolEnv
mkStoreDbPoolEnv StoreConfig {..} =
  do
    let poolSize = unrefine _configDbConnPoolSize.unDbConnPoolSize.unPosInt
        -- Append search_path to connection string so all connections use the correct schema
        -- Format: options='-csearch_path=schema_name' (no space between -c and search_path, and quoted)
        searchPathOption = " options='-csearch_path=" <> _configDbSchema.unDbSchema <> "'"
        connStringWithSchema = BS.append _configDbConnString.unDbConnString $ toS searchPathOption
    pool <- liftIO . runNoLoggingT $ createPostgresqlPool connStringWithSchema poolSize
    migrateDb _configDbSchema pool
    pure $ StoreDbPoolEnv pool

closeStoreDbPoolEnv :: StoreDbPoolEnv -> IO ()
closeStoreDbPoolEnv StoreDbPoolEnv {..} = 
  destroyAllResources unStoreDbPoolEnv
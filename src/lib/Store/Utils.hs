module Store.Utils where

import Control.Lens
import Control.Monad.IO.Class
import Control.Monad.Reader
import Database.Persist.Sql

import Store.Types

runQueryWithPool :: 
  (MonadIO m, MonadReader r m, HasStoreBackendPoolEnv r) =>
  ReaderT SqlBackend IO a -> m a
runQueryWithPool query =
  view storeBackendPoolEnv <&> (.unStoreBackendPoolEnv) >>=
    liftIO . runSqlPool query

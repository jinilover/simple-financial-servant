{-# LANGUAGE TemplateHaskell #-}
module Store.Types.StoreEnv where

import Control.Lens
import Data.Pool
import Database.Persist.Postgresql

newtype StoreBackendPoolEnv = StoreBackendPoolEnv
  { unStoreBackendPoolEnv :: Pool SqlBackend }
makeClassy ''StoreBackendPoolEnv
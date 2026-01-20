{-# LANGUAGE TemplateHaskell #-}
module Store.Types.StoreEnv where

import Control.Lens
import Data.Pool
import Database.Persist.Postgresql

newtype StoreDbPoolEnv = StoreDbPoolEnv
  { unStoreDbPoolEnv :: Pool SqlBackend }
makeClassy ''StoreDbPoolEnv
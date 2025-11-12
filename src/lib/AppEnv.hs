{-# LANGUAGE TemplateHaskell #-}
module AppEnv where

import Control.Lens

import AppConfig
import Plaid.Types
import Store.Types

data AppEnv = AppEnv
  { _configApp :: AppConfig
  , _envPlaid :: PlaidClientEnv
  , _envStoreBackendPool :: StoreBackendPoolEnv
  }
makeClassy ''AppEnv

instance HasPlaidConfig AppEnv where
  plaidConfig = configApp . configPlaid

instance HasPlaidClientEnv AppEnv where
  plaidClientEnv = envPlaid

instance HasStoreBackendPoolEnv AppEnv where
  storeBackendPoolEnv = envStoreBackendPool

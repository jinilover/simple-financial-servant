{-# LANGUAGE TemplateHaskell #-}
module AppEnv where

import Control.Lens
import Katip

import AppConfig
import Plaid.Types
import PlaidLinking.Types
import Store.Types

data AppEnv = AppEnv
  { _configApp :: AppConfig
  , _envPlaid :: PlaidClientEnv
  , _envStoreDbPool :: StoreDbPoolEnv
  , _logEnv :: LogEnv
  }
makeClassy ''AppEnv

instance HasPlaidConfig AppEnv where
  plaidConfig = configApp . configPlaid

instance HasPlaidLinkingConfig AppEnv where
  plaidLinkingConfig = configApp . configPlaidLinking

instance HasPlaidClientEnv AppEnv where
  plaidClientEnv = envPlaid

instance HasStoreDbPoolEnv AppEnv where
  storeDbPoolEnv = envStoreDbPool
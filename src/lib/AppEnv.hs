{-# LANGUAGE TemplateHaskell #-}
module AppEnv where

import Control.Lens

import AppConfig
import Plaid.Types

data AppEnv = AppEnv
  { _configApp :: AppConfig
  , _envPlaid :: PlaidClientEnv
  }
makeClassy ''AppEnv

instance HasPlaidConfig AppEnv where
  plaidConfig = configApp . configPlaid

instance HasPlaidClientEnv AppEnv where
  plaidClientEnv = envPlaid
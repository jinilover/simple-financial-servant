{-# LANGUAGE TemplateHaskell #-}
module Plaid.PlaidEnv where

import Control.Lens
import Servant.Client

newtype PlaidClientEnv = PlaidClientEnv 
  { unPlaidClientEnv :: ClientEnv }
makeClassy ''PlaidClientEnv

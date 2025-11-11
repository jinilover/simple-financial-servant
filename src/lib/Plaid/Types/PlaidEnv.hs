{-# LANGUAGE TemplateHaskell #-}
module Plaid.Types.PlaidEnv where

import Control.Lens
import Servant.Client

newtype PlaidClientEnv = PlaidClientEnv 
  { unPlaidClientEnv :: ClientEnv }
makeClassy ''PlaidClientEnv

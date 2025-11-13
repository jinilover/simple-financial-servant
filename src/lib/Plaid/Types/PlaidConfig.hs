{-# LANGUAGE TemplateHaskell #-}
module Plaid.Types.PlaidConfig where

import Control.Lens
import Servant.Client

import PlaidSecurity.Types.ClientId
import PlaidSecurity.Types.SecretKey

newtype Endpoint = Endpoint
  { unEndpoint :: BaseUrl }

data PlaidConfig = PlaidConfig 
  { _configEndpoint :: Endpoint
  , _configClientId :: ClientId
  , _configSecretKey :: SecretKey
  }
makeClassy ''PlaidConfig

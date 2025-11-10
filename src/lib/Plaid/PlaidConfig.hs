{-# LANGUAGE DerivingVia #-}
{-# LANGUAGE TemplateHaskell #-}
module Plaid.PlaidConfig where

import Control.Lens
import Servant.Client

import PlaidSecurity.Types.ClientId ( ClientId )
import PlaidSecurity.Types.SecretKey ( SecretKey )

newtype Endpoint = Endpoint
  { unEndpoint :: BaseUrl }

data PlaidConfig = PlaidConfig 
  { _configEndpoint :: Endpoint
  , _configClientId :: ClientId
  , _configSecretKey :: SecretKey
  }
makeClassy ''PlaidConfig

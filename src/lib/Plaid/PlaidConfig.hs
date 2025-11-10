{-# LANGUAGE DerivingVia #-}
{-# LANGUAGE TemplateHaskell #-}
module Plaid.PlaidConfig where

import Control.Lens
import Servant.Client

import PlaidGateway.Types.ClientId ( ClientId )
import PlaidGateway.Types.SecretKey ( SecretKey )

newtype Endpoint = Endpoint
  { unEndpoint :: BaseUrl }
makeClassy ''Endpoint
data PlaidConfig = PlaidConfig 
  { _configEndpoint :: Endpoint
  , _configClientId :: ClientId
  , _configSecretKey :: SecretKey
  }
makeClassy ''PlaidConfig

{-# LANGUAGE DerivingVia #-}
{-# LANGUAGE TemplateHaskell #-}
module Plaid.Types.PlaidConfig where

import Control.Lens
import Servant.Client

import PlaidLinking.Types.ClientId
import PlaidLinking.Types.SecretKey

newtype Endpoint = Endpoint
  { unEndpoint :: BaseUrl }
  deriving Show via BaseUrl

data PlaidConfig = PlaidConfig 
  { _configEndpoint :: Endpoint
  , _configClientId :: ClientId
  , _configSecretKey :: SecretKey
  }
  deriving Show
makeClassy ''PlaidConfig

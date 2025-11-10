{-# LANGUAGE TemplateHaskell #-}
module AppConfig where

import Control.Lens
import Refined
import Servant.Client

import Common.Types
import Plaid.PlaidConfig
import PlaidGateway.Types

newtype ServerPort = ServerPort
  { unServerPort :: PosInt }
makeClassy ''ServerPort

data AppConfig = AppConfig 
  { _configServerPort :: ServerPort
  , _configPlaid :: PlaidConfig
  }
makeClassy ''AppConfig

loadConfig :: IO AppConfig
loadConfig = parseBaseUrl "https://sandbox.plaid.com" <&> \baseUrl ->
  let
    _configServerPort = ServerPort $$(refineTH 8001)
    _configEndpoint = Endpoint baseUrl
    _configClientId = ClientId "CHANGEME"
    _configSecretKey = SecretKey "CHANGEME"
    _configPlaid = PlaidConfig {..}
  in
    AppConfig {..}
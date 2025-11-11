{-# LANGUAGE TemplateHaskell #-}
module AppConfig where

import Control.Lens
import Refined
import Servant.Client

import Common.Types
import qualified Plaid.Types as PL
import PlaidSecurity.Types

newtype ServerPort = ServerPort
  { unServerPort :: PosInt }
makeClassy ''ServerPort

data AppConfig = AppConfig 
  { _configServerPort :: ServerPort
  , _configPlaid :: PL.PlaidConfig
  }
makeClassy ''AppConfig

loadConfig :: IO AppConfig
loadConfig = parseBaseUrl "https://sandbox.plaid.com" <&> \baseUrl ->
  let
    _configServerPort = ServerPort $$(refineTH 8001)
    _configEndpoint = PL.Endpoint baseUrl
    _configClientId = ClientId "CHANGEME"
    _configSecretKey = SecretKey "CHANGEME"
    _configPlaid = PL.PlaidConfig {..}
  in
    AppConfig {..}
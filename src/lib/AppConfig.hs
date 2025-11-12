{-# LANGUAGE TemplateHaskell #-}
module AppConfig where

import Control.Lens
import Refined
import Servant.Client

import Common.Types
import qualified Plaid.Types as PL
import PlaidSecurity.Types
import Store.Types

newtype ServerPort = ServerPort
  { unServerPort :: PosInt }
makeClassy ''ServerPort

data AppConfig = AppConfig 
  { _configServerPort :: ServerPort
  , _configDb :: DbConfig
  , _configPlaid :: PL.PlaidConfig
  }
makeClassy ''AppConfig

loadConfig :: IO AppConfig
loadConfig = parseBaseUrl "https://sandbox.plaid.com" <&> \baseUrl ->
  let
    _configServerPort = ServerPort $$(refineTH 8001)
    _configDbConnString = DbConnString "host=localhost port=5432 user=haskell dbname=plaid_application_server_db password=haskell"
    _configDbConnPoolSize = DbConnPoolSize $$(refineTH 10)
    _configDbSchema = DbSchema "plaid_application_server"
    _configDb = DbConfig {..}
    _configEndpoint = PL.Endpoint baseUrl
    _configClientId = ClientId "CHANGEME"
    _configSecretKey = SecretKey "CHANGEME"
    _configPlaid = PL.PlaidConfig {..}
  in
    AppConfig {..}
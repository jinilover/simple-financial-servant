{-# LANGUAGE TemplateHaskell #-}
module AppConfig where

import Control.Lens
import Refined
import Servant.Client

import Common.Types
import Plaid.Types ( PlaidConfig(..), Endpoint(..) )
import PlaidSecurity.Types
import Store.Types

newtype ServerPort = ServerPort
  { unServerPort :: PosInt }
makeClassy ''ServerPort

data AppConfig = AppConfig 
  { _configServerPort :: ServerPort
  , _configDb :: DbConfig
  , _configPlaid :: PlaidConfig
  }
makeClassy ''AppConfig

loadConfig :: IO AppConfig
loadConfig = parseBaseUrl "https://sandbox.plaid.com" <&> \baseUrl ->
  let
    _configServerPort = ServerPort $ PosInt $$(refineTH 8001)
    _configDbConnString = DbConnString "host=localhost port=5432 user=haskell dbname=plaid_application_server_db password=haskell"
    _configDbConnPoolSize = DbConnPoolSize $ PosInt $$(refineTH 10)
    _configDbSchema = DbSchema "plaid_application_server"
    _configDb = DbConfig {..}
    _configEndpoint = Endpoint baseUrl
    _configClientId = ClientId "CHANGEME"
    _configSecretKey = SecretKey "CHANGEME"
    _configPlaid = PlaidConfig {..}
  in
    AppConfig {..}
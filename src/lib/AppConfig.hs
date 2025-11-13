{-# LANGUAGE TemplateHaskell #-}
module AppConfig where

import Control.Lens
import Control.Monad.IO.Class
import qualified Data.Text as T
import Dhall 
import Refined
import Servant.Client

import Common.Types
import Paths_plaid_application_server ( getDataFileName )
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

loadAppConfig :: MonadIO m => m AppConfig
loadAppConfig = 
  do 
    baseUrl <- liftIO $ parseBaseUrl "https://sandbox.plaid.com"
    filePath <- liftIO $ getDataFileName "config.dhall"
    _configDb <- loadDbConfig filePath
    let
      _configServerPort = ServerPort $ PosInt $$(refineTH 8001)
      _configEndpoint = Endpoint baseUrl
      _configClientId = ClientId "CHANGEME"
      _configSecretKey = SecretKey "CHANGEME"
      _configPlaid = PlaidConfig {..}
    pure AppConfig {..}
  where
    loadDbConfig = liftIO . input auto . T.pack
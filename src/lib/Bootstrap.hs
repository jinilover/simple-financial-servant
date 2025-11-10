module Bootstrap where

import Control.Exception

import AppConfig
import AppEnv
import Plaid.PlaidConfig
import Plaid.Resource
import Server

bootstrap :: IO ()
bootstrap = bracket mkAppEnv closeAppEnv startServer

mkAppEnv :: IO AppEnv
mkAppEnv =
  do
    _configApp <- loadConfig
    _envPlaid <- mkPlaidEnv _configApp._configPlaid._configEndpoint
    pure AppEnv {..}

closeAppEnv :: AppEnv -> IO ()
closeAppEnv = const . pure $ ()
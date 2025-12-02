module Bootstrap where

import Control.Exception
import Katip
import System.IO (stdout)

import AppConfig
import AppEnv
import Plaid.Resource
import Plaid.Types
import Server
import Store.Resource

bootstrap :: IO ()
bootstrap = bracket mkAppEnv closeAppEnv startServer

mkAppEnv :: IO AppEnv
mkAppEnv =
  do
    _configApp <- loadAppConfig
    _envPlaid <- mkPlaidEnv _configApp._configPlaid._configEndpoint
    _envStoreBackendPool <- mkStoreBackendPoolEnv _configApp._configDb
    pure AppEnv {..}

mkLogEnv :: IO LogEnv
mkLogEnv = 
  do
    le <- initLogEnv "plaid-application-serve" "sandbox"
    handleScribe <- mkHandleScribe ColorIfTerminal stdout (permitItem DebugS) V2
    registerScribe "stdout" handleScribe defaultScribeSettings le

closeAppEnv :: AppEnv -> IO ()
closeAppEnv AppEnv {..} =
  closeStoreBackendPoolEnv _envStoreBackendPool
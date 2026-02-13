module Bootstrap 
  ( bootstrap
  )
where

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
    _logEnv <- mkLogEnv
    runKatipContextT _logEnv () "main" . flip logExceptionM ErrorS $ 
      do
        _configApp <- loadAppConfig
        _envPlaid <- mkPlaidEnv _configApp._configPlaid._configEndpoint
        _envStoreDbPool <- mkStoreDbPoolEnv _configApp._configStore
        pure AppEnv {..}

mkLogEnv :: IO LogEnv
mkLogEnv = 
  do
    le <- initLogEnv "simple-financial-servant" "sandbox"
    handleScribe <- mkHandleScribe ColorIfTerminal stdout (permitItem DebugS) V2
    registerScribe "stdout" handleScribe defaultScribeSettings le

closeAppEnv :: AppEnv -> IO ()
closeAppEnv AppEnv {..} =
  closeScribes _logEnv *>
  closeStoreDbPoolEnv _envStoreDbPool
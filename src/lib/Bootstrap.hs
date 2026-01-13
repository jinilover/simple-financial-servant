{-# LANGUAGE TemplateHaskell #-}
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
    _logEnv <- mkLogEnv
    runKatipContextT _logEnv () "main" mkKatipContext
    _configApp <- loadAppConfig
    _envPlaid <- mkPlaidEnv _configApp._configPlaid._configEndpoint
    _envStoreBackendPool <- mkStoreBackendPoolEnv _configApp._configDb
    pure AppEnv {..}
  where
    mkKatipContext = 
      do
        $(logTM) InfoS "Hello Katip"
        katipAddNamespace "additional_namespace" . katipAddContext (sl "some_context" True) $ 
          $(logTM) WarningS "Now we're getting fancy"

mkLogEnv :: IO LogEnv
mkLogEnv = 
  do
    le <- initLogEnv "plaid-application-server" "sandbox"
    handleScribe <- mkHandleScribe ColorIfTerminal stdout (permitItem DebugS) V2
    registerScribe "stdout" handleScribe defaultScribeSettings le

closeAppEnv :: AppEnv -> IO ()
closeAppEnv AppEnv {..} =
  closeScribes _logEnv *>
  closeStoreBackendPoolEnv _envStoreBackendPool
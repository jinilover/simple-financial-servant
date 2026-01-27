{-# LANGUAGE DataKinds #-}
module Server 
  ( startServer
  )
where

import Control.Monad.Except
import Control.Monad.Reader
import Data.Proxy
import Data.UUID.V4
import Katip
import Refined
import Servant
import Network.Wai.Handler.Warp

import Account.AccountService
import Account.Api
import AppEnv
import AppConfig
import Common.Types
import PlaidLinking.AccessTokenStore
import PlaidLinking.Api
import PlaidLinking.TokenService
import Plaid.Client

type FullApi = "v1" :> (PlaidLinkingApi :<|> AccountApi)

type AppServerM = ReaderT AppEnv (KatipContextT (ExceptT ServerError IO))

startServer :: AppEnv -> IO ()
startServer appEnv' =
  let app = serve (Proxy @FullApi) (server appEnv')
      port = unrefine appEnv'._configApp._configServerPort.unServerPort.unPosInt
  in  run port app

server :: AppEnv -> Server FullApi
server appEnv' = hoistServer (Proxy @FullApi) toHandler fullApiServer
  where
    toHandler :: AppServerM a -> Handler a
    toHandler appServerM = Handler . runKatipContextT appEnv'._logEnv () "rest-server" $ 
      do
        reqId <- liftIO generateReqId
        katipAddContext (sl "req_id" reqId) (runReaderT appServerM appEnv')

    fullApiServer :: ServerT FullApi AppServerM
    fullApiServer = 
      let plaidClient = mkPlaidClient
          tokenService = mkTokenService plaidClient mkAccessTokenStore
          accountService = mkAccountService plaidClient tokenService
      in    
            exchangeToken tokenService
      :<|>  accountSummary accountService

    generateReqId = nextRandom
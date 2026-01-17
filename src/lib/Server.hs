module Server 
  ( startServer
  )
where

import Control.Monad.Except
import Control.Monad.Reader
import Data.Proxy
import Data.UUID.V4
import Refined
import Servant
import Network.Wai.Handler.Warp

import AppEnv
import AppConfig
import Common.Types
import PlaidSecurity.AccessTokenStore
import PlaidSecurity.Api
import PlaidSecurity.TokenService
import Plaid.Client
import Katip

type AppServerM = ReaderT AppEnv (KatipContextT (ExceptT ServerError IO))

startServer :: AppEnv -> IO ()
startServer appEnv' =
  let app = serve (Proxy @PlaidSecurityApi) (server appEnv')
      port = unrefine appEnv'._configApp._configServerPort.unServerPort.unPosInt
  in  run port app

server :: AppEnv -> Server PlaidSecurityApi
server appEnv' = hoistServer (Proxy @PlaidSecurityApi) toHandler serverTApiM
  where
    toHandler :: AppServerM a -> Handler a
    toHandler appServerM = Handler . runKatipContextT appEnv'._logEnv () "rest-server" $ 
      do
        reqId <- liftIO generateReqId
        katipAddContext (sl "req_id" reqId) (runReaderT appServerM appEnv')

    serverTApiM :: ServerT PlaidSecurityApi AppServerM
    serverTApiM = apiServer $ mkTokenService mkPlaidClient mkAccessTokenStore

    generateReqId = nextRandom
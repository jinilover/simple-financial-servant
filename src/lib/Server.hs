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
import PlaidLinking.AccessTokenStore
import PlaidLinking.Api
import PlaidLinking.TokenService
import Plaid.Client
import Katip

type AppServerM = ReaderT AppEnv (KatipContextT (ExceptT ServerError IO))

startServer :: AppEnv -> IO ()
startServer appEnv' =
  let app = serve (Proxy @PlaidLinkingApi) (server appEnv')
      port = unrefine appEnv'._configApp._configServerPort.unServerPort.unPosInt
  in  run port app

server :: AppEnv -> Server PlaidLinkingApi
server appEnv' = hoistServer (Proxy @PlaidLinkingApi) toHandler serverTApiM
  where
    toHandler :: AppServerM a -> Handler a
    toHandler appServerM = Handler . runKatipContextT appEnv'._logEnv () "rest-server" $ 
      do
        reqId <- liftIO generateReqId
        katipAddContext (sl "req_id" reqId) (runReaderT appServerM appEnv')

    serverTApiM :: ServerT PlaidLinkingApi AppServerM
    serverTApiM = apiServer $ mkTokenService mkPlaidClient mkAccessTokenStore

    generateReqId = nextRandom
module Server 
  ( startServer
  )
where

import Control.Lens
import Control.Monad.Except
import Control.Monad.Reader
import Data.Proxy
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

type AppServerM = ReaderT AppEnv (ExceptT ServerError IO)

startServer :: AppEnv -> IO ()
startServer appEnv' =
  let app = serve (Proxy @PlaidSecurityApi) (server appEnv')
      port = unrefine (appEnv' ^. configApp . configServerPort).unServerPort.unPosInt
  in  run port app

server :: AppEnv -> Server PlaidSecurityApi
server appEnv' = hoistServer (Proxy @PlaidSecurityApi) toHandler serverTApiM
  where
    toHandler :: AppServerM a -> Handler a
    toHandler = Handler . flip runReaderT appEnv'

    serverTApiM :: ServerT PlaidSecurityApi AppServerM
    serverTApiM = apiServer $ mkTokenService mkPlaidClient mkAccessTokenStore
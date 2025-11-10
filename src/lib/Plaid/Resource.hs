module Plaid.Resource where

import Control.Monad.IO.Class
import Data.Functor
import Network.HTTP.Client.TLS
import Servant.Client

import Plaid.PlaidEnv
import Plaid.PlaidConfig

mkPlaidEnv :: 
  MonadIO m =>
  Endpoint -> m PlaidClientEnv
mkPlaidEnv Endpoint {..} =
  newTlsManager <&> \mgr ->
    PlaidClientEnv { unPlaidClientEnv = mkClientEnv mgr unEndpoint }
{-# LANGUAGE DataKinds #-}
module Account.Api where

import Data.Functor
import Katip
import Servant

import Common.Katip
import Common.Types

type AccountApi = 
  ( "accounts" :> "summary" :> Capture "user_id" UserId :> Get '[JSON] UserId
  )

accountSummary :: 
  KatipContext m =>
  UserId -> m UserId
accountSummary userId = addNameSpace . addUserIdToContext userId $ 
  logFM InfoS ("Getting accounts summary for userId: " <> logStr (show userId)) $>
  userId

addNameSpace :: KatipContext m => m a -> m a
addNameSpace = katipAddNamespace "account-api"
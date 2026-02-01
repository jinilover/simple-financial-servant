{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingStrategies #-}
module Plaid.Types.AccountResponse where

import Data.Aeson
import GHC.Generics

import Plaid.Types.Account

-- TODO remove ToJSON
data AccountResponse = AccountResponse
  { accounts :: [Account] }
  deriving (Generic, FromJSON, ToJSON)
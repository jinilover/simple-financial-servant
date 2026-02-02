{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingStrategies #-}
module Plaid.Types.AccountResponse where

import Data.Aeson
import GHC.Generics

import Plaid.Types.Account

data AccountResponse = AccountResponse
  { accounts :: [Account] }
  deriving (Show, Generic, FromJSON)
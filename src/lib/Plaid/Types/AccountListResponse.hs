{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingStrategies #-}
module Plaid.Types.AccountListResponse where

import Data.Aeson
import GHC.Generics

import Plaid.Types.Account

data AccountListResponse = AccountListResponse
  { accounts :: [Account] }
  deriving (Show, Generic, FromJSON)
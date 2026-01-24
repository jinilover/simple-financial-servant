{-# LANGUAGE DeriveAnyClass #-}
module Plaid.Types.AccountRequest where

import Data.Aeson
import GHC.Generics

import Plaid.Types.ClientId
import Plaid.Types.SecretKey
import Plaid.Types.AccessToken

data AccountRequest = AccountRequest
  { client_id :: ClientId
  , secret :: SecretKey
  , access_token :: AccessToken
  } 
  deriving (Generic, ToJSON)
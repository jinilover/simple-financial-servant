{-# LANGUAGE DeriveAnyClass #-}
module Plaid.Types.ExchangeAccessTokenRequest where

import Data.Aeson
import GHC.Generics

import Plaid.Types.ClientId
import Plaid.Types.PublicToken
import Plaid.Types.SecretKey

data ExchangeAccessTokenRequest = ExchangeAccessTokenRequest
  { client_id :: ClientId
  , secret :: SecretKey
  , public_token :: PublicToken
  }
  deriving ( Generic, ToJSON )
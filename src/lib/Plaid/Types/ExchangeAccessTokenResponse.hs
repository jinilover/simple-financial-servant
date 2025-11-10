{-# LANGUAGE DeriveAnyClass #-}
module Plaid.Types.ExchangeAccessTokenResponse where

import Data.Aeson
import GHC.Generics

import Plaid.Types.AccessToken
import Plaid.Types.ItemId

data ExchangeAccessTokenResponse = ExchangeAccessTokenResponse
  { access_token :: AccessToken
  , item_id :: ItemId
  }
  deriving ( Generic, FromJSON )
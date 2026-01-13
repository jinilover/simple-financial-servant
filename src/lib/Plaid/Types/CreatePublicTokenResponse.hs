{-# LANGUAGE DeriveAnyClass #-}
module Plaid.Types.CreatePublicTokenResponse where

import Data.Aeson
import GHC.Generics

import Plaid.Types.ItemId
import Plaid.Types.PublicToken

data CreatePublicTokenResponse = CreatePublicTokenResponse
  { public_token :: PublicToken
  , item_id :: ItemId
  }
  deriving ( Generic, FromJSON )
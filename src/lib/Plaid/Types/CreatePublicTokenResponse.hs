{-# LANGUAGE DeriveAnyClass #-}
module Plaid.Types.CreatePublicTokenResponse where

import Data.Aeson
import GHC.Generics

import Plaid.Types.RequestId
import Plaid.Types.PublicToken

data CreatePublicTokenResponse = CreatePublicTokenResponse
  { public_token :: PublicToken
  , request_id :: RequestId
  }
  deriving ( Show, Generic, FromJSON )
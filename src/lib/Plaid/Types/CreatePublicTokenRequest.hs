{-# LANGUAGE DeriveAnyClass #-}
module Plaid.Types.CreatePublicTokenRequest where

import Data.Aeson
import GHC.Generics

import Plaid.Types.ClientId
import Plaid.Types.InstitutionId
import Plaid.Types.Product
import Plaid.Types.SecretKey

data CreatePublicTokenRequest = CreatePublicTokenRequest 
  { client_id :: ClientId
  , secret :: SecretKey
  , institution_id :: InstitutionId
  , initial_products :: [Product]
  }
  deriving ( Generic, ToJSON )

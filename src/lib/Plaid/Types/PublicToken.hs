{-# LANGUAGE DerivingVia #-}
module Plaid.Types.PublicToken where

import Data.Aeson
import Data.Text

import qualified PlaidSecurity.Types.PublicToken as PS

newtype PublicToken = PublicToken
  { unPublicToken :: Text }
  deriving ToJSON via Text

fromPSPublicToken :: PS.PublicToken -> PublicToken
fromPSPublicToken = PublicToken . (.unPublicToken)
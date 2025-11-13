module Plaid.Types.SecretKey where

import Data.Aeson
import Data.Text

import qualified PlaidSecurity.Types.SecretKey as PS

newtype SecretKey = SecretKey
  { unSecretKey :: Text }
  deriving ToJSON

fromPSSecretKey :: PS.SecretKey -> SecretKey
fromPSSecretKey = SecretKey . (.unSecretKey)
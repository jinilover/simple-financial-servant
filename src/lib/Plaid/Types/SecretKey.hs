module Plaid.Types.SecretKey where

import Data.Aeson
import Data.Text

import qualified PlaidLinking.Types.SecretKey as PLK

newtype SecretKey = SecretKey
  { unSecretKey :: Text }
  deriving ToJSON

fromPSSecretKey :: PLK.SecretKey -> SecretKey
fromPSSecretKey = SecretKey . (.unSecretKey)
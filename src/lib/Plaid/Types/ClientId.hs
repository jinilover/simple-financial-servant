module Plaid.Types.ClientId where

import Data.Aeson
import Data.Text

import qualified PlaidSecurity.Types.ClientId as PS

newtype ClientId = ClientId
  { unClientId :: Text }
  deriving ToJSON

fromPSClientId :: PS.ClientId -> ClientId
fromPSClientId = ClientId . (.unClientId)
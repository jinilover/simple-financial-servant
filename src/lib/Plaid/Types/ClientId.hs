module Plaid.Types.ClientId where

import Data.Aeson
import Data.Text

import qualified PlaidLinking.Types.ClientId as PLK

newtype ClientId = ClientId
  { unClientId :: Text }
  deriving ToJSON

fromPSClientId :: PLK.ClientId -> ClientId
fromPSClientId = ClientId . (.unClientId)
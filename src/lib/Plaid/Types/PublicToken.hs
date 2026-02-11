module Plaid.Types.PublicToken where

import Data.Aeson
import Data.Text

import qualified PlaidLinking.Types.PublicToken as PLK

newtype PublicToken = PublicToken
  { unPublicToken :: Text }
  deriving (Eq, Show, ToJSON, FromJSON)

fromPSPublicToken :: PLK.PublicToken -> PublicToken
fromPSPublicToken = PublicToken . (.unPublicToken)
module Plaid.Types.AccessToken where

import Data.Aeson
import Data.Text

newtype AccessToken = AccessToken
  { unAccessToken :: Text }
  deriving (FromJSON, ToJSON)
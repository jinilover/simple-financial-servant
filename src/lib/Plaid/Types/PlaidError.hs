module Plaid.Types.PlaidError where

import Data.ByteString.Lazy
import Data.Text
import Network.HTTP.Types

data PlaidError = 
    DeserializationError { when_ :: Text, errorMsg :: Text, jsonString :: ByteString }
  | HttpError { when_ :: Text, errorMsg :: Text, status :: Status } 
  | NetworkError { when_ :: Text, errorMsg :: Text}
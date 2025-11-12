module Plaid.Types.PlaidError where

import Data.ByteString.Lazy
import Data.Text
import Network.HTTP.Types

data PlaidError = 
    DeserializationError { errorMsg :: Text, jsonString :: ByteString }
  | HttpError { errorMsg :: Text, status :: Status } 
  | NetworkError { errorMsg :: Text}
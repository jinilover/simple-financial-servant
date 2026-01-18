module Plaid.Types.PlaidError where

import Data.ByteString.Lazy
import Data.Text
import Network.HTTP.Types

import Plaid.Types.ErrorResponseBody

data PlaidError = 
    DeserializationError { errorMsg :: Text, jsonString :: ByteString }
  | HttpError { errorMsg :: Text } 
  | NetworkError { errorMsg :: Text}
  | ApiErrorResponse { status :: Status, errorBody :: ErrorResponseBody }
module Common.Types.PlaidApiError where

import Data.ByteString.Lazy
import Data.Text
import Network.HTTP.Types

import Common.Types.ErrorResponseBody
import Plaid.Types hiding (ErrorResponseBody)

data PlaidApiError = 
    DecodeFailure Text ByteString
  | CommsError Text
  | PlaidErrorResponse Status ErrorResponseBody
  deriving Show

mapPlaidError :: PlaidError -> PlaidApiError
mapPlaidError DeserializationError {..} = DecodeFailure errorMsg jsonString
mapPlaidError HttpError {..} = CommsError errorMsg
mapPlaidError NetworkError {..} = CommsError errorMsg
mapPlaidError ApiErrorResponse {..} = 
  PlaidErrorResponse status $ fromPLErrorResponseBody errorBody


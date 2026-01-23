module Common.Types.PlaidApiError where

import Data.Aeson
import Data.ByteString.Lazy
import Data.String.Conv
import Data.Text
import Network.HTTP.Types
import Servant

import Common.Types.ErrorResponseBody
import Plaid.Types hiding (ErrorResponseBody(..))

data PlaidApiError = 
    DecodeFailure Text ByteString
  | CommsError Text
  | PlaidErrorResponse Status ErrorResponseBody
  deriving Show

fromPlaidError :: PlaidError -> PlaidApiError
fromPlaidError DeserializationError {..} = DecodeFailure errorMsg jsonString
fromPlaidError HttpError {..} = CommsError errorMsg
fromPlaidError NetworkError {..} = CommsError errorMsg
fromPlaidError ApiErrorResponse {..} = 
  PlaidErrorResponse status $ fromPLErrorResponseBody errorBody

toServerError :: PlaidApiError -> ServerError 
toServerError (DecodeFailure errorMsg jsonString) = 
  err500 { errReasonPhrase = toS errorMsg, errBody = jsonString }
toServerError (CommsError errorMsg) = 
  err500 { errReasonPhrase = toS errorMsg }
toServerError (PlaidErrorResponse status errorResponse) = 
  err422 
    { errReasonPhrase = "Plaid returns status code: " <> show status.statusCode
    , errBody = case errorResponse of 
        Payload bs -> bs
        StructuredResp errResp -> encode . toJSON $ errResp
    }
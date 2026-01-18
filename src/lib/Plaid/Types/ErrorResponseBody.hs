{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingVia #-}
module Plaid.Types.ErrorResponseBody where

import Control.Applicative
import Data.Aeson
import Data.ByteString.Lazy
import Data.Text
import GHC.Generics

data ErrorResponseBody = 
    Payload ByteString
  | StructuredResp ErrorResponse

data ErrorResponse = ErrorResponse {
      display_message :: Maybe DisplayMessage
    , error_code :: ErrorCode
    , error_message :: ErrorMessage
    , error_type :: ErrorType
    , request_id :: RequestId
    }
  deriving (Generic, FromJSON)

instance FromJSON ErrorResponseBody where
  parseJSON v = 
        (StructuredResp <$> parseJSON v)
    <|> (pure . Payload . encode $ v)  

newtype DisplayMessage = DisplayMessage
  { unDisplayMessage :: Text }
  deriving (FromJSON, Show) via Text

newtype ErrorCode = ErrorCode
  { unErrorCode :: Text }
  deriving (FromJSON, Show) via Text

newtype ErrorMessage = ErrorMessage
  { unErrorMessage :: Text }
  deriving (FromJSON, Show) via Text

newtype ErrorType = ErrorType
  { unErrorType :: Text }
  deriving (FromJSON, Show) via Text

newtype RequestId = RequestId
  { unRequestId :: Text }
  deriving (FromJSON, Show) via Text
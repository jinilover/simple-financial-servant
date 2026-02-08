{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingVia #-}
module Common.Types.ErrorResponseBody where

import Data.Aeson
import Data.ByteString.Lazy
import Data.Text
import GHC.Generics

import qualified Plaid.Types as PL
import Common.Types.RequestId

data ErrorResponseBody = 
    Payload ByteString
  | StructuredResp ErrorResponse
  deriving (Eq, Show)

fromPLErrorResponseBody :: PL.ErrorResponseBody -> ErrorResponseBody
fromPLErrorResponseBody (PL.Payload bs) = Payload bs
fromPLErrorResponseBody (PL.StructuredResp errResp) = StructuredResp $ fromPLErrorResponse errResp

data ErrorResponse = ErrorResponse {
      display_message :: Maybe DisplayMessage
    , error_code :: ErrorCode
    , error_message :: ErrorMessage
    , error_type :: ErrorType
    , request_id :: RequestId
    }
  deriving (Eq, Show, Generic, ToJSON)

fromPLErrorResponse :: PL.ErrorResponse -> ErrorResponse
fromPLErrorResponse PL.ErrorResponse {..} = 
  ErrorResponse 
    (fromPLDisplayMessage <$> display_message) 
    (fromPLErrorCode error_code)
    (fromPLErrorMessage error_message)
    (fromPLErrorType error_type)
    (fromPLRequestId request_id)

newtype DisplayMessage = DisplayMessage
  { unDisplayMessage :: Text }
  deriving (Eq, Show)
  deriving ToJSON via Text

fromPLDisplayMessage :: PL.DisplayMessage -> DisplayMessage
fromPLDisplayMessage = DisplayMessage . (.unDisplayMessage)  

newtype ErrorCode = ErrorCode
  { unErrorCode :: Text }
  deriving (Eq, Show)
  deriving ToJSON via Text

fromPLErrorCode :: PL.ErrorCode -> ErrorCode
fromPLErrorCode = ErrorCode . (.unErrorCode)  

newtype ErrorMessage = ErrorMessage
  { unErrorMessage :: Text }
  deriving (Eq, Show)
  deriving ToJSON via Text

fromPLErrorMessage :: PL.ErrorMessage -> ErrorMessage
fromPLErrorMessage = ErrorMessage . (.unErrorMessage)  

newtype ErrorType = ErrorType
  { unErrorType :: Text }
  deriving (Eq, Show)
  deriving ToJSON via Text

fromPLErrorType :: PL.ErrorType -> ErrorType
fromPLErrorType = ErrorType . (.unErrorType)  
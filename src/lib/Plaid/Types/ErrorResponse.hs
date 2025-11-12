{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingVia #-}
module Plaid.Types.ErrorResponse where

import Data.Aeson
import Data.Text
import GHC.Generics
import Network.URI

data ErrorResponse = ErrorResponse
  { display_message :: Maybe DisplayMessage
  , documentation_url :: DocumentationUrl
  , error_code :: ErrorCode
  , error_message :: ErrorMessage
  , error_type :: ErrorType
  , request_id :: RequestId
  , suggested_action :: Maybe SuggestAction
  }
  deriving (Generic, FromJSON)

newtype DisplayMessage = DisplayMessage
  { unDisplayMessage :: Text }
  deriving FromJSON via Text

newtype DocumentationUrl = DocumentationUrl
  { unDocumentationUrl :: URI }
  deriving FromJSON via URI

newtype ErrorCode = ErrorCode
  { unErrorCode :: Text }
  deriving FromJSON via Text

newtype ErrorMessage = ErrorMessage
  { unErrorMessage :: Text }
  deriving FromJSON via Text

newtype ErrorType = ErrorType
  { unErrorType :: Text }
  deriving FromJSON via Text

newtype RequestId = RequestId
  { unRequestId :: Text }
  deriving FromJSON via Text

newtype SuggestAction = SuggestAction
  { unSuggestAction :: Text }
  deriving FromJSON via Text

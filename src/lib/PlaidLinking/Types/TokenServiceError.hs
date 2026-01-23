module PlaidLinking.Types.TokenServiceError where

import Data.ByteString.Lazy
import Data.Text
import Network.HTTP.Types

import Common.Types

data PlaidApiError = 
    DecodeFailure Text ByteString
  | CommsError Text
  | PlaidErrorResponse Status ErrorResponseBody
  deriving Show

newtype TokenServiceError = 
  TokenServiceError PlaidApiError
module PlaidSecurity.Types.TokenServiceError where

import Data.ByteString.Lazy
import Data.Text
import Network.HTTP.Types

data PlaidApiError = 
    DecodeFailure Text ByteString
  | CommsError Text
  | PlaidErrorResponse Status ByteString

newtype TokenServiceError = 
  TokenServiceError PlaidApiError
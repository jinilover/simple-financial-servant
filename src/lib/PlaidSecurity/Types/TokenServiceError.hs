module PlaidSecurity.Types.TokenServiceError where

import Data.Text

newtype PlaidApiError = 
  PlaidApiError Text 

newtype TokenServiceError = 
  TokenServiceError PlaidApiError
module PlaidLinking.Types.AccessTokenNotFound where

import Common.Types.UserId

newtype AccessTokenNotFound = AccessTokenNotFound UserId
  deriving (Eq, Show)

{-# LANGUAGE DerivingVia #-}
module Domain.Types.UserId where

import Data.UUID
import Servant

newtype UserId = UserId
  { unUserId :: UUID }
  deriving FromHttpApiData via UUID
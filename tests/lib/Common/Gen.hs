module Common.Gen where

import Data.UUID
import Data.UUID.V4
import Control.Monad.IO.Class
import Hedgehog

import Common.Types

genUUID :: PropertyT IO UUID
genUUID = liftIO nextRandom

genUserId :: PropertyT IO UserId
genUserId = UserId <$> genUUID
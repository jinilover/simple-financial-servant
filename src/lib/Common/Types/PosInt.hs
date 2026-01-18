module Common.Types.PosInt where

import Refined

newtype PosInt = PosInt 
  { unPosInt :: Refined Positive Int }
  deriving Show

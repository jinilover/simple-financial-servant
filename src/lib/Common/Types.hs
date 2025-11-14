module Common.Types where

import Refined

newtype PosInt = PosInt 
  { unPosInt :: Refined Positive Int }
  deriving Show

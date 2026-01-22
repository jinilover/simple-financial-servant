{-# OPTIONS_GHC -Wno-orphans #-}

module PathPiece.Instances.UUID where

import Data.UUID
import Web.PathPieces

instance PathPiece UUID where
  toPathPiece = toText
  fromPathPiece = fromText
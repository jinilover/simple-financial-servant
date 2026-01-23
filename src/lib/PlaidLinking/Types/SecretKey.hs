{-# LANGUAGE DerivingVia #-}
module PlaidLinking.Types.SecretKey where

import Data.Text

newtype SecretKey = SecretKey
  { unSecretKey :: Text }
  deriving Show via Text

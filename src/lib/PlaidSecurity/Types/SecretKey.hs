{-# LANGUAGE DerivingVia #-}
module PlaidSecurity.Types.SecretKey where

import Data.Text

newtype SecretKey = SecretKey
  { unSecretKey :: Text }
  deriving Show via Text

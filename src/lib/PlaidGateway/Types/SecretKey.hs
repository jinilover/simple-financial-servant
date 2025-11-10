{-# LANGUAGE DerivingVia #-}
{-# LANGUAGE TemplateHaskell #-}
module PlaidGateway.Types.SecretKey where

import Control.Lens
import Data.Text

newtype SecretKey = SecretKey
  { unSecretKey :: Text }
makeClassy ''SecretKey

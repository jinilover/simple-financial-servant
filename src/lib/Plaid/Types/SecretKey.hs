{-# LANGUAGE DerivingVia #-}
{-# LANGUAGE TemplateHaskell #-}
module Plaid.Types.SecretKey where

import Control.Lens
import Data.Aeson
import Data.Text

import qualified PlaidGateway.Types as PG

newtype SecretKey = SecretKey
  { unSecretKey :: Text }
  deriving ToJSON via Text
makeClassy ''SecretKey

fromPGSecretKey :: PG.SecretKey -> SecretKey
fromPGSecretKey pg = SecretKey pg.unSecretKey
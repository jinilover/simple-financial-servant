{-# LANGUAGE DerivingVia #-}
{-# LANGUAGE TemplateHaskell #-}
module Plaid.Types.ClientId where

import Control.Lens
import Data.Aeson
import Data.Text

import qualified PlaidGateway.Types as PG

newtype ClientId = ClientId
  { unClientId :: Text }
  deriving ToJSON via Text
makeClassy ''ClientId

fromPGClientId :: PG.ClientId -> ClientId
fromPGClientId pg = ClientId pg.unClientId
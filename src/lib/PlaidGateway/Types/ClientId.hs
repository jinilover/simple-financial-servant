{-# LANGUAGE DerivingVia #-}
{-# LANGUAGE TemplateHaskell #-}
module PlaidGateway.Types.ClientId where

import Control.Lens
import Data.Text

newtype ClientId = ClientId
  { unClientId :: Text }
makeClassy ''ClientId
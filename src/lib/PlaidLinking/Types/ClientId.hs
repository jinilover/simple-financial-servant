module PlaidLinking.Types.ClientId where

import Data.Text

newtype ClientId = ClientId
  { unClientId :: Text }
  deriving Show
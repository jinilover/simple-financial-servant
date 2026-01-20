module Plaid.Types.RequestId where

import Data.Aeson
import Data.Text

newtype RequestId = RequestId
  { unRequestId :: Text }
  deriving FromJSON

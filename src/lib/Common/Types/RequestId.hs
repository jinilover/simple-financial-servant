module Common.Types.RequestId where

import Data.Aeson
import Data.Text

import qualified Plaid.Types as PL

newtype RequestId = RequestId
  { unRequestId :: Text }
  deriving (ToJSON, Show)

fromPLRequestId :: PL.RequestId -> RequestId
fromPLRequestId = RequestId . (.unRequestId)  


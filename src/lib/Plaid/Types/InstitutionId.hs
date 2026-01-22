module Plaid.Types.InstitutionId where

import Data.Aeson

data InstitutionId = Institution3

instance ToJSON InstitutionId where
  toJSON Institution3 = toJSON ("ins_3" :: String)
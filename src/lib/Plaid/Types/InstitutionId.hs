module Plaid.Types.InstitutionId where

import Data.Aeson

import Common.Utils (stringToJson)

data InstitutionId = Institution3

instance ToJSON InstitutionId where
  toJSON Institution3 = stringToJson "ins_3"
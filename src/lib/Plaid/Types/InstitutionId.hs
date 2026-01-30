module Plaid.Types.InstitutionId where

import Data.Aeson

import Aeson.Utils

data InstitutionId = Institution3

instance ToJSON InstitutionId where
  toJSON Institution3 = textToJSON "ins_3"
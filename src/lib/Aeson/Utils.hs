module Aeson.Utils where

import Data.Aeson
import Data.Text

textToJSON :: Text -> Value
textToJSON = toJSON
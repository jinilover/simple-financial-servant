module PlaidSecurity.Types.PublicToken where

import Data.Text
import Servant

newtype PublicToken = PublicToken
  { unPublicToken :: Text }
  deriving FromHttpApiData

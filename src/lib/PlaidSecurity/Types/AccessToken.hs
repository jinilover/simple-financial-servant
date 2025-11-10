{-# LANGUAGE DerivingVia #-}
module PlaidSecurity.Types.AccessToken where

import Data.Text

import qualified Plaid.Types.AccessToken as PL

newtype AccessToken = AccessToken
  { unAccessToken :: Text }

fromPLAccessToken :: PL.AccessToken -> AccessToken
fromPLAccessToken = AccessToken . (.unAccessToken)

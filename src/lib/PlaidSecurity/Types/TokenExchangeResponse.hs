{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingStrategies #-}
module PlaidSecurity.Types.TokenExchangeResponse where

import Data.Aeson
import GHC.Generics

import Common.Types
import qualified Plaid.Types as PL

newtype TokenExchangeResponse = TokenExchangeResponse
  { itemId :: ItemId }
  deriving Generic 
  deriving anyclass ToJSON

fromExchangeAccessTokenResponse :: PL.ExchangeAccessTokenResponse -> TokenExchangeResponse
fromExchangeAccessTokenResponse = TokenExchangeResponse . fromPLItemId . (.item_id)
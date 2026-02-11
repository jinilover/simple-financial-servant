module PlaidLinking.TestDataTypes where

import Data.Text

import Common.Types as COMMON
import Plaid.Types as PL
import PlaidLinking.Types as PLK

data TestExchangeToken = TestExchangeToken
  { purpose :: Text
  , firstPublicTokenToPlaid :: PLK.PublicToken
  , mockAccessTokenResps :: [Either PlaidError ExchangeAccessTokenResponse]
  , mockCreatePublicTokenConfigs :: [CreatePublicTokenConfig]
  , mockPublicTokenResp :: Either PlaidError CreatePublicTokenResponse
  , expectedReceivedPublicTokens :: [PL.PublicToken]
  , expectedCreatePublicTokenCount :: CreatePublicTokenCount
  , expectedStoredTokens :: [(PLK.AccessToken, COMMON.ItemId)]
  , expectedOutput :: Either PlaidApiError TokenExchangeResponse
  }
  deriving Show

newtype CreatePublicTokenCount = CreatePublicTokenCount
  { unCreatePublicTokenCount :: Int }
  deriving (Eq, Enum, Show)

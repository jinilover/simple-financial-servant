module Common.Stubs where

import Common.TestUtils
import Plaid.Client
import PlaidLinking.TokenService

plaidClientNoop :: PlaidClient m
plaidClientNoop = PlaidClient 
  { exchangeAccessToken = shouldNotBeCalled
  , createPublicToken = shouldNotBeCalled
  , getAccounts = shouldNotBeCalled
  }

tokenServiceNoop :: TokenService m
tokenServiceNoop = TokenService
  { exchangeToken = shouldNotBeCalled
  , fetchAccessTokenData = shouldNotBeCalled
  }  
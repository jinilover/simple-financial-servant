{-# LANGUAGE BlockArguments #-}
module Account.AccountServiceTest 
  ( tests
  )
where


import Hedgehog
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Range as Range
import Test.Tasty
import Test.Tasty.Hedgehog

import Common.Utils
import Common.Types
import Account.AccountService
import Account.Types
import PlaidLinking.TokenService 
import PlaidLinking.Types
import Plaid.Client

import Common.Gen
import Common.TestUtils

test_accountSummary :: Property
test_accountSummary = property 
  do
    n <- forAll $ Gen.int (Range.linear 0 100)
    n === n

test_accountSummary_accessNotFound :: Property
test_accountSummary_accessNotFound = property 
  do
    userId <- UserId <$> genUUID
    actual <- withKatipContext $ 
                let accountService = mkAccountService plaidClientNoop tokenServiceStub
                in accountService.accountSummary userId
    let expected = Left . PlaidLinkingError . AccessTokenNotFound $ userId
    actual === expected
    -- case actual of
    --   Left (PlaidLinkingError (AccessTokenNotFound userUuid)) -> userUuid === userId
    --   _ -> failure
  where
    tokenServiceStub = TokenService
      { exchangeToken = shouldNotBeCalled
      , fetchAccessTokenData = pureLeft . AccessTokenNotFound
      }

    plaidClientNoop = PlaidClient 
      { exchangeAccessToken = shouldNotBeCalled
      , createPublicToken = shouldNotBeCalled
      , getAccounts = shouldNotBeCalled
      }

-- test_accountSummary_plaidError :: Property
-- test_accountSummary_plaidError = undefined

tests :: [TestTree]
tests = 
  [ testProperty "accountSummary" test_accountSummary
  , testProperty "accountSummary_accessNotFound" test_accountSummary_accessNotFound
  -- , testProperty "accountSummary_plaidError" test_accountSummary_plaidError
  ]
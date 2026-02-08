{-# LANGUAGE BlockArguments #-}
module Account.AccountServiceTest 
  ( tests
  )
where

import Network.HTTP.Types

import Hedgehog
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Range as Range
import Test.Tasty
import Test.Tasty.Hedgehog

import Account.AccountService
import Account.Types
import Common.Utils
import Common.Types as COMMON
import PlaidLinking.TokenService 
import PlaidLinking.Types as PLK
import Plaid.Client
import Plaid.Types as PL

import Account.TestDataTypes
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
    userId <- genUserId
    actual <- withKatipContext $ 
                let accountService = mkAccountService plaidClientNoop tokenServiceStub
                in accountService.accountSummary userId
    let expected = Left . PlaidLinkingError . AccessTokenNotFound $ userId
    actual === expected
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

test_accountSummary_plaidError :: Property
test_accountSummary_plaidError = property
  do
    userId <- genUserId
    TestAccountSummaryPlaidError {..} <- forAll $ Gen.element testData
    actual <- withKatipContext $
                let accountService = mkAccountService (plaidClientStub mockPlaidError) tokenServiceStub
                in  accountService.accountSummary userId
    actual === Left expectedServiceError
  where
    testData = 
      let plStructuredErrorResp = PL.StructuredResp PL.ErrorResponse 
            { display_message = Nothing
            , error_code = PL.ErrorCode "INVALID_ACCESS_TOKEN"
            , error_message = PL.ErrorMessage "provided access token is invalid"
            , error_type = PL.ErrorType "INVALID INPUT"
            , request_id = PL.RequestId "DaxZjzBIzhYfO8H"
            }
          structuredErrorResp = COMMON.StructuredResp COMMON.ErrorResponse 
            { display_message = Nothing
            , error_code = COMMON.ErrorCode "INVALID_ACCESS_TOKEN"
            , error_message = COMMON.ErrorMessage "provided access token is invalid"
            , error_type = COMMON.ErrorType "INVALID INPUT"
            , request_id = COMMON.RequestId "DaxZjzBIzhYfO8H"
            }
          dataPairs = 
            [ (DeserializationError "decode-failure" "{}", DecodeFailure "decode-failure" "{}")
            , (HttpError "http-error", CommsError "http-error")
            , (NetworkError "network-error", CommsError "network-error")
            , (ApiErrorResponse status400 plStructuredErrorResp, PlaidErrorResponse status400 structuredErrorResp)
            ]
      in  [ uncurry TestAccountSummaryPlaidError . fmap PlaidClientError $ pair | pair <- dataPairs]

    tokenServiceStub = TokenService
      { exchangeToken = shouldNotBeCalled
      , fetchAccessTokenData = const . pureRight . PLK.AccessToken $ "value-doesnt-matter"
      }

    plaidClientStub plaidError = PlaidClient 
      { exchangeAccessToken = shouldNotBeCalled
      , createPublicToken = shouldNotBeCalled
      , getAccounts = const $ pureLeft plaidError
      }

tests :: [TestTree]
tests = 
  [ testProperty "accountSummary" test_accountSummary
  , testProperty "accountSummary_accessNotFound" test_accountSummary_accessNotFound
  , testProperty "accountSummary_plaidError" test_accountSummary_plaidError
  ]
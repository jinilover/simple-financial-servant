{-# LANGUAGE BlockArguments #-}
module Account.AccountServiceTest 
  ( tests
  )
where

import Network.HTTP.Types

import Hedgehog
import qualified Hedgehog.Gen as Gen
import Test.Tasty
import Test.Tasty.Hedgehog

import Account.AccountService
import Account.Types as ACC
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
    userId <- genUserId
    TestAccountSummary {..} <- forAll $ Gen.element testData
    actual <- withKatipContext $
                let accountService = mkAccountService (plaidClientStub $ Right mockPlaidData) tokenServiceForDummyToken
                in  accountService.accountSummary userId
    actual === expectedOutput
  where
    testData :: [TestAccountSummary]
    testData = 
      [ TestAccountSummary 
          { purpose = "invalid account - available balance and current balance are empty"
          , mockPlaidData = AccountListResponse 
              { accounts = 
                  [ PL.Account
                      { account_id = PL.AccountId "001"
                      , balances = PL.Balances 
                          { available = Nothing
                          , current = Nothing
                          , iso_currency_code = Just $ IsoCurrencyCode "USD"
                          , limit = Nothing
                          , unofficial_currency_code = Nothing
                          }
                      , mask = Nothing
                      , name = PL.AccountName "001 Account"
                      , official_name = Nothing
                      , subtype = Nothing
                      , account_type = AccountType "other"
                      }
                  , PL.Account
                      { account_id = PL.AccountId "002"
                      , balances = PL.Balances 
                          { available = Nothing
                          , current = Nothing
                          , iso_currency_code = Just $ IsoCurrencyCode "USD"
                          , limit = Nothing
                          , unofficial_currency_code = Nothing
                          }
                      , mask = Nothing
                      , name = PL.AccountName "002 Account"
                      , official_name = Nothing
                      , subtype = Nothing
                      , account_type = AccountType "otherXX"
                      }
                  ]
              }
          , expectedOutput = Left $ InvalidAccountData 
              { accountErrors = 
                  [ AccountValidationError 
                      { accountId = ACC.AccountId "001"
                      , errorMsg = "Both available and current are empty" 
                      }
                  , AccountValidationError 
                      { accountId = ACC.AccountId "002"
                      , errorMsg = "Both available and current are empty, Unknown account type: otherXX" 
                      }
                  ]

              }
          }

      ]

test_accountSummary_accessNotFound :: Property
test_accountSummary_accessNotFound = property 
  do
    userId <- genUserId
    actual <- withKatipContext $ 
                let accountService = mkAccountService plaidClientNoop tokenServiceForTokenNotFound
                in accountService.accountSummary userId
    let expected = Left . PlaidLinkingError . AccessTokenNotFound $ userId
    actual === expected

test_accountSummary_plaidError :: Property
test_accountSummary_plaidError = property
  do
    userId <- genUserId
    TestAccountSummaryPlaidError {..} <- forAll $ Gen.element testData
    actual <- withKatipContext $
                let accountService = mkAccountService (plaidClientStub $ Left mockPlaidError) tokenServiceForDummyToken
                in  accountService.accountSummary userId
    actual === Left expectedOutput
  where
    testData :: [TestAccountSummaryPlaidError]
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
      in  [ TestAccountSummaryPlaidError plaidError (PlaidClientError expectedOutput) | (plaidError, expectedOutput) <- dataPairs]

plaidClientNoop :: PlaidClient m
plaidClientNoop = PlaidClient 
  { exchangeAccessToken = shouldNotBeCalled
  , createPublicToken = shouldNotBeCalled
  , getAccounts = shouldNotBeCalled
  }

plaidClientStub :: Applicative m =>
  Either PlaidError AccountListResponse ->
  PlaidClient m
plaidClientStub mockData = plaidClientNoop 
  { getAccounts = const . pure $ mockData
  }

tokenServiceNoop :: TokenService m
tokenServiceNoop = TokenService
  { exchangeToken = shouldNotBeCalled
  , fetchAccessTokenData = shouldNotBeCalled
  }

tokenServiceForTokenNotFound :: Applicative m => 
  TokenService m
tokenServiceForTokenNotFound = tokenServiceNoop
  { fetchAccessTokenData = pureLeft . AccessTokenNotFound
  }

tokenServiceForDummyToken :: Applicative m => 
  TokenService m
tokenServiceForDummyToken = tokenServiceNoop
  { fetchAccessTokenData = const . pureRight . PLK.AccessToken $ "dummy-value"
  }

tests :: [TestTree]
tests = 
  [ testProperty "accountSummary" test_accountSummary
  , testProperty "accountSummary_accessNotFound" test_accountSummary_accessNotFound
  , testProperty "accountSummary_plaidError" test_accountSummary_plaidError
  ]
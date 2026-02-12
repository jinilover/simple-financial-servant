module PlaidLinking.TestData where

import Network.HTTP.Types

import Common.Types as COMMON
import Plaid.Types as PL
import PlaidLinking.Types as PLK

import PlaidLinking.TestDataTypes


testExchangeTokenData :: [TestExchangeToken]
testExchangeTokenData = 
  [ TestExchangeToken
      { purpose = 
          "happy day scenario, plaid receives public token once and returns access token, " <>
          "token store should be called once to store the token, " <>
          "service shouldn't use createPublicTokenConfigs/call for public token, " <>
          "service should return a success response"
      , firstPublicTokenToPlaid = PLK.PublicToken "valid-public-token"
      , mockAccessTokenResps = 
          [ Right $ ExchangeAccessTokenResponse (PL.AccessToken "success-access-token") (PL.ItemId "success-item-id")
          ]
      , mockCreatePublicTokenConfigs = []
      , mockPublicTokenResp = Right $ CreatePublicTokenResponse (PL.PublicToken "wont-be-called-for-public-token") (PL.RequestId "wont-be-called-for-public-token")
      , expectedReceivedPublicTokens = 
          [ PL.PublicToken "valid-public-token"
          ]
      , expectedCreatePublicTokenCount = CreatePublicTokenCount 0
      , expectedStoredTokens = 
          [ (PLK.AccessToken "success-access-token", COMMON.ItemId "success-item-id")
          ]
      , expectedOutput = Right . TokenExchangeResponse . COMMON.ItemId $ "success-item-id"
      }
  , TestExchangeToken
      { purpose =
          "plaid first time return ApiErrorResponse of expired public token, " <>
          "service uses createPublicTokenConfigs (single item) against the error, which is matched to make it call for public token, " <>
          "plaid should be called for public token and return success public token, " <>
          "plaid return success access token in second time, " <>
          "token store should be called once to store the token, " <>
          "service should return a success response"
      , firstPublicTokenToPlaid = PLK.PublicToken "expired-public-token"
      , mockAccessTokenResps = 
          [ Left . ApiErrorResponse status400 . PL.StructuredResp $ 
              PL.ErrorResponse Nothing (PL.ErrorCode "INVALID_PUBLIC_TOKEN") (PL.ErrorMessage "provided public token is expired. Public tokens expire 30 minutes after creation at which point they can no longer be exchanged") (PL.ErrorType "INVALID_INPUT") (PL.RequestId "sample-request-id")
          , Right $ ExchangeAccessTokenResponse (PL.AccessToken "finally-success-access-token") (PL.ItemId "finally-success-item-id")
          ]
      , mockCreatePublicTokenConfigs = 
          [ CreatePublicTokenConfig
              { _configMatchedErrorCode = MatchedErrorCode "invalid_public_token"
              , _configMatchedErrorWords = 
                  [ MatchedErrorWord "PUBLIC TOKEN"
                  , MatchedErrorWord "Expired"
                  ]
              }
          ]
      , mockPublicTokenResp = Right $ CreatePublicTokenResponse (PL.PublicToken "renewed-public-token") (PL.RequestId "renewed-public-token-request-id")
      , expectedReceivedPublicTokens = 
          [ PL.PublicToken "expired-public-token"
          , PL.PublicToken "renewed-public-token"
          ]
      , expectedCreatePublicTokenCount = CreatePublicTokenCount 1
      , expectedStoredTokens = 
          [ (PLK.AccessToken "finally-success-access-token", COMMON.ItemId "finally-success-item-id")
          ]
      , expectedOutput = Right . TokenExchangeResponse . COMMON.ItemId $ "finally-success-item-id"
      }
  , TestExchangeToken
      { purpose =
          "plaid first time return ApiErrorResponse of expired public token, " <>
          "service uses createPublicTokenConfigs (multiple item) against the error, which is matched to make it call for public token, " <>
          "plaid should be called for public token and return success public token, " <>
          "plaid return success access token in second time, " <>
          "token store should be called once to store the token, " <>
          "service should return a success response"
      , firstPublicTokenToPlaid = PLK.PublicToken "expired-public-token"
      , mockAccessTokenResps = 
          [ Left . ApiErrorResponse status400 . PL.StructuredResp $ 
              PL.ErrorResponse Nothing (PL.ErrorCode "match_any_of_them") (PL.ErrorMessage "aa bb xx") (PL.ErrorType "any_error_type") (PL.RequestId "sample-request-id")
          , Right $ ExchangeAccessTokenResponse (PL.AccessToken "finally-success-access-token") (PL.ItemId "finally-success-item-id")
          ]
      , mockCreatePublicTokenConfigs = -- match any CreatePublicTokenConfig is sufficient
          [ CreatePublicTokenConfig
              { _configMatchedErrorCode = MatchedErrorCode "invalid_public_token"
              , _configMatchedErrorWords = 
                  [ MatchedErrorWord "PUBLIC TOKEN"
                  , MatchedErrorWord "Expired"
                  ]
              }
          , CreatePublicTokenConfig -- both error code and all error words should be matched incase sensitive
              { _configMatchedErrorCode = MatchedErrorCode "match_any_of_them"
              , _configMatchedErrorWords = 
                  [ MatchedErrorWord "XX"
                  , MatchedErrorWord "AA"
                  ]
              }
          ]
      , mockPublicTokenResp = Right $ CreatePublicTokenResponse (PL.PublicToken "renewed-public-token") (PL.RequestId "renewed-public-token-request-id")
      , expectedReceivedPublicTokens = 
          [ PL.PublicToken "expired-public-token"
          , PL.PublicToken "renewed-public-token"
          ]
      , expectedCreatePublicTokenCount = CreatePublicTokenCount 1
      , expectedStoredTokens = 
          [ (PLK.AccessToken "finally-success-access-token", COMMON.ItemId "finally-success-item-id")
          ]
      , expectedOutput = Right . TokenExchangeResponse . COMMON.ItemId $ "finally-success-item-id"
      }
  , TestExchangeToken
      { purpose = 
          "plaid returns ApiErrorResponse of incorrect public token, " <>
          "the createPublicTokenConfigs makes the error deemed not to call for public token, " <>
          "plaid shouldn't be called for public token, " <>
          "token store shouldn't be called, " <>
          "service should by-pass the incorrect public token error"
      , firstPublicTokenToPlaid = PLK.PublicToken "incorrect-public-token"
      , mockAccessTokenResps = 
          [ Left . ApiErrorResponse status400 . PL.StructuredResp $ 
              PL.ErrorResponse Nothing (PL.ErrorCode "match_any_of_them") (PL.ErrorMessage "aa bb xx") (PL.ErrorType "any_error_type") (PL.RequestId "sample-request-id")
          ]
      , mockCreatePublicTokenConfigs = 
          [ CreatePublicTokenConfig
              { _configMatchedErrorCode = MatchedErrorCode "invalid_public_token"
              , _configMatchedErrorWords = 
                  [ MatchedErrorWord "PUBLIC TOKEN"
                  , MatchedErrorWord "Expired"
                  ]
              }
          , CreatePublicTokenConfig
              { _configMatchedErrorCode = MatchedErrorCode "match_any_of_them"
              , _configMatchedErrorWords = 
                  [ MatchedErrorWord "XX"
                  , MatchedErrorWord "AAx" -- this is matched from the error msg
                  ]
              }
          ]
      , mockPublicTokenResp = Right $ CreatePublicTokenResponse (PL.PublicToken "it-wont-be-called") (PL.RequestId "it-wont-be-called")
      , expectedReceivedPublicTokens =
          [ PL.PublicToken "incorrect-public-token"
          ]
      , expectedCreatePublicTokenCount = CreatePublicTokenCount 0
      , expectedStoredTokens = []
      , expectedOutput = Left . PlaidErrorResponse status400 . COMMON.StructuredResp $
          COMMON.ErrorResponse Nothing (COMMON.ErrorCode "match_any_of_them") (COMMON.ErrorMessage "aa bb xx") (COMMON.ErrorType "any_error_type") (COMMON.RequestId "sample-request-id")
      }
  , TestExchangeToken
      { purpose = 
          "plaid returns DeserializationError, " <>
          "DeserializationError deemed not to call for public token, " <>
          "plaid shouldn't be called for public token, " <>
          "token store shouldn't be called, " <>
          "service should by-pass the DeserializationError"
      , firstPublicTokenToPlaid = PLK.PublicToken "sample-public-token"
      , mockAccessTokenResps = 
          [ Left $ DeserializationError "randomErrorMsg" "{}"
          ]
      , mockCreatePublicTokenConfigs = []
      , mockPublicTokenResp = Right $ CreatePublicTokenResponse (PL.PublicToken "it-wont-be-called") (PL.RequestId "it-wont-be-called")
      , expectedReceivedPublicTokens =
          [ PL.PublicToken "sample-public-token"
          ]
      , expectedCreatePublicTokenCount = CreatePublicTokenCount 0
      , expectedStoredTokens = []
      , expectedOutput = Left $ DecodeFailure "randomErrorMsg" "{}"
      }
  , TestExchangeToken
      { purpose = 
          "plaid returns HttpError, " <>
          "HttpError deemed not to call for public token, " <>
          "plaid shouldn't be called for public token, " <>
          "token store shouldn't be called, " <>
          "service should by-pass the HttpError"
      , firstPublicTokenToPlaid = PLK.PublicToken "sample-public-token"
      , mockAccessTokenResps = 
          [ Left $ HttpError "randomHttpErrorMsg"
          ]
      , mockCreatePublicTokenConfigs = []
      , mockPublicTokenResp = Right $ CreatePublicTokenResponse (PL.PublicToken "it-wont-be-called") (PL.RequestId "it-wont-be-called")
      , expectedReceivedPublicTokens =
          [ PL.PublicToken "sample-public-token"
          ]
      , expectedCreatePublicTokenCount = CreatePublicTokenCount 0
      , expectedStoredTokens = []
      , expectedOutput = Left $ CommsError "randomHttpErrorMsg"
      }
  , TestExchangeToken
      { purpose = 
          "plaid returns NetworkError, " <>
          "NetworkError deemed not to call for public token, " <>
          "plaid shouldn't be called for public token, " <>
          "token store shouldn't be called, " <>
          "service should by-pass the NetworkError"
      , firstPublicTokenToPlaid = PLK.PublicToken "sample-public-token"
      , mockAccessTokenResps = 
          [ Left $ NetworkError "randomNetworkErrorMsg"
          ]
      , mockCreatePublicTokenConfigs = []
      , mockPublicTokenResp = Right $ CreatePublicTokenResponse (PL.PublicToken "it-wont-be-called") (PL.RequestId "it-wont-be-called")
      , expectedReceivedPublicTokens =
          [ PL.PublicToken "sample-public-token"
          ]
      , expectedCreatePublicTokenCount = CreatePublicTokenCount 0
      , expectedStoredTokens = []
      , expectedOutput = Left $ CommsError "randomNetworkErrorMsg"
      }
  , TestExchangeToken
      { purpose =
          "plaid first time return ApiErrorResponse of expired public token, " <>
          "error is deemed by createPublicTokenConfigs to call for public token, " <>
          "plaid should be called for public token and return success public token, " <>
          "plaid still returns expired public token in second time, " <>
          "service should give up and return the second expired public token error"
      , firstPublicTokenToPlaid = PLK.PublicToken "expired-public-token"
      , mockAccessTokenResps = 
          [ Left . ApiErrorResponse status400 . PL.StructuredResp $ 
              PL.ErrorResponse Nothing (PL.ErrorCode "INVALID_PUBLIC_TOKEN") (PL.ErrorMessage "public tokenexpired") (PL.ErrorType "expired token in first time") (PL.RequestId "sample-request-id-1")
          , Left . ApiErrorResponse status400 . PL.StructuredResp $ 
              PL.ErrorResponse Nothing (PL.ErrorCode "INVALID_PUBLIC_TOKEN") (PL.ErrorMessage "public tokenexpired") (PL.ErrorType "expired token in second time") (PL.RequestId "sample-request-id-2")
          ]
      , mockCreatePublicTokenConfigs =
          [ CreatePublicTokenConfig
              { _configMatchedErrorCode = MatchedErrorCode "INVALID_PUBLIC_TOKEN"
              , _configMatchedErrorWords = 
                  [ MatchedErrorWord "public token"
                  , MatchedErrorWord "expired"
                  ]
              }
          ]
      , mockPublicTokenResp = Right $ CreatePublicTokenResponse (PL.PublicToken "renewed-public-token") (PL.RequestId "renewed-public-token-request-id")
      , expectedReceivedPublicTokens = 
          [ PL.PublicToken "expired-public-token"
          , PL.PublicToken "renewed-public-token"
          ]
      , expectedCreatePublicTokenCount = CreatePublicTokenCount 1
      , expectedStoredTokens = []
      , expectedOutput = Left . PlaidErrorResponse status400 . COMMON.StructuredResp $
          COMMON.ErrorResponse Nothing (COMMON.ErrorCode "INVALID_PUBLIC_TOKEN") (COMMON.ErrorMessage "public tokenexpired") (COMMON.ErrorType "expired token in second time") (COMMON.RequestId "sample-request-id-2")
      }
  , TestExchangeToken
      { purpose =
          "plaid first time return ApiErrorResponse of expired public token, " <>
          "error is deemed by createPublicTokenConfigs to call for public token, " <>
          "plaid should be called for public token and return success public token, " <>
          "plaid returns DeserializationError in second time, " <>
          "service should return the DeserializationError"
      , firstPublicTokenToPlaid = PLK.PublicToken "expired-public-token"
      , mockAccessTokenResps = 
          [ Left . ApiErrorResponse status400 . PL.StructuredResp $ 
              PL.ErrorResponse Nothing (PL.ErrorCode "INVALID_PUBLIC_TOKEN") (PL.ErrorMessage "public tokenexpired") (PL.ErrorType "expired token in first time") (PL.RequestId "sample-request-id-1")
          , Left $ DeserializationError "randomErrorMsg" "{}"
          ]
      , mockCreatePublicTokenConfigs =
          [ CreatePublicTokenConfig
              { _configMatchedErrorCode = MatchedErrorCode "INVALID_PUBLIC_TOKEN"
              , _configMatchedErrorWords = 
                  [ MatchedErrorWord "public token"
                  , MatchedErrorWord "expired"
                  ]
              }
          ]
      , mockPublicTokenResp = Right $ CreatePublicTokenResponse (PL.PublicToken "renewed-public-token") (PL.RequestId "renewed-public-token-request-id")
      , expectedReceivedPublicTokens = 
          [ PL.PublicToken "expired-public-token"
          , PL.PublicToken "renewed-public-token"
          ]
      , expectedCreatePublicTokenCount = CreatePublicTokenCount 1
      , expectedStoredTokens = []
      , expectedOutput = Left $ DecodeFailure "randomErrorMsg" "{}"
      }
  ]
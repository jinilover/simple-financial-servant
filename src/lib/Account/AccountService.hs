{-# LANGUAGE LambdaCase #-}
module Account.AccountService where

import Control.Monad.Except
import Data.Functor
import Data.List.NonEmpty hiding (length, sortWith)
import qualified Data.Map as M
import Data.Maybe
import Data.String.Conv
import Data.Text hiding (length)
import Data.Validation
import GHC.Exts hiding (toList)
import Katip

import Account.Types
import Common.Types
import Common.Utils
import qualified Plaid.Types as PL
import Plaid.Client
import PlaidLinking.Types 
import PlaidLinking.TokenService

data AccountService m = AccountService
  { accountSummary :: UserId -> m (Either AccountSummaryError AccountSummaryResponse)
  }

mkAccountService :: 
  KatipContext m =>
  PlaidClient m ->
  TokenService m ->
  AccountService m
mkAccountService plaidClient tokenService = AccountService
  { accountSummary = \userId -> 
      addNameSpace $
      logFM InfoS ("Requesting account summary for " <> logStr (show userId)) *> 
      tokenService.fetchAccessTokenData userId >>= \case
        Left tokenNotFound -> logFM ErrorS (logStr $ show tokenNotFound) $> Left (PlaidLinkingError tokenNotFound)
        Right accessToken -> runExceptT . fmap toAccountSummaryResponse . ExceptT $ callForAccounts accessToken
  }
  where
    addNameSpace = katipAddNamespace "account-service"
    
    callForAccounts accessToken = 
      (plaidClient.getAccounts . PL.AccessToken . (.unAccessToken) $ accessToken) >>= \case 
        Left plaidError -> 
          logFM ErrorS (logStr $ show plaidError) $> 
          (Left . PlaidClientError . fromPlaidError) plaidError
        Right PL.AccountListResponse {..} -> 
          let infoMsg = "Received " <> show (length accounts) <> " accounts from plaid, validating and producing summary"
          in  logFM InfoS (logStr infoMsg) *>
          case traverse validatePLAccount accounts of
            Failure validationErrors -> 
              let accountValidationErrors = toList validationErrors
                  errMsg = intercalate "\n" . fmap (toS . show) $ accountValidationErrors
              in  logFM ErrorS (logStr errMsg) $> 
                  (Left . InvalidAccountData) accountValidationErrors
            Success validatedAccounts -> pureRight validatedAccounts

    toAccountSummaryResponse :: [Account] -> AccountSummaryResponse
    toAccountSummaryResponse accounts = 
      let summaryByCurrencies = groupByCurrency accounts 
      in  AccountSummaryResponse {..}

    groupByCurrency :: [Account] -> [SummaryByCurrency]
    groupByCurrency accounts = 
      let currencyAccountsMap = groupByKey (.balances.currencyCode) accounts
      in  sortWith (.currency) .
          fmap (\(currency, summaryByAccountTypes) ->
            let total = sumTotalBalance . fmap (.total) $ summaryByAccountTypes
            in  SummaryByCurrency {..}
          ) .
          M.toList . 
          M.map groupByAccountType $
          currencyAccountsMap

    groupByAccountType :: [Account] -> [SummaryByAccountType]
    groupByAccountType accounts = 
      let typeAccountsMap = groupByKey (.accountType) accounts
      in  sortWith (.accountType) .
          fmap (\(accountType, summaryBySubtypes) ->
            let total = sumTotalBalance . fmap (.total) $ summaryBySubtypes
            in  SummaryByAccountType {..}
          ) . 
          M.toList . 
          M.map groupBySubtype $
          typeAccountsMap

    groupBySubtype :: [Account] -> [SummaryBySubtype]
    groupBySubtype accounts = 
      let subtypeAccountsMap = groupByKey (.subtype) accounts
      in  sortWith (.subtype) .
          fmap (uncurry SummaryBySubtype) . 
          M.toList . 
          flip M.map subtypeAccountsMap $ 
          sumTotalBalance . mapMaybe (.balances.maybeAvailable)

    sumTotalBalance :: [AvailableBalance] -> AvailableBalance
    sumTotalBalance balances = AvailableBalance $ 
      case fmap (.unAvailableBalance) balances of 
        [] -> 0.0
        xs -> sum xs


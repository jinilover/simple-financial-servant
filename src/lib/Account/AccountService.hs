{-# LANGUAGE LambdaCase #-}
module Account.AccountService where

import Control.Monad.Except
import Data.Functor
import Data.List.NonEmpty
import qualified Data.Map as M
import Data.Maybe
import Data.Text
import Data.Validation
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
        Left plaidError -> logFM ErrorS (logStr $ show plaidError) $> (Left . PlaidClientError . fromPlaidError) plaidError
        Right accountResp -> 
          case traverse validatePLAccount . (.accounts) $ accountResp of
            Failure texts -> 
              let errMsg = intercalate ", " $ toList texts
              in  logFM ErrorS (logStr errMsg) $> (Left . InvalidAccountData) errMsg
            Success accounts -> pureRight accounts

    toAccountSummaryResponse :: [Account] -> AccountSummaryResponse
    toAccountSummaryResponse accounts = 
      let summaryByCurrencies = groupByCurrency accounts 
      in  AccountSummaryResponse {..}

    groupByCurrency :: [Account] -> [SummaryByCurrency]
    groupByCurrency accounts = 
      let currencyAccountsMap = groupByKey (.balances.currencyCode) accounts
      in  fmap (\(currency, summaryByAccountTypes) ->
            let total = sumTotalBalance . fmap (.total) $ summaryByAccountTypes
            in  SummaryByCurrency {..}
          ) .
          M.toList . 
          flip M.map currencyAccountsMap $
          groupByAccountType

    groupByAccountType :: [Account] -> [SummaryByAccountType]
    groupByAccountType accounts = 
      let typeAccountsMap = groupByKey (.accountType) accounts
      in  fmap (\(accountType, summaryBySubtypes) ->
            let total = sumTotalBalance . fmap (.total) $ summaryBySubtypes
            in  SummaryByAccountType {..}
          ) . 
          M.toList . 
          flip M.map typeAccountsMap $ 
          groupBySubtype

    groupBySubtype :: [Account] -> [SummaryBySubtype]
    groupBySubtype accounts = 
      let subtypeAccountsMap = groupByKey (.subtype) accounts
      in  fmap (uncurry SummaryBySubtype) . 
          M.toList . 
          flip M.map subtypeAccountsMap $ 
          sumTotalBalance . mapMaybe (.balances.maybeAvailable)

    sumTotalBalance :: [AvailableBalance] -> AvailableBalance
    sumTotalBalance balances = AvailableBalance $ 
      case fmap (.unAvailableBalance) balances of 
        [] -> 0.0
        xs -> sum xs


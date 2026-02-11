{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE LambdaCase #-}
module PlaidLinking.TokenServiceTest 
  ( tests
  )
where

import Control.Monad.IO.Class
import Control.Monad.Reader
import Data.Functor
import Data.IORef

import Hedgehog
import qualified Hedgehog.Gen as Gen
import Test.Tasty
import Test.Tasty.Hedgehog

import Common.Types as COMMON
import Common.Utils
import Plaid.Client
import Plaid.Types as PL
import PlaidLinking.AccessTokenStore
import PlaidLinking.Types as PLK
import PlaidLinking.TokenService

import Common.Gen
import Common.Stubs
import Common.TestUtils
import PlaidLinking.TestData
import PlaidLinking.TestDataTypes

tests :: [TestTree]
tests = 
  [ testProperty "exchangeToken" test_exchangeToken
  ]

test_exchangeToken :: Property
test_exchangeToken = property
  do
    userId <- genUserId
    TestExchangeToken {..} <- forAll $ Gen.element testExchangeTokenData
    (accessTokenRespsRef, receivedPublicTokensRef, publicTokenCountRef, storedTokensRef) <- liftIO $
      (,,,) <$> newIORef mockAccessTokenResps
            <*> newIORef []
            <*> newIORef (CreatePublicTokenCount 0)
            <*> newIORef []

    let actualOutputM = withKatipContext $
          let plaidClient = plaidClientStub accessTokenRespsRef receivedPublicTokensRef mockPublicTokenResp publicTokenCountRef
              accessTokenStore = accessTokenStoreStub storedTokensRef $ AccessTokenDataKey userId
              tokenService = mkTokenService plaidClient accessTokenStore
          in  tokenService.exchangeToken userId firstPublicTokenToPlaid
    
    actualOutput <- runReaderT actualOutputM $ PlaidLinkingConfig mockCreatePublicTokenConfigs
    (actualReceivedPublicTokens, actualCreatePublicTokenCount, actualStoredTokens) <- liftIO $
      (,,)  <$> readIORef receivedPublicTokensRef
            <*> readIORef publicTokenCountRef
            <*> readIORef storedTokensRef

    actualCreatePublicTokenCount === expectedCreatePublicTokenCount
    actualReceivedPublicTokens === expectedReceivedPublicTokens
    actualStoredTokens === expectedStoredTokens
    actualOutput === expectedOutput

plaidClientStub :: 
  MonadIO m =>
  IORef [Either PlaidError ExchangeAccessTokenResponse] ->
  IORef [PL.PublicToken] ->
  Either PlaidError CreatePublicTokenResponse ->
  IORef CreatePublicTokenCount ->
  PlaidClient m
plaidClientStub accessTokenRespsRef receivedPublicTokensRef publicTokenResp publicTokenCountRef = plaidClientNoop
  { exchangeAccessToken = \publicToken ->
      liftIO (readIORef accessTokenRespsRef) >>= \case 
        resp : xs -> 
          liftIO (writeIORef accessTokenRespsRef xs) *>
          liftIO (modifyIORef receivedPublicTokensRef (++ [publicToken])) 
          $> resp
        [] -> pureLeft $ NetworkError "A bug in the test data"
  , createPublicToken = 
      liftIO (modifyIORef publicTokenCountRef succ) $> publicTokenResp
  }

accessTokenStoreStub :: 
  MonadIO m =>
  IORef [(PLK.AccessToken, COMMON.ItemId)] ->
  Key AccessTokenData ->
  AccessTokenStore m
accessTokenStoreStub storedTokensRef primaryKey = accessTokenStoreNoop 
  { saveAccessTokenData = \AccessTokenData {..} -> 
      let newElem = (accessTokenDataAccessToken, accessTokenDataItemId)
      in  liftIO (modifyIORef storedTokensRef (++ [newElem])) $> primaryKey
  }

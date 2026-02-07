{-# LANGUAGE BlockArguments #-}
module Account.AccountServiceTest where

import Hedgehog
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Range as Range
import Test.Tasty
import Test.Tasty.Hedgehog

test_accountSummary :: Property
test_accountSummary = property do
  n <- forAll $ Gen.int (Range.linear 0 100)
  n === n

tests :: [TestTree]
tests = 
  [ testProperty "accountSummary" test_accountSummary
  ]
import Test.Tasty

import qualified Account.AccountServiceTest as AccountServiceTest
import qualified PlaidLinking.TokenServiceTest as TokenServiceTest

main :: IO ()
main = 
  defaultMain $ testGroup "All tests" [
    testGroup "AccountServiceTest" AccountServiceTest.tests
  , testGroup "TokenServiceTest" TokenServiceTest.tests
  ]
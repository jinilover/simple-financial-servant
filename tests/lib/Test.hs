import Test.Tasty

import qualified Account.AccountServiceTest as AccountServiceTest

main :: IO ()
main = 
  defaultMain $ testGroup "All tests" [
    testGroup "AccountServiceTest" AccountServiceTest.tests
  ]
module Account.TestData where

import Account.Types as ACC
import Plaid.Types as PL

import Account.TestDataTypes

testAccountSummaryData :: [TestAccountSummary]
testAccountSummaryData = 
  [ TestAccountSummary 
      { purpose = "empty availableBalance and currentBalance"
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
              ]
          }
      , expectedOutput = Left $ InvalidAccountData 
          { accountErrors = 
              [ AccountValidationError 
                  { accountId = ACC.AccountId "001"
                  , errorMsg = "Both available and current are empty" 
                  }
              ]

          }
      }
  -- , TestAccountSummary 
  --   { purpose = "2 accounts, 1 has empty availableBalance and currentBalance, the other has even invalid accountType"
  --   , mockPlaidData = AccountListResponse 
  --       { accounts = 
  --           [ PL.Account
  --               { account_id = PL.AccountId "001"
  --               , balances = PL.Balances 
  --                   { available = Nothing
  --                   , current = Nothing
  --                   , iso_currency_code = Just $ IsoCurrencyCode "USD"
  --                   , limit = Nothing
  --                   , unofficial_currency_code = Nothing
  --                   }
  --               , mask = Nothing
  --               , name = PL.AccountName "001 Account"
  --               , official_name = Nothing
  --               , subtype = Nothing
  --               , account_type = AccountType "other"
  --               }
  --           , PL.Account
  --               { account_id = PL.AccountId "002"
  --               , balances = PL.Balances 
  --                   { available = Nothing
  --                   , current = Nothing
  --                   , iso_currency_code = Just $ IsoCurrencyCode "USD"
  --                   , limit = Nothing
  --                   , unofficial_currency_code = Nothing
  --                   }
  --               , mask = Nothing
  --               , name = PL.AccountName "002 Account"
  --               , official_name = Nothing
  --               , subtype = Nothing
  --               , account_type = AccountType "otherXX"
  --               }
  --           ]
  --       }
  --   , expectedOutput = Left $ InvalidAccountData 
  --       { accountErrors = 
  --           [ AccountValidationError 
  --               { accountId = ACC.AccountId "001"
  --               , errorMsg = "Both available and current are empty" 
  --               }
  --           , AccountValidationError 
  --               { accountId = ACC.AccountId "002"
  --               , errorMsg = "Both available and current are empty, Unknown account type: otherXX" 
  --               }
  --           ]

  --       }
  --   }
  -- , TestAccountSummary 
  --   { purpose = "multiple accounts with fields aim to fail all the validation"
  --   , mockPlaidData = AccountListResponse 
  --       { accounts = 
  --           [ PL.Account
  --               { account_id = PL.AccountId "001"
  --               , balances = PL.Balances 
  --                   { available = Nothing
  --                   , current = Nothing
  --                   , iso_currency_code = Just $ IsoCurrencyCode "USD"
  --                   , limit = Nothing
  --                   , unofficial_currency_code = Just $ UnofficialCurrencyCode "unknownXyz"
  --                   }
  --               , mask = Nothing
  --               , name = PL.AccountName "001 Account"
  --               , official_name = Nothing
  --               , subtype = Nothing
  --               , account_type = AccountType "other"
  --               }
  --           , PL.Account
  --               { account_id = PL.AccountId "002"
  --               , balances = PL.Balances 
  --                   { available = Nothing
  --                   , current = Nothing
  --                   , iso_currency_code = Just $ IsoCurrencyCode "USD"
  --                   , limit = Nothing
  --                   , unofficial_currency_code = Nothing
  --                   }
  --               , mask = Nothing
  --               , name = PL.AccountName "002 Account"
  --               , official_name = Nothing
  --               , subtype = Nothing
  --               , account_type = AccountType "otherXX"
  --               }
  --           , PL.Account
  --               { account_id = PL.AccountId "003"
  --               , balances = PL.Balances 
  --                   { available = Nothing
  --                   , current = Nothing
  --                   , iso_currency_code = Just $ IsoCurrencyCode "USD"
  --                   , limit = Nothing
  --                   , unofficial_currency_code = Just $ UnofficialCurrencyCode "unknownXyz"
  --                   }
  --               , mask = Nothing
  --               , name = PL.AccountName "002 Account"
  --               , official_name = Nothing
  --               , subtype = Nothing
  --               , account_type = AccountType "otherXX"
  --               }
  --           ]
  --       }
  --   , expectedOutput = Left $ InvalidAccountData 
  --       { accountErrors = 
  --           [ AccountValidationError 
  --               { accountId = ACC.AccountId "001"
  --               , errorMsg = "Both available and current are empty, " 
  --               }
  --           , AccountValidationError 
  --               { accountId = ACC.AccountId "002"
  --               , errorMsg = undefined -- "Both available and current are empty, Unknown account type: otherXX" 
  --               }
  --           ]

  --       }
  --   }
  ]

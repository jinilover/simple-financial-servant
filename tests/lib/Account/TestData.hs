module Account.TestData where

import Account.Types as ACC
import Plaid.Types as PL

import Account.TestDataTypes

testAccountSummaryData :: [TestAccountSummary]
testAccountSummaryData = 
  single_account_single_error_test_data ++
  single_account_multiple_errors_test_data ++
  multiple_account_single_error_test_data ++
  multiple_accounts_multiple_errors_test_data
  where
    single_account_single_error_test_data = 
      [ TestAccountSummary 
          { purpose = "empty available balance and current_balance"
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
      , TestAccountSummary 
          { purpose = "empty iso_currency_code and unofficial_currency_code"
          , mockPlaidData = AccountListResponse 
              { accounts = 
                  [ PL.Account
                      { account_id = PL.AccountId "001"
                      , balances = PL.Balances 
                          { available = Just $ PL.AvailableBalance 0.1
                          , current = Nothing
                          , iso_currency_code = Nothing
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
                      , errorMsg = "Both iso_currency_code and unofficial_currency_code are empty"
                      }
                  ]

              }
          }
      , TestAccountSummary 
          { purpose = "non-empty iso_currency_code and unofficial_currency_code"
          , mockPlaidData = AccountListResponse 
              { accounts = 
                  [ PL.Account
                      { account_id = PL.AccountId "001"
                      , balances = PL.Balances 
                          { available = Just $ PL.AvailableBalance 0.1
                          , current = Nothing
                          , iso_currency_code = Just $ IsoCurrencyCode "USD"
                          , limit = Nothing
                          , unofficial_currency_code = Just $ UnofficialCurrencyCode "whatIsIt"
                          }
                      , mask = Nothing
                      , name = PL.AccountName "001 Account"
                      , official_name = Nothing
                      , subtype = Just $ AccountSubtype "money market"
                      , account_type = AccountType "depository"
                      }
                  ]
              }
          , expectedOutput = Left $ InvalidAccountData 
              { accountErrors = 
                  [ AccountValidationError 
                      { accountId = ACC.AccountId "001"
                      , errorMsg = "Both iso_currency_code and unofficial_currency_code have value"
                      }
                  ]

              }
          }
      , TestAccountSummary 
          { purpose = "unknown unofficial currency code"
          , mockPlaidData = AccountListResponse 
              { accounts = 
                  [ PL.Account
                      { account_id = PL.AccountId "001"
                      , balances = PL.Balances 
                          { available = Just $ PL.AvailableBalance 0.1
                          , current = Nothing
                          , iso_currency_code = Nothing
                          , limit = Nothing
                          , unofficial_currency_code = Just $ UnofficialCurrencyCode "whatIsIt"
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
                      , errorMsg = "Unknown unofficial currency code: whatIsIt"
                      }
                  ]
              }
          }
      , TestAccountSummary 
          { purpose = "'other' account type has subtype "
          , mockPlaidData = AccountListResponse 
              { accounts = 
                  [ PL.Account
                      { account_id = PL.AccountId "001"
                      , balances = PL.Balances 
                          { available = Just $ PL.AvailableBalance 0.1
                          , current = Nothing
                          , iso_currency_code = Just $ IsoCurrencyCode "USD"
                          , limit = Nothing
                          , unofficial_currency_code = Nothing
                          }
                      , mask = Nothing
                      , name = PL.AccountName "001 Account"
                      , official_name = Nothing
                      , subtype = Just $ AccountSubtype "HasSubType!?"
                      , account_type = AccountType "other"
                      }
                  ]
              }
          , expectedOutput = Left $ InvalidAccountData 
              { accountErrors = 
                  [ AccountValidationError 
                      { accountId = ACC.AccountId "001"
                      , errorMsg = "'other' account type has subtype value"
                      }
                  ]
              }
          }
      , TestAccountSummary 
          { purpose = "'depository' account type has no subtype "
          , mockPlaidData = AccountListResponse 
              { accounts = 
                  [ PL.Account
                      { account_id = PL.AccountId "001"
                      , balances = PL.Balances 
                          { available = Just $ PL.AvailableBalance 0.1
                          , current = Nothing
                          , iso_currency_code = Just $ IsoCurrencyCode "USD"
                          , limit = Nothing
                          , unofficial_currency_code = Nothing
                          }
                      , mask = Nothing
                      , name = PL.AccountName "001 Account"
                      , official_name = Nothing
                      , subtype = Nothing
                      , account_type = AccountType "depository"
                      }
                  ]
              }
          , expectedOutput = Left $ InvalidAccountData 
              { accountErrors = 
                  [ AccountValidationError 
                      { accountId = ACC.AccountId "001"
                      , errorMsg = "'depository' account type requires subtype"
                      }
                  ]

              }
          }
      , TestAccountSummary 
          { purpose = "'credit' account type has no subtype "
          , mockPlaidData = AccountListResponse 
              { accounts = 
                  [ PL.Account
                      { account_id = PL.AccountId "001"
                      , balances = PL.Balances 
                          { available = Just $ PL.AvailableBalance 0.1
                          , current = Nothing
                          , iso_currency_code = Just $ IsoCurrencyCode "USD"
                          , limit = Nothing
                          , unofficial_currency_code = Nothing
                          }
                      , mask = Nothing
                      , name = PL.AccountName "001 Account"
                      , official_name = Nothing
                      , subtype = Nothing
                      , account_type = AccountType "credit"
                      }
                  ]
              }
          , expectedOutput = Left $ InvalidAccountData 
              { accountErrors = 
                  [ AccountValidationError 
                      { accountId = ACC.AccountId "001"
                      , errorMsg = "'credit' account type requires subtype"
                      }
                  ]

              }
          }
      , TestAccountSummary 
          { purpose = "'loan' account type has no subtype "
          , mockPlaidData = AccountListResponse 
              { accounts = 
                  [ PL.Account
                      { account_id = PL.AccountId "001"
                      , balances = PL.Balances 
                          { available = Just $ PL.AvailableBalance 0.1
                          , current = Nothing
                          , iso_currency_code = Just $ IsoCurrencyCode "USD"
                          , limit = Nothing
                          , unofficial_currency_code = Nothing
                          }
                      , mask = Nothing
                      , name = PL.AccountName "001 Account"
                      , official_name = Nothing
                      , subtype = Nothing
                      , account_type = AccountType "loan"
                      }
                  ]
              }
          , expectedOutput = Left $ InvalidAccountData 
              { accountErrors = 
                  [ AccountValidationError 
                      { accountId = ACC.AccountId "001"
                      , errorMsg = "'loan' account type requires subtype"
                      }
                  ]

              }
          }
      , TestAccountSummary 
          { purpose = "'investment' account type has no subtype "
          , mockPlaidData = AccountListResponse 
              { accounts = 
                  [ PL.Account
                      { account_id = PL.AccountId "001"
                      , balances = PL.Balances 
                          { available = Just $ PL.AvailableBalance 0.1
                          , current = Nothing
                          , iso_currency_code = Just $ IsoCurrencyCode "USD"
                          , limit = Nothing
                          , unofficial_currency_code = Nothing
                          }
                      , mask = Nothing
                      , name = PL.AccountName "001 Account"
                      , official_name = Nothing
                      , subtype = Nothing
                      , account_type = AccountType "investment"
                      }
                  ]
              }
          , expectedOutput = Left $ InvalidAccountData 
              { accountErrors = 
                  [ AccountValidationError 
                      { accountId = ACC.AccountId "001"
                      , errorMsg = "'investment' account type requires subtype"
                      }
                  ]

              }
          }
      , TestAccountSummary 
          { purpose = "'payroll' account type has no subtype "
          , mockPlaidData = AccountListResponse 
              { accounts = 
                  [ PL.Account
                      { account_id = PL.AccountId "001"
                      , balances = PL.Balances 
                          { available = Just $ PL.AvailableBalance 0.1
                          , current = Nothing
                          , iso_currency_code = Just $ IsoCurrencyCode "USD"
                          , limit = Nothing
                          , unofficial_currency_code = Nothing
                          }
                      , mask = Nothing
                      , name = PL.AccountName "001 Account"
                      , official_name = Nothing
                      , subtype = Nothing
                      , account_type = AccountType "payroll"
                      }
                  ]
              }
          , expectedOutput = Left $ InvalidAccountData 
              { accountErrors = 
                  [ AccountValidationError 
                      { accountId = ACC.AccountId "001"
                      , errorMsg = "'payroll' account type requires subtype"
                      }
                  ]

              }
          }
      , TestAccountSummary 
          { purpose = "'depository' account type has invalid subtype "
          , mockPlaidData = AccountListResponse 
              { accounts = 
                  [ PL.Account
                      { account_id = PL.AccountId "001"
                      , balances = PL.Balances 
                          { available = Just $ PL.AvailableBalance 0.1
                          , current = Nothing
                          , iso_currency_code = Just $ IsoCurrencyCode "USD"
                          , limit = Nothing
                          , unofficial_currency_code = Nothing
                          }
                      , mask = Nothing
                      , name = PL.AccountName "001 Account"
                      , official_name = Nothing
                      , subtype = Just $ AccountSubtype "CashManagement"
                      , account_type = AccountType "depository"
                      }
                  ]
              }
          , expectedOutput = Left $ InvalidAccountData 
              { accountErrors = 
                  [ AccountValidationError 
                      { accountId = ACC.AccountId "001"
                      , errorMsg = "Unknown depository subtype: CashManagement"
                      }
                  ]

              }
          }
      , TestAccountSummary 
          { purpose = "'credit' account type has invalid subtype "
          , mockPlaidData = AccountListResponse 
              { accounts = 
                  [ PL.Account
                      { account_id = PL.AccountId "001"
                      , balances = PL.Balances 
                          { available = Just $ PL.AvailableBalance 0.1
                          , current = Nothing
                          , iso_currency_code = Just $ IsoCurrencyCode "USD"
                          , limit = Nothing
                          , unofficial_currency_code = Nothing
                          }
                      , mask = Nothing
                      , name = PL.AccountName "001 Account"
                      , official_name = Nothing
                      , subtype = Just $ AccountSubtype "apple pay"
                      , account_type = AccountType "credit"
                      }
                  ]
              }
          , expectedOutput = Left $ InvalidAccountData 
              { accountErrors = 
                  [ AccountValidationError 
                      { accountId = ACC.AccountId "001"
                      , errorMsg = "Unknown credit subtype: apple pay"
                      }
                  ]

              }
          }
      , TestAccountSummary 
          { purpose = "'loan' account type has invalid subtype "
          , mockPlaidData = AccountListResponse 
              { accounts = 
                  [ PL.Account
                      { account_id = PL.AccountId "001"
                      , balances = PL.Balances 
                          { available = Just $ PL.AvailableBalance 0.1
                          , current = Nothing
                          , iso_currency_code = Just $ IsoCurrencyCode "USD"
                          , limit = Nothing
                          , unofficial_currency_code = Nothing
                          }
                      , mask = Nothing
                      , name = PL.AccountName "001 Account"
                      , official_name = Nothing
                      , subtype = Just $ AccountSubtype "shark loan"
                      , account_type = AccountType "loan"
                      }
                  ]
              }
          , expectedOutput = Left $ InvalidAccountData 
              { accountErrors = 
                  [ AccountValidationError 
                      { accountId = ACC.AccountId "001"
                      , errorMsg = "Unknown loan subtype: shark loan"
                      }
                  ]

              }
          }
      , TestAccountSummary 
          { purpose = "'investment' account type has invalid subtype "
          , mockPlaidData = AccountListResponse 
              { accounts = 
                  [ PL.Account
                      { account_id = PL.AccountId "001"
                      , balances = PL.Balances 
                          { available = Just $ PL.AvailableBalance 0.1
                          , current = Nothing
                          , iso_currency_code = Just $ IsoCurrencyCode "USD"
                          , limit = Nothing
                          , unofficial_currency_code = Nothing
                          }
                      , mask = Nothing
                      , name = PL.AccountName "001 Account"
                      , official_name = Nothing
                      , subtype = Just $ AccountSubtype "etf"
                      , account_type = AccountType "investment"
                      }
                  ]
              }
          , expectedOutput = Left $ InvalidAccountData 
              { accountErrors = 
                  [ AccountValidationError 
                      { accountId = ACC.AccountId "001"
                      , errorMsg = "Unknown investment subtype: etf"
                      }
                  ]

              }
          }
      , TestAccountSummary 
          { purpose = "'payroll' account type has invalid subtype "
          , mockPlaidData = AccountListResponse 
              { accounts = 
                  [ PL.Account
                      { account_id = PL.AccountId "001"
                      , balances = PL.Balances 
                          { available = Just $ PL.AvailableBalance 0.1
                          , current = Nothing
                          , iso_currency_code = Just $ IsoCurrencyCode "USD"
                          , limit = Nothing
                          , unofficial_currency_code = Nothing
                          }
                      , mask = Nothing
                      , name = PL.AccountName "001 Account"
                      , official_name = Nothing
                      , subtype = Just $ AccountSubtype "cheque"
                      , account_type = AccountType "payroll"
                      }
                  ]
              }
          , expectedOutput = Left $ InvalidAccountData 
              { accountErrors = 
                  [ AccountValidationError 
                      { accountId = ACC.AccountId "001"
                      , errorMsg = "Unknown payroll subtype: cheque"
                      }
                  ]

              }
          }
      ]
    
    multiple_account_single_error_test_data = 
      [ TestAccountSummary 
          { purpose = "2 accounts, " <> 
              "one has empty available balance and current_balance, " <>
              "the other has invalid account type"
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
                  ,  PL.Account
                      { account_id = PL.AccountId "002"
                      , balances = PL.Balances 
                          { available = Just $ PL.AvailableBalance 0.1
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
                      , errorMsg = "Unknown account type: otherXX" 
                      }
                  ]
              }
          }
      ]

    single_account_multiple_errors_test_data = 
      [ TestAccountSummary 
          { purpose = "single account with all fields fail validation to test if errors are accumulated"
          , mockPlaidData = AccountListResponse 
              { accounts = 
                  [ PL.Account
                      { account_id = PL.AccountId "001"
                      , balances = PL.Balances 
                          { available = Nothing
                          , current = Nothing
                          , iso_currency_code = Nothing
                          , limit = Nothing
                          , unofficial_currency_code = Nothing
                          }
                      , mask = Nothing
                      , name = PL.AccountName "001 Account"
                      , official_name = Nothing
                      , subtype = Nothing
                      , account_type = AccountType "whatIsIt"
                      }
                  ]
              }
          , expectedOutput = Left $ InvalidAccountData 
              { accountErrors = 
                  [ AccountValidationError 
                      { accountId = ACC.AccountId "001"
                      , errorMsg = 
                          "Both available and current are empty, " <>
                          "Both iso_currency_code and unofficial_currency_code are empty, " <>
                          "Unknown account type: whatIsIt"
                      }
                  ]
              }
          }
      ]

    multiple_accounts_multiple_errors_test_data = 
      [ TestAccountSummary 
          { purpose = "multiple accounts, each has multiple error"
          , mockPlaidData = AccountListResponse 
              { accounts = 
                  [ PL.Account
                      { account_id = PL.AccountId "001"
                      , balances = PL.Balances 
                          { available = Nothing
                          , current = Nothing
                          , iso_currency_code = Nothing
                          , limit = Nothing
                          , unofficial_currency_code = Nothing
                          }
                      , mask = Nothing
                      , name = PL.AccountName "001 Account"
                      , official_name = Nothing
                      , subtype = Just $ AccountSubtype "other-subtype"
                      , account_type = AccountType "other"
                      }
                  , PL.Account
                      { account_id = PL.AccountId "002"
                      , balances = PL.Balances 
                          { available = Nothing
                          , current = Nothing
                          , iso_currency_code = Nothing
                          , limit = Nothing
                          , unofficial_currency_code = Just $ UnofficialCurrencyCode "renq"
                          }
                      , mask = Nothing
                      , name = PL.AccountName "002 Account"
                      , official_name = Nothing
                      , subtype = Just $ AccountSubtype "shark"
                      , account_type = AccountType "loan"
                      }
                  ]
              }
          , expectedOutput = Left $ InvalidAccountData 
              { accountErrors = 
                  [ AccountValidationError 
                      { accountId = ACC.AccountId "001"
                      , errorMsg = 
                          "Both available and current are empty, " <>
                          "Both iso_currency_code and unofficial_currency_code are empty, " <>
                          "'other' account type has subtype value"
                      }
                  ,  AccountValidationError 
                      { accountId = ACC.AccountId "002"
                      , errorMsg = 
                          "Both available and current are empty, " <>
                          "Unknown unofficial currency code: renq, " <>
                          "Unknown loan subtype: shark"
                      }
                  ]
              }
          }
      ]

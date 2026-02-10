module Account.TestData where

import Network.HTTP.Types

import Account.Types as ACC
import Common.Types as COMMON
import Plaid.Types as PL

import Account.TestDataTypes

testAccountSummaryData :: [TestAccountSummary]
testAccountSummaryData = 
  single_account_single_error_test_data ++
  single_account_multiple_errors_test_data ++
  multiple_account_single_error_test_data ++
  multiple_accounts_multiple_errors_test_data ++
  [account_summary_data]
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
          { purpose = "other account type has subtype "
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
                      , errorMsg = "other account type has subtype value"
                      }
                  ]
              }
          }
      , TestAccountSummary 
          { purpose = "depository account type has no subtype "
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
                      , errorMsg = "depository account type requires subtype"
                      }
                  ]

              }
          }
      , TestAccountSummary 
          { purpose = "credit account type has no subtype "
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
                      , errorMsg = "credit account type requires subtype"
                      }
                  ]

              }
          }
      , TestAccountSummary 
          { purpose = "loan account type has no subtype "
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
                      , errorMsg = "loan account type requires subtype"
                      }
                  ]

              }
          }
      , TestAccountSummary 
          { purpose = "investment account type has no subtype "
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
                      , errorMsg = "investment account type requires subtype"
                      }
                  ]

              }
          }
      , TestAccountSummary 
          { purpose = "payroll account type has no subtype "
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
                      , errorMsg = "payroll account type requires subtype"
                      }
                  ]

              }
          }
      , TestAccountSummary 
          { purpose = "depository account type has invalid subtype "
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
          { purpose = "credit account type has invalid subtype "
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
          { purpose = "loan account type has invalid subtype "
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
          { purpose = "investment account type has invalid subtype "
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
          { purpose = "payroll account type has invalid subtype "
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
                          "other account type has subtype value"
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

    account_summary_data = 
      let purpose = "Accounts are all valid, check if summary is calculated correctly in ascending order"
          mockPlaidData = AccountListResponse
            { accounts = 
                [ PL.Account
                    { account_id = PL.AccountId "4Nl9Jljp7WTErX6NReymuj969XvWDoflPvaLB"
                    , balances = PL.Balances 
                        { available = Just $ PL.AvailableBalance 100
                        , current = Just $ PL.CurrentBalance 110
                        , iso_currency_code = Just $ IsoCurrencyCode "USD"
                        , limit = Nothing
                        , unofficial_currency_code = Nothing
                        }
                    , mask = Just $ PL.Mask "0000"
                    , name = PL.AccountName "Plaid Checking"
                    , official_name = Just $ PL.OfficialName "Plaid Gold Standard 0% Interest Checking"
                    , subtype = Just $ AccountSubtype "checking"
                    , account_type = AccountType "depository"
                    }
                , PL.Account
                    { account_id = PL.AccountId "NvWorWbMzZT5ebLPDG87crmbmXp5QWiXwGMQg"
                    , balances = PL.Balances 
                        { available = Just $ PL.AvailableBalance 200
                        , current = Just $ PL.CurrentBalance 210
                        , iso_currency_code = Just $ IsoCurrencyCode "USD"
                        , limit = Nothing
                        , unofficial_currency_code = Nothing
                        }
                    , mask = Just $ PL.Mask "1111"
                    , name = PL.AccountName "Plaid Saving"
                    , official_name = Just $ PL.OfficialName "Plaid Silver Standard 0.1% Interest Saving"
                    , subtype = Just $ AccountSubtype "savings"
                    , account_type = AccountType "depository"
                    }
                , PL.Account
                    { account_id = PL.AccountId "jBoj8oXky4UAGvxD4rRZtdqvqjAmo1Fve7Jaq"
                    , balances = PL.Balances 
                        { available = Just . PL.AvailableBalance $ 1020
                        , current = Just $ PL.CurrentBalance 410
                        , iso_currency_code = Just $ IsoCurrencyCode "USD"
                        , limit = Nothing
                        , unofficial_currency_code = Nothing
                        }
                    , mask = Just $ PL.Mask "3333"
                    , name = PL.AccountName "Plaid Credit Card"
                    , official_name = Just $ PL.OfficialName "Plaid Diamond 12.5% APR Interest Credit Card"
                    , subtype = Just $ AccountSubtype "credit card"
                    , account_type = AccountType "credit"
                    }
                , PL.Account
                    { account_id = PL.AccountId "77r69r3LZnCEl4P7kz61uV5d5XB86Ef8q5Xxn"
                    , balances = PL.Balances 
                        { available = Just $ PL.AvailableBalance 43200
                        , current = Just $ PL.CurrentBalance 43200
                        , iso_currency_code = Just $ IsoCurrencyCode "USD"
                        , limit = Nothing
                        , unofficial_currency_code = Nothing
                        }
                    , mask = Just $ PL.Mask "4444"
                    , name = PL.AccountName "Plaid Money Market"
                    , official_name = Just $ PL.OfficialName "Plaid Platinum Standard 1.85% Interest Money Market"
                    , subtype = Just $ AccountSubtype "money market"
                    , account_type = AccountType "depository"
                    }
                , PL.Account
                    { account_id = PL.AccountId "elZdmZQyABsjrVMdB67LFQNxNl5q9eHaGbWmk"
                    , balances = PL.Balances 
                        { available = Nothing
                        , current = Just $ PL.CurrentBalance 320.76
                        , iso_currency_code = Just $ IsoCurrencyCode "USD"
                        , limit = Nothing
                        , unofficial_currency_code = Nothing
                        }
                    , mask = Just $ PL.Mask "5555"
                    , name = PL.AccountName "Plaid IRA"
                    , official_name = Nothing
                    , subtype = Just $ AccountSubtype "ira"
                    , account_type = AccountType "investment"
                    }
                , PL.Account
                    { account_id = PL.AccountId "QwnE3ng7xLC57XEALbPzcREXENxDQLCGVgKDD"
                    , balances = PL.Balances 
                        { available = Nothing
                        , current = Just $ PL.CurrentBalance 23631.9805
                        , iso_currency_code = Just $ IsoCurrencyCode "USD"
                        , limit = Nothing
                        , unofficial_currency_code = Nothing
                        }
                    , mask = Just $ PL.Mask "6666"
                    , name = PL.AccountName "Plaid 401k"
                    , official_name = Nothing
                    , subtype = Just $ AccountSubtype "401k"
                    , account_type = AccountType "investment"
                    }
                , PL.Account
                    { account_id = PL.AccountId "ZX3vm3DpQnUKzVaAdrxLCqlml9zpyQsJBE7G1"
                    , balances = PL.Balances 
                        { available = Nothing
                        , current = Just $ PL.CurrentBalance 65262
                        , iso_currency_code = Just $ IsoCurrencyCode "USD"
                        , limit = Nothing
                        , unofficial_currency_code = Nothing
                        }
                    , mask = Just $ PL.Mask "7777"
                    , name = PL.AccountName "Plaid Student Loan"
                    , official_name = Nothing
                    , subtype = Just $ AccountSubtype "student"
                    , account_type = AccountType "loan"
                    }
                , PL.Account
                    { account_id = PL.AccountId "MvkpKkGRrQT57w4NAdg1cnbMb4p8eBC4rWQ1X"
                    , balances = PL.Balances 
                        { available = Just . PL.AvailableBalance $ -10000
                        , current = Just $ PL.CurrentBalance 56302.06
                        , iso_currency_code = Just $ IsoCurrencyCode "USD"
                        , limit = Nothing
                        , unofficial_currency_code = Nothing
                        }
                    , mask = Just $ PL.Mask "8888"
                    , name = PL.AccountName "Plaid Mortgage"
                    , official_name = Nothing
                    , subtype = Just $ AccountSubtype "mortgage"
                    , account_type = AccountType "loan"
                    }
                , PL.Account
                    { account_id = PL.AccountId "Lv8Lq8yQKeT5yGNMkapVcv3q3eKgWVie5xNEj"
                    , balances = PL.Balances 
                        { available = Just $ PL.AvailableBalance 12060
                        , current = Just $ PL.CurrentBalance 12060
                        , iso_currency_code = Just $ IsoCurrencyCode "USD"
                        , limit = Nothing
                        , unofficial_currency_code = Nothing
                        }
                    , mask = Just $ PL.Mask "9002"
                    , name = PL.AccountName "Plaid Cash Management"
                    , official_name = Just $ PL.OfficialName "Plaid Growth Cash Management"
                    , subtype = Just $ AccountSubtype "cash management"
                    , account_type = AccountType "depository"
                    }
                , PL.Account
                    { account_id = PL.AccountId "pNG1WGplKQTzG8M3K1Bli7vDvqVLo1SJdv5zM"
                    , balances = PL.Balances 
                        { available = Just $ PL.AvailableBalance 4980
                        , current = Just $ PL.CurrentBalance 5020
                        , iso_currency_code = Just $ IsoCurrencyCode "USD"
                        , limit = Nothing
                        , unofficial_currency_code = Nothing
                        }
                    , mask = Just $ PL.Mask "9999"
                    , name = PL.AccountName "Plaid Business Credit Card"
                    , official_name = Just $ PL.OfficialName "Plaid Platinum Small Business Credit Card"
                    , subtype = Just $ AccountSubtype "credit card"
                    , account_type = AccountType "credit"
                    }
                ]
            }
          expectedOutput = Right 
            [ SummaryByCurrency 
                { summaryByAccountTypes = 
                    [  SummaryByAccountType
                        { accountType = Credit
                        , total = ACC.AvailableBalance 6000
                        , summaryBySubtypes = 
                            [ SummaryBySubtype
                                { subtype = Subtype "credit card"
                                , total = ACC.AvailableBalance 6000
                                }
                            ]
                        }
                    , SummaryByAccountType
                        { accountType = Depository
                        , total = ACC.AvailableBalance 55560
                        , summaryBySubtypes = 
                            [ SummaryBySubtype
                                { subtype = Subtype "cash management"
                                , total = ACC.AvailableBalance 12060
                                }
                            , SummaryBySubtype
                                { subtype = Subtype "checking"
                                , total = ACC.AvailableBalance 100
                                }
                            , SummaryBySubtype
                                { subtype = Subtype "money market"
                                , total = ACC.AvailableBalance 43200
                                }
                            , SummaryBySubtype
                                { subtype = Subtype "savings"
                                , total = ACC.AvailableBalance 200
                                }
                            ]
                        }
                    , SummaryByAccountType
                        { accountType = Investment
                        , total = ACC.AvailableBalance 0
                        , summaryBySubtypes = 
                            [ SummaryBySubtype
                                { subtype = Subtype "401k"
                                , total = ACC.AvailableBalance 0
                                }
                            , SummaryBySubtype
                                { subtype = Subtype "ira"
                                , total = ACC.AvailableBalance 0
                                }
                            ]
                        }
                    , SummaryByAccountType
                        { accountType = Loan
                        , total = ACC.AvailableBalance $ -10000
                        , summaryBySubtypes = 
                            [ SummaryBySubtype
                                { subtype = Subtype "mortgage"
                                , total = ACC.AvailableBalance $ -10000
                                }
                            , SummaryBySubtype
                                { subtype = Subtype "student"
                                , total = ACC.AvailableBalance 0
                                }
                            ]
                        }
                    ]
                , currency = Iso "USD"
                , total = ACC.AvailableBalance 51560
                }
            ]
      in  TestAccountSummary {..}

testAccountSummaryPlaidErrorData :: [TestAccountSummaryPlaidError]
testAccountSummaryPlaidErrorData = 
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

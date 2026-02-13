let StoreConfig =
  { dbConnString : Text
  , dbConnPoolSize : Natural
  , dbSchema : Text
  }

let PlaidConfig =
  { endpoint : Text
  , clientId : Text
  , secretKey : Text
  }

let CreatePublicTokenConfig =
  { matchedErrorCode : Text
  , matchedErrorWords : List Text
  }

let PlaidLinkingConfig =
  { createPublicTokens : List CreatePublicTokenConfig
  }

let Config =
  { serverPort : Natural
  , store : StoreConfig
  , plaid : PlaidConfig
  , plaidLinking : PlaidLinkingConfig
  }

let config : Config =
  { serverPort = 8001
  , store = 
      { dbConnString = "host=localhost port=5432 user=haskell dbname=simple_financial_servant_db password=haskell"
      , dbConnPoolSize = 10
      , dbSchema = "simple_financial_servant"
      }
  , plaid = 
      { endpoint = "https://sandbox.plaid.com"
      , clientId = "CHANGEME"
      , secretKey = "CHANGEME"
      }
  , plaidLinking =
      { createPublicTokens = 
        [ { matchedErrorCode = "INVALID_PUBLIC_TOKEN"
          , matchedErrorWords = ["public token", "expired"]
          }
        ]
      }
  }

in config
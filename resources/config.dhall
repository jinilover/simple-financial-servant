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

let PlaidSecurityConfig =
  { createPublicTokens : List CreatePublicTokenConfig
  }

let Config =
  { serverPort : Natural
  , store : StoreConfig
  , plaid : PlaidConfig
  , plaidSecurity : PlaidSecurityConfig
  }

let config : Config =
  { serverPort = 8001
  , store = 
      { dbConnString = "host=localhost port=5432 user=haskell dbname=plaid_application_server_db password=haskell"
      , dbConnPoolSize = 10
      , dbSchema = "plaid_application_server"
      }
  , plaid = 
      { endpoint = "https://sandbox.plaid.com"
      , clientId = "CHANGEME"
      , secretKey = "CHANGEME"
      }
  , plaidSecurity =
      { createPublicTokens = 
        [ { matchedErrorCode = "INVALID_PUBLIC_TOKEN"
          , matchedErrorWords = ["public token", "expired"]
          }
        ]
      }
  }

in config
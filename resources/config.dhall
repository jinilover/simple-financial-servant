let DbConfig =
  { dbConnString : Text
  , dbConnPoolSize : Natural
  , dbSchema : Text
  }

let PlaidConfig =
  { endpoint : Text
  , clientId : Text
  , secretKey : Text
  }

let Config =
  { serverPort : Natural
  , db : DbConfig
  , plaid : PlaidConfig
  }

let config : Config =
  { serverPort = 8001
  , db = 
      { dbConnString = "host=localhost port=5432 user=haskell dbname=plaid_application_server_db password=haskell"
      , dbConnPoolSize = 10
      , dbSchema = "plaid_application_server"
      }
  , plaid = 
      { endpoint = "https://sandbox.plaid.com"
      , clientId = "CHANGEME"
      , secretKey = "CHANGEME"
      }
  }

in config
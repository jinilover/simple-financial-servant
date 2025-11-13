let DbConfig =
  { _configDbConnString : Text
  , _configDbConnPoolSize : Natural
  , _configDbSchema : Text
  }

let dbConfig : DbConfig =
  { _configDbConnString = "host=localhost port=5432 user=haskell dbname=plaid_application_server_db password=haskell"
  , _configDbConnPoolSize = 10
  , _configDbSchema = "plaid_application_server"
  }

in dbConfig
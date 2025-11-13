let DbConnString = Text
let DbConnPoolSize = Integer
let DbSchema = Text

let DbConfig : Type =
      { _configDbConnString : DbConnString
      , _configDbConnPoolSize : DbConnPoolSize
      , _configDbSchema : DbSchema
      }

in { _configDbConnString = "host=localhost port=5432 user=haskell dbname=plaid_application_server_db password=haskell"
   , _configDbConnPoolSize = +10
   , _configDbSchema = "plaid_application_server"
   } : DbConfig
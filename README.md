# Simple Financial Servant

A simple REST-based financial service integrates with the Plaid API to provide bank account linking and financial data aggregation.  It is built with Servant, Persistent, Katip, Dhall, classy lens and mtl.


## Architecture Highlights

The codebase follows a **layered architecture** with clear separation of concerns:

- **API Layer** (`Account.Api`, `PlaidLinking.Api`): Defines type-safe REST endpoints by using Servant's type-level DSL with proper error handling
- **Service Layer** (`AccountService`, `TokenService`): Business logic encapsulated in testable service data types 
- **Data Layer** (`AccessTokenStore`, `Store`): Database abstractions using Persistent with PostgreSQL, connection pooling, and schema migrations
- **Integration layer** (`Client`): Uses Servant's type-level DSL to query the Plaid API
- Katip is used across different layers for structured logging
- Mtl (and classy lens if applicable) is used on each layer to keep it polymorphic, with the concrete monad is defined at the bootstrap level.

### Effect Management

The application uses a monad stack (`ReaderT AppEnv (KatipContextT (ExceptT ServerError IO))`) to manage:
- **Environment passing** via `ReaderT` pattern with classy lens instances
- **Structured logging** with Katip's context propagation and namespacing
- **Error handling** with `Either` types and Servant's `ServerError` conversion
- **Resource management** using `bracket` for proper cleanup of database pools and katip log scribes

### Type Safety & Validation

- **Refinement types** (`refined`) for compile-time validation of positive integers, non-empty strings, and URLs
- **Validation library** for accumulating validation errors with `NonEmpty` error lists
- **Newtype wrappers** for domain types (`UserId`, `ItemId`, `AccountId`) preventing type confusion
- **Type-level API definitions** in Servant ensuring compile-time route safety

### Testing

- **Testable architecture** each layer is kept polymorphic using mtl and classy lens, test monads and stubbing dependencies are easily swapped in for testing
- **Property-based testing** with Hedgehog covering service logic and error cases
- **Comprehensive test data** generators for UUIDs and domain types

### Configuration Management

- **Dhall** for type-safe, version-controlled configuration
- **Validation pipeline** converting Dhall config to validated application config with detailed error messages
- **Classy lens** for accessing nested configuration throughout the application

## API Documentation

The service exposes a REST API under the `/v1` prefix with the following endpoints:

### Exchange Public Token

**Endpoint:** `GET /v1/token/exchange/{user_id}/{public_token}`

Exchanges a Plaid public token for an access token and stores it for the user.

**Path Parameters:**
- `user_id` (UUID): The unique identifier for the user
- `public_token` (Text): The Plaid public token to exchange

**Response:** `200 OK` with JSON body:
```json
{
  "itemId": "string"
}
```

**Error Responses:**
- `422 Unprocessable Entity`: Plaid API error (includes error details in response body)
- `500 Internal Server Error`: Communication or deserialization errors

### Get Account Summary

**Endpoint:** `GET /v1/accounts/summary/{user_id}`

Retrieves a summary of all accounts for a user, grouped by currency, account type, and subtype.

**Path Parameters:**
- `user_id` (UUID): The unique identifier for the user

**Response:** `200 OK` with JSON body:
```json
{
  "summaryByCurrencies": [
    {
      "currency": "USD",
      "total": 1234.56,
      "summaryByAccountTypes": [
        {
          "accountType": "depository",
          "total": 1234.56,
          "summaryBySubtypes": [
            {
              "subtype": "checking",
              "total": 1234.56
            }
          ]
        }
      ]
    }
  ],
  "accounts": [...]
}
```

**Error Responses:**
- `400 Bad Request`: Access token not found for the user
- `422 Unprocessable Entity`: Invalid account data from Plaid (includes validation errors)
- `500 Internal Server Error`: Plaid API communication errors

## Run tests
```bash
nix develop --command cabal test lib-test
```

## Build & Run

### `cabal run` application in the nix shell
Create the db inside the nix shell by `nix develop`.
```bash
# To check if postgres pkg installed
which psql
psql --version
pg_ctl --version
pg_isready --version

# Start a local Postgres
initdb -D ./pgdata
pg_ctl -D ./pgdata -o "-p 5432" -l ./pg.log start
pg_isready -h localhost -p 5432

# Create a role and DB 
createuser haskell --pwprompt
createdb simple_servant_app_db -O haskell

# To check the created DB
psql -U haskell -d simple_servant_app_db
```

Make sure `clientId`, `secretKey` in `config.dhall` are changed to correct values.
```bash
# Run the service inside the nix shell
cabal run simple-financial-servant
```

### Build application outside the nix shell
Besides `cabal run` inside the nix shell, application can be built by
```bash
nix build
```
Executable `simple-financial-servant` is built under created `result/bin`, a symbolic link to `/nix/store` subfolder.


## Technical note of the Haskell-specific knowledge
### Record "field" names conflict
The record field names are indeed function names.  Therefore "field" names conflict happen often.  `NoFieldSelectors` and `OverloadedRecordDot` are used to avoid the conflicts and enable cleaner record access.  It should be aware that when they are enabled, spaces must be inserted around the dot for function or lens composition.
e.g.
```
f = undefined :: Int -> String
g = undefined :: String -> Char
```
`g.f` is allowed.  After `OverloadedRecordDot` is enabled, GHC treats `f` is a field of record `g`, composition should be written as `g . f`

## Single-column primary key in Persistent
When the primary key in Persistent is a single column (e.g., `Primary userUuid`), Persistent requires `ToHttpApiData` and `PathPiece` instances for that type, even though these are web framework concerns.  If it's a composite key, such type class instances will not be required.

Example:
```haskell
-- Single-column key requires web instances
AccessTokenData
  userUuid UserId
  Primary userUuid  -- Key AccessTokenData = UserId (needs ToHttpApiData, PathPiece)

-- Composite key doesn't require web instances  
AccessTokenData
  userUuid UserId
  itemId ItemId
  Primary userUuid itemId  -- Key AccessTokenData = (UserId, ItemId) (no web instances needed)
```

The possible reason is Persistent is designed for the convenience for web apps at the cost of mixing persistence and web framework concerns.  Having said that, Persistent is usable as a standalone library.  The fix is adding `ToHttpApiData` and `PathPiece` instances to types used as single-column primary keys.

## Things to improve
There are many interesting functionalities to be added.  Personally I think the important improvement to be made are
* Using environment variables in the dhall file, e.g. values of `clientId` and `secretKey`
* At the moment, db schema migration is done by Persistent's automatic database migrations.  This can be only used for prototyping.  A proper db migration, like flyway, should be used.
* Encryption of sensitive data in db storage.

## Reference
* https://docs.servant.dev/en/latest/tutorial/index.html
* https://hackage-content.haskell.org/package/katip-0.8.8.4/docs/Katip.html
* Classy 😎 https://gist.github.com/andrevdm/b6fd3b3d2c482bd5d5fb767c4eeae644
* https://dhall-lang.org/
* https://www.yesodweb.com/book/persistent, https://dev.to/zelenya/how-to-use-postgresql-with-haskell-persistent-esqueleto-4n6i
* https://plaid.com/docs/

# plaid-application-server

## Persistent Quirk: Web Framework Instances for Single-Column Primary Keys

When using a single-column primary key in Persistent (e.g., `Primary userUuid`), the `Key` type becomes that column's type directly. Persistent then requires `ToHttpApiData` and `PathPiece` instances for that type, even though these are web framework concerns.

**Why this happens:**
- Single-column keys: `Key Entity` = the column type (e.g., `UserId`)
- Composite keys: `Key Entity` = tuple type (e.g., `(UserId, ItemId)`)
- Persistent assumes web app usage and requires serialization instances for single-column keys

**Example:**
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

**The Fix:**
Add `ToHttpApiData` and `PathPiece` instances to types used as single-column primary keys. See `src/lib/Common/Types/UserId.hs` for an example.

This is a known design trade-off in Persistent: convenience for web apps at the cost of mixing persistence and web framework concerns.
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE DataKinds #-}
module PlaidSecurity.AccessTokenStore where

import Control.Monad.Reader
import Data.Functor
import Database.Persist
import Database.Persist.TH

import Common.Types
import PlaidSecurity.Types
import Store.Types
import Store.Utils

share [mkPersist sqlSettings, mkMigrate "migrateAccessToken"] [persistLowerCase|
AccessTokenData
  userUuid UserId
  itemId ItemId
  accessToken AccessToken
  createdAt CreatedAt
  updatedAt UpdatedAt
  Primary userUuid
  deriving Show
|]

data AccessTokenStore m = AccessTokenStore
  { saveAccessTokenData :: AccessTokenData -> m (Key AccessTokenData)
  , fetchAccessTokenData :: Key AccessTokenData -> m (Maybe AccessTokenData)
  }

mkAccessTokenStore ::
  (MonadIO m, MonadReader r m, HasStoreDbPoolEnv r) =>
  AccessTokenStore m
mkAccessTokenStore = AccessTokenStore 
  { saveAccessTokenData = \accessTokenData -> runQueryWithPool $
      upsert accessTokenData
      [ AccessTokenDataItemId =. accessTokenData.accessTokenDataItemId
      , AccessTokenDataAccessToken =. accessTokenData.accessTokenDataAccessToken
      , AccessTokenDataUpdatedAt =. accessTokenData.accessTokenDataUpdatedAt
      ] 
      <&> \(Entity key _) -> key

  , fetchAccessTokenData = runQueryWithPool . get
  }

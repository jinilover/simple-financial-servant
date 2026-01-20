{-# LANGUAGE DeriveAnyClass #-}
module DhallConfig where

import Control.Monad.IO.Class
import Data.String.Conv
import Dhall

loadDhallConfig :: MonadIO m => FilePath -> m DhallConfig
loadDhallConfig = liftIO . input auto . toS

data DhallPlaidConfig = DhallPlaidConfig
  { endpoint :: Text
  , clientId :: Text
  , secretKey :: Text
  }
  deriving (Show, Generic, FromDhall)

data DhallStoreConfig = DhallStoreConfig
  { dbConnString :: Text
  , dbConnPoolSize :: Natural
  , dbSchema :: Text
  }
  deriving (Show, Generic, FromDhall)

data DhallCreatePublicTokenConfig = DhallCreatePublicTokenConfig
  { matchedErrorCode :: Text
  , matchedErrorWords :: [Text]
  } 
  deriving (Show, Generic, FromDhall)

data DhallPlaidSecurityConfig = DhallPlaidSecurityConfig
  { createPublicTokens :: [DhallCreatePublicTokenConfig]
  } 
  deriving (Show, Generic, FromDhall)

data DhallConfig = DhallConfig
  { serverPort :: Natural
  , store :: DhallStoreConfig
  , plaid :: DhallPlaidConfig
  , plaidSecurity :: DhallPlaidSecurityConfig
  }
  deriving (Show, Generic, FromDhall)
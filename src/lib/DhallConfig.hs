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

data DhallDbConfig = DhallDbConfig
  { dbConnString :: Text
  , dbConnPoolSize :: Natural
  , dbSchema :: Text
  }
  deriving (Show, Generic, FromDhall)

data DhallConfig = DhallConfig
  { serverPort :: Natural
  , db :: DhallDbConfig
  , plaid :: DhallPlaidConfig
  }
  deriving (Show, Generic, FromDhall)
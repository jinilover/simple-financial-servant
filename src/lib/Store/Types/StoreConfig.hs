{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DerivingVia #-}
module Store.Types.StoreConfig where

import Control.Lens
import Data.ByteString
import Data.Text

import Common.Types

newtype DbConnPoolSize = DbConnPoolSize
  { unDbConnPoolSize :: PosInt }
  deriving Show via PosInt
makeClassy ''DbConnPoolSize

newtype DbConnString = DbConnString
  { unDbConnString :: ByteString }
  deriving Show via ByteString
makeClassy ''DbConnString

newtype DbSchema = DbSchema
  { unDbSchema :: Text }
  deriving Show via Text
makeClassy ''DbSchema

data StoreConfig = StoreConfig 
  { _configDbConnString :: DbConnString
  , _configDbConnPoolSize :: DbConnPoolSize
  , _configDbSchema :: DbSchema
  }
  deriving Show
makeClassy ''StoreConfig

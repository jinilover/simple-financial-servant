{-# LANGUAGE TemplateHaskell #-}
module Store.Types.DbConfig where

import Control.Lens
import Data.ByteString
import Data.Text

import Common.Types

newtype DbConnPoolSize = DbConnPoolSize
  { unDbConnPoolSize :: PosInt }
  deriving Show
makeClassy ''DbConnPoolSize

newtype DbConnString = DbConnString
  { unDbConnString :: ByteString }
  deriving Show
makeClassy ''DbConnString

newtype DbSchema = DbSchema
  { unDbSchema :: Text }
  deriving Show
makeClassy ''DbSchema

data DbConfig = DbConfig 
  { _configDbConnString :: DbConnString
  , _configDbConnPoolSize :: DbConnPoolSize
  , _configDbSchema :: DbSchema
  }
  deriving Show
makeClassy ''DbConfig

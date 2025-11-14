{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingVia #-}
{-# LANGUAGE TemplateHaskell #-}
module Store.Types.DbConfig where

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

data DbConfig = DbConfig 
  { _configDbConnString :: DbConnString
  , _configDbConnPoolSize :: DbConnPoolSize
  , _configDbSchema :: DbSchema
  }
  deriving Show
makeClassy ''DbConfig

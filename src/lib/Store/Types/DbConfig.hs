{-# LANGUAGE TemplateHaskell #-}
module Store.Types.DbConfig where

import Control.Lens
import Data.ByteString
import Data.Text
import Dhall

import Common.Types

newtype DbConnPoolSize = DbConnPoolSize
  { unDbConnPoolSize :: PosInt }
makeClassy ''DbConnPoolSize

newtype DbConnString = DbConnString
  { unDbConnString :: ByteString }
  deriving FromDhall
makeClassy ''DbConnString

newtype DbSchema = DbSchema
  { unDbSchema :: Text }
  deriving FromDhall
makeClassy ''DbSchema

data DbConfig = DbConfig {
  _configDbConnString :: DbConnString
, _configDbConnPoolSize :: DbConnPoolSize
, _configDbSchema :: DbSchema
}
makeClassy ''DbConfig

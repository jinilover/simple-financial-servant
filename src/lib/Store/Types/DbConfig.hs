{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingVia #-}
{-# LANGUAGE TemplateHaskell #-}
module Store.Types.DbConfig where

import Control.Lens
import Data.ByteString
import Data.Text
import Data.Text.Encoding
import Dhall

import Common.Types

newtype DbConnPoolSize = DbConnPoolSize
  { unDbConnPoolSize :: PosInt }
  deriving (Show, FromDhall) via PosInt
makeClassy ''DbConnPoolSize

newtype DbConnString = DbConnString
  { unDbConnString :: ByteString }
  deriving Show via ByteString
makeClassy ''DbConnString

instance FromDhall DbConnString where
  autoWith _ = auto @Text <&> DbConnString . encodeUtf8

newtype DbSchema = DbSchema
  { unDbSchema :: Text }
  deriving (Show, FromDhall) via Text
makeClassy ''DbSchema

data DbConfig = DbConfig 
  { _configDbConnString :: DbConnString
  , _configDbConnPoolSize :: DbConnPoolSize
  , _configDbSchema :: DbSchema
  }
  deriving (Show, Generic, FromDhall)
makeClassy ''DbConfig

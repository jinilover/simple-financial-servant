{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingStrategies #-}
module AppConfig 
  ( loadAppConfig
  , AppConfig(..)
  , HasAppConfig(..)
  , ServerPort(..)
  , HasServerPort(..)
  )where

import Control.Lens
import Control.Monad.Catch
import Control.Monad.IO.Class
import Data.Bifunctor
import Data.Validation
import Data.List.NonEmpty hiding (nonEmpty)
import Data.String.Conv
import qualified Data.Text as T
import Dhall 
import Refined hiding (NonEmpty)
import Servant.Client

import Common.Types
import DhallConfig
import Paths_plaid_application_server ( getDataFileName )
import Plaid.Types ( PlaidConfig(..), Endpoint (..))
import PlaidSecurity.Types
import Store.Types

newtype ConfigException = ConfigException Text
  deriving Show
  deriving anyclass Exception

newtype ServerPort = ServerPort
  { unServerPort :: PosInt }
  deriving Show
makeClassy ''ServerPort

data AppConfig = AppConfig 
  { _configServerPort :: ServerPort
  , _configDb :: DbConfig
  , _configPlaid :: PlaidConfig
  }
  deriving Show
makeClassy ''AppConfig

loadAppConfig :: (MonadIO m, MonadCatch m) => m AppConfig
loadAppConfig = 
  do 
    filePath <- liftIO (getDataFileName "config.dhall")
    dhallConfig <- loadDhallConfig filePath
    validation (throwM . ConfigException . T.intercalate "\n" . toList) pure $ validateDhallConfig dhallConfig

validateDhallConfig :: DhallConfig -> Validation (NonEmpty Text) AppConfig
validateDhallConfig (DhallConfig port db plaid) = 
    AppConfig
      <$> fmap ServerPort (positive "serverPort" port)
      <*> validateDhallDbConfig db
      <*> validateDhallPlaidConfig plaid
  where
    validateDhallPlaidConfig :: DhallPlaidConfig -> Validation (NonEmpty Text) PlaidConfig
    validateDhallPlaidConfig DhallPlaidConfig {..} = 
      PlaidConfig
        <$> fmap Endpoint (validateUrl endpoint)
        <*> fmap ClientId (nonEmpty "clientId" clientId)
        <*> fmap SecretKey (nonEmpty "secretKey" secretKey)

    validateDhallDbConfig :: DhallDbConfig -> Validation (NonEmpty Text) DbConfig
    validateDhallDbConfig (DhallDbConfig connStr poolSize schema) = 
      DbConfig 
        <$> fmap DbConnString (nonEmpty "dbConnString" connStr)
        <*> fmap DbConnPoolSize (positive "dbConnPoolSize" poolSize)
        <*> fmap DbSchema (nonEmpty "dbSchema" schema)

    validateUrl :: Text -> Validation (NonEmpty Text) BaseUrl
    validateUrl txt = fromEither . first (const . singleton $ txt <> " is invalid url") . parseBaseUrl . toS $ txt

    nonEmpty :: StringConv Text a => Text -> Text -> Validation (NonEmpty Text) a
    nonEmpty name txt = if T.null txt 
      then Failure . singleton $ name <> " is empty"
      else Success $ toS txt

    positive :: Text -> Natural -> Validation (NonEmpty Text) PosInt
    positive name n = case refine @Positive (fromIntegral n) of
      Left _ -> Failure . singleton $ name <> ": " <> toS (show n) <> " is not positive"
      Right r -> Success $ PosInt r 

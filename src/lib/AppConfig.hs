{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingVia #-}
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
import PlaidLinking.Types
import Store.Types

newtype ConfigException = ConfigException Text
  deriving Show
  deriving anyclass Exception

newtype ServerPort = ServerPort
  { unServerPort :: PosInt }
  deriving Show via PosInt
makeClassy ''ServerPort

data AppConfig = AppConfig 
  { _configServerPort :: ServerPort
  , _configStore :: StoreConfig
  , _configPlaid :: PlaidConfig
  , _configPlaidLinking :: PlaidLinkingConfig
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
validateDhallConfig (DhallConfig port store plaid plaidLinking) = 
    AppConfig
      <$> fmap ServerPort (positive "serverPort" port)
      <*> validateDhallStore store
      <*> validateDhallPlaid plaid
      <*> validateDhallPlaidLinking plaidLinking
  where
    validateDhallPlaidLinking :: DhallPlaidLinkingConfig -> Validation (NonEmpty Text) PlaidLinkingConfig
    validateDhallPlaidLinking DhallPlaidLinkingConfig {..} = 
      PlaidLinkingConfig <$> traverse validateDhallCreatePublicToken createPublicTokens

    validateDhallCreatePublicToken :: DhallCreatePublicTokenConfig -> Validation (NonEmpty Text) CreatePublicTokenConfig
    validateDhallCreatePublicToken DhallCreatePublicTokenConfig {..} = 
      CreatePublicTokenConfig
        <$> fmap MatchedErrorCode (nonEmpty "matchedErrorCode" matchedErrorCode)
        <*> traverse (fmap MatchedErrorWord . nonEmpty "matchErrorWords") matchedErrorWords

    validateDhallPlaid :: DhallPlaidConfig -> Validation (NonEmpty Text) PlaidConfig
    validateDhallPlaid DhallPlaidConfig {..} = 
      PlaidConfig
        <$> fmap Endpoint (validateUrl endpoint)
        <*> fmap ClientId (nonEmpty "clientId" clientId)
        <*> fmap SecretKey (nonEmpty "secretKey" secretKey)

    validateDhallStore :: DhallStoreConfig -> Validation (NonEmpty Text) StoreConfig
    validateDhallStore (DhallStoreConfig connStr poolSize schema) = 
      StoreConfig 
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

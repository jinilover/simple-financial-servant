{-# LANGUAGE DerivingVia #-}
{-# LANGUAGE TemplateHaskell #-}
module PlaidSecurity.Types.PlaidSecurityConfig where

import Control.Lens
import Data.Text

newtype MatchedErrorCode = MatchedErrorCode
  { unMatchedErrorCode :: Text }
  deriving Show via Text

newtype MatchedErrorWord = MatchedErrorWord
  { unMatchedErrorWord :: Text }
  deriving Show via Text

data CreatePublicTokenConfig = CreatePublicTokenConfig
  { _configMatchedErrorCode :: MatchedErrorCode
  , _configMatchedErrorWords :: [MatchedErrorWord]
  } 
  deriving Show

data PlaidSecurityConfig = PlaidSecurityConfig
  { _configCreatePublicTokens :: [CreatePublicTokenConfig]
  }
  deriving Show
makeClassy ''PlaidSecurityConfig
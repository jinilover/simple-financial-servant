{-# LANGUAGE DerivingVia #-}
{-# LANGUAGE TemplateHaskell #-}
module PlaidLinking.Types.PlaidLinkingConfig where

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

data PlaidLinkingConfig = PlaidLinkingConfig
  { _configCreatePublicTokens :: [CreatePublicTokenConfig]
  }
  deriving Show
makeClassy ''PlaidLinkingConfig
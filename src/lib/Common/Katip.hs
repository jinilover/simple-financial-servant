module Common.Katip where

import Common.Types

import Katip

addUserIdToContext :: 
  KatipContext m =>
  UserId -> m a -> m a
addUserIdToContext = katipAddContext . sl "user_id"
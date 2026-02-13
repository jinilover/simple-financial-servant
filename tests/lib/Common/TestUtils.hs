module Common.TestUtils where

import Control.Monad.IO.Class
import Katip

shouldNotBeCalled :: a
shouldNotBeCalled = error "not required in this test"

withKatipContext :: MonadIO m => KatipContextT m a -> m a
withKatipContext ma = 
  do
    logEnv <- liftIO $ initLogEnv "simple-financial-servant" "unit-tests"
    runKatipContextT logEnv () "test" ma
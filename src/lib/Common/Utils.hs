module Common.Utils where

import Data.Functor
import Data.Aeson

pureRight :: Applicative f => a -> f (Either e a)
pureRight = pure . Right

pureLeft :: Applicative f => e -> f (Either e a)
pureLeft = pure . Left

tap :: Monad m => (a -> m b) -> m a -> m a
tap f = (>>= \a -> f a $> a)

stringToJson :: String -> Value
stringToJson = toJSON
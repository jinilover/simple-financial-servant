module Common.Utils where

pureRight :: Applicative f => a -> f (Either e a)
pureRight = pure . Right

pureLeft :: Applicative f => e -> f (Either e a)
pureLeft = pure . Left
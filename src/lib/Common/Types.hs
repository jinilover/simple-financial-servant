module Common.Types where

-- import Data.Bifunctor
import Data.Either.Validation
import Data.List.NonEmpty
import qualified Data.Text as T
import Dhall
import Refined

-- type PosInt = Refined Positive Int

newtype PosInt = PosInt 
  { unPosInt :: Refined Positive Int }

instance FromDhall PosInt where
  autoWith _ = Decoder
    { expected = expected integer
    , extract = \expr -> 
        case extract integer expr of 
          Failure errs -> Failure errs
          Success n -> 
            case refine @Positive (fromIntegral n) of
              Left err -> (Failure . DhallErrors . singleton . ExtractError) ("expected a positive integer: " <> T.pack (show err))
              Right r -> Success $ PosInt r
    }


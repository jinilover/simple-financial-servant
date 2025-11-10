module PlaidSecurity.TokenService 
  ( TokenService(..) 
  , mkTokenService
  )
where

import Data.Bifunctor
import Data.Functor
import qualified Data.Text as T
  
import Plaid.Client
import qualified Plaid.Types as PL
import PlaidSecurity.Types 

newtype TokenService m = TokenService 
  { exchangeToken :: PublicToken -> m (Either TokenServiceError TokenExchangeResponse) 
  }

mkTokenService :: 
  Functor m =>
  PlaidClient m ->
  TokenService m 
mkTokenService plaidClient = 
  TokenService
  { exchangeToken = \publicToken -> 
      plaidClient.exchangeAccessToken (PL.fromPSPublicToken publicToken) <&>
        bimap (TokenServiceError . mapClientError) fromExchangeAccessTokenResponse
  }

mapClientError :: PL.PlaidError -> PlaidApiError
mapClientError PL.DeserializationError {..} = 
  PlaidApiError $ T.append when_ errorMsg
mapClientError PL.HttpError {..} =
  PlaidApiError $ T.append when_ errorMsg
mapClientError PL.NetworkError {..} =
  PlaidApiError $ T.append when_ errorMsg

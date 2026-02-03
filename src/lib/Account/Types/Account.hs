{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingStrategies #-}
module Account.Types.Account where

import Data.Aeson
import Data.Functor
import Data.List.NonEmpty
import Data.Text hiding (singleton, elem)
import Data.Validation as V
import GHC.Generics

import qualified Plaid.Types as PL

data Account = Account 
  { accountId :: AccountId
  , balances :: Balances
  , maybeMask :: Maybe Mask
  , name :: AccountName
  , maybeOfficialName :: Maybe OfficialName
  , accountType :: AccountType
  , subtype :: Subtype
  }
  deriving (Generic, Show, ToJSON)

newtype AccountId = AccountId
  { unAccountId :: Text }
  deriving Show
  deriving newtype ToJSON

newtype Mask = Mask
  { unMask :: Text }
  deriving Show
  deriving newtype ToJSON

newtype AccountName = AccountName
  { unAccountName :: Text }
  deriving Show
  deriving newtype ToJSON

newtype OfficialName = OfficialName
  { unOfficialName :: Text }
  deriving Show
  deriving newtype ToJSON

data AccountType =
    Depository
  | Credit
  | Loan
  | Investment
  | Payroll
  | OtherType
  deriving (Generic, Show, Eq, Ord, ToJSON)

newtype Subtype = Subtype
  { unSubtype :: Text }
  deriving Show
  deriving newtype (Eq, Ord, ToJSON)

data Balances = Balances 
  { maybeAvailable :: Maybe AvailableBalance
  , maybeCurrent :: Maybe CurrentBalance
  , currencyCode :: CurrencyCode
  }
  deriving (Generic, Show, ToJSON)

newtype AvailableBalance = AvailableBalance
  { unAvailableBalance :: Double }
  deriving Show
  deriving newtype ToJSON

newtype CurrentBalance = CurrentBalance
  { unCurrentBalance :: Double }
  deriving Show
  deriving newtype ToJSON

data CurrencyCode = 
    Iso Text
  | Unofficial UnofficialCode
  deriving (Show, Eq, Ord)

instance ToJSON CurrencyCode where
  toJSON (Iso text) = toJSON text
  toJSON (Unofficial unofficialCode) = toJSON unofficialCode

data UnofficialCode = 
    ADA
  | BAT
  | BCH
  | BNB
  | BTC
  | BTG
  | BSV
  | CNH
  | DASH
  | DOGE
  | ETC
  | ETH
  | GBX
  | LSK
  | NEO
  | OMG
  | QTUM
  | USDT
  | XLM
  | XMR
  | XRP
  | ZEC
  | ZRX
  deriving (Eq, Ord, Show, Generic)

instance ToJSON UnofficialCode where
  toJSON = genericToJSON defaultOptions

validatePLAccount :: PL.Account -> Validation (NonEmpty Text) Account
validatePLAccount plAccount = 
  (Account (fromPLAccountId plAccount.account_id)
    <$> validateBalances plAccount.balances
    <*> pure (fromPLMask plAccount.mask)
    <*> pure (fromName plAccount.name)
    <*> pure (fromOfficialName plAccount.official_name)
    <&> uncurry)
    <*> validateAccountSubtypes plAccount.account_type plAccount.subtype
  where
    validateBalances :: PL.Balances -> Validation (NonEmpty Text) Balances
    validateBalances balances = 
      uncurry Balances
        <$> validateAvailableCurrent balances.available balances.current
        <*> validateCurrencyCode balances.iso_currency_code balances.unofficial_currency_code

    validateAvailableCurrent :: Maybe PL.AvailableBalance -> Maybe PL.CurrentBalance -> Validation (NonEmpty Text) (Maybe AvailableBalance, Maybe CurrentBalance)
    validateAvailableCurrent Nothing Nothing = V.Failure $ singleton "Both available and current are empty"
    validateAvailableCurrent maybeAvailable maybeCurrent = V.Success (fromPLAvailableBalance <$> maybeAvailable, fromPLCurrentBalance <$> maybeCurrent)

    fromPLAvailableBalance = AvailableBalance . (.unAvailableBalance)

    fromPLCurrentBalance = CurrentBalance . (.unCurrentBalance)

    validateCurrencyCode :: Maybe PL.IsoCurrencyCode -> Maybe PL.UnofficialCurrencyCode -> Validation (NonEmpty Text) CurrencyCode
    validateCurrencyCode maybeIsoCurrCode maybeUnofficialCurrCode = 
      case ((.unIsoCurrencyCode) <$> maybeIsoCurrCode, (.unUnofficialCurrencyCode) <$> maybeUnofficialCurrCode) of
        (Just _, Just _) -> V.Failure $ singleton "Both iso_currency_code and unofficial_currency_code have value"
        (Nothing, Nothing) -> V.Failure $ singleton "Both iso_currency_code and unofficial_currency_code are empty"
        (Just text, _) -> V.Success $ Iso text
        (_, Just unofficialText) -> Unofficial <$> validateUnofficialCode unofficialText

    validateUnofficialCode :: Text -> Validation (NonEmpty Text) UnofficialCode
    validateUnofficialCode "ADA" = V.Success ADA
    validateUnofficialCode "BAT" = V.Success BAT
    validateUnofficialCode "BCH" = V.Success BCH
    validateUnofficialCode "BNB" = V.Success BNB
    validateUnofficialCode "BTC" = V.Success BTC
    validateUnofficialCode "BTG" = V.Success BTG
    validateUnofficialCode "BSV" = V.Success BSV
    validateUnofficialCode "CNH" = V.Success CNH
    validateUnofficialCode "DASH" = V.Success DASH
    validateUnofficialCode "DOGE" = V.Success DOGE
    validateUnofficialCode "ETC" = V.Success ETC
    validateUnofficialCode "ETH" = V.Success ETH
    validateUnofficialCode "GBX" = V.Success GBX
    validateUnofficialCode "LSK" = V.Success LSK
    validateUnofficialCode "NEO" = V.Success NEO
    validateUnofficialCode "OMG" = V.Success OMG
    validateUnofficialCode "QTUM" = V.Success QTUM
    validateUnofficialCode "USDT" = V.Success USDT
    validateUnofficialCode "XLM" = V.Success XLM
    validateUnofficialCode "XMR" = V.Success XMR
    validateUnofficialCode "XRP" = V.Success XRP
    validateUnofficialCode "ZEC" = V.Success ZEC
    validateUnofficialCode "ZRX" = V.Success ZRX
    validateUnofficialCode t = V.Failure . singleton $ "Unknown unofficial currency code: " <> t

    fromPLAccountId = AccountId . (.unAccountId)

    fromPLMask = fmap (Mask . (.unMask))

    fromName = AccountName . (.unAccountName)

    fromOfficialName = fmap (OfficialName . (.unOfficialName))

    validateAccountSubtypes :: PL.AccountType -> Maybe PL.AccountSubtype -> Validation (NonEmpty Text) (AccountType, Subtype)
    validateAccountSubtypes accountType maybeSubtype = 
      case (accountType.unAccountType, (.unAccountSubtype) <$> maybeSubtype ) of 
        ("depository", Just subtype) -> (Depository, ) <$> validateDepositoryType subtype
        ("depository", Nothing) -> V.Failure $ singleton "\"depository\" account type requires subtype"
        ("credit", Just subtype) -> (Credit, ) <$> validateCreditType subtype
        ("credit", Nothing) -> V.Failure $ singleton "\"credit\" account type requires subtype"
        ("loan", Just subtype) -> (Loan, ) <$> validateLoanType subtype
        ("loan", Nothing) -> V.Failure $ singleton "\"loan\" account type requires subtype"
        ("investment", Just subtype) -> (Investment, ) <$> validateInvestmentType subtype
        ("investment", Nothing) -> V.Failure $ singleton "\"investment\" account type requires subtype"
        ("payroll", Just subtype) -> (Payroll, ) <$> validatePayrollType subtype
        ("payroll", Nothing) -> V.Failure $ singleton "\"payroll\" account type requires subtype"
        ("other", Nothing) -> V.Success (OtherType, Subtype "Other or unknown account type")
        ("other", _) -> V.Failure $ singleton "\"other\" account type has subtype value"
        (unknownType, _) -> V.Failure . singleton $ "Unknown account type: " <> unknownType

    validateDepositoryType :: Text -> Validation (NonEmpty Text) Subtype
    validateDepositoryType = 
      let validTypes = 
            [ "checking"
            , "savings"
            , "cd"
            , "money market"
            , "paypal"
            , "prepaid"
            , "hsa"
            , "cash management"
            ]
      in  validateSubtype "depository" validTypes

    validateCreditType :: Text -> Validation (NonEmpty Text) Subtype
    validateCreditType =
      let validTypes = 
            [ "credit card"
            , "paypal"
            ]
      in  validateSubtype "credit" validTypes

    validateLoanType :: Text -> Validation (NonEmpty Text) Subtype
    validateLoanType =
      let validTypes = 
            [ "auto"
            , "business"
            , "commercial"
            , "construction"
            , "consumer"
            , "home equity"
            , "line of credit"
            , "loan"
            , "mortgage"
            , "other"
            , "overdraft"
            , "student"
            ]
      in  validateSubtype "loan" validTypes

    validateInvestmentType :: Text -> Validation (NonEmpty Text) Subtype
    validateInvestmentType =
      let validTypes = 
            [ "529"
            , "401a"
            , "401k"
            , "403b"
            , "457b"
            , "brokerage"
            , "cash isa"
            , "crypto exchange"
            , "education savings account"
            , "fixed annuity"
            , "gic"
            , "health reimbursement arrangement"
            , "hsa"
            , "ira"
            , "isa"
            , "keogh"
            , "lif"
            , "life insurance"
            , "lira"
            , "lrif"
            , "lrsp"
            , "mutual fund"
            , "non-custodial wallet"
            , "non-taxable brokerage account"
            , "other"
            , "other annuity"
            , "other insurance"
            , "pension"
            , "prif"
            , "profit sharing plan"
            , "qshr"
            , "rdsp"
            , "resp"
            , "retirement"
            , "rlif"
            , "roth"
            , "roth 401k"
            , "rrif"
            , "rrsp"
            , "sarsep"
            , "sep ira"
            , "simple ira"
            , "sipp"
            , "stock plan"
            , "tfsa"
            , "thrift savings plan"
            , "trust"
            , "ugma"
            , "utma"
            , "variable annuity"
            ]
      in  validateSubtype "investment" validTypes

    validatePayrollType :: Text -> Validation (NonEmpty Text) Subtype
    validatePayrollType =
      let validTypes = 
            [ "payroll"
            ]
      in  validateSubtype "payroll" validTypes

    validateSubtype :: Text -> [Text] -> Text -> Validation (NonEmpty Text) Subtype
    validateSubtype subtypeName validSubtypes t = 
      if t `elem` validSubtypes
        then V.Success $ Subtype t
        else V.Failure . singleton $ "Unknown " <> subtypeName <> " subtype: " <> t
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingStrategies #-}
module Account.Types.Account where

import Data.Aeson
import Data.List.NonEmpty
import Data.Text hiding (singleton)
import Data.Validation as V
import GHC.Generics

import Aeson.Utils
import qualified Plaid.Types as PL

data Account = Account 
  { accountId :: AccountId
  , balances :: Balances
  , maybeMask :: Maybe Mask
  , name :: AccountName
  , maybeOfficialName :: Maybe OfficialName
  , accountType :: AccountType
  }
  deriving (Generic, ToJSON)

newtype AccountId = AccountId
  { unAccountId :: Text }
  deriving newtype ToJSON

newtype Mask = Mask
  { unMask :: Text }
  deriving newtype ToJSON

newtype AccountName = AccountName
  { unAccountName :: Text }
  deriving newtype ToJSON

newtype OfficialName = OfficialName
  { unOfficialName :: Text }
  deriving newtype ToJSON

data AccountType = 
    Depository DepositoryType
  | Credit CreditType 
  | Loan LoanType
  | Investment InvestmentType
  | Payroll PayrollType
  | Other

instance ToJSON AccountType where
  toJSON (Depository dt) = object 
    [ "type" .= textToJSON "depository"
    , "subtype" .= toJSON dt
    ]
  toJSON (Credit ct) = object 
    [ "type" .= textToJSON "credit"
    , "subtype" .= toJSON ct
    ]
  toJSON (Loan lt) = object 
    [ "type" .= textToJSON "loan"
    , "subtype" .= toJSON lt
    ]
  toJSON (Investment it) = object 
    [ "type" .= textToJSON "investment"
    , "subtype" .= toJSON it
    ]
  toJSON (Payroll pt) = object 
    [ "type" .= textToJSON "payroll"
    , "subtype" .= toJSON pt
    ]
  toJSON Other = object 
    [ "type" .= textToJSON "other" ]

data DepositoryType =
    Checking        
  | Savings         
  | Cd              
  | MoneyMarket     
  | DtPaypal          
  | Prepaid         
  | Hsa             
  | CashManagement  
  deriving (Eq, Show, Generic)

instance ToJSON DepositoryType where
  toJSON Checking = textToJSON "checking"
  toJSON Savings = textToJSON "savings"
  toJSON Cd = textToJSON "cd"
  toJSON MoneyMarket = textToJSON "money market"
  toJSON DtPaypal = textToJSON "paypal"
  toJSON Prepaid = textToJSON "prepaid"
  toJSON Hsa = textToJSON "hsa"
  toJSON CashManagement = textToJSON "cash management"  

data CreditType =
    CreditCard
  | CtPaypal
  deriving (Eq, Show, Generic)

instance ToJSON CreditType where
  toJSON CreditCard = textToJSON "credit card"
  toJSON CtPaypal = textToJSON "paypal"

data LoanType =
    Auto
  | Business
  | Commercial
  | Construction
  | Consumer
  | HomeEquity
  | LineOfCredit
  | LtLoan
  | Mortgage
  | LtOther
  | Overdraft
  | Student
  deriving (Eq, Show, Generic)

instance ToJSON LoanType where
  toJSON Auto = textToJSON "auto"
  toJSON Business = textToJSON "business"
  toJSON Commercial = textToJSON "commercial"
  toJSON Construction = textToJSON "construction"
  toJSON Consumer = textToJSON "consumer"
  toJSON HomeEquity = textToJSON "home equity"
  toJSON LineOfCredit = textToJSON "line of credit"
  toJSON LtLoan = textToJSON "loan"
  toJSON Mortgage = textToJSON "mortgage"
  toJSON LtOther = textToJSON "other"
  toJSON Overdraft = textToJSON "overdraft"
  toJSON Student = textToJSON "student"

data InvestmentType =
    It529
  | It401a
  | It401k
  | It403b
  | It457b
  | Brokerage
  | CashIsa
  | CryptoExchange
  | EducationSavingsAccount
  | FixedAnnuity
  | Gic
  | HealthReimbursementArrangement
  | ItHsa
  | Ira
  | Isa
  | Keogh
  | Lif
  | LifeInsurance
  | Lira
  | Lrif
  | Lrsp
  | MutualFund
  | NonCustodialWallet
  | NonTaxableBrokerageAccount
  | ItOther
  | OtherAnnuity
  | OtherInsurance
  | Pension
  | Prif
  | ProfitSharingPlan
  | Qshr
  | Rdsp
  | Resp
  | Retirement
  | Rlif
  | Roth
  | Roth401k
  | Rrif
  | Rrsp
  | Sarsep
  | SepIra
  | SimpleIra
  | Sipp
  | StockPlan
  | Tfsa
  | ThriftSavingsPlan
  | Trust
  | Ugma
  | Utma
  | VariableAnnuity
  deriving (Eq, Show, Generic)

instance ToJSON InvestmentType where
  toJSON It529 = textToJSON "529"
  toJSON It401a = textToJSON "401a"
  toJSON It401k = textToJSON "401k"
  toJSON It403b = textToJSON "403b"
  toJSON It457b = textToJSON "457b"
  toJSON Brokerage = textToJSON "brokerage"
  toJSON CashIsa = textToJSON "cash isa"
  toJSON CryptoExchange = textToJSON "crypto exchange"
  toJSON EducationSavingsAccount = textToJSON "education savings account"
  toJSON FixedAnnuity = textToJSON "fixed annuity"
  toJSON Gic = textToJSON "gic"
  toJSON HealthReimbursementArrangement = textToJSON "health reimbursement arrangement"
  toJSON ItHsa = textToJSON "hsa"
  toJSON Ira = textToJSON "ira"
  toJSON Isa = textToJSON "isa"
  toJSON Keogh = textToJSON "keogh"
  toJSON Lif = textToJSON "lif"
  toJSON LifeInsurance = textToJSON "life insurance"
  toJSON Lira = textToJSON "lira"
  toJSON Lrif = textToJSON "lrif"
  toJSON Lrsp = textToJSON "lrsp"
  toJSON MutualFund = textToJSON "mutual fund"
  toJSON NonCustodialWallet = textToJSON "non-custodial wallet"
  toJSON NonTaxableBrokerageAccount = textToJSON "non-taxable brokerage account"
  toJSON ItOther = textToJSON "other"
  toJSON OtherAnnuity = textToJSON "other annuity"
  toJSON OtherInsurance = textToJSON "other insurance"
  toJSON Pension = textToJSON "pension"
  toJSON Prif = textToJSON "prif"
  toJSON ProfitSharingPlan = textToJSON "profit sharing plan"
  toJSON Qshr = textToJSON "qshr"
  toJSON Rdsp = textToJSON "rdsp"
  toJSON Resp = textToJSON "resp"
  toJSON Retirement = textToJSON "retirement"
  toJSON Rlif = textToJSON "rlif"
  toJSON Roth = textToJSON "roth"
  toJSON Roth401k = textToJSON "roth 401k"
  toJSON Rrif = textToJSON "rrif"
  toJSON Rrsp = textToJSON "rrsp"
  toJSON Sarsep = textToJSON "sarsep"
  toJSON SepIra = textToJSON "sep ira"
  toJSON SimpleIra = textToJSON "simple ira"
  toJSON Sipp = textToJSON "sipp"
  toJSON StockPlan = textToJSON "stock plan"
  toJSON Tfsa = textToJSON "tfsa"
  toJSON ThriftSavingsPlan = textToJSON "thrift savings plan"
  toJSON Trust = textToJSON "trust"
  toJSON Ugma = textToJSON "ugma"
  toJSON Utma = textToJSON "utma"
  toJSON VariableAnnuity = textToJSON "variable annuity"

data PayrollType =
    PtPayroll
  deriving (Eq, Show, Generic)

instance ToJSON PayrollType where
  toJSON PtPayroll = textToJSON "payroll"

data Balances = Balances 
  { available :: Maybe AvailableBalance
  , current :: Maybe CurrentBalance
  , currencyCode :: CurrencyCode
  }
  deriving (Generic, ToJSON)

newtype AvailableBalance = AvailableBalance
  { unAvailableBalance :: Double }
  deriving newtype ToJSON

newtype CurrentBalance = CurrentBalance
  { unCurrentBalance :: Double }
  deriving newtype ToJSON

data CurrencyCode = 
    Iso Text
  | Unofficial UnofficialCode

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
  deriving (Eq, Show, Generic)

instance ToJSON UnofficialCode where
  toJSON = genericToJSON defaultOptions

validatePLAccount :: PL.Account -> Validation (NonEmpty Text) Account
validatePLAccount plAccount = 
  Account (fromPLAccountId plAccount.account_id)
    <$> validateBalances plAccount.balances
    <*> pure (fromPLMask plAccount.mask)
    <*> pure (fromName plAccount.name)
    <*> pure (fromOfficialName plAccount.official_name)
    <*> validateAccountType plAccount.account_type plAccount.subtype
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

    validateAccountType :: PL.AccountType -> Maybe PL.AccountSubtype -> Validation (NonEmpty Text) AccountType
    validateAccountType accountType maybeSubtype = 
      case (accountType.unAccountType, (.unAccountSubtype) <$> maybeSubtype ) of 
        ("depository", Just subtype) -> Depository <$> validateDepositoryType subtype
        ("depository", Nothing) -> V.Failure $ singleton "\"depository\" account type requires subtype"
        ("credit", Just subtype) -> Credit <$> validateCreditType subtype
        ("credit", Nothing) -> V.Failure $ singleton "\"credit\" account type requires subtype"
        ("loan", Just subtype) -> Loan <$> validateLoanType subtype
        ("loan", Nothing) -> V.Failure $ singleton "\"loan\" account type requires subtype"
        ("investment", Just subtype) -> Investment <$> validateInvestmentType subtype
        ("investment", Nothing) -> V.Failure $ singleton "\"investment\" account type requires subtype"
        ("payroll", Just subtype) -> Payroll <$> validatePayrollType subtype
        ("payroll", Nothing) -> V.Failure $ singleton "\"payroll\" account type requires subtype"
        ("other", Nothing) -> V.Success Other
        ("other", _) -> V.Failure $ singleton "\"other\" account type has subtype value"
        (unknownType, _) -> V.Failure . singleton $ "Unknown account type: " <> unknownType

    validateDepositoryType :: Text -> Validation (NonEmpty Text) DepositoryType
    validateDepositoryType "checking" = V.Success Checking
    validateDepositoryType "savings" = V.Success Savings
    validateDepositoryType "cd" = V.Success Cd
    validateDepositoryType "money market" = V.Success MoneyMarket
    validateDepositoryType "paypal" = V.Success DtPaypal
    validateDepositoryType "prepaid" = V.Success Prepaid
    validateDepositoryType "hsa" = V.Success Hsa
    validateDepositoryType "cash management" = V.Success CashManagement
    validateDepositoryType t = V.Failure . singleton $ "Unknown depository subtype: " <> t

    validateCreditType :: Text -> Validation (NonEmpty Text) CreditType
    validateCreditType "credit card" = V.Success CreditCard
    validateCreditType "paypal" = V.Success CtPaypal
    validateCreditType t = V.Failure . singleton $ "Unknown credit subtype: " <> t

    validateLoanType :: Text -> Validation (NonEmpty Text) LoanType
    validateLoanType "auto" = V.Success Auto
    validateLoanType "business" = V.Success Business
    validateLoanType "commercial" = V.Success Commercial
    validateLoanType "construction" = V.Success Construction
    validateLoanType "consumer" = V.Success Consumer
    validateLoanType "home equity" = V.Success HomeEquity
    validateLoanType "line of credit" = V.Success LineOfCredit
    validateLoanType "loan" = V.Success LtLoan
    validateLoanType "mortgage" = V.Success Mortgage
    validateLoanType "other" = V.Success LtOther
    validateLoanType "overdraft" = V.Success Overdraft
    validateLoanType "student" = V.Success Student
    validateLoanType t = V.Failure . singleton $ "Unknown loan subtype: " <> t

    validateInvestmentType :: Text -> Validation (NonEmpty Text) InvestmentType
    validateInvestmentType "529" = V.Success It529
    validateInvestmentType "401a" = V.Success It401a
    validateInvestmentType "401k" = V.Success It401k
    validateInvestmentType "403b" = V.Success It403b
    validateInvestmentType "457b" = V.Success It457b
    validateInvestmentType "brokerage" = V.Success Brokerage
    validateInvestmentType "cash isa" = V.Success CashIsa
    validateInvestmentType "crypto exchange" = V.Success CryptoExchange
    validateInvestmentType "education savings account" = V.Success EducationSavingsAccount
    validateInvestmentType "fixed annuity" = V.Success FixedAnnuity
    validateInvestmentType "gic" = V.Success Gic
    validateInvestmentType "health reimbursement arrangement" = V.Success HealthReimbursementArrangement
    validateInvestmentType "hsa" = V.Success ItHsa
    validateInvestmentType "ira" = V.Success Ira
    validateInvestmentType "isa" = V.Success Isa
    validateInvestmentType "keogh" = V.Success Keogh
    validateInvestmentType "lif" = V.Success Lif
    validateInvestmentType "life insurance" = V.Success LifeInsurance
    validateInvestmentType "lira" = V.Success Lira
    validateInvestmentType "lrif" = V.Success Lrif
    validateInvestmentType "lrsp" = V.Success Lrsp
    validateInvestmentType "mutual fund" = V.Success MutualFund
    validateInvestmentType "non-custodial wallet" = V.Success NonCustodialWallet
    validateInvestmentType "non-taxable brokerage account" = V.Success NonTaxableBrokerageAccount
    validateInvestmentType "other" = V.Success ItOther
    validateInvestmentType "other annuity" = V.Success OtherAnnuity
    validateInvestmentType "other insurance" = V.Success OtherInsurance
    validateInvestmentType "pension" = V.Success Pension
    validateInvestmentType "prif" = V.Success Prif
    validateInvestmentType "profit sharing plan" = V.Success ProfitSharingPlan
    validateInvestmentType "qshr" = V.Success Qshr
    validateInvestmentType "rdsp" = V.Success Rdsp
    validateInvestmentType "resp" = V.Success Resp
    validateInvestmentType "retirement" = V.Success Retirement
    validateInvestmentType "rlif" = V.Success Rlif
    validateInvestmentType "roth" = V.Success Roth
    validateInvestmentType "roth 401k" = V.Success Roth401k
    validateInvestmentType "rrif" = V.Success Rrif
    validateInvestmentType "rrsp" = V.Success Rrsp
    validateInvestmentType "sarsep" = V.Success Sarsep
    validateInvestmentType "sep ira" = V.Success SepIra
    validateInvestmentType "simple ira" = V.Success SimpleIra
    validateInvestmentType "sipp" = V.Success Sipp
    validateInvestmentType "stock plan" = V.Success StockPlan
    validateInvestmentType "tfsa" = V.Success Tfsa
    validateInvestmentType "thrift savings plan" = V.Success ThriftSavingsPlan
    validateInvestmentType "trust" = V.Success Trust
    validateInvestmentType "ugma" = V.Success Ugma
    validateInvestmentType "utma" = V.Success Utma
    validateInvestmentType "variable annuity" = V.Success VariableAnnuity
    validateInvestmentType t = V.Failure . singleton $ "Unknown investment subtype: " <> t

    validatePayrollType :: Text -> Validation (NonEmpty Text) PayrollType
    validatePayrollType "payroll" = V.Success PtPayroll
    validatePayrollType t = V.Failure . singleton $ "Unknown payroll subtype: " <> t
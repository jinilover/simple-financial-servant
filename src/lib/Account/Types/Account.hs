{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingStrategies #-}
module Account.Types.Account where

import Data.Aeson
import Data.Text
import GHC.Generics

import Aeson.Utils

data Account = Account 
  { accountId :: AccountId
  , balances :: Balances
  , mask :: Mask
  , name :: AccountName
  , officialName :: Maybe OfficialName
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
  toJSON (Depository dt) = object ["type" .= textToJSON "depository", "subtype" .= toJSON dt]
  toJSON (Credit ct) = object ["type" .= textToJSON "credit", "subtype" .= toJSON ct]
  toJSON (Loan lt) = object ["type" .= textToJSON "loan", "subtype" .= toJSON lt]
  toJSON (Investment it) = object ["type" .= textToJSON "investment", "subtype" .= toJSON it]
  toJSON (Payroll pt) = object ["type" .= textToJSON "payroll", "subtype" .= toJSON pt]
  toJSON Other = object ["type" .= textToJSON "other"]

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
  , limit :: Maybe Limit
  }
  deriving (Generic, ToJSON)

newtype AvailableBalance = AvailableBalance
  { unAvailableBalance :: Double }
  deriving newtype ToJSON

newtype CurrentBalance = CurrentBalance
  { unCurrentBalance :: Double }
  deriving newtype ToJSON

newtype Limit = Limit
  { unLimit :: Double }
  deriving newtype ToJSON

data CurrencyCode = 
    Iso Text
  | Unofficial UnofficialCode
  deriving (Generic, ToJSON)

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

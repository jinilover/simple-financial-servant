{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingStrategies #-}
module Account.Types.Account where

import Data.Aeson
import Data.Text
import GHC.Generics

data Account = Account 
  { accountId :: AccountId
  , balances :: Balances
  , mask :: Mask
  , name :: AccountName
  , officialName :: Maybe OfficialName
  , subtype :: AccountSubtype
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

newtype AccountSubtype = AccountSubtype
  { unAccountSubtype :: Text }
  deriving newtype ToJSON

data AccountType = 
    Depository DepositoryType
  | Credit CreditType 
  | Loan LoanType
  | Investment InvestmentType
  | Payroll PayrollType
  | Other OtherType
  deriving (Generic, ToJSON)

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
  toJSON Checking = toJSON ("checking" :: Text)
  toJSON Savings = toJSON( "savings" :: Text)
  toJSON Cd = toJSON ("cd" :: Text)
  toJSON MoneyMarket = toJSON( "money market" :: Text)
  toJSON DtPaypal = toJSON ("paypal" :: Text)
  toJSON Prepaid = toJSON ("prepaid" :: Text)
  toJSON Hsa = toJSON ("hsa" :: Text)
  toJSON CashManagement = toJSON ("cash management" :: Text)  

data CreditType =
    CreditCard
  | CtPaypal
  deriving (Eq, Show, Generic)

instance ToJSON CreditType where
  toJSON CreditCard = toJSON ("credit card" :: Text)
  toJSON CtPaypal = toJSON ("paypal" :: Text)

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
  toJSON Auto = toJSON ("auto" :: Text)
  toJSON Business = toJSON ("business" :: Text)
  toJSON Commercial = toJSON ("commercial" :: Text)
  toJSON Construction = toJSON ("construction" :: Text)
  toJSON Consumer = toJSON ("consumer" :: Text)
  toJSON HomeEquity = toJSON ("home equity" :: Text)
  toJSON LineOfCredit = toJSON ("line of credit" :: Text)
  toJSON LtLoan = toJSON ("loan" :: Text)
  toJSON Mortgage = toJSON ("mortgage" :: Text)
  toJSON LtOther = toJSON ("other" :: Text)
  toJSON Overdraft = toJSON ("overdraft" :: Text)
  toJSON Student = toJSON ("student" :: Text)

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
  toJSON It529 = toJSON ("529" :: Text)
  toJSON It401a = toJSON ("401a" :: Text)
  toJSON It401k = toJSON ("401k" :: Text)
  toJSON It403b = toJSON ("403b" :: Text)
  toJSON It457b = toJSON ("457b" :: Text)
  toJSON Brokerage = toJSON ("brokerage" :: Text)
  toJSON CashIsa = toJSON ("cash isa" :: Text)
  toJSON CryptoExchange = toJSON ("crypto exchange" :: Text)
  toJSON EducationSavingsAccount = toJSON ("education savings account" :: Text)
  toJSON FixedAnnuity = toJSON ("fixed annuity" :: Text)
  toJSON Gic = toJSON ("gic" :: Text)
  toJSON HealthReimbursementArrangement = toJSON ("health reimbursement arrangement" :: Text)
  toJSON ItHsa = toJSON ("hsa" :: Text)
  toJSON Ira = toJSON ("ira" :: Text)
  toJSON Isa = toJSON ("isa" :: Text)
  toJSON Keogh = toJSON ("keogh" :: Text)
  toJSON Lif = toJSON ("lif" :: Text)
  toJSON LifeInsurance = toJSON ("life insurance" :: Text)
  toJSON Lira = toJSON ("lira" :: Text)
  toJSON Lrif = toJSON ("lrif" :: Text)
  toJSON Lrsp = toJSON ("lrsp" :: Text)
  toJSON MutualFund = toJSON ("mutual fund" :: Text)
  toJSON NonCustodialWallet = toJSON ("non-custodial wallet" :: Text)
  toJSON NonTaxableBrokerageAccount = toJSON ("non-taxable brokerage account" :: Text)
  toJSON ItOther = toJSON ("other" :: Text)
  toJSON OtherAnnuity = toJSON ("other annuity" :: Text)
  toJSON OtherInsurance = toJSON ("other insurance" :: Text)
  toJSON Pension = toJSON ("pension" :: Text)
  toJSON Prif = toJSON ("prif" :: Text)
  toJSON ProfitSharingPlan = toJSON ("profit sharing plan" :: Text)
  toJSON Qshr = toJSON ("qshr" :: Text)
  toJSON Rdsp = toJSON ("rdsp" :: Text)
  toJSON Resp = toJSON ("resp" :: Text)
  toJSON Retirement = toJSON ("retirement" :: Text)
  toJSON Rlif = toJSON ("rlif" :: Text)
  toJSON Roth = toJSON ("roth" :: Text)
  toJSON Roth401k = toJSON ("roth 401k" :: Text)
  toJSON Rrif = toJSON ("rrif" :: Text)
  toJSON Rrsp = toJSON ("rrsp" :: Text)
  toJSON Sarsep = toJSON ("sarsep" :: Text)
  toJSON SepIra = toJSON ("sep ira" :: Text)
  toJSON SimpleIra = toJSON ("simple ira" :: Text)
  toJSON Sipp = toJSON ("sipp" :: Text)
  toJSON StockPlan = toJSON ("stock plan" :: Text)
  toJSON Tfsa = toJSON ("tfsa" :: Text)
  toJSON ThriftSavingsPlan = toJSON ("thrift savings plan" :: Text)
  toJSON Trust = toJSON ("trust" :: Text)
  toJSON Ugma = toJSON ("ugma" :: Text)
  toJSON Utma = toJSON ("utma" :: Text)
  toJSON VariableAnnuity = toJSON ("variable annuity" :: Text)

data PayrollType
  deriving (Generic, ToJSON)

data OtherType
  deriving (Generic, ToJSON)

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

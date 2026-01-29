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

data InvestmentType
  deriving (Generic, ToJSON)

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

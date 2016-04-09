Class Data.Portfolio Extends %Persistent
{

Property Customer As Data.Customer;

/// STOCK, BOND, OPTION
Property Security As %String;

Property ISIN As %String;

Property Ticker As %String;

Property Currency As %String;

Property Quantity As %String;

Property Quote As %Numeric [ Calculated, SqlComputeCode = {Set {*} = ##class(Data.Portfolio).GetQuote({Ticker},{ISIN})}, SqlComputed ];

Property Value As %Numeric [ Calculated, SqlComputeCode = {Set {*} = {Quantity} * ##class(Data.Portfolio).GetQuote({Ticker},{ISIN})}, SqlComputed ];

/// Long or Short
Property Position As %String;

Property Industry As %String;

Property Rating As %String;

Index idxCust On Customer;

ClassMethod Init()
{
	#Dim custId as %String
	Do ##class(Data.Customer).%KillExtent()
	Do ##class(Data.Portfolio).%KillExtent()
	Set custId = ##class(Data.Customer).Insert("Defensive Pension Fund")
	Do ..Insert(custId, "Stock", "", "AAPL", 100, "Long")
	Do ..Insert(custId, "Stock", "", "DIS", 100, "Long")
	Do ..Insert(custId, "Stock", "", "WMT", 100, "Long")
	Do ..Insert(custId, "Bond", "ABC12345678", "", 2000, "Long")
	Set custId = ##class(Data.Customer).Insert("Aggressive Elderly Mutual Fund")
	Do ..Insert(custId, "Stock", "", "AAPL", 1000, "Short")
}

ClassMethod Insert(custId, security, isin, ticker, quantity, position)
{
	&sql(Insert into Data.Portfolio (Customer, Security, ISIN, Ticker, Quantity, Position)
	     Values (:custId, :security, :isin, :ticker, :quantity, :position))
}

ClassMethod GetQuote(ticker, isin) As %Numeric
{
	//put some code to get the quote from REST service
	//currently hardcoded
	If ticker="AAPL" Quit 100
	If ticker="AAPL" Quit 99.95
	If ticker="WML" Quit 66
	Quit $random(100)
}

Storage Default
{
<Data name="PortfolioDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Customer</Value>
</Value>
<Value name="3">
<Value>Security</Value>
</Value>
<Value name="4">
<Value>ISIN</Value>
</Value>
<Value name="5">
<Value>Ticker</Value>
</Value>
<Value name="6">
<Value>Quantity</Value>
</Value>
<Value name="7">
<Value>Position</Value>
</Value>
<Value name="8">
<Value>Currency</Value>
</Value>
<Value name="9">
<Value>Industry</Value>
</Value>
<Value name="10">
<Value>Rating</Value>
</Value>
</Data>
<DataLocation>^Data.PortfolioD</DataLocation>
<DefaultData>PortfolioDefaultData</DefaultData>
<IdLocation>^Data.PortfolioD</IdLocation>
<IndexLocation>^Data.PortfolioI</IndexLocation>
<StreamLocation>^Data.PortfolioS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

Class Data.Customer Extends %Persistent
{

Property Name As %String;

ClassMethod Insert(name As %String) As %String
{
	&sql(insert into Data.Customer (Name)
	     Values (:name))
	Return $Select(SQLCODE=0:%ROWID, 1: "")
}

Storage Default
{
<Data name="CustomerDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
</Data>
<DataLocation>^Data.CustomerD</DataLocation>
<DefaultData>CustomerDefaultData</DefaultData>
<IdLocation>^Data.CustomerD</IdLocation>
<IndexLocation>^Data.CustomerI</IndexLocation>
<StreamLocation>^Data.CustomerS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

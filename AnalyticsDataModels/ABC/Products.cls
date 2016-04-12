/// This example class represents Products for the fictional "ABC" corporation.
Class ABC.Products Extends %Persistent
{

Property Name As %String;

Property Code As %String;

Property ListPrice As %Numeric(SCALE = 2);

Index CodeIndex On Code [ IdKey, Unique ];

// Method to return the product category name for a product

ClassMethod GetCategory(item As %String) As %String
{
	set categoryCode = $p(item,"-",1)
	set categoryName = $Case(categoryCode,"BK":"Books","DVD":"DVDs","EL":"Electronics",:"")
	quit categoryName
}

Storage Default
{
<Data name="ProductsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>ListPrice</Value>
</Value>
</Data>
<DataLocation>^ABC.ProductsD</DataLocation>
<DefaultData>ProductsDefaultData</DefaultData>
<IdLocation>^ABC.ProductsD</IdLocation>
<IndexLocation>^ABC.ProductsI</IndexLocation>
<StreamLocation>^ABC.ProductsS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

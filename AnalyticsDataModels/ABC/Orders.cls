/// This example class represents Orders for the fictional "ABC" corporation.
Class ABC.Orders Extends %Persistent [ SqlTableName = Orders ]
{

/// Track changes to this class.
Parameter DSTIME = "auto";

/// If true, this represents an internal order
Property Internal As %Boolean;

/// Order ID
Property OrderID As %String;

/// Date of this order.
Property Date As %String;

/// Order Type.
Property Type As %Integer;

/// Item Ordered. (XXX-9999)
Property Item As ABC.Products;

/// Quantity ordered.
Property Quantity As %Integer;

/// Cost per item.
Property PerItemCharge As %Numeric(SCALE = 2);

Index OrderIDIndex On OrderID [ Unique ];

Storage Default
{
<Data name="OrdersDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Internal</Value>
</Value>
<Value name="3">
<Value>Date</Value>
</Value>
<Value name="4">
<Value>Type</Value>
</Value>
<Value name="5">
<Value>Item</Value>
</Value>
<Value name="6">
<Value>Quantity</Value>
</Value>
<Value name="7">
<Value>PerItemCharge</Value>
</Value>
<Value name="8">
<Value>OrderID</Value>
</Value>
</Data>
<DataLocation>^ABC.OrdersD</DataLocation>
<DefaultData>OrdersDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^ABC.OrdersD</IdLocation>
<IndexLocation>^ABC.OrdersI</IndexLocation>
<StreamLocation>^ABC.OrdersS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

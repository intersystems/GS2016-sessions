/// This cube represents a model for the fictional "ABC" corporation.
/// It is based on the classes within the ABC package.<br/>
/// <br/>
/// To create data for this model and build the cubes,  
/// use the Setup method within the <class>ABC.Utils</class> class:<br/>
/// From the command line:<br/>
/// <example language="cache">
/// Do ##class(ABC.Utils).Setup()
/// </example>
/// <br/>
/// Orders B is a better cube than Orders A because not all fields are used as dimensions/meaures.
/// There are more meaningful names. Also this cube includes the use of sourceExpression.
/// a time dimension, a multi-level hierarchy, and 2 calculated members.
/// <br/>
Class ABC.CubeB Extends %DeepSee.CubeDefinition [ DependsOn = ABC.Orders ]
{

Parameter DOMAIN = "ABC";

/// This xml document defines the HoleFoods model.
XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube name="Orders B" 
caption="Orders B - Better Cube"
defaultListing="Listing"
sourceClass="ABC.Orders"
buildRestriction="Internal=0"
countMeasureCaption="Order Count"
>

<listing name="Listing" 
fieldList='%ID,"Date",Item,Quantity' 
 orderBy="%ID"/>

<measure name="Units Sold" displayName="Units Sold" sourceProperty="Quantity"
             aggregate="SUM" formatString="#,###"/>
<measure name="Price" disabled="true"  sourceProperty="PerItemCharge" 
               aggregate="SUM"  formatString="$#,###.##" />
<measure name="Extended Price" sourceExpression="%source.Quantity*%source.PerItemCharge" 
              aggregate="SUM" formatString="$#,###.##" />
<measure name="Avg Extended Price" sourceExpression="%source.Quantity*%source.PerItemCharge" 
              aggregate="AVG" formatString="$#,###.##" />

<calculatedMember 
name="Product percent of total"
displayName="Product % of Total" 
dimension="Measures" 
valueExpression="Product.CurrentMember/Product.[All Product].%ALL" 
 formatString="###.##%"/>


<calculatedMember name="Current Value" 
displayName="Current Value" 
description="Value at current list price"
dimension="Measures"
valueExpression=
'%KPI("ABC.CurrentValue","VALUE",1,"%CONTEXT")' 
 formatString="$#,###.##" />


<dimension name="Order Date" displayName="Order Date" type="time"
              sourceExpression='$zdh(%source.Date,3)' >
<hierarchy name="H1">
<level name="Year Ordered" timeFunction="Year" />
<level name="Month Ordered" timeFunction="MonthYear" />
<level name="Day Ordered" timeFunction="DayMonthYear" />
</hierarchy>
</dimension>

<dimension name="Product" displayName="Product" >
<hierarchy name="H1">
<level name="Product Category"  sourceExpression='$p(%source.Item,"-",1)' >
<property name="Category Name" 
        sourceExpression="##class(ABC.Products).GetCategory(%source.Item)"
         isName="true" />
</level>
<level name="Product"  sourceProperty="Item" >
<property name="Product Name" sourceProperty="Item.Name" isName="true" />
<property name="Item Code" sourceExpression="%source.Item" isDescription="true" />
</level>
</hierarchy>
</dimension>

<dimension name="Order Type" displayName="Order Type" >
<hierarchy name="H1">
<level name="Order Type"  sourceProperty="Type" 
        rangeExpression="1:Retail;2:Online;" nullReplacement="No Type" />
</hierarchy>
</dimension>

</cube>
}

}

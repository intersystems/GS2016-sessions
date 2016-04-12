/// This cube represents a model for the fictional "ABC" corporation.
/// It is based on the classes within the ABC package.<br/>
/// <br/>
/// To create data for this model and build the cubes  
/// use the Setup method within the <class>ABC.Utils</class> class:<br/>
/// From the command line:<br/>
/// <example language="cache">
/// Do ##class(ABC.Utils).Setup()
/// </example>
/// <br/>
/// Orders A is an example of a "bad" cube because it makes every numeric field a 
/// measure and every text field a dimension (not all are good dimensions/measures).
/// Also the names used are the names of the fields in the source class,
/// which may not be meaningful names.
Class ABC.CubeA Extends %DeepSee.CubeDefinition [ DependsOn = ABC.Orders ]
{

Parameter DOMAIN = "ABC";

/// This xml document defines the Orders A model.
XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube name="Orders A" 
caption="Orders A - Bad Cube"
defaultListing="Listing"
sourceClass="ABC.Orders">

<listing name="Listing" 
fieldList='%ID,"Date",Item,Quantity' 
 orderBy="%ID"/>

<measure name="Quantity" displayName="Quantity" sourceProperty="Quantity" aggregate="SUM" formatString="#,###"/>
<measure name="PerItemCharge" sourceProperty="PerItemCharge" aggregate="SUM" />

<dimension name="OrderID" displayName="OrderID" >
<hierarchy name="H1">
<level name="OrderID"  sourceProperty="OrderID" />
</hierarchy>
</dimension>


<dimension name="Date" displayName="Date" >
<hierarchy name="H1">
<level name="Date"  sourceProperty="Date" />
</hierarchy>
</dimension>

<dimension name="Item" displayName="Item" >
<hierarchy name="H1">
<level name="Item"  sourceProperty="Item" />
</hierarchy>
</dimension>

<dimension name="Internal" displayName="Internal" >
<hierarchy name="H1">
<level name="Internal"  sourceProperty="Internal" />
</hierarchy>
</dimension>

<dimension name="Type" displayName="Type" >
<hierarchy name="H1">
<level name="Type"  sourceProperty="Type" />
</hierarchy>
</dimension>

</cube>
}

}

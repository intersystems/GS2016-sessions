/// This Analytic plug-in computes the MEDIAN on a given measure for a given cube.
Class ABC.CurrentValuePlugin Extends %DeepSee.KPIPlugIn [ System = 4 ]
{

/// Cube(s) that this plug-in is based on.
Parameter BASECUBE = "[Orders B]";

Parameter LISTINGSOURCE = "SourceTable";

Parameter LISTINGFIELDS = "ID,Item,Quantity,Item->ListPrice as Price";

Parameter PLUGINTYPE = "Aggregate";

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi name="ABC.CurrentValue" displayName="CurrentValue" caption="CurrentValue" >

<property name="VALUE" displayName="Value" description="Current Value" />

</kpi>
}

/// Get the base query for this plug-in.
Method %OnGetMDX(ByRef pMDX As %String) As %Status
{
	Set pMDX = "SELECT FROM [Orders B]"
	Quit $$$OK
}

/// Returns the field list (RETURN clause) of the listing used to supply data for this plug-in.
/// In this case, determine which measure we need.
/// Compute the median of values within the result set.
Method %OnCompute(pSQLRS As %SQL.StatementResult, pFactCount As %Integer) As %Status
{
	Set tSC = $$$OK
	Try {
		Set tTotal = 0
		Set tCount = 0
		Set tErrMsg = ""
		Set n = 0

		While (pSQLRS.%Next(.tSC)) {
			If $$$ISERR(tSC) {
				Set tErrMsg = $System.Status.GetErrorText(tSC)
				Quit
			}
			Set n = n + 1

			Set tPrice = pSQLRS.Price
			If ($ZSTRIP($P(tPrice,":"),"<>W")="ERROR") {
				Set tErrMsg = $P(tPrice,":",2)
				Quit
			}
			Set tQuantity = pSQLRS.Quantity
			
			set tValue = tPrice * tQuantity
			
			If (tValue'="") {
				Set tTotal = tTotal + tValue
			}

			// update pct complete
			If (n#100 = 0) {
				Do ..%SetPercentComplete(100*(n/pFactCount))
			}
		}

		// place answer in KPI output
		Set ..%seriesCount = 1
		Set ..%seriesNames(1) = "Total"
		If (tErrMsg'="") {
			Set ..%data(1,"VALUE") = tErrMsg
		}
		Else {
			Set ..%data(1,"VALUE") = tTotal
		}
	}
	Catch(ex) {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

}

Include %DeepSee

/// This class contains utility methods for the ABC example. <br/>
/// To create data for this model and build the cubes  
/// use the Setup method within the <class>ABC.Utils</class> class:<br/>
/// From the command line:<br/>
/// <example language="cache">
/// Do ##class(ABC.Utils).Setup()
/// </example>
/// <br/>
/// The first argument is the number of records to create (defaults to 100000)<br/> 
/// the second argument indicates that index building should be done in parallel<br/>
/// the third is a verbose flag; if true, then progress is displayed as the data is built<br/>
Class ABC.Utils Extends %RegisteredObject
{

/// Add this alias so that each DeepSee sample has a Setup() method
ClassMethod Setup(pCount As %Integer = 100000, pASync As %Boolean = 1, pVerbose As %Boolean = 1)
{
	do ..BuildData(pCount,pASync,pVerbose)
	do $system.DeepSee.BuildCube("Orders A")
	do $system.DeepSee.BuildCube("Orders B")
}

/// Build the transactional data that will provide data for the DeepSee model.
/// Any old records will be deleted.<br/>
/// <var>pCount</var> is the number of records to create.<br/>
/// <var>pAsync</var> if true, indicates that parallel processing should be used to build the cube.<br/>
/// <var>pVerbose</var> if true, indicates that status messages should be written to the console.<br/>
ClassMethod BuildData(pCount As %Integer = 100000, pASync As %Boolean = 1, pVerbose As %Boolean = 1)
{
	
	// Kill old data
	Do ##class(ABC.Orders).%KillExtent()

	// build new data
	Do ..CreateRecords(pCount,pVerbose)
}

/// Does the actual work of creating new records in the source data.
/// <var>pCount</var> is the number of records to create.<br/>
/// <var>pVerbose</var> if true, indicates that status messages should be written to the console.<br/>
ClassMethod CreateRecords(pCount As %Integer = 1000, pVerbose As %Boolean = 1) [ Private ]
{
	Set tSC = $$$OK
	Try {
		// build new data

		// Create array of Products $lb(product code, list price, product name)
		Kill tProducts
		Set tProducts($I(tProducts)) = $LB("DVD-10100",25.99,"Star Wars: Return of the Merchandise")
		Set tProducts($I(tProducts)) = $LB("DVD-10200",17.50,"Rambo,Part 13")
		Set tProducts($I(tProducts)) = $LB("DVD-10300",15,"Old Frankenstein")
		Set tProducts($I(tProducts)) = $LB("DVD-10400",20,"Spiderman 2: Again")
		Set tProducts($I(tProducts)) = $LB("DVD-10600",10.50,"Batman Returns: Again")

		Set tProducts($I(tProducts)) = $LB("BK-41003",32.50,"The Complete Book of Everything")
		Set tProducts($I(tProducts)) = $LB("BK-51004",29.95,"The Second Book of Everything")
		Set tProducts($I(tProducts)) = $LB("BK-51202",19.50,"Even More Everyting")

		Set tProducts($I(tProducts)) = $LB("EL-21007",24.75,"Car Adaptor")
		Set tProducts($I(tProducts)) = $LB("EL-31305",17.50,"USB Cable")
		Set tProducts($I(tProducts)) = $LB("EL-51202",25.30,"Hair Dryer")
		Set tProducts($I(tProducts)) = $LB("EL-51402",18.00,"Headphones")
		Set tProducts($I(tProducts)) = $LB("EL-52407",21.00,"Surge Protector")

		do ##class(ABC.Products).%KillExtent()
		For i=1:1:tProducts {
			set pr = ##class(ABC.Products).%New()
			set pr.Code = $li(tProducts(i),1) // Product Code
			set pr.ListPrice = $li(tProducts(i),2)
			set pr.Name = $li(tProducts(i),3)  //Product Name
			do pr.%Save()
		}
		
		// distribution of dates increasing with time
		// last 3 full years, plus part of current year
		Set tCurrYear = +$E($ZDT($H,3),1,4)
		Set tStartYear = tCurrYear - 3
		Set tCurrMonth = +$E($ZDT($H,3),6,7)
		Set tMonthSeed = 1000
		Set tMonthTotal = tMonthSeed
		Set tMonths = 36 + tCurrMonth
		For m = 1:1:tMonths {
			Set tMonthTotal = (tMonthTotal * 1.01)\1
			Set tMonthDist(tMonthTotal) = m
		}

		// now build main table
		Set tCount = pCount
	
		Set tRows = 0

		//possible discount values
		set tDiscount = $lb(0,0.5,.10,.20)
		
		For n = 1:1:tCount {
			Set tRecord = ##class(ABC.Orders).%New()
			
			// make some orders internal
			Set tRecord.Internal = $S($R(10)<9:0,1:1)
		
			// last 5 full years plus part of current year, with distribution increasing with time
			Set tMonth = 1
			Set mr = $R(tMonthTotal - tMonthSeed) + tMonthSeed
			Set mi = $O(tMonthDist(mr))
			Set:mi'="" tMonth = $G(tMonthDist(mi),1)

			Set tYear = tStartYear + ((tMonth-1)\12)
			Set tMonth = ((tMonth-1)#12) + 1
			Set tDay = $R($$$iscDaysInMonth(tYear,tMonth)) + 1
			Set tH = +$ZDTH(tYear_"-"_$$$iscPadZero(tMonth,2)_"-"_$$$iscPadZero(tDay,2),3)

			Set tRecord.Date = $zd(tH,3)
			
			// product
			Set tItem = tProducts($R(tProducts)+1)
			Do tRecord.ItemSetObjectId($list(tItem,1))

			// random quantity
			Set tRecord.Quantity = $S($R(10)<7:1,1:$R(4)+1)
			
			// PerItemCharge is list price with discount
			Set tRecord.PerItemCharge = $list(tItem,2) * (1-($li(tDiscount,$r(4)+1)))
			
			// slowly change value
			Set tRecord.Type = $S($R(18000)<(tH-50000):2,1:1)

			// set some Types to null
			If ($R(10) < 1) Set tRecord.Type = ""


   			Set tSC = tRecord.%Save()
			If $$$ISERR(tSC) {
				Do $System.Status.DisplayError(tSC)
			}
			Else {
				Set tRows = tRows + 1
			}
			
			Set tRecord.OrderID = 513000000+tRecord.%Id()
   			Set tSC = tRecord.%Save()
			If $$$ISERR(tSC) {
				Do $System.Status.DisplayError(tSC)
			}

			If (pVerbose&&('(tRows#1000))) Write $C(13,27)_"[0J"_$FN(tRows,",",0)_" rows created"

		}

		If (pVerbose) Write $C(13,27)_"[0J"_$FN(+$G(tRows),",",0)_" row(s) created"

	}
	Catch(ex) {
		Set tSC = ex.AsStatus()
	}

	If $$$ISERR(tSC) {
		Do $System.Status.DisplayError(tSC)
	}
}

}

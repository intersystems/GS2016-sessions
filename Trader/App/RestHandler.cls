Include %IKPublic

Class App.RestHandler Extends %CSP.REST
{

XData UrlMap
{
<Routes>
<Route Url="/Customer" Method="GET" Call="GetCustomers"/>
<Route Url="/Customer/:custId/Portfolio" Method="GET" Call="GetCustPortfolios"/>
<Route Url="/Portfolio/:pfId" Method="GET" Call="GetPortfolio"/>
<Route Url="/Portfolio/:pfId" Method="PUT" Call="SavePortfolio"/>
<Route Url="/Portfolio" Method="POST" Call="SavePortfolio"/>
<Route Url="/Portfolio/:pfId" Method="DELETE" Call="DeletePortfolio"/>
<Route Url="/CheckRules" Method="POST" Call="CheckRules"/>
</Routes>
}

ClassMethod GetCustomers() As %Status
{
	#Dim sql as %String
	#Dim e as %Exception.AbstractException
	#Dim status as %Status = $$$OK
	
	Try {
		Set sql="Select * from Data.Customer"
		If $Data(%response) {
			Set %response.ContentType="application/json"
		}
		Do ##class(%ZEN.Auxiliary.jsonSQLProvider).%WriteJSONFromSQL(,sql,,10000)
    } Catch (e) {
        Set status=e.AsStatus()
        Do ..ErrorHandler(status)
        set ^dwerr($i(^dwerr))=$ze
    }    
    Quit $$$OK
}

ClassMethod GetCustPortfolios(custId As %Integer) As %Status
{
	#Dim sql as %String
	#Dim e as %Exception.AbstractException
	#Dim status as %Status = $$$OK
	
	Try {
		Set sql="Select * from Data.Portfolio Where Customer = "_custId
		If $Data(%response) {
			Set %response.ContentType="application/json"
		}
		Do ##class(%ZEN.Auxiliary.jsonSQLProvider).%WriteJSONFromSQL(,sql,,10000)
    } Catch (e) {
        Set status=e.AsStatus()
        Do ..ErrorHandler(status)
        set ^dwerr($i(^dwerr))=$ze
    }    
    Quit $$$OK
}

ClassMethod GetPortfolio(pfId As %Integer) As %Status
{
    #dim tSC As %Status = $$$OK
    #dim e As %Exception.AbstractException
	#dim status as %Status
	#dim objPortfolio as Data.Portfolio
	Try {
		set objPortfolio = ##class(Data.Patterns).%OpenId(pfId)
		if $IsObject(objPortfolio) {
			Do ##class(%ZEN.Auxiliary.jsonProvider).%WriteJSONFromObject(,objPortfolio)
		} else {
			Write "{ ""todo"" : ""errorstatus "_pfId_" not found"" }"
		}
    } Catch (e) {
        Set status=e.AsStatus()
        Do ..ErrorHandler(status)
		set ^dwerr($i(^dwerr))=$ze
	}
	Quit tSC
}

ClassMethod CheckRules() As %Status
{
    #dim tSC As %Status = $$$OK
	Try {
		set objStream=%request.Content
		If 'objStream.AtEnd {
			Set line = objStream.ReadLine()
			set stat = ##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(line,,.pObject)
			If ##class(App.Rules).Check(pObject, .msg) {
				Write "{ ""Status"" : 1,"
				Write "  ""Message"" : ""Transaction approved by Trade Compliance."" "
				Write "}"
			} else {
				Write "{ ""Status"" : 0,"
				Write "  ""Message"" : ""Transaction refused by Trade Compliance violating Rule"", "
				Write "  ""Rules"" : [ "
				For iMsg=1:1:msg {
					If iMsg>1 Write ","
					Write "  { ""Rule"" : """,$list(msg(iMsg),1),""", "
					Write "    ""Paragraph"" : """,$zcvt($list(msg(iMsg),2),"O","JSON"),""" "
					Write " }"
				}				
				Write "  ]"
				Write "}"
			}
		}
	} catch e {
        Set status=e.AsStatus()
        Do ..ErrorHandler(status)
		set ^dwerr($i(^dwerr))=$ze
	}
	Quit tSC
}

ClassMethod SavePortfolio(pfId As %Integer) As %Status
{
	#Dim status as %Status = $$$OK
	#Dim e as %Exception.AbstractException
	Try {
	  	set objStream=%request.Content
		If 'objStream.AtEnd {
			Set line = objStream.ReadLine()
			set stat = ##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(line,,.pObject)
			
			If 1 {
				Set objPortfolio = $Select('$Data(pfId):"",1:##class(Data.Portfolio).%OpenId(pfId))
				If objPortfolio = "" {
					Set objPortfolio = ##class(Data.Portfolio).%New()
					Do objPortfolio.CustomerSetObjectId(pObject.Customer)
				}
				Set objPortfolio.Security  = pObject.Security
				Set objPortfolio.ISIN  = pObject.ISIN
				Set objPortfolio.Ticker  = pObject.Ticker
				Set objPortfolio.Quantity  = pObject.Quantity
				Set objPortfolio.Position  = pObject.Position
				Set objPortfolio.Currency  = pObject.Currency
				Set objPortfolio.Rating    = pObject.Rating
				Set objPortfolio.Industry  = pObject.Industry
				Set status = objPortfolio.%Save()
				If $$$ISOK(status) {
					Set id = objPortfolio.%Id()
					Do ..StatusHandler("Portfolio saved with id = "_id)
				} else {
  				 	Do ..ErrorHandler(status)
				}
			}
		}
	} catch e {
        Set status=e.AsStatus()
        Do ..ErrorHandler(status)
		set ^dwerr($i(^dwerr))=$ze
	}
    Quit $$$OK
}

ClassMethod DeletePortfolio(pfId As %Integer) As %Status
{
	#Dim status as %Status = $$$OK
	#Dim e as %Exception.AbstractException
	Try {
		&sql(Delete From Data.Portfolio
			 Where (ID = :pfId))
		If SQLCODE = 0 {
			Do ..StatusHandler("Item deleted with id = "_%ROWID)
		} else {
	  		 Do ..ErrorHandlerCode(SQLCODE, "SQL error")
		}
	} catch e {
        Set status=e.AsStatus()
        Do ..ErrorHandler(status)
		set ^dwerr($i(^dwerr))=$ze
	}
    Quit $$$OK
}

/******************************************************************
        error handling
*******************************************************************/
ClassMethod ErrorHandler(status)
{
	#Dim errorcode, errormessage as %String;
	set errorcode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	set errormessage=##class(%SYSTEM.Status).GetOneStatusText(status)
	Quit ..ErrorHandlerCode(errorcode,errormessage)
}

ClassMethod ErrorHandlerCode(errorcode, errormessage) As %Status
{
	Write "{"
	Write " ""ErrorNum"" : """,errorcode,""","
	Write " ""ErrorMessage"" : """,$ZCVT(errormessage,"O","HTML"),""""
	write "}"

	If $Data(%response) {
		Set %response.ContentType="application/json"
	}
	quit $$$OK
}

ClassMethod StatusHandler(Message As %String) As %Status
{
	Write "{"
	Write " ""Status"" : """,1,""","
	Write " ""Message"" : """,Message,""""
	write "}"

	If $Data(%response) {
		Set %response.ContentType="application/json"
	}
	Quit $$$OK
}

}

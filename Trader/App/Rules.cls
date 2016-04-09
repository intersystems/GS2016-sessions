Class App.Rules
{

ClassMethod Test()
{
	Set ok = ..CheckParam(1, "Stock", "USD", 100, 123.45, 12345, "Long", "Technology", "AAA", .msg, 0)
	If 'ok Write "Stock USD Long Tech AAA",! For i=1:1:msg Write "--> ",msg(i),!
	Set ok = ..CheckParam(1, "Stock", "CAD", 100, 123.45, 12345, "Long", "Technology", "AAA", .msg, 0)
	If 'ok Write "Stock CAD Long Tech ",! For i=1:1:msg Write "--> ",msg(i),!
	Set ok = ..CheckParam(1, "Stock", "CAD", 100, 123.45, 12345, "Long", "Tobacco", "AAA", .msg, 0)
	If 'ok Write "Stock CAD Long Tobacco ",! For i=1:1:msg Write "--> ",msg(i),!
	Set ok = ..CheckParam(1, "Stock", "USD", 100, 123.45, 12345, "Long", "Alcohol", "AAA", .msg, 0)
	If 'ok Write "Stock USD Long Tobacco ",! For i=1:1:msg Write "--> ",msg(i),!
}

ClassMethod CheckParam(custId, security, currency, quantity, quote, value, position, industry, rating, ByRef msg, verbose As %Boolean = 0) As %Boolean
{
	If verbose Write "Transaction : ",security," ",currency," ",quantity," x ",quote," = ",value," (",position,") in ",industry," > ",rating," : ",!
	#Dim obj as %Object
	Kill msg
	Set obj={"Customer":custId,
			 "Security":security,
	         "Currency":currency,
	         "Quantity":quantity,
	         "Quote"   :quote,
	         "Value"   :value,
	         "Position":position,
	         "Industry":industry,
	         "Rating"  :rating}
	Return ..Check(obj, .msg, verbose)
}

ClassMethod Check(obj, ByRef msg As %String, verbose As %Boolean = 0) As %Boolean
{
	#Dim message, paragraph, custName, mapping as %String
	#Dim sqlStatement as %SQL.Statement = ##class(%SQL.Statement).%New()
	#Dim sqlResult as %SQL.StatementResult
	#Dim idRule, custId as %Integer
	#Dim ok as %Boolean
	#Dim allOk as %Boolean = 1
	#Dim sc as %Status
	Do ..GetMappings(.mapping)
	;loop thru rules for customer
	Set custId = obj.Customer
	Set custName = ##class(Data.Customer).NameGetStored(custId)
	Set sc = sqlStatement.%Prepare("Select ID From Demo_RulesBuilder.SavedRule Where (DocumentName = ?) or (Comments = ?)")
	If sc {
		Set sqlResult = sqlStatement.%Execute(custName, custId)	
		While sqlResult.%Next() {
			Set idRule = sqlResult.%Get("ID")
			Kill message
			Set ok = ..CheckRule(idRule, obj, .mapping, .message, .paragraph, verbose)
			If 'ok {
				Set msg($i(msg)) = $lb(message, paragraph)
				Set allOk = 0
			}
		}
	}
	Return allOk
}

ClassMethod CheckRule(idRule, obj, ByRef mapping, ByRef message, ByRef paragraph, verbose As %Boolean = 0) As %Boolean
{
	#dim iElem as %Integer
	#dim dictUri, data, property, val as %String
	#dim negation as %Boolean = 0
	#dim conditionOk as %Boolean = 1
	#dim objElem as Demo.RulesBuilder.ExtractionResultElement
	#dim objRule as Demo.RulesBuilder.SavedRule
	Set objRule=##class(Demo.RulesBuilder.SavedRule).%OpenId(idRule)
	If verbose Write "-> rule ",idRule," ",objRule.RuleText," : ",!
	;for each rule :
	For iElem = 1:1:objRule.ExtractionResult.MatchedElements.Count() {
		Set objElem=objRule.ExtractionResult.MatchedElements.GetAt(iElem)
		If verbose {
			write iElem,":"
			write objElem.Literal,?20,objElem.RuleElement.Name,?40,objElem.RuleElement.Count,?60,objElem.RuleElement.Negation,?70,objElem.Negation,!
		}
		Set dictUri=objElem.RuleElement.Name
		If ((objElem.RuleElement.Negation="rule")!(objElem.RuleElement.Negation="negative"))&(objElem.Negation=1) {
			Set negation = 'negation
			If verbose Write "rule"," -> Negation : ",negation,!					
		}
		If $E(dictUri,1)=":" {
			;get value from mapping
			Set data = $Get(mapping(dictUri))
			if data[":" {
				set property = $piece(data,":",1)
				set val = $piece(data,":",2)
				Set conditionOk = ($property(obj,property)=val)
				If verbose Write property,":",val,":",conditionOk, "(",negation,")",!
				Set message = objRule.RuleText _ "( "_property _ " = " _ $property(obj,property)_")"
				Set paragraph = objRule.Paragraph.FullTextContents
			} else {
				If data="negation" {
					Set negation = 'negation
					If verbose Write data," -> Negation : ",negation,!
				}
			}
		} else {
			;Set conditionOk = 1
		}
	}
	If negation Set conditionOk = 'conditionOk
	;Write "condition=",conditionOk,!
	If verbose Write "-> result : ",conditionOk,! Zwrite message
	Return conditionOk
}

ClassMethod GetMappings(ByRef mapping As %String)
{
	;mapping(dictionary uri) = property:value
	set mapping(":instr:common stock")     = "Security:Stock"
	set mapping(":instr:bonds")            = "Security:Bond"
	set mapping(":instr:stocks")           = "Security:Stock"
	set mapping(":trading:long-position")  = "Position:Long"
	set mapping(":trading:short-position") = "Position:Short"
	set mapping(":measure:USD")            = "Currency:USD" 
	set mapping(":org:tobacco")            = "Industry:Tobacco"
	set mapping(":org:reinsurer")          = "Industry:Insurance"
	set mapping(":org:insurer")            = "Industry:Insurance"
	set mapping(":org:alcohol")            = "Industry:Alcohol"
	set mapping(":logic:other-than")       = "negation"
	set mapping(":logic:excluding")        = "negation"
}

}

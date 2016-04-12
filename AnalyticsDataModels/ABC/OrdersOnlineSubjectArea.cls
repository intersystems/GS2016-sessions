/// Example of a DeepSee Subject Area.<br/>
/// This includes only the online orders from the Orders B cube.
Class ABC.OrdersOnlineSubjectArea Extends %DeepSee.SubjectArea [ DependsOn = ABC.CubeB, ProcedureBlock ]
{

/// SubjectArea definition from Architect.
XData SubjectArea [ XMLNamespace = "http://www.intersystems.com/deepsee/subjectarea" ]
{
<subjectArea xmlns="http://www.intersystems.com/deepsee/subjectarea" 
  name="Orders Online" baseCube="Orders B" caption="Orders Onine" 
  filterSpec="[ORDER TYPE].[H1].[ORDER TYPE].&amp;[Online]">
  <measure name="Extended Price" displayName="Revenue" hidden="false"></measure>
  <calculatedMember name="Current Value" dimension="measures" hidden="true"></calculatedMember>
</subjectArea>
}

Parameter DOMAIN = "ABC";

}

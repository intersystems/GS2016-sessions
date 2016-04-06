Class SN.DefaultInstaller Extends %RegisteredObject
{

XData SNInstall [ XMLNamespace = INSTALLER ]
{
<Manifest>
	<SystemSetting Name="Config.config.MaxServers"  Value="64"/>      
	<SystemSetting Name="Config.config.MaxServerConn"  Value="64"/>      
	<SystemSetting Name="Config.SQL.SaveMAC"  Value="1"/>      

	<Namespace Name="%SYS">
         <Invoke Class="SN.DefaultInstaller" Method="EnableECPService" CheckStatus="1"/>
      </Namespace>
   </Manifest>
}

ClassMethod EnableECPService() As %Status
{
 //w ##class(Security.Services).Get("%Service_ECP",.props)
 s props("Enabled")=1
 s sc=##class(Security.Services).Modify("%Service_ECP",.props)
 quit sc
}

ClassMethod setup(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
   #; Let XGL document generate code for this method. 
   Quit ##class(%Installer.Manifest).%Generate(%compiledclass,%code, "SNInstall")
}

}

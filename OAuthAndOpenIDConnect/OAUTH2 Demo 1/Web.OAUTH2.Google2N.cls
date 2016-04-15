Include %occInclude

Class Web.OAUTH2.Google2N Extends %CSP.Page
{

Parameter OAUTH2APPNAME = "Google";

Parameter OAUTH2ROOT = "https://www.googleapis.com";

Parameter OAUTH2CLIENTREDIRECTURI = "https://localhost/csp/google/Web.OAUTH2.Google2N.cls";

ClassMethod OnPage() As %Status
{
	&html<<html>
	 <head>
	  <meta name="description" content="website description" />
      <meta name="keywords" content="website keywords, website keywords" />
      <meta http-equiv="content-type" content="text/html; charset=windows-1252" />
      <link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Tangerine&amp;v1" />
      <link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Yanone+Kaffeesatz" />
      <link rel="stylesheet" type="text/css" href="https://localhost/csp/broker/style/style.css" />
	 </head>
	 <body>
	 <div id="main">
	    <div id="header">
	      <div id="logo">
	        <h1>Integrating Oauth 2.0 and OpenID Connect</h1>
	        <div class="slogan">Let's see what we got here!</div>
	      </div>
	      <div id="menubar">
	        <ul id="menu">
	          <!-- put class="current" in the li tag for the selected page - to highlight which page you're on -->
	          <li><a href="http://localhost/demo/">Home</a></li>
	          <li class="current"><a href="https://localhost/csp/google/Web.OAUTH2.Google1N.cls">Demo 1</a></li>
	          <li><a href="https://dk-gs2016/csp/oauth2/Web.OAUTH2.Cache1N.cls">Demo 2</a></li>
	          <li><a href="http://localhost/demo/tutorial.html">Tutorial</a></li>
	        </ul>
	      </div>
	    </div>
	    <div id="site_content">
		<div id="sidebar_container">
	        <img class="paperclip" src="style/paperclip.png" alt="paperclip" />
	        <div class="sidebar">
	        <!-- insert your sidebar items here -->
	        <h3>About this demo</h3>
	        <h4>Global Summit</h4>
	        <h5>April 2016</h5>
	        <p>Please post you comments and ask your questions to the <br /><a href="https://community.intersystems.com/">InterSystems Developer Community!</a></p>
	        </div>
			<img class="paperclip" src="style/paperclip.png" alt="paperclip" />
	        <div class="sidebar">
	        <!-- insert your sidebar items here -->
	        <h3>Where to go from here...</h3>
			<ul>
			<li>For detailed technical discussions contact <b>Marvin Tener</b> in the <b>Developer Zone</b></li>
			<li>You may also be interested in these <a href="http://localhost/demo/whatnext.html">sessions</a></li>
			<li>Please fill-in feedback form</li>
			<li>Don't forget to participate at the unconference next the door!</li>
			<li>Contact your Sales Enginner for additional post-conference engagements</li>
			</ul>
	        </div>
        </div>
        <div id="content">
	 >
	
	// Check if we have an access token
	set scope="https://www.googleapis.com/auth/userinfo.email "_
		"https://www.googleapis.com/auth/userinfo.profile "_
		"https://www.googleapis.com/auth/drive.metadata.readonly "_
		"https://www.googleapis.com/auth/calendar.readonly"

	set isAuthorized=##class(%SYS.OAuth2.AccessToken).IsAuthorized(..#OAUTH2APPNAME,,scope,.accessToken,.idtoken,.responseProperties,.error)
	if isAuthorized {	
		// Google has no introspection endpoint - nothing to call - the introspection endpoint and display result -- see RFC 7662.	

		w "<h3>Data from <span style='color:red;'>GetUserInfo API</span></h3>"
		// userinfo has special API, but could be also retrieved by just calling Get() method with appropriate url		
		try {
		set tHttpRequest=##class(%Net.HttpRequest).%New()
			$$$THROWONERROR(sc,##class(%SYS.OAuth2.AccessToken).AddAccessToken(tHttpRequest,"query","GOOGLE",..#OAUTH2APPNAME))
			$$$THROWONERROR(sc,##class(%SYS.OAuth2.AccessToken).GetUserinfo(..#OAUTH2APPNAME,accessToken,,.jsonObject))
			w jsonObject.$toJSON()
		} catch (e) {
			w "<h3><span style='color: red;'>ERROR: ",$zcvt(e.DisplayString(),"O","HTML")_"</span></h3>"		
		}

		/******************************************
		*                                         *
		*      Retrieve info from other APIs      *
		*                                         *
		******************************************/
		w "<hr>"

		do ..RetrieveAPIInfo("/drive/v3/files")

		do ..RetrieveAPIInfo("/calendar/v3/users/me/calendarList")

	}

	&html<</div>
    </div>
    <div id="footer">
      <p>Copyright &copy; HTML5 Templates | <a href="http://validator.w3.org/check?uri=referer">HTML5</a> | <a href="http://jigsaw.w3.org/css-validator/check/referer">CSS</a> | <a href="http://www.html5webtemplates.co.uk">Website templates</a></p>
    </div>
  </div>
  </body>
  </html>>
	Quit $$$OK
}

ClassMethod RetrieveAPIInfo(api As %String)
{
	w "<h3>Data from <span style='color:red;'>"_api_"</span></h3><p>"
	
	try {
		set tHttpRequest=##class(%Net.HttpRequest).%New()
		$$$THROWONERROR(sc,##class(%SYS.OAuth2.AccessToken).AddAccessToken(tHttpRequest,"query","GOOGLE",..#OAUTH2APPNAME))
		$$$THROWONERROR(sc,tHttpRequest.Get(..#OAUTH2ROOT_api))

		set tHttpResponse=tHttpRequest.HttpResponse
		s tJSONString=tHttpResponse.Data.Read()
		if $e(tJSONString)'="{" {
			// not a JSON
			d tHttpResponse.OutputToDevice()
		} else {			
			w tJSONString
			w "<hr/>"
			/*
			// new JSON API
			&html<<table border=1 style='border-collapse: collapse'>>
			s tJSONObject=##class(%Object).$fromJSON(tJSONString)
			set iterator=tJSONObject.$getIterator()
		    while iterator.$getNext(.key,.value) {
			    
			    if $isobject(value) {
				    set iterator1=value.$getIterator()
				    w "<tr><td>",key,"</td><td><table border=1 style='border-collapse: collapse'>"
				    while iterator1.$getNext(.key1,.value1) {
						
						if $isobject(value1) {
						    set iterator2=value1.$getIterator()
						   	w "<tr><td>",key1,"</td><td><table border=0 style='border-collapse: collapse'>"
						    while iterator2.$getNext(.key2,.value2) {
					        	write !, "<tr><td>",key2, "</td><td>",value2,"</td></tr>"									 	
						    }
						    // this way we can go on and on into the embedded objects/arrays
							w "</table></td></tr>"
						} else {
				        	write !, "<tr><td>",key1, "</td><td>",value1,"</td></tr>"				
						}
				    }
					w "</table></td></tr>"
			    } else {
		        	write !, "<tr><td>",key, "</td><td>",value,"</td></tr>"
			    }
		    }				
		&html<</table><hr/>
		>
		*/
		}
	} catch (e) {
		w "<h3><span style='color: red;'>ERROR: ",$zcvt(e.DisplayString(),"O","HTML")_"</span></h3>"
	}
}

/// Event handler for <b>PreHTTP</b> event: this is invoked before
/// the HTTP headers for a CSP page have been sent.  All changes to the
/// <class>%CSP.Response</class> class, such as adding cookies, HTTP headers,
/// setting the content type etc. must be made from within the OnPreHTTP() method.
/// Also changes to the state of the CSP application such as changing
/// %session.EndSession or %session.AppTimeout must be made within the OnPreHTTP() method.
/// It is prefered that changes to %session.Preserve are also made in the OnPreHTTP() method
/// as this is more efficient, although it is supported in any section of the page.
/// Return <b>0</b> to prevent <method>OnPage</method> from being called.
ClassMethod OnPreHTTP() As %Boolean [ ServerOnly = 1 ]
{
	set scope="https://www.googleapis.com/auth/userinfo.email "_
		"https://www.googleapis.com/auth/userinfo.profile "_
		"https://www.googleapis.com/auth/drive.metadata.readonly "_
		"https://www.googleapis.com/auth/calendar.readonly"
	set sc=##class(%SYS.OAuth2.Authorization).GetAccessTokenAuthorizationCode(..#OAUTH2APPNAME,
		scope,..#OAUTH2CLIENTREDIRECTURI,.properties)
	quit +sc
}

}

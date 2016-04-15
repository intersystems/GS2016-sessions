Class Web.OAUTH2.Cache2N Extends %CSP.Page
{

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
          <li><a href="https://localhost/csp/google/Web.OAUTH2.Google1N.cls">Demo 1</a></li>
          <li class="current"><a href="https://dk-gs2016/csp/oauth2/Web.OAUTH2.Cache1N.cls">Demo 2</a></li>
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
        <!-- insert the page content here -->
		<p>>

	set applicationName="demo client"
	// Check if we have an access token
	set isAuthorized=##class(%SYS.OAuth2.AccessToken).IsAuthorized(applicationName,,"",.accessToken,.idtoken,.responseProperties,.error)
	
	// Continue with further checks if an access token exists.
	// Below are all possible tests and may not be needed in all cases.
	// The JSON object which is returned for each test is just displayed.
	if isAuthorized {
		write "Authorized.<br>",!
		write "<br>",!
		
		// Validate and get the details from the access token, if it is a JWT.
		set valid=##class(%SYS.OAuth2.Validation).ValidateJWT(applicationName,accessToken,"scope1 scope2",,.jsonObject,.securityParameters,.sc)
		if $$$ISOK(sc) {
			if valid {
				write "Valid JWT"_"<br>",!	
			} else {
				write "Invalid JWT"_"<br>",!	
			}
			write "Access token="
			do jsonObject.$toJSONFormat()
			write "<br>",!
		} else {
			write "JWT Error="_..EscapeHTML($system.Status.GetErrorText(sc))_"<br>",!	
		}
		write "<br>",!

		// Call the introspection endpoint and display result -- see RFC 7662.
		set sc=##class(%SYS.OAuth2.AccessToken).GetIntrospection(applicationName,accessToken,.jsonObject)
		if $$$ISOK(sc) {
			write "Introspection="
			do jsonObject.$toJSONFormat()
			write "<br>",!
		} else {
			write "Introspection Error="_..EscapeHTML($system.Status.GetErrorText(sc))_"<br>",!	
		}
		write "<br>",!
		
		if idtoken'="" {
			// Validate and display the IDToken -- see OpenID Connect Core specification.
			set valid=##class(%SYS.OAuth2.Validation).ValidateIDToken(applicationName,idtoken,accessToken,,,.jsonObject,.securityParameters,.sc)
			if $$$ISOK(sc) {
				if valid {
					write "Valid IDToken"_"<br>",!	
				} else {
					write "Invalid IDToken"_"<br>",!	
				}
				write "IDToken="
				do jsonObject.$toJSONFormat()
				write "<br>",!
			} else {
				write "IDToken Error="_..EscapeHTML($system.Status.GetErrorText(sc))_"<br>",!	
			}
		} else {
			write "No IDToken returned"_"<br>",!
		}
		write "<br>",!
	
		// not needed for the application logic, but provides information about user that we can pass to Delegated authentication
	
		// Call the userinfo endpoint and display the result -- see OpenID Connect Core specification.
		set sc=##class(%SYS.OAuth2.AccessToken).GetUserinfo(applicationName,accessToken,,.jsonObject)
		if $$$ISOK(sc) {
			write "Userinfo="
			do jsonObject.$toJSONFormat()
			write "<br>",!
		} else {
			write "Userinfo Error="_..EscapeHTML($system.Status.GetErrorText(sc))_"<br>",!	
		}
		write "<br>",!
		
		
		/***************************************************
		*                                                  *
		*   Call the resource server and display result.   *
		*                                                  *
		***************************************************/
		
		
		// option 1 - resource server is just THIS csp application
		//          - you need to do nothing but just return data
		//			- or you can use privileged routine to assign appropriate role(s) per scope information and then return data (in case you need proper security context within Cache database)


		// option 2 - alternatively, you can use delegated authentication and call into another CSP application (with delegated authentication protection)
		// 			- that's what we do here in this demo
		
		
		
		write "Call resource server","<br>",!
		set httpRequest=##class(%Net.HttpRequest).%New()
		// AddAccessToken adds the current access token to the request.
		set sc=##class(%SYS.OAuth2.AccessToken).AddAccessToken(httpRequest,,"sslunittest",applicationName)
		if $$$ISOK(sc) {
			set sc=httpRequest.Get("https://dk-gs2016/csp/portfolio/oauth2test.demoResource.cls")
			//set sc=httpRequest.Get("https://dk-gs2016/csp/oauth2/oauth2test.demoResource.cls")
		}
		if $$$ISOK(sc) {
			set body=httpRequest.HttpResponse.Data
			if $isobject(body) {
				do body.Rewind()
				set body=body.Read()
			}
			write body,"<br>",!
		}
		if $$$ISERR(sc) {
			write "Resource Server Error="_..EscapeHTML($system.Status.GetErrorText(sc))_"<br>",!	
		}
		write "<br>",!

	} else {
		write "Not Authorized.<br>",!
		If $isobject(error) {
			write "Authorization Error="_..EscapeHTML(error.AsString())_"<br>",!
		}
	}	
	&html<
	</div>
	    </div>
	    <div id="footer">
	      <p>Copyright &copy; HTML5 Templates | <a href="http://validator.w3.org/check?uri=referer">HTML5</a> | <a href="http://jigsaw.w3.org/css-validator/check/referer">CSS</a> | <a href="http://www.html5webtemplates.co.uk">Website templates</a></p>
	    </div>
	  </div>
	</body>
	</html>>
	Quit $$$OK
}

}

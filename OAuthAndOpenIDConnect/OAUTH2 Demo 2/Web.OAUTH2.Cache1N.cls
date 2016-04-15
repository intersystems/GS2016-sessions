Class Web.OAUTH2.Cache1N Extends %CSP.Page
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
  
  
  <style>
  
  .portalLogo {
    color: rgb(53,107,141);
    position: relative;
    font-weight: bold;
    font-size: 12pt;
    top: 0px;
    right: 0px;
    border: 2px solid rgb(53,107,141);
    padding: 2px;
    padding-left: 5px;
    padding-right: 5px;
    border-radius: 4px;
    background: #E0E0F0;
}

.portalLogoBox {
    position: static;
    padding: 10px;
    padding-bottom: 4px;
    padding-right: 30px;
    text-align: center;
}

.portalLogoSub {
    position: relative;
    color: #808080;
    font-size: 8pt;
    top: 3px;
    right: 0px;
}
  
  </style>
  
  
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
        <h1>Authenticating and Authorizing against Cache&acute; OAuth2 provider</h1>
        <p>This page demo shows how to call Cache&acute; API functions using OAuth2 authorization.
        <p>We are going to call Cache&acute; authentication and authorization server to grant our application access to data stored at another
        Cache&acute; server.
        
        >
	// Check if already authorized
	set isAuthorized=##class(%SYS.OAuth2.AccessToken).IsAuthorized("demo client",,"",.accessToken,.idtoken,.responseProperties,.error)
	if $isobject(error) {
		write "IsAuthorized Error="_..EscapeHTML(error.AsString())_"<br>",!
	}

	// If authorized already, revoke the existing access token
	// using revocation endpoint -- see RFC 7009.
	if isAuthorized {
		set sc=##class(%SYS.OAuth2.AccessToken).RevokeToken("demo client",accessToken)
		if $$$ISERR(sc) {
			write "Revocation Error="_..EscapeHTML($system.Status.GetErrorText(sc))_"<br>",!	
		}
	}

	// Get the url for authorization endpoint with appropriate redirect and scopes.
	// The returned url is used in the button below.
	set redirect="https://dk-gs2016/csp/oauth2/Web.OAUTH2.Cache2N.cls"
	set scope="openid profile scope1 scope2"
	set url=##class(%SYS.OAuth2.Authorization).GetAuthorizationCodeEndpoint("demo client",scope,redirect,.properties,.isAuthorized,.sc)
	if $$$ISERR(sc) {
		write "GetAuthorizationCodeEndpoint Error="_..EscapeHTML($system.Status.GetErrorText(sc))_"<br>",!
		quit
	}
	
	
	
	&html<
	<div class="portalLogoBox"><a class="portalLogo" href="#(url)#">Authorize for <b>ISC</b></a></div>
	
	
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

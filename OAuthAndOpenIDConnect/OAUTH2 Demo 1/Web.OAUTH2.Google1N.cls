Class Web.OAUTH2.Google1N Extends %CSP.Page
{

Parameter OAUTH2CLIENTREDIRECTURI = "https://localhost/csp/google/Web.OAUTH2.Google2N.cls";

Parameter OAUTH2APPNAME = "Google";

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
        <!-- insert the page content here -->
        <h1>Google OAuth2 API</h1>
        <p>This page demo shows how to call Google API functions using OAuth2 authorization.
        <p>We are going to retrieve information about user and his/her Google Drive files as well as calendar entries.
        >
        
	// Check if already authorized
	set isAuthorized=##class(%SYS.OAuth2.AccessToken).IsAuthorized(..#OAUTH2APPNAME,,"",.accessToken,
		.idtoken,.responseProperties,.error)
	if $isobject(error) {
		write "<p>IsAuthorized Error="_..EscapeHTML(error.AsString())_"<br>",!
	}

	if isAuthorized {
		set sc=##class(%SYS.OAuth2.AccessToken).RevokeToken(..#OAUTH2APPNAME,accessToken)
		if $$$ISERR(sc) {
			//write "<p>Revocation Error="_..EscapeHTML($system.Status.GetErrorText(sc))_"<br>",!	
		}
	}

	// TRICK - our API expects idtoken, so we need to put openid into the scope
	set scope="openid https://www.googleapis.com/auth/userinfo.email "_
	"https://www.googleapis.com/auth/userinfo.profile "_
	"https://www.googleapis.com/auth/drive.metadata.readonly "_
	"https://www.googleapis.com/auth/calendar.readonly"
	set properties("approval_prompt")="force"
	set properties("include_granted_scopes")="true"
	
	set url=##class(%SYS.OAuth2.Authorization).GetAuthorizationCodeEndpoint(..#OAUTH2APPNAME,scope,
		..#OAUTH2CLIENTREDIRECTURI,.properties,.isAuthorized,.sc)	
	w !,"<p><a href='"_url_"'><img border='0' alt='Google Sign In' src='images/google-signin-button.png' ></a>"	

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

}

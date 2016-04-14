**LDAP: Beyond the Simple Schema** session on [InterSystems Community](https://community.intersystems.com/post/global-summit-2016-ldap-beyond-simple-schema)

# LDAP-Beyond the Simple Schema 

The code provide in this example will demostrate how to interact with LDAP
programatically.  We will utilize Cache Delegated Authentication to take 
advantage of LDAP to authenticate the user and provide parameters for an
application (simulated) security model.

This example will rely on the following pieces:
* Cache 2016.1 - though any recent version should work
* OpenLDAP version 2.4

## OpenLDAP Environment
The Global Summit session that utilized this code setup a virtual machine
running on CentOS 7 to run the OpenLDAP server.  If you don't have an 
OpenLDAP enironment this setup is recommended.  
[Setting up OpenLDAP on CentOS 7](http://www.server-world.info/en/note?os=CentOS_7&p=openldap)

## This archive contains the following files

The following files are provided:
* **Cache.ldif** - an LDAP definition file for the Cache properties (for information only)
* **GSDemoAppSchema.ldif** - an LDAP definition file to add the application schema to OpenLDAP
* **GSusers.ldiff** - an LDAP definition file to add 3 users to the LDAP database
* **ZAUTHENTICATE.mac** - Contains the authentication code used in the presentation.  
	* *You will have to update the IP address of the LDAP server.*
* **LDAP setup.gof** - export file containing all the globals to support the examples security environment.


## Setting up the example
Instructions:
1. Install Cache
2. Setup your OpenLDAP environment. If there is no OpenLDAP server available
	follow the insrtuctions in the link under *OpenLDAP Environment*
	2a. transfer the GSDemoAppSchema.ldif and GSusers.ldif file to your LDAP server
	2b. run the *ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/MyApp2.ldif*
			command to add our application user security properties to LFAP
	2c. run the *ldapadd -D cn=Manager,dc=intersystems,dc=com -W -f GSusers.ldif*
			to add some sample users to the LDAP server.  Note you should change dc=intersystems,dc=com
			to be the domain name reference as defined on the server.
3. determine the network name ot IP Afdress for your LDAP server.
4. Open the Ateleir IDE
5. Open a connection the %SYS namespace
6. Import the ZAUTHENTICATE.xml file
7. open the System Management Portal I
	7a. go to Operationa->Globals.
	7b. import the *LDAP setup.gof* file. 
8. Update the ^LDAPenv("server") global node to correct the IP Address or server name 
	 to be used (was 192.168.1.233)
	 
## Code Examples
There are two example provided in the code.  These are labeled Example 1 and Example 2 with block
comments. The two ezamples are mutually exvlusive so you will need to comment and
umcomment the labeled code blocks as necessary.

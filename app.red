Red/System []

connString: "hostaddr = '127.0.0.1' port='5432' dbname = 'testdb' user=postgres"

#enum ConnStatusType! [
	CONNECTION_OK
	CONNECTION_BAD
	CONNECTION_STARTED
	CONNECTION_MADE		
	CONNECTION_AWAITING_RESPONSE
									
	CONNECTION_AUTH_OK
								 
	CONNECTION_SETENV			
	CONNECTION_SSL_STARTUP
	CONNECTION_NEEDED	
	CONNECTION_CHECK_WRITABLE
								 
	CONNECTION_CONSUME	
								
	CONNECTION_GSS_STARTUP
	CONNECTION_CHECK_TARGET		
]

#import [
   "libpq.dll" cdecl [
       conn: "PQconnectdb" [
           connString    [c-string!]
           return: [integer!]
       ]   
	   dbname: "PQdb" [
		PGconn [integer!]
		return: [c-string!]
	   ]
	   
	   get-connect-status: "PQstatus" [
		PGconn [integer!]
		return: [ConnStatusType!]
	   ]

	   get-if-connection-need-pass: "PQconnectionNeedsPassword" [
		PGconn [integer!]
		return: [ConnStatusType!]
	   ]

	   ; Closes the connection to the server. Also frees memory
	   close-connection: "PQfinish" [
		PGconn [integer!]
	   ]		   	    
	   
	   close-connection: "PQreset" [
		PGconn [integer!]
	   ]

   ]
]

conn-obj: conn connString
connect-status: get-connect-status conn-obj
either not connect-status = CONNECTION_OK
[
	print "Can't connect"
]
[
	print "Connected"
]

if (get-if-connection-need-pass conn-obj) = 1
[
	print "password required"
]

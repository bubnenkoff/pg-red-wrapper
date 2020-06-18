Red []
#system [
connString: "hostaddr = '127.0.0.1' port='5432' dbname = 'testdb' user=postgres"

; https://github.com/postgres/postgres/blob/e78b93094518b1e262cba8115470f252dde6f446/src/interfaces/libpq/libpq-fe.h#L54
; PGresult success is: PGRES_TUPLES_OK or PGRES_SINGLE_TUPLE

#enum ConnStatusType! [
	CONNECTION_OK
	CONNECTION_BAD
	; The existence of these should never be relied upon
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

#enum ExecStatusType! [
	PGRES_EMPTY_QUERY: 0		; empty query string was executed 
	PGRES_COMMAND_OK			; a query command that doesn't return
								;  anything was executed properly by the
								;  backend 
	PGRES_TUPLES_OK				; a query command that returns tuples was
								;  executed properly by the backend, PGresult
								;  contains the result tuples 
	PGRES_COPY_OUT				; Copy Out data transfer in progress 
	PGRES_COPY_IN				; Copy In data transfer in progress 
	PGRES_BAD_RESPONSE			; an unexpected response was recv'd from the
								;  backend 
	PGRES_NONFATAL_ERROR		; notice or warning message 
	PGRES_FATAL_ERROR			; query failed 
	PGRES_COPY_BOTH				; Copy In/Out data transfer in progress 
	PGRES_SINGLE_TUPLE			; single tuple from larger resultset 

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
	   
	   ; if a working connection is lost.
	   reset-connection: "PQreset" [
		PGconn [integer!]
	   ]

	   ; https://www.postgresql.org/docs/10/libpq-exec.html
	   prepare-query: "PQprepare" [
		PGconn [integer!]
		stmtName [c-string!] ; can be "" to create an unnamed statement
		sql-query [c-string!]
		nParams [integer!]
		paramTypes [integer!]
		return: [integer!] ; PGresult A null result indicates out-of-memory or inability to send the command at all 
	   ]

	   ; Submits a command to the server and waits for the result.
	   exec-query: "PQexec" [
		PGconn [integer!]
		sql-query [c-string!]
		return: [integer!] ; PGresult PQresultStatus function should be called to check the return value for any errors
	   ]	   

	   get-query-status: "PQresultStatus" [
		PGresult [integer!] ; not connection but PGresult!
		return: [ExecStatusType!] ; ExecStatusType
	   ]
	   
	   ; Frees the storage associated with a PGresult. 
	   ; Every command result should be freed via PQclear when it is no longer needed.
	    free-result: "PQclear" [
		PGresult [integer!] 
	   ]

		; https://www.postgresql.org/docs/9.1/libpq-exec.html#LIBPQ-EXEC-MAIN
	    ; extract information from a PGresult
		; Returns the number of rows (tuples) in the query result
		get-result-number-of-rows: "PQntuples" [
		PGresult [integer!] ; not connection but PGresult!
		return: [integer!] 
	   ]	   

	    ; extract information from a PGresult
		; Returns the number of columns (fields) in each row of the query result.
		get-result-number-of-field: "PQnfields" [
		PGresult [integer!] ; not connection but PGresult!
		return: [integer!] ; 
	   ]	   

	    ; extract information from a PGresult
		; Returns the column name
		get-result-column-name: "PQfname" [
		PGresult [integer!] ; not connection but PGresult!
		column_number [integer!]
		return: [integer!] ; 
	   ]	   	   

	    ; extract information from a PGresult
		; Returns a single field value of one row of a PGresult
		; Row and column numbers start at 0
		get-result-single-value: "PQgetvalue" [
		PGresult [integer!] ; not connection but PGresult!
		row_number [integer!]
		column_number [integer!]
		return: [c-string!] 
		]

	    ; extract information from a PGresult
		; Returns the number of rows affected by the SQL command.
		; This function returns a string containing the number of rows affected by the SQL statement
		get-result-affected-number: "PQcmdTuples" [
		PGresult [integer!] ; not connection but PGresult!
		return: [c-string!] 
		]		

	    ; extract information from a PGresult
		; Returns the OID of the inserted row
		; Otherwise, this function returns InvalidOid
		get-result-oid-inserted-row: "PQoidValue" [
		PGresult [integer!] ; not connection but PGresult!
		return: [integer!] ; Oid 
		]		

	    ; extract information from a PGresult
		; Returns the data type associated with the given column number
		get-result-columns-type: "PQftype" [
		PGresult [integer!] ; not connection but PGresult!
		column_number [integer!]
		return: [integer!] ; Oid 
		]	

   ]
]
]

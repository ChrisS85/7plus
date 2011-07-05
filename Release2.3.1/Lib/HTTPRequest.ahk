
; ##################################################################################################
; ###                                       HTTPRequest                                          ###
; ##################################################################################################

HTTPRequest( url, byref in_POST_out_DATA="", byref inout_HEADERS="", options="" ) { ; --------------
; Function by [VxE] (7-1-2011). Special thanks to derRaphael for inspiring this function.
; Submits one request to the specified URL and returns the number of bytes in the response.
; 'in_POST_out_DATA' must be a variable, which may contain data to be send as POST data. If the
; request completes successfully, 'in_POST_out_DATA' receives the response data. 'inout_HEADERS'
; must be a variable, and may contain headers to use for the request. If the request completes
; successfully, 'inout_HEADERS' receives the response headers; otherwise it receives an error summary.
; NOTE: If the function encounters an error, an error message will be put into 'inout_HEADERS' and
; the function will return '0'. Since it is possible for a successful request to elicit a response
; with zero bytes, you should consult the response headers to determine if an error occured. On the
; other hand, if you are requesting data, a zero-byte response would indicate an error anyways.
; IMPORTANT: each header in 'inout_HEADERS' must conform to the following format:
; "<header name>: <header text>", and multiple headers MUST be separated by a linefeed.
; THE FOLLOWING HEADERS ARE HANDLED SPECIALLY:
; Content-Length  -> the header is added automatically IF AND ONLY IF the post data is not empty.
;                    Use the Content-Length header to override data length auto-detection.
; Content-MD5     -> the value is computed automatically IF AND ONLY IF the VALUE is left blank.
; User-Agent      -> the header is set automatically if it isn't specified or if the value is blank.
;                    NOTE: The automatic user-agent contains the script file's name and OS version.
;                    If this is not desirable, please specify your own user-agent.
; Referrer        -> is uncorrected to 'Referer' because that's the actual official header name.
;
; Any of the following may appear in the 'options' parameter:
; +Flag: FlagName    Use this to set custom flags for a request. 'FlagName' can either be the name
;                    of one of the internet flags specified below OR an exact power of 2.
;                    E.g: "+Flag: INTERNET_FLAG_FORMS_SUBMIT", OR "+Flag: 0x40"
; -Flag: FlagName    This can remove an internet flag in case you want to negate one of the default
;                    flags. Default flags include KEEP_CONNECTION, RELOAD and NO_CACHE_WRITE.
; >> FilePath        Use this to write the downloaded data to a file (overwriting the file).
;                    After the data has been written to the indicated file, the file is read into
;                    'in_POST_out_DATA' (this function still returns the number of bytes downloaded,
;                    which may not be the actual length of the data). This will overwrite the file
;                    if it already exists. This is functionally similar to URLDownloadToFile.
; Proxy: HostURL     Use this options to specify a proxy service to use when making the request.
; ProxyBypass: Host  Use this to define a host (repeat this for multiple hosts) that HTTPRequest
;                    should access directly, not through any proxy.
; Callback: func     Use this to specify a callback function to handle upload/download progress.
;                    The function should accept one or two parameters. The first parameter receives
;                    the fraction indicating the current progress (ranging from -1 to 1, where a
;                    negative value indicates data is being uploaded and a value greater than 0
;                    indicates a data download is in progress. The second parameter receives the
;                    total number of bytes that the transaction is expected to handle (in other
;                    words, parameter 2 is the Content-Length, both for the POST data and the
;                    response data). When either download or upload has finished, the callback
;                    function is called with an empty string as the first parameter.
; IMPORTANT: for users of unicode versions of AHK: if you want to submit text as POST data (either
; a query string or XML feed or other text) AND your target url does not accept UTF-16 (wide-char)
; text, HTTPRequest can automatically convert the POST text to UTF-8, but ONLY IF you supply a
; Content-Type header with the attribute 'charset=UTF-8'. E.g: Content-Type: text/xml charset=UTF-8

     Static URL_Components, WorA := "", ModuleName := "WinINet.dll"
		, Scheme, Host, User, Pass, UrlPath, ExtraInfo, URL_Components
		, INTERNET_OPEN_TYPE_DIRECT := 1, INTERNET_OPEN_TYPE_PROXY := 3, hModule := 0
		, INTERNET_FLAG_DONT_CACHE                     := 0x04000000
		, INTERNET_FLAG_NO_CACHE_WRITE                 := 0x20000000
		, INTERNET_FLAG_FORMS_SUBMIT                   := 0x00000040
		, INTERNET_FLAG_FROM_CACHE                     := 0x01000000
		, INTERNET_FLAG_FWD_BACK                       := 0x00000020
		, INTERNET_FLAG_HYPERLINK                      := 0x00000400
		, INTERNET_FLAG_IGNORE_CERT_CN_INVALID         := 0x00001000
		, INTERNET_FLAG_IGNORE_CERT_DATE_INVALID       := 0x00002000
		, INTERNET_FLAG_IGNORE_REDIRECT_TO_HTTP        := 0x00008000
		, INTERNET_FLAG_IGNORE_REDIRECT_TO_HTTPS       := 0x00004000
		, INTERNET_FLAG_KEEP_CONNECTION                := 0x00400000
		, INTERNET_FLAG_MAKE_PERSISTENT                := 0x02000000
		, INTERNET_FLAG_MUST_CACHE_REQUEST             := 0x00000010
		, INTERNET_FLAG_NEED_FILE                      := 0x00000010
		, INTERNET_FLAG_NO_AUTH                        := 0x00040000
		, INTERNET_FLAG_NO_AUTO_REDIRECT               := 0x00200000
		, INTERNET_FLAG_NO_CACHE_WRITE                 := 0x04000000
		, INTERNET_FLAG_NO_COOKIES                     := 0x00080000
		, INTERNET_FLAG_NO_UI                          := 0x00000200
		, INTERNET_FLAG_OFFLINE                        := 0x01000000
		, INTERNET_FLAG_FROM_CACHE                     := 0x08000000
		, INTERNET_FLAG_PRAGMA_NOCACHE                 := 0x00000100
		, INTERNET_FLAG_RAW_DATA                       := 0x40000000
		, INTERNET_FLAG_READ_PREFETCH                  := 0x00100000
		, INTERNET_FLAG_RELOAD                         := 0x80000000
		, INTERNET_FLAG_RESTRICTED_ZONE                := 0x00020000
		, INTERNET_FLAG_RESYNCHRONIZE                  := 0x00000800
		, INTERNET_FLAG_SECURE                         := 0x00800000
		, iFlagList := "
		( LTRIM JOIN
			,INTERNET_FLAG_DONT_CACHE,INTERNET_FLAG_NO_CACHE_WRITE,INTERNET_FLAG_FORMS_SUBMIT
			,INTERNET_FLAG_FROM_CACHE,INTERNET_FLAG_FWD_BACK,INTERNET_FLAG_HYPERLINK
			,INTERNET_FLAG_IGNORE_CERT_CN_INVALID,INTERNET_FLAG_IGNORE_CERT_DATE_INVALID
			,INTERNET_FLAG_IGNORE_REDIRECT_TO_HTTP,INTERNET_FLAG_IGNORE_REDIRECT_TO_HTTPS
			,INTERNET_FLAG_KEEP_CONNECTION,INTERNET_FLAG_MUST_CACHE_REQUEST
			,INTERNET_FLAG_NEED_FILE,INTERNET_FLAG_NO_AUTH,INTERNET_FLAG_NO_AUTO_REDIRECT
			,INTERNET_FLAG_NO_CACHE_WRITE,INTERNET_FLAG_NO_COOKIES,INTERNET_FLAG_NO_UI
			,INTERNET_FLAG_OFFLINE,INTERNET_FLAG_FROM_CACHE,INTERNET_FLAG_PRAGMA_NOCACHE
			,INTERNET_FLAG_RAW_DATA,INTERNET_FLAG_READ_PREFETCH,INTERNET_FLAG_RELOAD
			,INTERNET_FLAG_RESTRICTED_ZONE,INTERNET_FLAG_RESYNCHRONIZE,INTERNET_FLAG_SECURE,
		)"

	If ( WorA = "" ) ; Initialize Static Varaibles
	{
		WorA := A_IsUnicode ? "W" : "A" ; Either 'A' (ansi) or 'W' (wide-chars).
	; Filling the URL_Components structure with the addresses of static variables only needs to
	; happen once per script instance. For unicode, the string capacities are doubled.
	; URL_COMPONENTS structure > http://msdn.microsoft.com/en-us/library/aa385420%28v=VS.85%29.aspx
		VarSetCapacity( URL_Components, 60, 0 )
		NumPut( 60, URL_Components, 0, "Int" )
		VarSetCapacity( Scheme, 16 << !! A_IsUnicode, 0 )
		NumPut( &Scheme, URL_Components, 4, "UInt" )
		VarSetCapacity( Host, 2048 << !! A_IsUnicode, 0 )
		NumPut( &Host, URL_Components, 16, "UInt" )
		VarSetCapacity( User, 2048 << !! A_IsUnicode, 0 )
		NumPut( &User, URL_Components, 28, "UInt" )
		VarSetCapacity( Pass, 2048 << !! A_IsUnicode, 0 )
		NumPut( &Pass, URL_Components, 36, "UInt" )
		VarSetCapacity( UrlPath, 4096 << !! A_IsUnicode, 0 )
		NumPut( &UrlPath, URL_Components, 44, "UInt" )
		VarSetCapacity( ExtraInfo, 4096 << !! A_IsUnicode, 0 )
		NumPut( &ExtraInfo, URL_Components, 52, "UInt" )
	}

	inout_HEADERS := "`r`n" inout_HEADERS "`r`n" ; Padding... yes it's important.

	; Determine the length of the POST data and auto-add the content-type if needed
	If RegexMatch( inout_HEADERS, "i)\v\h*Content-Length:\h*\K(?:0x[\da-f]+|\d+)", Content_Length )
	{
		Content_Length := RegexReplace( Content_Length + 0.0, ".*\K\..*" ) ; coerce to decimal
		; Give a default content-type header if there IS POST data but no content-type header.
		If !RegexMatch( inout_HEADERS, "i)\v\h*Content-Type:\h*\K\w+", Content_Type )
		{
			StringGetPos, pos, in_POST_out_DATA, <?xml
			If !( ErrorLevel ) && ( pos < 5 )
				Content_Type := "text/xml"
			Else Content_Type := "application/x-www-form-urlencoded"
			inout_HEADERS .= "Content-Type: " Content_Type "`r`n"
		}
	}
	Else ; the POST is either blank or contains text so we can determine the length automatically.
	{
		StringLen, Content_Length, in_POST_out_DATA
		If ( 0 < ( Content_Length := RegexReplace( Content_Length + 0.0, ".*\K\..*" ) ) )
		{
			inout_HEADERS .= "Content-Length: " Content_Length "`r`n"
			; Give a default content-type header if there IS POST data but no content-type header.
			If !RegexMatch( inout_HEADERS, "i)\v\h*Content-Type:\h*\K\V+", Content_Type )
			{
				StringGetPos, pos, in_POST_out_DATA, <?xml
				If !( ErrorLevel ) && ( pos < 5 )
					Content_Type := "text/xml"
				Else Content_Type := "application/x-www-form-urlencoded"
				inout_HEADERS .= "Content-Type: " Content_Type "`r`n"
			}
		}
	}

	; If the user wants to POST text in UTF-8, but they are using a unicode-version of AHK,
	; convert the POST data to UTF-8 and recalculate the length
	If ( A_IsUnicode && InStr( Content_Type, "charset=UTF-8" ) )
	{
		buffers := in_POST_out_DATA
		; WideCharToMultiByte > http://msdn.microsoft.com/en-us/library/dd374130%28v=vs.85%29.aspx
		VarSetCapacity( in_POST_out_DATA, size := DllCall( "WideCharToMultiByte"
			, "UInt", 65001, "UInt", 0, "UInt", &buffers, "UInt", Content_Length
			, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0 ), 0 )
		DllCall( "WideCharToMultiByte"
			, "UInt", 65001, "UInt", 0, "UInt", &buffers, "UInt", Content_Length
			, "UInt", &in_POST_out_DATA, "UInt", size, "UInt", 0, "UInt", 0 )
		size := RegexReplace( size + 0.0, ".*\K\..*" )
		StringReplace, inout_HEADERS, inout_HEADERS, % "Content-Length: " Content_Length "`r`n", % "Content-Length: " size "`r`n"
		Content_Length := size
	}

	; Determine the accept type
	If !RegexMatch( inout_HEADERS, "i)\v\h*Accept:\h*\K\V+", Accept_Types )
		Accept_Types := "text/xml, text/* q=0.2, */* q=0.1"

	; Get the agent, if it's specified. Otherwise, add an auto-generated agent that has enough
	; info to satisfy any API that requires an informative agent.
	If !RegexMatch( inout_HEADERS, "i)\v\h*User-Agent:\h*\K\V+", Agent )
		inout_HEADERS .= "User-Agent: " ( Agent := RegexReplace( A_ScriptName, ".*\K\..*" )
				. "/1.0 (Language=AutoHotkey/" A_AhkVersion "; Platform=" A_OSVersion ")" ) "`r`n"

	; Check the referer url
	RegexMatch( inout_HEADERS, "i)\v\h*Referr?er:\h+\K\V+", Referer_URL )

	; Check the content-MD5 header
	If RegexMatch( inout_HEADERS, "i)\v\h*Content-MD5:\h*\K\w*", pos ) && 40 != StrLen( pos )
		inout_HEADERS := RegexReplace( inout_HEADERS, "i)\v\h*Content-MD5:\K\h+\V*"
					, " " HTTPRequest_MD5( in_POST_out_DATA, Content_Length ) )

	; Properly format the headers. For each line in the headers, check to make sure it's formatted
	; like a header (Name: Value) and if it is, then append it to the the actual headers followed
	; by CRLF. Also, check the headers for additional flags the user may want to use.
	Loop, Parse, inout_HEADERS, `n, % "`t`r "
		If ( A_Index = 1 )
			inout_HEADERS := ""
		Else If RegexMatch( A_LoopField, "^(?<name>[^\h:]+):\h*\K.+", header )
				inout_HEADERS .= headername ": " header "`r`n"

	; Typical flags for normal HTTP requests.
	iDoCallback := 0, bUseProxy := 0, Flags := 0
	Flags |= INTERNET_FLAG_KEEP_CONNECTION
	Flags |= INTERNET_FLAG_RELOAD
	Flags |= INTERNET_FLAG_NO_CACHE_WRITE

	; Handle the optional parameters
	Loop, Parse, options, `n
	{
		StringReplace, options, A_LoopField, :, `n ; replace first : (value delimiter) with newline
		StringReplace, options, options, >, >`n, A
		Loop, Parse, options, `n, % "`t`r "
			If ( A_Index = 1 )
				options := A_LoopField
			Else If ( options = ">" ) ; use an output file
			{
				If !InStr( A_LoopField, "\" )
				|| FileExist( RegexReplace( A_LoopField, ".*\K\\.*" ) )
					RegexMatch( A_LoopField, "^(?:\w:)?[^*?:""<>|\v\t]+", output_file )
			}
			Else If ( options = "Callback" ) ; do a transfer progress callback
				iDoCallback := IsFunc( Callback_Func := A_LoopField )
			Else If ( options = "Proxy" ) ; use a proxy (don't bother checking the URL validity)
				proxy_url := A_LoopField, bUseProxy := 1
			Else If ( options = "ProxyBypass" ) ; bypass the proxy for these hosts
				proxy_bypass .= A_LoopField "`r`n"
			Else If ( options = "+Flag" || options = "-Flag" ) ; add or remove a flag
					IfInString, iFlagList, % "," A_LoopField ","
						Flags := Asc( options ) = 45 ? ~%A_LoopField% & Flags : %A_LoopField% | Flags
					Else If ( header = 1 << Ln( header ) / Ln( 2 ) )
						Flags := Asc( options ) = 45 ? ~A_LoopField & Flags : A_LoopField | Flags
	}
	StringTrimRight, proxy_bypass, proxy_bypass, 2

	; Load WinINet.dll. Because the 'hModule' is static, we can tell if the function interrupted
	; itself. If the function is interrupting itself, it shouldn't unload WinINet before ending.
	If !( interrupted := 0 != hModule )
	&& !( hModule := DllCall( "LoadLibrary" WorA, "UInt", &ModuleName ) )
	{
		inout_HEADERS := "There was a problem loading WinINet.dll. ErrorLevel = " ErrorLevel ", A_LastError = " A_LastError
		Return 0
	}

	; Put the sizes into the URL_Components structure (the sizes are the same for unicode and ansi
	; because the sizes are actually a character count, not a byte count).
	NumPut( 16, URL_Components, 8, "Int" )
	NumPut( 2048, URL_Components, 20, "Int" )
	NumPut( 2048, URL_Components, 32, "Int" )
	NumPut( 2048, URL_Components, 40, "Int" )
	NumPut( 4096, URL_Components, 48, "Int" )
	NumPut( 4096, URL_Components, 56, "Int" )

	; InternetCrackUrl > http://msdn.microsoft.com/en-us/library/aa384376%28VS.85%29.aspx
	If !DllCall( "WinINet\InternetCrackUrl" WorA, "UInt", &URL, "Int", StrLen( URL ), "UInt", 0, "UInt", &URL_Components )
	{
		inout_HEADERS := "There was a problem with the provided URL (InternetCrackUrl). ErrorLevel = " ErrorLevel ", A_LastError = " A_LastError
		If !( interrupted )
			hModule := 0 & DllCall( "FreeLibrary", "UInt", hModule )
		Return 0
	}
	; The port should always be 80... but if it's zero, then something went terribly wrong
	If !( Port := NumGet( URL_Components, 24, "UShort" ) )
	{
		inout_HEADERS := "There was a problem with the provided URL. The connection port could not be determined."
		If !( interrupted )
			hModule := 0 & DllCall( "FreeLibrary", "UInt", hModule )
		Return 0
	}

	; Update the internal lengths of the strings that were just cracked
	VarSetCapacity( Scheme, -1 )
	VarSetCapacity( Host, -1 )
	VarSetCapacity( User, -1 )
	VarSetCapacity( Pass, -1 )
	VarSetCapacity( UrlPath, -1 )
	VarSetCapacity( ExtraInfo, -1 )
	Query := UrlPath ExtraInfo

	If ( Scheme = "https" ) ; Apply these flags to HTTPS requests
		Flags |= INTERNET_FLAG_IGNORE_CERT_CN_INVALID | INTERNET_FLAG_SECURE | INTERNET_FLAG_IGNORE_CERT_DATE_INVALID
	Else If ( Scheme != "http" )
	{
	; Schemes other than HTTP and HTTPS are not supported by this function.
		inout_HEADERS := "HTTPRequest does not support '" Scheme "' type connections."
		If !( interrupted )
			hModule := 0 & DllCall( "FreeLibrary", "UInt", hModule )
		Return 0
	}

	; Tweak the accept type string to look like a list
	Loop, Parse, Accept_Types, `,
		Loop, Parse, A_LoopField, % Chr( 59 + !( pos := A_Index ) ), % "`t`n`r "
			If ( A_Index = 1 )
				If ( pos = 1 )
					Accept_Types := A_LoopField
				Else Accept_Types .= "`n" A_LoopField
	VarSetCapacity( int_array, pos + 1 << 2, 0 )

	; Build an array of pointers to the valid accept type strings and insert nulls into the
	; accept types string to make it look like a collection of null-terminated strings.
	pos := 0
	Loop, Parse, Accept_Types, `n
	{
		NumPut( &Accept_Types + pos, int_array, A_Index - 1 << 2, "UInt" )
		pos += StrLen( A_LoopField ) << !!A_IsUnicode
		NumPut( 0, Accept_Types, pos, A_IsUnicode ? "UShort" : "UChar" )
		pos += 1 << !!A_IsUnicode
	}

	; Get an internet handle. InternetOpen > http://msdn.microsoft.com/en-us/library/aa385096(v=VS.85).aspx
	hInternet := DllCall( "WinINet\InternetOpen" WorA
		, "UInt", &Agent
		, "UInt", bUseProxy ? INTERNET_OPEN_TYPE_PROXY : INTERNET_OPEN_TYPE_DIRECT
		, "UInt", bUseProxy ? &proxy_url : 0
		, "UInt", bUseProxy && proxy_bypass = "" ? 0 : &proxy_bypass
		, "UInt", 0 )

	If !( hInternet )
	{
		inout_HEADERS := "There was a problem opening an internet handle. ErrorLevel = " ErrorLevel ", A_LastError = " A_LastError
		If !( interrupted )
			hModule := 0 & DllCall( "FreeLibrary", "UInt", hModule )
		Return 0
	}

	; Open a connection. InternetConnect > http://msdn.microsoft.com/en-us/library/aa384363%28v=VS.85%29.aspx
	hConnection := DllCall( "WinINet\InternetConnect" WorA, "UInt", hInternet
		, "UInt", &Host
		, "UInt", Port
		, "UInt", &User
		, "UInt", &Pass
		, "UInt", 3 ; INTERNET_SERVICE_HTTP = 3
		, "UInt", Flags
		, "UInt", 0 )

	If !( hConnection )
	{
		inout_HEADERS := "There was a problem opening a connection to the host. ErrorLevel = " ErrorLevel ", A_LastError = " A_LastError
		hInternet := 0 & DllCall( "WinINet\InternetCloseHandle", "UInt", hInternet )
		If !( interrupted )
			hModule := 0 & DllCall( "FreeLibrary", "UInt", hModule )
		Return 0
	}

	; Open a request. HttpOpenRequest > http://msdn.microsoft.com/en-us/library/aa384233%28v=VS.85%29.aspx
	hRequest := DllCall( "WinINet\HttpOpenRequest" WorA, "UInt", hConnection
		, "Str", Content_Length = 0 ? "GET" : "POST"
		, "UInt", &Query
		, "Str", "HTTP/1.1"
		, "UInt", &Referer_URL
		, "UInt", &int_array
		, "UInt", Flags )

	If !( hRequest )
	{
		inout_HEADERS := "There was a problem opening the request. ErrorLevel = " ErrorLevel ", A_LastError = " A_LastError
		DllCall( "WinINet\InternetCloseHandle", "UInt", hConnection )
		DllCall( "WinINet\InternetCloseHandle", "UInt", hInternet )
		If !( interrupted )
			hModule := 0 & DllCall( "FreeLibrary", "UInt", hModule )
		Return 0
	}

	; apply the headers to the request ( to allow header errors to be detected and reported )
	pos := DllCall( "WinINet\HttpAddRequestHeaders" WorA, "UInt", hRequest
		, "Str", inout_HEADERS
		, "UInt", StrLen( inout_HEADERS )
		, "UInt", 0x20000000 ) ; HTTP_ADDREQ_FLAG_ADD = 0x20000000
	If !( pos )
	{
		inout_HEADERS := "There was a applying one or more headers to the request. ErrorLevel = " ErrorLevel ", A_LastError = " A_LastError "`nHeaders:`n" inout_HEADERS
		StringReplace, inout_HEADERS, inout_HEADERS, `r`n, `n, A
		DllCall( "WinINet\InternetCloseHandle", "UInt", hRequest )
		DllCall( "WinINet\InternetCloseHandle", "UInt", hConnection )
		DllCall( "WinINet\InternetCloseHandle", "UInt", hInternet )
		If !( interrupted )
			hModule := 0 & DllCall( "FreeLibrary", "UInt", hModule )
		Return 0
	}
	VarSetCapacity( int_array, 4, 0 ) ; recycle this variable (use it as an INT)

	; Update: Version (7-1-2011) - To implement the upload progress callback, I needed to swap out
	; the HttpSendRequest function for HttpSendRequestEx, which allows tighter control over the
	; POST operation. GET reqeusts still use the HttpSendRequest function (for simplicity)
	If ( Content_Length )
	{
		VarSetCapacity( buffers, 40, 0 )
		NumPut( 40, buffers, 0, "Int" )
		NumPut( Content_Length, buffers, 28, "Int" )
		; Send the POST request. HttpSendRequestEx > http://msdn.microsoft.com/en-us/library/aa384318%28v=VS.85%29.aspx
		If !( DllCall( "WinINet\HttpSendRequestEx" WorA, "UInt", hRequest
			, "UInt", &buffers, "UInt", 0, "UInt", 0, "UInt", 0 ) )
		{
			inout_HEADERS := "There was a problem sending the POST request. ErrorLevel = " ErrorLevel ", A_LastError = " A_LastError
			DllCall( "WinINet\InternetCloseHandle", "UInt", hRequest )
			DllCall( "WinINet\InternetCloseHandle", "UInt", hConnection )
			DllCall( "WinINet\InternetCloseHandle", "UInt", hInternet )
			If !( interrupted )
				hModule := 0 & DllCall( "FreeLibrary", "UInt", hModule )
			Return 0
		}

		If ( iDoCallback = 2 || iDoCallback = 3 )
			%Callback_Func%( -1, Content_Length )
		; Submit the POST data in 4K chunks
		size := 0
		Loop
			If ( Content_Length <= size )
				Break
			Else
			{
				; InternetWriteFile > http://msdn.microsoft.com/en-us/library/aa385128%28v=VS.85%29.aspx
				pos := DllCall( "WinINet\InternetWriteFile", "UInt", hRequest
					, "UInt", &in_POST_out_DATA + size
					, "Int", size + 4096 < Content_Length ? 4096 : Content_Length - size
					, "UInt", &int_array )

				If !( pos )
				{
					inout_HEADERS := "There was a problem uploading the POST data. ErrorLevel = " ErrorLevel ", A_LastError = " A_LastError
					DllCall( "WinINet\HttpEndRequest" WorA, "UInt", hRequest, "UInt", 0, "UInt", 0, "UInt", 0 )
					DllCall( "WinINet\InternetCloseHandle", "UInt", hRequest )
					DllCall( "WinINet\InternetCloseHandle", "UInt", hConnection )
					DllCall( "WinINet\InternetCloseHandle", "UInt", hInternet )
					If !( interrupted )
						hModule := 0 & DllCall( "FreeLibrary", "UInt", hModule )
					Return 0
				}

				size += NumGet( int_array, 0, "Int" )

				If ( iDoCallback = 2 || iDoCallback = 3 )
					%Callback_Func%( size / Content_Length - 1, Content_Length )
			}
		If ( iDoCallback = 2 || iDoCallback = 3 )
			%Callback_Func%( "", 0 )
		; A request opened by HttpSendRequestEx must be closed by HttpEndRequest.
		; HttpEndRequest > http://msdn.microsoft.com/en-us/library/aa384230%28v=VS.85%29.aspx
		DllCall( "WinINet\HttpEndRequest" WorA, "UInt", hRequest, "UInt", 0, "UInt", 0, "UInt", 0 )
	}
	Else	; Send the GET request. HttpSendRequest > http://msdn.microsoft.com/en-us/library/aa384247%28v=VS.85%29.aspx
		If !( DllCall( "WinINet\HttpSendRequest" WorA, "UInt", hRequest
			, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0 ) )
		{
			inout_HEADERS := "There was a problem sending the GET request. ErrorLevel = " ErrorLevel ", A_LastError = " A_LastError
			DllCall( "WinINet\InternetCloseHandle", "UInt", hRequest )
			DllCall( "WinINet\InternetCloseHandle", "UInt", hConnection )
			DllCall( "WinINet\InternetCloseHandle", "UInt", hInternet )
			If !( interrupted )
				hModule := 0 & DllCall( "FreeLibrary", "UInt", hModule )
			Return 0
		}

	; Query the request for ready data. Actualy, it waits for data to become ready.
	; InternetQueryDataAvailable > http://msdn.microsoft.com/en-us/library/aa385100%28v=VS.85%29.aspx
	DllCall( "WinINet\InternetQueryDataAvailable", "UInt", hRequest, "UInt", &int_array, "UInt", 0, "UInt", 0 )

	VarSetCapacity( inout_HEADERS, 4096, 0 ) ; use 4K as first-try for response header length.
	NumPut( 4096, int_array )
	Loop 2 ; Get the response headers separated by CRLF. The first line has the HTTP response code
	{
		; HttpQueryInfo > http://msdn.microsoft.com/en-us/library/aa384238%28v=VS.85%29.aspx
		If ( pos := DllCall( "WinINet\HttpQueryInfo" WorA, "UInt", hRequest
			, "UInt", 22 ; HTTP_QUERY_RAW_HEADERS_CRLF = 22
			, "UInt", &inout_HEADERS
			, "UInt", &int_array
			, "UInt", 0 ) )
				Break

		If ( A_LastError = 122 ) ; ERROR_INSUFFICIENT_BUFFER = 122
			VarSetCapacity( inout_HEADERS, NumGet( int_array ) + 2, 0 )
	}

	If !( pos )
	{
		inout_HEADERS := "There was a problem reading the response headers. ErrorLevel = " ErrorLevel ", A_LastError = " A_LastError
		DllCall( "WinINet\InternetCloseHandle", "UInt", hRequest )
		DllCall( "WinINet\InternetCloseHandle", "UInt", hConnection )
		DllCall( "WinINet\InternetCloseHandle", "UInt", hInternet )
		If !( interrupted )
			hModule := 0 & DllCall( "FreeLibrary", "UInt", hModule )
		Return 0
	}

	; Update response header outputvar length and remove carriage returns
	VarSetCapacity( inout_HEADERS, -1 )
	StringReplace, inout_HEADERS, inout_HEADERS, `r`n, `n, A
	; Get the content length header (since the content-length header is not guaranteed to be in
	; the response headers, the value is only used in the progress callback function).
	StringGetPos, pos, inout_HEADERS, % "`nContent-Length: "
	pos += 18
	If !( ErrorLevel )
		StringMid, Content_Length, inout_HEADERS, pos, InStr( inout_HEADERS "`n", "`n", 0, pos ) - pos
	Else Content_Length := 65535 ; arbitrary (unknown) content-length
	If ( iDoCallback = 2 || iDoCallback = 3 )
		%Callback_Func%( 0, Content_Length )
	; Get the content type (well use it to see if we should treat the response as a string)
	StringGetPos, pos, inout_HEADERS, % "`nContent-Type: "
	pos += 16
	StringMid, Accept_Types, inout_HEADERS, pos, InStr( inout_HEADERS "`n", "`n", 0, pos ) - pos
	If ( bTextdata := InStr( Accept_Types, "text/" ) = 1
		|| InStr( Accept_Types, "/xml" )
		|| InStr( Accept_Types, "/atom" )
		|| InStr( Accept_Types, "/json" )
		|| InStr( Accept_Types, "/x-www-form-urlencoded" )
		|| InStr( Accept_Types, "/xhtml" )
		|| InStr( Accept_Types, "/html" )
		|| InStr( Accept_Types, "/soap" ) )
		Codepage := InStr( Accept_Types, "charset=ISO-8859-1" ) ? 28591 : 65001

	; Download the response data
	Size := 0
	If ( output_file != "" )
	{
		; The user wants to save the info as a file, so delete the file if it exists.
		IfExist, % output_file
			FileDelete, % output_file

		; Use binary-mode file write. CreateFile > http://msdn.microsoft.com/en-us/library/aa363858%28v=vs.85%29.aspx
		If !( hFile := DllCall( "CreateFile" WorA, "Str", output_file
					, "Uint", 0x40000000 ; GENERIC_WRITE = 0x40000000
      				, "Uint", 0, "UInt", 0, "UInt", 4 ; OPEN_ALWAYS = 4
					, "Uint", 0, "UInt", 0 ) )
			inout_HEADERS .= "`nHTTPRequest Error: Could not create/open the file for writing. ErrorLevel = " ErrorLevel ", A_LastError = " A_LastError
		Else
		{
			; Read from the internet response and write to the file
			Loop
			{
				VarSetCapacity( buffers, 4096, 0 ) ; Use a 4K buffer
				; InternetReadFile > http://msdn.microsoft.com/en-us/library/aa385103%28v=VS.85%29.aspx
				pos := DllCall( "WinINet\InternetReadFile", "UInt", hRequest
					, "UInt", &buffers
					, "UInt", 4096
					, "UInt", &int_array )
				If !( pos && NumGet( int_array ) )
				{
					; CloseHandle > http://msdn.microsoft.com/en-us/library/ms724211%28v=vs.85%29.aspx
					DllCall( "CloseHandle", "Uint", hFile )
					If !( pos )
						inout_HEADERS .= "`nHTTPRequest Warning: InternetReadFile Failed. ErrorLevel = " ErrorLevel ", A_LastError = " A_LastError
					Else FileRead, in_POST_out_DATA, % "*c " output_file
					Break
				}
				Sleep -1
				Size += buffersize := NumGet( int_array )
				; WriteFile > http://msdn.microsoft.com/en-us/library/aa365747%28v=vs.85%29.aspx
				If !DllCall( "WriteFile", "UInt", hFile, "UInt", &buffers, "Int", buffersize, "UInt", &int_array, "UInt", 0 )
				{
					DllCall( "CloseHandle", "Uint", hFile )
					FileDelete, % output_file
					inout_HEADERS .= "`nHTTPRequest Error: There was a problem writing to the file. ErrorLevel = " ErrorLevel ", A_LastError = " A_LastError
					Break
				}
				Sleep -1
				If ( iDoCallback = 2 || iDoCallback = 3 )
					%Callback_Func%( Size / Content_Length, Content_Length )
			}
			buffers := ""
		}
	}
	Else
	{
		; Read the response and store it into a pseudo-array of buffers
		Loop
		{
			buffers := A_Index
			VarSetCapacity( HTTPRequest_Buffer_%A_Index% := "", 4096, 0 )
			; InternetReadFile > http://msdn.microsoft.com/en-us/library/aa385103%28v=VS.85%29.aspx
			pos := DllCall( "WinINet\InternetReadFile", "UInt", hRequest
				, "UInt", &HTTPRequest_Buffer_%A_Index%
				, "UInt", 4096
				, "UInt", &int_array )
			If !( pos && NumGet( int_array ) )
				Break
			Size += HTTPRequest_BufferSize_%A_Index% := NumGet( int_array )
			Sleep -1
			If ( iDoCallback = 2 || iDoCallback = 3 )
				%Callback_Func%( Size / Content_Length, Content_Length )
		}
		If !( pos )
			inout_HEADERS .= "`nHTTPRequest Warning: InternetReadFile Failed. ErrorLevel = " ErrorLevel ", A_LastError = " A_LastError
		VarSetCapacity( in_POST_out_DATA, Size + 1 << !!A_IsUnicode, 0 ) ; always put an ending null, even for non-text data
		Size := 0
		Loop % buffers - 1 ; Then copy the buffered data into the output parameter.
		{
			If ( A_IsUnicode ) && bTextdata ; convert ANSI or UTF-8 into Wide-Char (UTF-16)
				; MultiByteToWideChar > http://msdn.microsoft.com/en-us/library/dd319072%28v=vs.85%29.aspx
				Size += DllCall( "MultiByteToWideChar"
						, "UInt", CodePage, "UInt", 0
						, "UInt", &HTTPRequest_Buffer_%A_Index%
						, "UInt", HTTPRequest_BufferSize_%A_Index%
						, "UInt", &in_POST_out_DATA + Size
						, "UInt", HTTPRequest_BufferSize_%A_Index% << 1 ) << 1
			Else ; the script isn't unicode, so just copy byte for byte
			{
				; MoveMemory > http://msdn.microsoft.com/en-us/library/aa366788%28v=vs.85%29.aspx
				DllCall( "RtlMoveMemory"
						, "UInt", &in_POST_out_DATA + Size
						, "UInt", &HTTPRequest_Buffer_%A_Index%
						, "UInt", HTTPRequest_BufferSize_%A_Index% )
				Size += HTTPRequest_BufferSize_%A_Index%
			}
			HTTPRequest_Buffer_%A_Index% := ""
		}

		; If the content-type is text, update the output data length
		If ( bTextdata )
			VarSetCapacity( in_POST_out_DATA, -1 )
		; Scrapped idea: if content-type = text/xml, insert newlines and tabs to make it pretty
	} ; End Else
	If ( iDoCallback = 2 || iDoCallback = 3 )
		%Callback_Func%( "", 0 )

	; InternetCloseHandle > http://msdn.microsoft.com/en-us/library/aa384350%28v=VS.85%29.aspx
	DllCall( "WinINet\InternetCloseHandle", "UInt", hRequest )
	DllCall( "WinINet\InternetCloseHandle", "UInt", hConnection )
	DllCall( "WinINet\InternetCloseHandle", "UInt", hInternet )
	If !( interrupted )
		hModule := 0 & DllCall( "FreeLibrary", "UInt", hModule )
	Return Size
} ; HTTPRequest( url, byref in_POST_out_DATA="", byref inout_HEADERS="", options="" ) --------------

HTTPRequest_MD5( byref data, length=-1 ) { ; -------------------------------------------------------
; Computes the MD5 hash of a data blob of length 'length'. If 'length' is less than zero, this
; function assumes that 'data' is a null-terminated string and determines the length automatically.
	; static variables and constants r[0~63], encoded here as bytes with an offset of 64
	; ( that means the real value is the byte value minus 64, e.g: r[0] = 7, so 7 + 64 = 71 = 'G' )
	Static S, k, p:=0, r := "GLQVGLQVGLQVGLQVEINTEINTEINTEINTDKPWDKPWDKPWDKPWFJOUFJOUFJOUFJOU"

	VarSetCapacity( S, 64, 0 ) ; Initialize the block buffer S and constants p and k[0~63]
	IfEqual, p, 0, Loop % VarSetCapacity( k, 256 + !( p := &S ) ) >> 2 & 64
		NumPut( Floor(Abs(Sin(A_Index)) * 2**32 ), k, A_Index - 1 << 2, "UInt" )

	; autodetect message length if it's not specified (or is not positive)
	IfLess, length, 1, StringLen, length, data

	; initialize running accumulators and terminator (the terminator is appended to the message)
	ha := 0x67452301, hb := 0xEFCDAB89, hc := 0x98BADCFE, hd := 0x10325476

	; Begin rolling the message. This loop does 1 iteration for each 64 byte block such that the
	; last block has fewer than 55 bytes in it ( to leave room for the terminator and data length )
	Loop % length + 72 >> 6
	{
		If ( f := length - 64 > ( e := A_Index - 1 << 6 ) ? 64 : length > e ? length - e : 0 )
			DllCall( "RtlMoveMemory", "UInt", p, "UInt", &data + e, "Int", f ) ; copy the block
		If ( f != 64 && e <= length ) ; append the terminator to the message
			NumPut( 128, S, f, "UChar" )
		IfLess, f, 56, Loop 8 ; if this is the real last block, insert the data length in BITS
			NumPut( ( length << 3 >> ( A_Index - 1 << 3 ) ) & 255, S, 55 + A_Index, "UChar" )
		
		a := ha, b := hb, c := hc, d := hd ; copy running accumulators to intermediate variables

		Loop 64 ; begin rolling the block. These operations have been condensed and obfuscated.
		{ ; For i from 0 to 63 {
			e := NumGet( r, ( 2 - !A_IsUnicode ) * i := A_Index - 1, "UChar" ) & 31
			f := 0 = ( j := i >> 4 ) ? (b&c)|(~b&d) : j=1 ? (d&b)|(~d&c) : j=2 ? b^c^d : c^(~d|b)
			g := (( i * ( 3817 >> j * 3 & 7 ) + ( 328 >> j * 3 & 7 ) & 15 ) << 2 ) + p
			w := (*(g+3) << 24 | *(g+2) << 16 | *(g+1) << 8 | *g) + a + f + NumGet(k,i<<2,"UInt")
			a := d, d := c, c := b, b += w << e | (( w & 0xFFFFFFFF ) >> ( 32 - e ))
		}
		; add the intermediate variables to the running accumlators (making sure to mod by 2**32)
		ha := ha+a&0xFFFFFFFF, hb := hb+b&0xFFFFFFFF, hc := hc+c&0xFFFFFFFF, hd := hd+d&0xFFFFFFFF
		VarSetCapacity( S, 64, 0 ) ; Clear the block ( set bits to zero )
	}
	Loop 32 ; convert the running accumulators into 32 hex digits
		i := Chr( 96 + ( A_Index + 7 >> 3 ) ), S .= SubStr( "123456789abcdef0"
		, h%i% >> ( ( A_Index - 1 + ( A_Index & 1 ) - !( A_Index & 1 ) & 7 ) << 2 ) & 15, 1 )
	Return S ; return the hex digits
} ; HTTPRequest_MD5( byref data, length=-1 ) -------------------------------------------------------

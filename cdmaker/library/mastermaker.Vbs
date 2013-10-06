Class MasterMaker
	Private strPTBurnJobDir, strConnection
	
	Public Property Get PTBurnJobDir
		PTBurnJobDir = strPTBurnJobDir
	End Property
	
	Public Property Let PTBurnJobDir(Byval varNewVal)
		strPTBurnJobDir = varNewVal
	End Property
	
	Public Property Get Connection
		Connection = strConnection
	End Property
	
	Public Property Let Connection(Byval varNewVal)
		strConnection = varNewVal
	End Property
	
	Public Sub MakeMasters
		Dim  sRobotName, sRobotStatusFile, iCartridgeFill, iNumberOfDiscsInHopper
		Dim  sSystemStatusFile, iDiscsToMake, sSummary, iWaitingMasters
		
		sSystemStatusFile = strPTBurnJobDir & "status\systemstatus.txt"
		
		'1. Get status of ink cartridge in printer. 
		'   If ink level Is 1% Or lower send a notification email And Exit the program
		
		'read the status file To get the duplicator name
		sRobotName = ReadIni(sSystemStatusFile, "RobotList" , "Robot0")
		sRobotStatusFile = strPTBurnJobDir & "status\" & sRobotName & ".txt"
		'sRobotStatusFile = strPTBurnJobDir & "status\" & "Copy of " & sRobotName & ".txt" 'for testing only
		'wscript.stdout.writeline sRobotStatusFile 'for testing only
		iCartridgeFill = CInt(ReadIni(sRobotStatusFile, "System" , "CartridgeFill0")) 
		
		If iCartridgeFill < 3 Then
			'send email
			'wscript.stdout.writeline "Problem Cartridge fill: " & iCartridgeFill
			SendEmailMessage True,"Unable to make masters! There is insufficient ink in the printer. Cartridge Level: " & iCartridgeFill
		Else
			'wscript.stdout.writeline "Cartridge fill: " & iCartridgeFill
		
			'2. Get # of discs in auto cd duplicator hopper.
			SendCheckBinsCommand sRobotName
			iNumberOfDiscsInHopper = CInt(ReadIni(sRobotStatusFile, "System" , "DiscsInLeftBin"))
			If iNumberOfDiscsInHopper <= 0 Then
			  'insufficient or unknown number of discs in the hopper. Abort and send email
			  SendEmailMessage True, "Unable to make masters! Unknown or insufficient number of discs in the duplicator."
			Else
				sSummary = "Master Maker Summary Report" & vbCr & vbLf & vbCr & vbLf 
				sSummary = sSummary & "     System Status: " & vbCr & vbLf
				sSummary = sSummary & "          Discs In Hopper: " & iNumberOfDiscsInHopper & vbCr & vbLf
				sSummary = sSummary & "          Ink Cartridge Level: " & iCartridgeFill & "%" & vbCr & vbLf & vbCr & vbLf
				sSummary = sSummary & "     Current Run Information: " & vbCr & vbLf
				  
				'wscript.stdout.writeline "Discs in hopper: " & iNumberOfDiscsInHopper
				Set oConn = createobject("ADODB.Connection")
				oConn.ConnectionString = strConnection
				oConn.Open
				'Find out how many masters are waiting to be made before this new round is submitted
				sSQL = "SELECT COUNT(*) FROM JOBS WHERE STATUS <= 3 AND MASTER = 'y'"
				Set oRS = CreateObject("ADODB.Recordset")
				oRS.Open sSQL, oConn, adOpenKeyset
				iWaitingMasters = CInt(oRS.Fields(0))
				oRS.Close
				sSummary = sSummary & "          Number of master jobs in queue prior to start: " & iWaitingMasters & vbCr & vbLf
					
				'3. Get tapeid of masters to be printed
				'    SQL Query that gets any tapes that have not successfuly had a master printed
				'    The query limits to tapes having a year equal to or greater than the "current" year
				'    based an a date seven days prior to the date of execution. This takes care of crossing
				'    into a new year for up to seven days:
				'      select * from "Tapes" t 
				'      where "Year" >= extract(year from (now() - 7) ) 
				'        And t."ID" Not In ( Select tapeid from jobs where status <= 4 And master = 'y' )  
				'      order by "Year", "Month", "Date"
				sSQL = "Select * from ""Tapes"" t"
				sSQL = sSQL & " where ""Year"" >= extract(year from (now() - 7) )"
				sSQL = sSQL & " And t.""ID"" Not In ( Select tapeid from jobs where status <= 4 And master = 'y' )"
				sSQL = sSQL & " order by ""Year"", ""Month"", ""Date"" "
								
				oRS.Open sSQL, oConn, adOpenKeyset
				'wscript.stdout.writeline "RecordCount: " & oRS.RecordCount
				sSummary = sSummary & "          Number of masters that have not been made or are in the queue: " & oRS.RecordCount & vbCr & vbLf
				If (oRS.RecordCount + iWaitingMasters) > iNumberOfDiscsInHopper Then
					iDiscsToMake = iNumberOfDiscsInHopper - iWaitingMasters
				Else
					iDiscsToMake = oRS.RecordCount
				End If
				'wscript.stdout.writeline "Discs To Make: " & iDiscsToMake
				sSummary = sSummary & "          Number of masters to be made in this run: " & iDiscsToMake & vbCr & vbLf
				sSummary = sSummary & "          Number of masters that cannot be made this run: " & oRS.RecordCount - iDiscsToMake & vbCr & vbLf
				
				'4. Insert job records for the # of discs 
				For i = 1 To iDiscsToMake
					
					sSQL = "insert into jobs (tapeid,copies,remainingdiscs,status,master)"
					sSQL = sSQL & " values ( " & oRS.Fields("ID") & ", 1,1,1,'y')" 
					oConn.Execute sSQL
					'wscript.stdout.writeline sSQL
					oRS.MoveNext
				Next 
				
				oRS.Close
				Set oRS = Nothing
				oConn.Close
				Set oConn = Nothing								
				
				'5. Send email report showing how many discs were attempted to be printed and how many were not submitted
				'wscript.stdout.writeline sSummary
				SendEmailMessage False, sSummary
			End If
	
		End If
	
	End Sub
	

	Public Sub SendEmailMessage( bError, strMessage )
	
		Set objMessage = CreateObject("CDO.Message") 
		
		If bError Then
			objMessage.Subject = "MasterMaker Error Notification"
		Else
			objMessage.Subject = "MasterMaker Status Notification"
		End If
		
		objMessage.From = "cplazas@thechurchofcolumbus.org" 
		objMessage.To = "cplazas@gmail.com" 
		objMessage.TextBody = strMessage
		'==This section provides the configuration information for the remote SMTP server. 
		'==Normally you will only change the server name Or IP. 
		objMessage.Configuration.Fields.Item _ 
		  ("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2 
	
		'Name or IP of Remote SMTP Server 
		objMessage.Configuration.Fields.Item _ 
		  ("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "smtp.gmail.com" 
	
		'Server port (typically 25) 
		objMessage.Configuration.Fields.Item _ 
		  ("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 465 
	
	        'Type of authentication, NONE, Basic (Base64 encoded), NTLM
	        objMessage.Configuration.Fields.Item _
	          ("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = 1 'Basic
	
	
	        'Your UserID on the SMTP server
	        objMessage.Configuration.Fields.Item _
	          ("http://schemas.microsoft.com/cdo/configuration/sendusername") = "cplazas@thechurchofcolumbus.org"
	
	        'Your password on the SMTP server
	        objMessage.Configuration.Fields.Item _
	          ("http://schemas.microsoft.com/cdo/configuration/sendpassword") = "lavon26"
	
	        'Use SSL for the connection (False or True)
	        objMessage.Configuration.Fields.Item _
	          ("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = True
	
	        'Connection Timeout in seconds (the maximum time CDO will try to establish a connection to the SMTP server)
	        objMessage.Configuration.Fields.Item _
	          ("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout") = 60
	
		objMessage.Configuration.Fields.Update 
		'==End remote SMTP server configuration section== 
	
		objMessage.Send 
	
		Set objMessage = nothing
	End Sub
	
	Public Sub SendCheckBinsCommand (strRobotName)
		Dim FSO, jobFile, jobFileName
		Set FSO = CreateObject("Scripting.FileSystemObject")
		jobFileName = strPTBurnJobDir & "CheckBins.ptm" 
		Set jobFile = FSO.CreateTextFile( jobFileName, True )
		jobFile.WriteLine "Message = CHECK_DISCSINBIN"
		jobFile.WriteLine "ClientID=Administrator"
		jobFile.WriteLine "RobotName = " & strRobotName
		jobFile.Close
		wscript.sleep(10000) 'sleep for 10 seconds while waiting for the command to be executed
	End Sub

Private Function ReadIni( myFilePath, mySection, myKey )
    ' This function returns a value read from an INI file
    '
    ' Arguments:
    ' myFilePath  [string]  the (path and) file name of the INI file
    ' mySection   [string]  the section in the INI file to be searched
    ' myKey       [string]  the key whose value is to be returned
    '
    ' Returns:
    ' the [string] value for the specified key in the specified section
    '
    ' CAVEAT:     Will return a space if key exists but value is blank
    '
    ' Written by Keith Lacelle
    ' Modified by Denis St-Pierre and Rob van der Woude

    Const ForReading   = 1
    Const ForWriting   = 2
    Const ForAppending = 8

    Dim intEqualPos
    Dim objFSO, objIniFile
    Dim strFilePath, strKey, strLeftString, strLine, strSection

    Set objFSO = CreateObject( "Scripting.FileSystemObject" )

    ReadIni     = ""
    strFilePath = Trim( myFilePath )
    strSection  = Trim( mySection )
    strKey      = Trim( myKey )

    If objFSO.FileExists( strFilePath ) Then
        Set objIniFile = objFSO.OpenTextFile( strFilePath, ForReading, False )
        Do While objIniFile.AtEndOfStream = False
            strLine = Trim( objIniFile.ReadLine )

            ' Check if section is found in the current line
            If LCase( strLine ) = "[" & LCase( strSection ) & "]" Then
                strLine = Trim( objIniFile.ReadLine )

                ' Parse lines until the next section is reached
                Do While Left( strLine, 1 ) <> "["
                    ' Find position of equal sign in the line
                    intEqualPos = InStr( 1, strLine, "=", 1 )
                    If intEqualPos > 0 Then
                        strLeftString = Trim( Left( strLine, intEqualPos - 1 ) )
                        ' Check if item is found in the current line
                        If LCase( strLeftString ) = LCase( strKey ) Then
                            ReadIni = Trim( Mid( strLine, intEqualPos + 1 ) )
                            ' In case the item exists but value is blank
                            If ReadIni = "" Then
                                ReadIni = " "
                            End If
                            ' Abort loop when item is found
                            Exit Do
                        End If
                    End If

                    ' Abort if the end of the INI file is reached
                    If objIniFile.AtEndOfStream Then Exit Do

                    ' Continue with next line
                    strLine = Trim( objIniFile.ReadLine )
                Loop
            Exit Do
            End If
        Loop
        objIniFile.Close
    End If
End Function


End Class

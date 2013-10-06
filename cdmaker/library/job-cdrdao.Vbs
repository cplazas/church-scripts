Function CreateLabel()
	'Dim oLabel
	'Set oLabel = new Label
	Set CreateLabel = new Label
End Function

Class Job
	Private nID, oLabel, nLabelID, nCopies, nStatus, nGoodDiscs, nBadDiscs, nRemainingDiscs, bPrintOnly, bDVD, conn
	
	Public Sub Initialize( id, Byref oConn, byref ologfile )
		Dim strSQL, oRS
		strSQL = "select * from jobs where id = " & id
		Set oRS = CreateObject("ADODB.Recordset")
		oRS.Open strSQL, oConn, adOpenKeyset
		If oRS.RecordCount > 0  Then
			nID = oRS.Fields("id")
			nLabelID = oRS.Fields("tapeid")
			nCopies = oRS.Fields("copies")
			nStatus = oRS.Fields("status")
			If  oRS.Fields("printonly") = "y" Then
				bPrintOnly = True
			Else
				bPrintOnly = False
			End If
			
			If oRS.Fields("dvd") = "y" Then
				bDVD = True
			Else
				bDVD = False
			End If 
			
			Set oLabel = CreateLabel()'new Label
			Label.LoadFromDB nLabelID,oConn
		End If
		oRS.Close
		Set oRS = Nothing
		Set conn = oConn 'save conection for later use
	End Sub
		
	Public Sub GetStatusFromDB( oConn )
	
		Dim strSQL, oRS
		strSQL = "select status from jobs where id = " & nID
		Set oRS = CreateObject("ADODB.Recordset")
		oRS.Open strSQL, oConn, adOpenKeyset
		If oRS.RecordCount > 0  Then
			nStatus = oRS.Fields("status")
			'nCopies = 
		End If
		oRS.Close
		Set oRS = Nothing
			
	End Sub
		
	Public Sub SetStatusInDB( oConn )
		'wscript.stdout.writeline "new status: " & nStatus	
		Dim strSQL
		strSQL = "update jobs set status = " & nStatus & ", lastupdate = now() where id = " & nID
		oConn.Execute strSQL

	End Sub
	
	Public Function CreateTOCFile( strCDRDAOJobsDir, strAudioFilesDir)
	
	'----------------------------------------------------------------------------
	' Function:   GenerateTOCFile
	'
	' Parameters:
	'             strCDRDAOJobsDir  - path to directory where file will be 
	'                                 generated for use by CDRDAO
	'             strAudioFilesDir  - path to use for searching for audio files
	'                                 that belong to this job
	'
	' Returns:    string containing the fully qualified name of the TOC that was 
	'             generated or 'error' if the file could not be generated                 
	'----------------------------------------------------------------------------
	
		'now we write the data into the job file 
		Dim FSO, jobFile, jobFileName,fldr,fc,f,regex, regex2
		Set FSO = CreateObject("Scripting.FileSystemObject")
		jobFileName = strCDRDAOJobsDir & oLabel.GetLabelKey & ".toc"
		'wscript.stdout.writeline strPTBurnJobsDir & oLabel.GetLabelKey & ".jrq"
		Set jobFile = FSO.CreateTextFile( jobFileName, True )
		'wscript.echo jobFileName

		Set fldr = FSO.GetFolder( strAudioFilesDir )
		Set fc = fldr.Files

		Set regex = New RegExp
		regex.Global = True
		regex.IgnoreCase = True
		
		Set regex2 = new RegExp
		regex.Global = True
		regex.IgnoreCase = True
		
		regex.Pattern = "\\"
		

		jobFile.WriteLine "CD_DA"
		
		Dim trackno 
		trackno = 1

		For Each f In fc
			regex.Pattern = oLabel.GetLabelKey & ".+\.mp3" 'match the wav extension of a file
			If regex.Test(f.name) Then
				jobFile.WriteLine "TRACK AUDIO"
				If ( trackno > 1 ) Then
					jobFile.WriteLine "PREGAP 00:02:00"
				End If
				jobFile.WriteLine "FILE " & Chr(34) & regex.Replace(strCDRDAOJobsDir,"/") & FSO.GetBaseName(f.name) & ".wav" & Chr(34) & " 0"
				trackno = trackno + 1
			End If
		Next

		jobFile.Close
		
		If trackno < 2 Then
			CreateTOCFile = "error"
		Else
			CreateTOCFile = jobFileName
		End If
	End Function
	
	Public Sub GenerateBurnFiles( strCDRDAOJobsDir, strAudioFilesDir)
		Dim strMadplayPath
		Dim strMadplayOptions
		Dim FSO,fldr,fc,f,regex, shell
		
		strMadPlayPath = "c:\cd\bin\mp3utils\mad\madplay.exe"
		strMadplayOptions = " --output=wav:"
			
			Set shell = WScript.CreateObject("WScript.Shell") 
		
		Set FSO = CreateObject("Scripting.FileSystemObject")
		Set fldr = FSO.GetFolder( strAudioFilesDir )
		Set fc = fldr.Files
		
		Set regex = New RegExp
		regex.Global = True
		regex.IgnoreCase = True
		For Each f In fc
			regex.Pattern = oLabel.GetLabelKey & ".+\.mp3" 'match the mp3 extension of a file
			If regex.Test(f.name) Then
				shell.Run strMadPlayPath & strMadplayOptions & strCDRDAOJobsDir & FSO.GetBaseName(f.name) & ".wav" & " " & strAudioFilesDir & f.name,,True 'synchronous wait for return  
				'wscript.echo strMadPlayPath & strMadplayOptions & strCDRDAOJobsDir & FSO.GetBaseName(f.name) & ".wav" & " " & strAudioFilesDir & f.name'synchronous wait for return  

			End If
		Next
		
	End Sub
	
	Public Function DriveReady
		Dim cdrdaocmd, cdrdaoreadopts, ready, cancelburn, shell, cdrdao
		Dim regex, regex2, blankregex, fullregex, discfull, nodisc, line
		Dim nodiscmessage, fulldiscmessage
	
		cdrdaocmd = "c:\cd\bin\cdrdao\cdrdao.exe" '"c:\program files\burnatonce\external\cdrdao"
		cdrdaoreadopts = " disk-info --device SPTI:1,0,0 --driver generic-mmc "
		
		nodiscmessage = "Please insert a blank disc in the drive and click yes to continue. Click no to cancel."
		fulldiscmessage = "There is a non-blank disc in the drive please remove it, insert a blank disc in the drive and click yes to continue. Click no to cancel."
	
	
		'nodiscregex =
		fullregex = "CD-R empty.+:.+no"
		blankregex = "CD-R empty.+:.+yes"
	
		ready = False
		cancelburn = False
		
		Set shell = createobject("WScript.Shell")
		Set regex = new RegExp
		Set regex2 = new RegExp
		
		regex.global = True
		regex.ignorecase = True
		regex.pattern = fullregex
		
		
		regex2.global = True
		regex2.ignorecase = True
		regex2.pattern = blankregex
	
		Do While Not ready And Not cancelburn
		
			discfull = False
			nodisc = False
			
			Set cdrdao = shell.exec( cdrdaocmd & cdrdaoreadopts )
			While Not cdrdao.stdout.atendofstream
				line = cdrdao.stdout.readline
		 		If regex.test( line ) Then
					discfull = True
					driveready = False
				End If
				
				If regex2.test( line ) Then
					discfull = False
					driveready = True
				End If
		 	Wend
			
			Do While cdrdao.status = 0
				wscript.sleep 100
			Loop
			
			If cdrdao.exitcode <> 0 Then
				nodisc = True
			End If
			
			If Not ready Then
				If nodisc Then
					If shell.popup(nodiscmessage,0,"Continue?", 4 + 32 ) = 7 Then
						cancelburn = True
					End If
				End If
				
				If discfull Then
					If shell.popup(fulldiscmessage,0,"Continue?", 4 + 32 ) = 7 Then
						cancelburn = True
					End If
				End If
				
			End If
		
		Loop
	
		If Not cancelburn Then
			DriveReady = True
		Else
			'wscript.echo "burn cancelled"
			nStatus = 5 ' failed - since we didn't do any work
			DriveReady = False
		End If

	
	End Function
	
	Public Sub BurnDisc( strTOCFile )
	
		Dim cdrdaocmd, cdrdaowriteopts, shell, cdrdao
	
		wscript.stdout.writeline "  burning disc: " & oLabel.GetLabelKey & "..."
		cdrdaocmd = "c:\cd\bin\cdrdao\cdrdao.exe" '"c:\program files\burnatonce\external\cdrdao"
		cdrdaowriteopts = " write --device SPTI:1,0,0 --driver generic-mmc --speed 24 --eject -n "
				
		Set shell = createobject("WScript.Shell")

		
		Set cdrdao = shell.exec( cdrdaocmd & cdrdaowriteopts & strTOCFile )
		Do While cdrdao.status = 0
			wscript.sleep 100
		Loop
		
		If cdrdao.exitcode <> 0 Then
			'an error occurred while writing
			nStatus = 5 'failed
		Else
			'everything worked ok
			nStatus = 4 'complete
		End If
	
		
		' this will be done in the caller: SetStatusInDB ( conn ) 'update the status in the database for what occurred above
	
	End Sub
	
	Public Sub CleanupBurnFiles( strCDRDAOJobsDir )
		Dim FSO,fldr,fc,f,regex
			
		Set shell = WScript.CreateObject("WScript.Shell") 
		
		Set FSO = CreateObject("Scripting.FileSystemObject")
		Set fldr = FSO.GetFolder( strCDRDAOJobsDir )
		Set fc = fldr.Files
		
		Set regex = New RegExp
		regex.Global = True
		regex.IgnoreCase = True
		For Each f In fc
			regex.Pattern = oLabel.GetLabelKey & ".+\.wav" 'match the wav extension of a file
			If regex.Test(f.name) Then
				f.delete ' remove file
			End If
		Next
		'now delete the TOC file we created
		FSO.DeleteFile( strCDRDAOJobsDir & oLabel.GetLabelKey & ".toc" )		
	
	End Sub
	
	Public Sub SubmitJobToCDRDAO( strAudioFilesDir, strCDRDAOJobsDir)
		'wscript.stdout.writeline "test"
		'wscript.echo "hello"
		If RequiredFilesExist(strAudioFilesDir) Then
		'wscript.echo "hello again"
			' attempt to create a toc file
			Dim strTOCFile
			strTOCFile = CreateTOCFile(strCDRDAOJobsDir,strAudioFilesDir)
			If strTOCFile = "error" Then
				nStatus = 5
				SetStatusInDB(conn) 'communicate to the system that the job failed
			Else
				If DriveReady Then
					GenerateBurnFiles strCDRDAOJobsDir, strAudioFilesDir
					BurnDisc( strTOCFile )
					'SetStatusInDB(conn)
					CleanupBurnFiles strCDRDAOJobsDir
				End If
			End If
		Else
			'signal an error since we don't have the required files
			nStatus = 5
			'SetStatusInDB( conn )
		End If
		SetStatusInDB ( conn )
		
	End Sub
	
	Public Function RequiredFilesExist( strAudioFilesDir )
		Dim fso, fldr, fc, f, count
		Dim regex
		
		Set fso = CreateObject("Scripting.FileSystemObject")
		Set fldr = fso.GetFolder( strAudioFilesDir )
		Set fc = fldr.Files
		
		Set regex = New RegExp
		regex.Global = True
		regex.IgnoreCase = True
	
		count = 0
		'wscript.echo strAudioFilesDir
		For Each f In fc
			regex.Pattern = oLabel.GetLabelKey & ".+\.mp3" 'match the wav extension of a file
		
			If regex.Test(f.name) Then
				count = count + 1
			End If
		Next
		
		If count > 0 Then
			RequiredFilesExist = True
			'wscript.echo "files found"
		Else
			RequiredFilesExist = False
			'wscript.echo "no files"
		End If
		
	End Function
		
	Public Property Let Status(Byval varStatusIn)
		nStatus = varStatusIn
	End Property
	
	'Public Property Set Label(Byref onewLabel )
	'	Set oLabel = onewLabel
	'End Property
	
	Public Property Get Status
		Status = nStatus
	End Property
	
	Public Property Get ID
		ID = nID
	End Property
	
	Public Property Get Label
		Set Label = oLabel
	End Property
	
	Public Property Get Copies
		Copies = nCopies
	End Property
	
	Public Property Get LabelID
		LabelID = nLabelID
	End Property
	 
End Class

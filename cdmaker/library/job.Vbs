Function CreateLabel()
	'Dim oLabel
	'Set oLabel = new Label
	Set CreateLabel = new Label
End Function

Class Job
	Private nID, oLabel, nLabelID, nCopies, nStatus, nGoodDiscs, nBadDiscs, nRemainingDiscs, bPrintOnly, bDVD, bMaster, bPulpit, oLog
	
	Public Sub Initialize( id, Byref oConn, byref ologfile )
		Dim strSQL, oRS
		ologfile.WriteLine Now & " Initializing Job: " & id
		Set oLog = ologfile
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
			
			If oRS.Fields("master") = "y" Then
				bMaster = True
			Else
				bMaster = False
			End If
			
			If oRS.Fields("pulpit") = "y" Then
				bPulpit = True
			Else
				bPulpit = False
			End If
			
			Set oLabel = CreateLabel()'new Label
			Label.LoadFromDB nLabelID, oConn
		End If
		oRS.Close
		Set oRS = Nothing
		ologfile.WriteLine Now & " Finished initializing Job: " & id
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
	
	Public Sub GetStatusFromPTBurn( strPTBurnJobsDir, strLabelFileDir ) 
		'valid statuses: 
		'0 - on hold 
		'1 - submitted 
		'2 - received 
		'3 - processing 
		'4 - completed 
		'5 - failed (error) 
		Dim FSO, folder, fc, fl, regex
		
		oLog.WriteLine Now & " Getting job status for Job: " & nID & " for Service: " & oLabel.GetLabelKey()
		Set FSO = CreateObject("Scripting.FileSystemObject") 
		If fso.FileExists( strPTBurnJobsDir & "JOB_" & nID & ".jrq" ) Then
			nStatus = 2
		Else
			If  fso.FileExists( strPTBurnJobsDir & "JOB_" & nID & ".inp" ) Then 
				nStatus = 3 
			Else 
				If fso.FileExists( strPTBurnJobsDir & "JOB_" & nID & ".qrj" ) Then
					nStatus = 3
				Else
					'At this point the job is ether successful or failed
					'we should clean up any .prn files associated with this job
					'now that .prn files are being created on a per-job basis
					Set regex = new RegExp
					regex.Global = True 
	                        regex.IgnoreCase = True 
					regex.Pattern = ".+\-" & CStr(nID) & "\.prn"
					Set folder = FSO.GetFolder(strLabelFileDir)
					Set fc = folder.Files	
					For Each fl In fc
						If  regex.Test(fl.name)  Then
							fl.Delete 'delete the file if it exists
						End If
					Next
					 
					If fso.FileExists( strPTBurnJobsDir & "JOB_" & nID & ".don" ) Then 
						nStatus = 4

					Else 
						If fso.FileExists ( strPTBurnJobsDir & "JOB_" & nID & ".err" ) Then 
							'either of these conditions result in an error, the first means there was an acutal error from ptburn 
							nStatus = 5 

						Else 
							'the second means that we couldn't even find the job file for this running job so we flag it as an error 
							nStatus = 5 

						End If 
					End If 
				End If
			End If 
		End If
		oLog.WriteLine Now & "     Job Status: " & nStatus
	End Sub
	
	Public Sub SetStatusInDB( oConn )
		'wscript.stdout.writeline "new status: " & nStatus	
		Dim strSQL
		strSQL = "update jobs set status = " & nStatus & ", lastupdate = now() where id = " & nID
		oConn.Execute strSQL

	End Sub
	
	Public Sub SubmitJobToPTBurn( strAudioFilesDir, strLabelFileDir, strPTBurnJobsDir)
		'wscript.stdout.writeline "cucu"
		oLog.WriteLine Now & " Submitting Job: " & nID & " for Service: " & oLabel.GetLabelKey() & " To PTBurn."
		Dim FSO, jobFile, jobFileName,fldr,fc,f,regex, strLabelFile
		If bPrintOnly Or RequiredFilesExist(strAudioFilesDir) Then
			
			'do some work
			'wscript.stdout.writeline "wasabi"
			'wscript.stdout.writeline oLabel.GetLabelKey
			
			'first we make the label so it can be referenced in the job
			If bDVD Then
				'''oLabel.CreateLabelFile "c:\cd\data\label\word-dvd-label.doc", strLabelFileDir, bDVD, CStr(nID), strPTBurnJobsDir
				strLabelFile = "dvd-label.std"
			Else
				If bMaster Then
					'''oLabel.CreateLabelFile "c:\cd\data\label\word-cd-label-master.doc", strLabelFileDir, bDVD, CStr(nID), strPTBurnJobsDir
					strLabelFile = "cd-label-master.std"
				Else
					If bPulpit Then
						'''oLabel.CreateLabelFile "c:\cd\data\label\word-cd-label-bw.doc", strLabelFileDir, bDVD, CStr(nID), strPTBurnJobsDir
						strLabelFile = "cd-label-pulpit.std"
					Else
						'''oLabel.CreateLabelFile "c:\cd\data\label\word-cd-label.doc", strLabelFileDir, bDVD, CStr(nID), strPTBurnJobsDir
						strLabelFile = "cd-label.std"
					End If
				End If
			End If
					
			'now we write the data into the job file 
			
			Set FSO = CreateObject("Scripting.FileSystemObject")
			'jobFileName = strPTBurnJobsDir & oLabel.GetLabelKey & ".jrq"
			jobFileName = strPTBurnJobsDir & "JOB_" & nID & ".jrq" 
			'wscript.stdout.writeline strPTBurnJobsDir & oLabel.GetLabelKey & ".jrq"
			Set jobFile = FSO.CreateTextFile( jobFileName, True )
			
			Set fldr = FSO.GetFolder( strAudioFilesDir )
			Set fc = fldr.Files
			
			Set regex = New RegExp
			regex.Global = True
			regex.IgnoreCase = True
	
			jobFile.WriteLine "JobID = " & nID
			
			If Not bPrintOnly Then 
				jobFile.WriteLine "VolumeName = " & oLabel.GetLabelKey
				For Each f In fc
					regex.Pattern = oLabel.GetLabelKey & ".+\.mp3" 'match the wav extension of a file
					If regex.Test(f.name) Then
						jobFile.WriteLine "AudioFile = " & strAudioFilesDir & f.name
					End If
				Next
				'jobFile.WriteLine "BurnSpeed = 24" 'if this is ommited the max speed is used
				jobFile.WriteLine "CloseDisc = YES"
			End If
			
			jobFile.WriteLine "Copies = " & nCopies
			jobFile.WriteLine "PrintLabel = " & strLabelFileDir & strLabelFile
			jobfile.WriteLine "MergeField = " & oLabel.ServiceTitle
			jobfile.WriteLine "MergeField = " & oLabel.ServiceDate
			jobfile.WriteLine "MergeField = " & oLabel.ServiceDay
			jobfile.WriteLine "MergeField = " & oLabel.ServiceMinister
			
			jobFile.Close
			oLog.WriteLine Now & " Job was submitted."
			
		End If
	End Sub
	
	Public Function RequiredFilesExist( strAudioFilesDir )
	      oLog.WriteLine Now & "     Checking if required files exist for current job."
		Dim fso, fldr, fc, f, count
		Dim regex
		
		Set fso = CreateObject("Scripting.FileSystemObject")
		Set fldr = fso.GetFolder( strAudioFilesDir )
		Set fc = fldr.Files
		
		Set regex = New RegExp
		regex.Global = True
		regex.IgnoreCase = True
	
		count = 0
		
		For Each f In fc
			regex.Pattern = oLabel.GetLabelKey & ".+\.mp3" 'match the wav extension of a file
			If regex.Test(f.name) Then
				count = count + 1
			End If
		Next
		
		If count > 0 Then
			RequiredFilesExist = True
		Else
			RequiredFilesExist = False
			oLog.WriteLine Now & "    Unable to find required files."
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

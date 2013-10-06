Function CreateJob()
	Set CreateJob = new Job
End Function

Class CDMaker
	
	Private strAudioFilesDir, strCDRDAOJobDir, strLabelFileDir, strConnection
	
	Public Property Get AudioFilesDir
		AudioFilesDir = strAudioFilesDir
	End Property
	
	Public Property Let AudioFilesDir(Byval varNewVal)
		strAudioFilesDir = varNewVal
	End Property

	Public Property Get CDRDAOJobDir
		CDRDAOJobDir = strCDRDAOJobDir
	End Property
	
	Public Property Let CDRDAOJobDir(Byval varNewVal)
		strCDRDAOJobDir = varNewVal
	End Property
	
	Public Property Get Connection
		Connection = strConnection
	End Property

	Public Property Let Connection(Byval varNewVal)
		strConnection = varNewVal
	End Property


	Public Sub Go()
		Dim oConn, ProcessSet, WshShell, exitApp, inputLine
		
		exitApp = False
		'Dim strConnection
		
		'Dim myJob, myLabel
		
		'strConnection = "DSN=Tape;"
		If  isempty(strConnection) Or isempty(strAudioFilesDir) Or isempty (strCDRDAOJobDir) Then
			'some necessary stuff was not set
			wscript.stdout.writeline "Error: CDMaker was not initialized properly."
			If isempty(strConnection) Then
				wscript.stdout.writeline "     Connection property was not set."
			End If
			If isempty(strAudioFilesDir) Then
				wscript.stdout.writeline "     AudioFilesDir property was not set."
			End If
			If isempty (strCDRDAOJobDir) Then
				wscript.stdout.writeline "     CDRDAOJobsDir property was not set."
			End If
						
			Exit Sub
		End If 
		

		
		Set oConn = createobject("ADODB.Connection")
		oConn.ConnectionString = strConnection
		oConn.Open
		'wscript.echo "checking for jobs"
		wscript.stdout.writeline "Processing CDs..."
		While Not exitApp 
'			If Not wscript.stdin.atendofline Then
'				inputLine = wscript.stdin.readline
'				If inputline = "q" Then
'					exitApp = True
'				End If
'			End If
			
			wscript.stdout.writeline "  checking for new jobs..."
			If CheckForNewJobs(oConn) Then
				Dim jobarray
				jobarray = GrabNewJobs(oConn)
				
				'If Not ServiceIsRunning Then
				'	StartService
				'End If
				
				'wscript.stdout.writeline lbound(jobarray)
				'wscript.stdout.writeline ubound(jobarray)
				For i = lbound(jobarray) To ubound(jobarray)
					'wscript.stdout.writeline "test"
					'jobarray(i).SubmitJobToPTBurn strAudioFilesDir, strLabelFileDir, strPTBurnJobDir
					'wscript.echo "found a job to process"
					jobarray(i).SubmitJobToCDRDAO strAudioFilesDir, strCDRDAOJobDir
					'wscript.stdout.writeline jobarray(i).Label.ServiceTitle
				Next
				
			End If
			wscript.sleep 60000 'sleep for two minutes
		Wend
		


'		If CheckForRunningJobs(oConn) Then
'			Dim currentjobs
'			currentjobs = GetRunningJobs(oConn)
				'wscript.stdout.writeline "one"
				'wscript.stdout.writeline ubound(currentjobs)
'			For i = lbound(currentjobs) To ubound(currentjobs)
'				currentjobs(i).GetStatusFromPTBurn strPTBurnJobDir
'				currentjobs(i).SetStatusInDB oConn
				'wscript.stdout.writeline "whateva"
				'wscript.stdout.writeline currentjobs(i).Status
'			Next
'		End If
		
		oConn.Close
		Set oConn = Nothing
	End Sub
	
	Private Function CheckForNewJobs( byref oConn )
		Dim oRS, sSQL, ret
		ret = False
		sSQL = "SELECT COUNT(*) FROM JOBS WHERE STATUS = 1"
		Set oRS = CreateObject("ADODB.Recordset")
		oRS.Open sSQL, oConn, adOpenKeyset
		If Clng(oRS.Fields(0)) > 0 Then
			ret = True
			'wscript.stdout.writeline "there are new jobs"
			'wscript.echo "there are new jobs"
		End If
		oRS.Close
		Set oRS = Nothing
		CheckForNewJobs = ret
	End Function
	
	Private Function GrabNewJobs ( byref oConn )
		Dim jobarray()
		Dim oRS, sSQL, i
		
		sSQL = "SELECT ID FROM JOBS WHERE STATUS = 1"
		Set oRS = CreateObject("ADODB.Recordset")
		oRS.Open sSQL, oConn, adOpenKeyset 
		'wscript.stdout.writeline oRS.RecordCount
		Redim jobarray(oRS.RecordCount - 1)

		i = 0
		While Not oRS.EOF
			Set jobarray(i) = CreateJob()
			jobarray(i).Initialize oRS.Fields("id"), oConn, oLog
			jobarray(i).Status = 2
			jobarray(i).SetStatusInDB oConn
			oRS.MoveNext
			i = i + 1
		Wend
		oRS.Close
		Set oRS = Nothing
		'wscript.stdout.writeline isempty(jobarray(0))
		GrabNewJobs = jobarray
	End Function
	
	Private Function CheckForRunningJobs( byref oConn )
		Dim oRS, sSQL, ret
		ret = False
		sSQL = "SELECT COUNT(*) FROM JOBS WHERE STATUS > 1 AND STATUS < 4"
		Set oRS = CreateObject("ADODB.Recordset")
		oRS.Open sSQL, oConn, adOpenKeyset
		If Clng(oRS.Fields(0)) > 0 Then
			ret = True
			'wscript.stdout.writeline "there are new jobs"
		End If
		oRS.Close
		Set oRS = Nothing
		CheckForRunningJobs = ret
	End Function
	
	
	Private Function GetRunningJobs ( byref oConn )
		Dim jobarray()
		Dim oRS, sSQL, i
		
		sSQL = "SELECT ID FROM JOBS WHERE STATUS > 1 AND STATUS < 4"
		Set oRS = CreateObject("ADODB.Recordset")
		oRS.Open sSQL, oConn, adOpenKeyset 
		If ( oRS.RecordCount > 0 ) Then
			'wscript.stdout.writeline "two"
			Redim jobarray(oRS.RecordCount - 1)
	
			i = 0
			While Not oRS.EOF
				Set jobarray(i) = CreateJob()
				jobarray(i).Initialize oRS.Fields("id"), oConn, oLog
				oRS.MoveNext
				i = i + 1
			Wend
			oRS.Close
			Set oRS = Nothing
		End If
		GetRunningJobs = jobarray
	End Function	


End Class

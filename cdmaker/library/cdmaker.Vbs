Function CreateJob()
	Set CreateJob = new Job
End Function

Class CDMaker
	
	Private strAudioFilesDir, strPTBurnJobDir, strLabelFileDir, strConnection
	
	Public Property Get AudioFilesDir
		AudioFilesDir = strAudioFilesDir
	End Property
	
	Public Property Let AudioFilesDir(Byval varNewVal)
		strAudioFilesDir = varNewVal
	End Property

	Public Property Get PTBurnJobDir
		PTBurnJobDir = strPTBurnJobDir
	End Property
	
	Public Property Let PTBurnJobDir(Byval varNewVal)
		strPTBurnJobDir = varNewVal
	End Property
	
	Public Property Get LabelFileDir
		LabelFileDir = strLabelFileDir
	End Property
	
	Public Property Let LabelFileDir(Byval varNewVal)
		strLabelFileDir = varNewVal
	End Property
	
	Public Property Get Connection
		Connection = strConnection
	End Property

	Public Property Let Connection(Byval varNewVal)
		strConnection = varNewVal
	End Property


	Public Sub Go()
		Dim oConn, ProcessSet, WshShell
		'Dim strConnection
		
		'Dim myJob, myLabel
		
		'strConnection = "DSN=Tape;"
		If  isempty(strConnection) Or isempty(strAudioFilesDir) Or isempty (strPTBurnJobDir) Or isempty(strLabelFileDir) Then
			'some necessary stuff was not set
			wscript.stdout.writeline "Error: CDMaker was not initialized properly."
			If isempty(strConnection) Then
				wscript.stdout.writeline "     Connection property was not set."
			End If
			If isempty(strAudioFilesDir) Then
				wscript.stdout.writeline "     AudioFilesDir property was not set."
			End If
			If isempty (strPTBurnJobDir) Then
				wscript.stdout.writeline "     PTBurnJobsDir property was not set."
			End If
			If isempty(strLabelFileDir) Then
				wscript.stdout.writeline "     LabelFileDir property was not set."
			End If
						
			Exit Sub
		End If 
		
		'The below is no longer needed now that PTBurn SDK runs as a windows service. 1/21/2009
		'here we make sure ptburn is running before we do anything else
		'Set ProcessSet = GetObject("winmgmts:{impersonationLevel=impersonate}").ExecQuery("select * from Win32_Process where name ='ptburn.exe' ") 
		'If  ProcessSet.Count > 0 Then
		'	'ptburn is already running
		'	WScript.Sleep(50)
		'Else 
		'	Set WshShell = WScript.CreateObject("WScript.Shell") 
		'	WshShell.Run """C:\Program Files\Primera Technology\PTBurn Server\Server\ptburn.exe"""  
		'	WScript.Sleep(1000)
		'End If

		
		Set oConn = createobject("ADODB.Connection")
		oConn.ConnectionString = strConnection
		oConn.Open
		
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
				jobarray(i).SubmitJobToPTBurn strAudioFilesDir, strLabelFileDir, strPTBurnJobDir
				'wscript.stdout.writeline jobarray(i).Label.ServiceTitle
			Next
			
		End If
		


		If CheckForRunningJobs(oConn) Then
			Dim currentjobs
			currentjobs = GetRunningJobs(oConn)
				'wscript.stdout.writeline "one"
				'wscript.stdout.writeline ubound(currentjobs)
			For i = lbound(currentjobs) To ubound(currentjobs)
				currentjobs(i).GetStatusFromPTBurn strPTBurnJobDir, strLabelFileDir
				currentjobs(i).SetStatusInDB oConn
				'wscript.stdout.writeline "whateva"
				'wscript.stdout.writeline currentjobs(i).Status
			Next
		End If
		
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

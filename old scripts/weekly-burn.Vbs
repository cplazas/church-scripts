<job>
	<script language="vbscript" src="label.vbs"/>
	'<script language="vbscript" src="job.vbs"/>
	'<script language="vbscript" src="cdmaker.vbs"/>
	<reference Object = "ADODB.Recordset"/>
	<reference Object = "ADODB.Connection"/>
	<script language="vbscript">
		
		'globals
		Dim FSO, fldr, fc, f, regex, oLabel
		
		Function CreateLabel()
			'Dim oLabel
			'Set oLabel = new Label
			Set CreateLabel = new Label
		End Function
		
		Public Function RequiredFilesExist( strAudioFilesDir )
			Dim count
			
			Set fldr = fso.GetFolder( strAudioFilesDir )
			Set fc = fldr.Files 
			
			Set regex = New RegExp 
			regex.Global = True 
			regex.IgnoreCase = True 
			count = 0 

			For Each f In fc
				regex.Pattern = oLabel.GetLabelKey & ".+\.wav" 'match the wav extension of a file
				If regex.Test(f.name) Then 
					count = count + 1 
				End If 
			Next 
			
			If count > 0 Then 
				RequiredFilesExist = True 
			Else 
				RequiredFilesExist = False 
			End If 
			
		End Function 
		
		
		

		Sub SubmitJobToPTBurn( strAudioFilesDir, strLabelFileDir, strPTBurnJobsDir)
			'wscript.stdout.writeline "cucu" 
			If RequiredFilesExist(strAudioFilesDir) Then 
				
				'do some work 
				'wscript.stdout.writeline "wasabi" 
				'wscript.stdout.writeline oLabel.GetLabelKey 
				
				'first we make the label so it can be referenced in the job 
				oLabel.CreateLabelFile "c:\cd\data\label\word-cd-label.doc", strLabelFileDir, False 
						
				'now we write the data into the job file  
				Dim jobFile, jobFileName
				'jobFileName = strPTBurnJobsDir & oLabel.GetLabelKey & ".jrq" 
				jobFileName = strPTBurnJobsDir & "CURRENT_SERVICE" & ".jrq"  
				'wscript.stdout.writeline strPTBurnJobsDir & oLabel.GetLabelKey & ".jrq" 
				Set jobFile = FSO.CreateTextFile( jobFileName, True ) 
				
				Set fldr = FSO.GetFolder( strAudioFilesDir ) 
				Set fc = fldr.Files 
				
				Set regex = New RegExp 
				regex.Global = True 
				regex.IgnoreCase = True 
		
				jobFile.WriteLine "JobID = CURRENT"  
				
				If Not bPrintOnly Then  
					jobFile.WriteLine "VolumeName = " & oLabel.GetLabelKey 
					For Each f In fc 
						regex.Pattern = oLabel.GetLabelKey & ".+\.wav" 'match the wav extension of a file 
						If regex.Test(f.name) Then 
							jobFile.WriteLine "AudioFile = " & strAudioFilesDir & f.name 
						End If 
					Next 
					'jobFile.WriteLine "BurnSpeed = 24" 'if this is ommited the max speed is used 
					jobFile.WriteLine "CloseDisc = YES" 
				End If 
				
				jobFile.WriteLine "Copies = 1" 
				
				jobFile.WriteLine "PrintLabel = " & strLabelFileDir & oLabel.GetLabelKey & ".PRN" 
				
				jobFile.Close 
				
			End If 
		End Sub 

		
			Set FSO = CreateObject("Scripting.FileSystemObject") 
		Set fldr = FSO.GetFolder( strAudioFilesDir )  
		Set fc = fldr.Files  
		
		Set regex = New RegExp  
		regex.Global = True  
		regex.IgnoreCase = True  
		
		Dim bFoundWav, sMonth, sDay, sService, sPattern
		bFoundWav = False
		
		If hour(now) < 18 Then
			service = "AM" 
		Else 
			service = "PM" 
		End If 
		
		smonth = cstr(month(now)) 
		If month(now) < 10 Then 
			smonth = "0" & smonth 
		End If 
		
		sday = cstr(day(now)) 
		If day(now) < 10 Then 
			sday = "0" & sday 
		End If 
		
		sPattern = smonth & sday & right(cstr(year(now) ),2) & sService	
			
		For Each f In fc  
			regex.Pattern = sPattern & ".+\.wav" 'match the wav extension of a file  
			If regex.Test(f.name) Then 
			 	bFoundWav = True
			End If  
		Next  
		
		If bFoundWav Then
			'find the id of our label,
			Dim oConn
			
			Set oConn = createobject("ADODB.Connection")
			oConn.ConnectionString = "DSN=Tape;"  
			oConn.Open 
			
			Dim oRS, sSQL,nLabelID
			nLabelID = 0
			
			sSQL = "SELECT ""ID"" FROM ""Tapes"" WHERE ""Month"" = '" & smonth & "' AND ""Date"" = '" & sday 
			sSQL = sSQL & "' AND ""Year"" = '" &  cstr(year(now)) &  "' AND ""Day"" like '%" & sService & "'"
			Set oRS = CreateObject("ADODB.Recordset") 
			oRS.Open sSQL, oConn, adOpenKeyset 
			If Not oRS.EOF Then
				nLabelID = oRS.Fields("ID")
			End If
			oRS.Close 
			Set oRS = Nothing 
			
			If nLabelID > 0 Then
						' create a label and initialize it
						Set oLabel = CreateLabel()'new Label
				oLabel.LoadFromDB nLabelID,oConn 
				
				  		' submit the job
				  		SubmitJobToPTBurn "c:\cd\data\temp\weekly\burn\" , "c:\cd\data\label\", "C:\ptburnjobsnw\"
				  		
				  		
				  End If		
 
		End If
	
	</script>
</job>



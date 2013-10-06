Class Label
	Private nID, dDate, sDay, sService, sMinister, sSermonTitle
	
	Public Property Get ID
		ID = nID
	End Property

	Public Property Get ServiceDate
		ServiceDate = dDate
	End Property
	
	Public Property Get ServiceDay
		ServiceDay = sDay
	End Property
	
	Public Property Get ServiceNumber
		ServiceNumber = nService
	End Property
	
	Public Property Get ServiceMinister
		ServiceMinister = sMinister
	End Property
	
	Public Property Get ServiceTitle
		ServiceTitle = sSermonTitle
	End Property
	
	
	Public Sub LoadFromDB ( nID, byref oConn )
		Dim oRS, sSQL
		Set oRS = CreateObject("ADODB.Recordset")
		sSQL = "SELECT * FROM ""Tapes"" WHERE ""ID"" = '" & nID & "'"
		oRS.Open sSQL,oConn,adOpenKeyset
		If oRS.RecordCount > 0 Then
			nID = oRS.Fields("ID")
			dDate = CDate(oRS.Fields("Month") & "/" & oRS.Fields("Date") & "/" & oRS.Fields("Year"))
			sDay = oRS.Fields("Day")
			sService = oRS.Fields("Service#")
			sMinister = oRS.Fields("Minister")
			sSermonTitle = oRS.Fields("Sermon Title")
		End If
		oRS.Close
		Set oRS = Nothing
	End Sub
	
	Public Sub CreateLabelFile ( sTemplateFile, sTargetPath, sDVD, sJobID, sPTBurnJobsDir )
		Dim PRNFile, MSWord, FSO, shape, bPrinterReady, sRobotName, sRobotStatusFile, bMoreJobsToCheck
		Dim iJobCounter, sIniJob, sIniJobStatus
		
		If  sDVD Then
			PRNFile = sTargetPath & GetLabelKey & "_DVD" & "-" & sJobID & ".PRN" 
		Else
			PRNFile = sTargetPath & GetLabelKey & "-" & sJobID & ".PRN"
		End If

		'new feature override default label template if a .doc file named with the "label key"
                'of the cd/dvd exists in the label directory
                
                'first instantiate a file system object
                Set FSO = CreateObject("Scripting.FileSystemObject") 
		
                'next check if the override template file exists and if so, use it in place of the default
                If sDVD Then
                    If FSO.FileExists(sTargetPath & GetLabelKey & "_DVD.DOC" ) Then
                         sTemplateFile = sTargetPath & GetLabelKey & "_DVD.DOC"
                    End If
                Else
                    IF FSO.FileExists(sTargetPath & GetLabelKey & ".DOC" ) Then 
                         sTemplateFile = sTargetPath & GetLabelKey & ".DOC" 
                    End If
                End If 

                Set FSO = Nothing

		Set MSWord = CreateObject("Word.Application") 
		MSWord.Visible = False 
		MSWord.Documents.Open sTemplateFile
		

		For Each shape In MSWord.ActiveDocument.Shapes
			If shape.Type = 17  Then ' this means the shape is a text box
				If shape.TextFrame.TextRange.Text = "SERMON" & Vbcr Then
					shape.TextFrame.TextRange.Text = sSermonTitle
				End If
				If shape.TextFrame.TextRange.Text = "DATE" & Vbcr Then
					shape.TextFrame.TextRange.Text = dDate
				End If
				If shape.TextFrame.TextRange.Text = "DAY" & Vbcr Then
					shape.TextFrame.TextRange.Text = sDay
				End If
				If shape.TextFrame.TextRange.Text = "MINISTER" & Vbcr Then
					shape.TextFrame.TextRange.Text = sMinister
				End If
			End If 
		Next
		


		
		'before printing the file we have to make sure the printer is not busy: either
		'actively printing a job or making robotic movements
		'to do this we check the duplicator status file for active jobs and each one must have
		'a status of "Recording Disc X" or "Waiting for Recorder"
		
		'read the status file To get the duplicator name
		sRobotName = MSWord.System.PrivateProfileString(sPTBurnJobsDir & "status\systemstatus.txt", "RobotList" , "Robot0")
		sRobotStatusFile = sPTBurnJobsDir & "status\" & sRobotName & ".txt"
		
		bPrinterReady = False 'initial state so we can begin checking job status in the loop below
		
		While Not bPrinterReady
		  
		  bMoreJobsToCheck = True
		  iJobCounter = -1
		  While bMoreJobsToCheck
		    iJobCounter = iJobCounter + 1
		    sIniJob = MSWord.System.PrivateProfileString( sRobotStatusFile, "JobList", "Job" & CStr(iJobCounter))
		    
		    If sIniJob = "" Then
		      bMoreJobsToCheck = False
		      If iJobCounter = 0 Then
		        'this is the first time through and if we find no active jobs then we 
		        'can assume the printer Is ready
		        bPrinterReady = True
		      End If
		    End If
		    
		    If bMoreJobsToCheck Then
		      sIniJobStatus = MSWord.System.PrivateProfileString(sRobotStatusFile, sIniJob, "CurrentStatus" )
		      sIniJobStatus = left(sIniJobStatus, instr(sIniJobStatus," ")-1)
                  'need To look at the condition below To make sure that If 
		      If  sIniJobStatus <> "Recording" And sIniJobStatus <> "Waiting" Then
		        bPrinterReady = False
		        bMoreJobsToCheck = False 'this stops searching the job statuses
		      Else
		        bPrinterReady = True
		      End If
		    End If
		  Wend
		  
		  If Not bPrinterReady Then
		  	wscript.sleep(5000) ' wait five seconds before checking the status again
		  End If
		Wend
		

		MSWord.ActiveDocument.PrintOut ,,,PRNFile,,,,,,,True
		wscript.sleep(3000) 'Wait for 3 seconds for the file to be generated
		MSWord.Quit 0
		Set MSWord = Nothing
	
		'write out the newly modified file
		'FileStream.SaveToFile sTargetPath & STFile, adSaveCreateOverWrite
		
	End Sub
	
	Public Function GetLabelKey()
		Dim sDate, sMonth, sYear,sAMPM
		'MergeFile = "080803PM.TXT"
		If month(dDate) < 10 Then
			sMonth = "0" & CStr(month(dDate))
		Else
			sMonth = CStr(month(dDate))
		End If
		
		If day(dDate) < 10 Then
			sDate = "0" & CStr(day(dDate))
		Else
			sDate = CStr(day(dDate))
		End If
		
		sYear = right(Cstr(year(dDate)),2)
		sAMPM = ucase(right(sDay,2))
		
		GetLabelKey = sMonth & sDate & sYear & sAMPM

	End Function
	
End class
	
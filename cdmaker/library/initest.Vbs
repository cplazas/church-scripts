Dim MSWord, sRobotName,bPrinterReady, sRobotStatusFile 
Dim bMoreJobsToCheck,iJobCounter, sIniJob, sIniJobStatus,sPTBurnJobsDir
sPTBurnJobsDir = "C:\PTBurnJobs\"



Set MSWord = CreateObject("Word.Application") 
MSWord.Visible = False 
'sRobotName = MSWord.System.PrivateProfileString("C:\PTBurnJobs\Status\Disc Publisher SE.txt", "JobList" , "Job0")
'
'If sRobotName = "" Then
'wscript.stdout.writeline sRobotName
'  wscript.stdout.writeline "No Active Jobs Found"
'Else
'  wscript.stdout.writeline "Active Jobs Found. First Job is: " & sRobotName
'End If


'before printing the file we have to make sure the printer is not busy: either
		'actively printing a job or making robotic movements
		'to do this we check the duplicator status file for active jobs and each one must have
		'a status of "Recording Disc X" or "Waiting for Recorder"
		
		'read the status file To get the duplicator name
		sRobotName = MSWord.System.PrivateProfileString(sPTBurnJobsDir & "status\systemstatus.txt", "RobotList" , "Robot0")
		sRobotStatusFile = sPTBurnJobsDir & "status\" & sRobotName & ".txt"
		wscript.stdout.writeline sRobotStatusFile
		
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
		      wscript.stdout.writeline sIniJobStatus
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
		      wscript.stdout.writeline "Printer Not Ready"
		  	wscript.sleep(5000) ' wait two seconds before checking the status again
		  End If
		Wend
		
		wscript.stdout.writeline "Proceeding To print"


MSWord.Quit 0
Set MSWord = Nothing

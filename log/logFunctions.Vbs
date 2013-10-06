'Function: openLog
'Purpose:
'  Opens a text file in the specified directory for the purpose of logging 
'
'Arguments: 
'  logFile - the fully qualified name of the file that will be used as the log file
'  openMessage - (optional) a message that will be printed as the first line in the log file
'  
'Return Value:
'  returns a file object that can be written to
'
Public Function openLog( logFile, openMessage)
	Dim fso, oLog
	
	Set fso = CreateObject("Scripting.FileSystemObject")
	
	Set oLog = fso.CreateTextFile(logFile,True)
	
	'deallocate the fso we used above, after we are done with it
	Set fso = Nothing
	
	oLog.WriteLine openMessage
	Set openLog = oLog
End Function

'Function: closeLog
'Purpose:
'  Closes the specified log file object 
'
'Arguments: 
'  oLog - a file object that is to be closed
'  closeMessage - (optional) a message that will be printed as the last line in the log file
'
Public Sub closeLog ( oLog, closeMessage )
	oLog.WriteLine closeMessage
	oLog.Close
	'deallocate the log file since we no longer need it after it is closed
	Set oLog = Nothing
End Sub

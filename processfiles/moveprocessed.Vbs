'steps
' 1. rename files to mddyyy[am|pm]_track[track number].wav
' 2. convert files to mp3
' 3. determine which files needed for cd and discard any unnecessary ones
' 4. apply normalization

'globals
Dim sourcepath, destpath, rejectpath, oLog, logpath

sourcepath = "c:\cd\data\incoming\"
'sourcepath = "e:\temp"
destpath = "c:\cd\data\audio\"
rejectpath = "c:\cd\data\reject\"
logpath = "C:\cd\data\moveprocessedfiles.log"

Public Sub notifyhuman( filename )
	'wscript.stdout.writeline "Error file too big for cd: " & filename
	Dim URL

	URL = "http://messaging.sprintpcs.com/textmessaging/composeconfirm?&phoneNumber=7065933315&callBackNumber=7065710919"
	URL = URL & "&message=CD%20too%20large.%20Key:%20" & filename
	  
	On Error Resume Next   
	Set objXML = CreateObject("MSXML2.XMLHTTP")   

	' Call the remote machine the request  
	objXML.open "GET", URL, False 
	objXML.send
	' clean up  
	Set objXML = Nothing 
	
	
	
End Sub

Public Sub movefiles()

	Dim fso, fldr, fc, f, fname 
	Dim regex 
	oLog.WriteLine Now & " - Moving Files to the final destination..."
	
	Set fso = CreateObject("Scripting.FileSystemObject") 
	Set fldr = fso.GetFolder(sourcepath) 
	Set fc = fldr.Files 
	
	Set regex = New RegExp 
	regex.Global = True 
	regex.IgnoreCase = True 


	For Each f In fc 
		regex.Pattern = ".+\.mp3" 'match the wav extension of a file 
		If regex.Test(f.name) Then 
                        fname = f.name
                        oLog.WriteLine Now & " - Attempting to move file " & f.name & " to: " & destpath & f.name
			fso.movefile sourcepath & f.name , destpath & f.name
			oLog.WriteLine Now & " - Moved file: " & fname & " successfully."
		End If
	Next
	
	oLog.WriteLine Now & " - Moving Files Completed. "

End Sub


Public Sub openlog()
	Dim fso
	Set fso = CreateObject("Scripting.FileSystemObject")
	Set oLog = fso.CreateTextFile(logpath,True)
	oLog.WriteLine Now & " - MoveProcessedFiles Started."
End Sub

openlog
movefiles
oLog.Writeline Now & " - MoveProcessedFiles Ended. "
oLog.Close

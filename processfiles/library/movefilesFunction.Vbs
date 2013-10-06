'Purpose:
'  move processed files from the source folder to the destination folder
'Arguments: 
'  sourcePath - the path containing the files to be moved
'  destPath   - the path to the destination folder
'  oLog       - a Scripting.FileSystemObject to be used for logging progress
'
Public Sub moveFiles( sourcePath, destPath, oLog)

	Dim fso
	oLog.WriteLine Now & " - Moving Files to the final destination. From: " & sourcePath & " To: " & destPath
	
	Set fso = CreateObject("Scripting.FileSystemObject") 
	  
	  ' have to make sure the destination folder exists or we might lose data
	  If fso.FolderExists( destPath ) Then
	  		
	  		fso.movefile sourcePath & "*.mp3" , destPath
	
	Else
		
		oLog.WriteLine Now & " - Destination folder does not exist! Files not moved."
	
	End If
	
	oLog.WriteLine Now & " - Moving Files Completed. "

End Sub

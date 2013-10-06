'Purpose:
'  Remove files in the source folder that have the confirm suffix in their name.
'Arguments: 
'  sourcePath - the folder containing the files to be removed
'  confirmSuffix - the suffix to append to the base filename for confirmed files
'  oLog       - a Scripting.FileSystemObject to be used for logging progress
'
Public Sub removeFiles( sourcePath, confirmSuffix, oLog)

	Dim fso, regex
	oLog.WriteLine Now & " - Removing Confirmed Files "

	Set regex = New RegExp 
	regex.Global = True  
	regex.IgnoreCase = True  
	
	Set fso = CreateObject("Scripting.FileSystemObject") 
	Set folder = fso.GetFolder(sourcePath) 
	Set files = folder.Files 
	
	For Each file In files  
		regex.Pattern = ".+\-" & confirmSuffix & "\...."  
		If regex.Test(file.name) Then
		    'delete any files that were confirmed in the prior run				
				'delete any confirmed files that are more than two weeks old
				If ( Now > DateAdd("d",15,file.DateLastModified) ) Then
					oLog.WriteLine Now & " - removing file: " & file.name
					file.delete
				End If
			
		End If
	Next
	
	oLog.WriteLine Now & " - Removing Files Completed. "

End Sub

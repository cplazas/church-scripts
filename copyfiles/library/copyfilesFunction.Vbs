'Purpose:
'  copy files from source folder to destination folder and rename succcessfully copied files
'  by suffixing the original file name with the specified suffix. The suffix will be 
'  separated from the original file name with a dash '-'.
'Arguments: 
'  sourcePath - the path containing the files to be copied
'  destPath   - the path to the destination folder
'  filenamePattern - the regular expression pattern used to match file names of files eligible for copying
'  copiedSuffix - the suffix to append to the file name of successfully copied files 
'  oLog       - a Scripting.FileSystemObject to be used for logging progress
'
Public Sub copyFiles( sourcePath, destPath, filenamePattern, copiedSuffix, oLog)

	Dim fso, folder, files, regex, newname
	oLog.WriteLine Now & " - Copying Files From: " & sourcePath & " To: " & destPath
	
	Set fso = CreateObject("Scripting.FileSystemObject") 
	Set folder = fso.GetFolder(sourcePath)
	Set files = folder.Files
	
	Set regex = New RegExp
      regex.Global = True
	regex.IgnoreCase = True

	regex.Pattern = filenamePattern '"(.+)\-(.+)\-(.+)\-song(.+)\.wav"
	For Each file In files
		If regex.Test(file.name) Then 
			'here we actually copy the files
			oLog.WriteLine Now & " - copying file: " & file.name
			fso.copyfile sourcePath & file.name, destPath & file.name
			'now we rename it to -copied
			'Dim newname
			newname = split(file.name, "." )
			If copiedSuffix <> "" Then
				oLog.WriteLine Now & " - renaming file: " & sourcePath & file.name & " To: " & sourcePath & newname(0) & "-" & copiedSuffix & "." & newname(1)
				fso.movefile sourcePath & file.name, sourcePath & newname(0) & "-" & copiedSuffix & "." & newname(1)
			End If
		End If
	Next	  
	
	oLog.WriteLine Now & " - Copying Files Completed. "

End Sub

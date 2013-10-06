'Purpose:
'  Rename files in the source folder using the confirm suffix if the file exists in the destination folder
'  and that file was copied previously. The source files are in MM-DD-[AM|PM]-song[0-9]-copied.wav format
'  the destination files are in MMDDYY_TRACK[0-9].mp3
'Arguments: 
'  sourcePath - the folder containing the files to be renamed
'  destPath   - the folder containing the files to compare with
'  copiedSuffix - the suffix that the previously copied files will have on their file name
'  confirmSuffix - the suffix to append to the base filename for confirmed files
'  oLog       - a Scripting.FileSystemObject to be used for logging progress
'
Public Sub confirmFilesOld( sourcePath, destPath, copiedSuffix, confirmSuffix,  oLog)

	Dim fso, regex
	oLog.WriteLine Now & " - Confirming Files Previously Copied. From: " & sourcePath & " To: " & destPath
	
	Set fso = CreateObject("Scripting.FileSystemObject") 
	Set folder = fso.GetFolder(sourcePath) 
	Set files = folder.Files 

	Set regex = New RegExp
	regex.Global = True 
	regex.IgnoreCase = True 

	For Each file In files 
		regex.Pattern = ".+\-" & copiedSuffix & "\.wav" 
		
		If regex.Test(file.name) Then 
			' check for a complementary file in the audiodir 
			regex.Pattern = "(.+)\-(.+)\-(.+)\-song(.+)\-" & copiedSuffix & "\.wav"  
			Dim oMatches, oMatch, oSubMatch  
			Set oMatches = regex.Execute(file.name)  
			If oMatches.Count > 0 Then 
				Set oMatch = oMatches(0)  
				Dim filename  
				Dim moint, dyint, mostr, dystr, yrstr   
				moint = Int(oMatch.SubMatches(0))  
				If moint > 0 And moint < 10 Then  
					 mostr = "0" & CStr(moint)  
				Else  
					mostr = CStr(moint)  
				End If  
				'Wscript.StdOut.WriteLine mostr  
				dyint = Int(oMatch.SubMatches(1))  
				If dyint > 0 And dyint < 10 Then   
					dystr = "0" & CStr(dyint)  
				Else  
					dystr = CStr(dyint)  
				End If  
				yrstr = right(cstr(year(file.datelastmodified)),2) 
				filename = ucase (mostr & dystr &	yrstr & oMatch.SubMatches(2) & "_TRACK" & oMatch.SubMatches(3) & ".mp3") 
				If fso.fileexists( destPath & filename ) Then 
					oLog.WriteLine Now & " - file: " & file.name & " confirmed." 
					'Dim newname 
					newname = split(file.name,".")  
					fso.movefile sourcePath & file.name, sourcePath & newname(0) & "-confirmed." & newname(1) 
				Else
					oLog.WriteLine Now & " - Could not confirm file: " & file.name  
				End If
			End If	  
		End If 
	Next
	
	oLog.WriteLine Now & " - Confirming Files Completed. "

End Sub

'Purpose: 
'  Rename files in the source folder using the confirm suffix if the file exists in the destination folder 
'  and that file was copied previously 
'Arguments:  
'  sourcePath - the folder containing the files to be renamed 
'  destPath   - the folder containing the files to compare with 
'  copiedSuffix - the suffix for files that have been previously copied 
'  confirmSuffix - the suffix for files that are confirmed 
'  oLog       - a Scripting.FileSystemObject to be used for logging progress 
'
Public Sub confirmFiles( sourcePath, destPath, copiedSuffix, confirmSuffix, oLog)

	Dim fso, regex
	oLog.WriteLine Now & " - Confirming Files Previously Copied. From: " & sourcePath & " To: " & destPath

	Set regex = New RegExp 
	regex.Global = True  
	regex.IgnoreCase = True  

	Set fso = CreateObject("Scripting.FileSystemObject")
	Set folder = fso.GetFolder(sourcePath) 
	Set files = folder.Files 
	  
	For Each file In files 
		regex.Pattern = ".+\-" & copiedSuffix & "\...." 
		If regex.Test(file.name) then
			'get the filename without the suffix
			regex.Pattern = "(.+)\-" & copiedSuffix & "(\....)"
			Dim oMatches, oMatch, oSubMatch 
			Set oMatches = regex.Execute(file.name) 
			If oMatches.Count > 0 Then
				Set oMatch = oMatches(0) 
				Dim filename 
				Dim basename,extension, newname
				basename = oMatch.SubMatches(0)
				extension = oMatch.SubMatches(1)
				filename = basename & extension	
				'look For it In the destPath
				If fso.fileexists( destPath & filename ) Then
					oLog.WriteLine Now & " - file: " & file.name & " confirmed." 
					newname = basename & "-" & confirmSuffix & extension
					fso.movefile sourcePath & file.name, sourcePath & newname
				Else 
					oLog.WriteLine Now & " - Could not confirm file: " & file.name 
				End If 
				
			End If
	
		End If
		
	Next
	
	oLog.WriteLine Now & " - Confirming Files Completed. "

End Sub
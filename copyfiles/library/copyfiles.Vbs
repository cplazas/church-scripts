'copy files
' 1. determine which files need to be copied
'    have to have some method of determining which files have already been copied successfuly
' 2. copy the files that have been identified
' 3. delete any files that are ready for deletion 
'    have some criteria for this ( maybe look for a file with the same month and day in
'    the audio files directory in the target computer


'step 1 delete any files named -confirmed

Dim fso, folder, files, file, sourcedir, incomingdir, audiodir, regex, oLog, oError, newname

sourcedir = "\\cdrecorder\temp\cdmastering\raw\"
incomingdir = "c:\cd\data\incoming\"
audiodir = "c:\cd\data\audio\"

Set fso = CreateObject("Scripting.FileSystemObject")
Set folder = fso.GetFolder(sourcedir)
Set files = folder.Files

set regex = New RegExp
regex.Global = True
regex.IgnoreCase = True

'open our log files
Set oLog = fso.CreateTextFile("c:\cd\data\copyfiles.log",True)
Set oError = fso.CreateTextFile("c:\cd\data\copyfiles-error.log", True)

oLog.WriteLine Now & " - CopyFiles Started."


For Each file In files
	regex.Pattern = ".+\-confirmed\.wav" 'match the wav extension of a file
	If regex.Test(file.name) Then
		'delete any files that were confirmed in the prior run
		oLog.WriteLine Now & " - removing file: " & file.name
		file.delete
	Else
		regex.Pattern = ".+\-copied\.wav"
		If regex.Test(file.name) Then
			' check for a complementary file in the audiodir
			regex.Pattern = "(.+)\-(.+)\-(.+)\-song(.+)-copied\.wav" 
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
				If fso.fileexists( audiodir & filename ) Then
					oLog.WriteLine Now & " - file: " & file.name & " confirmed."
					'Dim newname
					newname = split(file.name,".") 
					fso.movefile sourcedir & file.name, sourcedir & newname(0) & "-confirmed." & newname(1)
				Else
					oError.WriteLine Now & " - Could not confirm file: " & file.name 
				End If
			End If
				
		Else
			regex.Pattern = "(.+)\-(.+)\-(.+)\-song(.+)\.wav"
			If regex.Test(file.name) Then
				'here we actually copy the files
				oLog.WriteLine Now & " - copying file: " & file.name
				fso.copyfile sourcedir & file.name, incomingdir & file.name
				'now we rename it to -copied
				'Dim newname
				newname = split(file.name, "." )
				fso.movefile sourcedir & file.name, sourcedir & newname(0) & "-copied." & newname(1)
			End If
		End If
	End If
Next

oLog.WriteLine Now & " - CopyFiles complete."
oLog.Close
oError.Close


'step 2 for each file named -copied look for a file with the same date in the
'       audio directory and if one is found then rename that file to -confirmed
'       if the file is not found leave the -copied file alone and log it to the
'       error log.

'step 3 for each file not named -confirmed or -copied, that is a normal, new file
'       copy it to the incoming directory and rename it to -copied


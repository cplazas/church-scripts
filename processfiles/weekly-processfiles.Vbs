'steps
' 1. rename files to mddyyy[am|pm]_track[track number].wav
' 2. convert files to mp3
' 3. determine which files needed for cd and discard any unnecessary ones
' 4. apply normalization

'globals
Dim sourcepath, destpath, rejectpath, oLog, logpath

sourcepath = "c:\cd\data\temp\weekly\"
'sourcepath = "e:\temp"
destpath = "c:\cd\data\temp\weekly\burn\"
rejectpath = "c:\cd\data\temp\weekly\reject\"
logpath = "C:\cd\data\temp\weekly\processfiles.log"


'rename files
Public Sub rename ()
	Dim fso, fldr, fc, f
	Dim regex
	
	oLog.WriteLine Now & " - Renaming Files... "
	
	Set fso = CreateObject("Scripting.FileSystemObject")
	Set fldr = fso.GetFolder(sourcepath)
	Set fc = fldr.Files
	
	Set regex = New RegExp
	regex.Global = True
	regex.IgnoreCase = True


	For Each f In fc
		regex.Pattern = ".+\.wav" 'match the wav extension of a file
		If regex.Test(f.name) Then
			regex.Pattern = "(.+)\-(.+)\-(.+)\-song(.+)\.wav" 
			Dim oMatches, oMatch, oSubMatch 
			Set oMatches = regex.Execute(f.name) 
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
				yrstr = right(cstr(year(f.datelastmodified)),2) 
				filename = ucase (mostr & dystr &	yrstr & oMatch.SubMatches(2) & "_TRACK" & oMatch.SubMatches(3) & ".wav") 		 
						'filename = oMatch.SubMatches(0) & "03" & oMatch.SubMatches(1) & "_" & elements(1) 
						oLog.WriteLine Now & " - " & f.name & " -> " & filename
				fso.MoveFile sourcepath &  f.name , sourcepath & filename 

				'wscript.stdout.writeline f.name & vbTab & filename 
			End If
		End if
	Next 
	oLog.WriteLine Now & " - Renaming Files Completed. "
End Sub


Public Sub convert()
	Dim encodercommand, fso, regex

	oLog.WriteLine Now & " - Converting Files to mp3 format... "

	Set fso = CreateObject("Scripting.FileSystemObject")
	Set fldr = fso.GetFolder(sourcepath) 
	Set fc = fldr.Files 
	
	Set regex = New RegExp 
	regex.Global = True 
	regex.IgnoreCase = True 
	
	encodercommand = "c:\cd\bin\lame\lame.exe -S -h "

	'encode each file in turn
	For Each f In fc 
		regex.Pattern = ".+track.+\.wav" 'match the wav extension of a file 
		If regex.Test(f.name) Then
			regex.Pattern = "(.+)\.wav"  
			Dim oMatches, oMatch, oSubMatch
			Set oMatches = regex.Execute(f.name)
			Set oMatch = oMatches(0) 
			Dim filename, command, shell, oExec
			filename = oMatch.SubMatches(0)
			command = encodercommand & sourcepath & f.name & " " & sourcepath & filename & ".mp3"	
			
			oLog.WriteLine Now & " - Processing file: " & f.name
			
			Set shell = WScript.CreateObject("WScript.Shell")
			Set oExec = shell.Exec(command)
			'While Not oExec.StdErr.AtEndOfStream
			'	wscript.stdout.writeline oExec.StdErr.Readline
			'Wend
			While oExec.Status = 0
				'this makes it synchronous
				wscript.sleep 500
			Wend
			
			'once the encode is complete we can get rid of the original wav file
			f.delete

		End If
	Next
	oLog.WriteLine Now & " - Converting Files Completed."
	'delete the original file
	'For Each f In fc
	'	f.delete
	'Next
End Sub

Public Sub sizecds()

	'this windows script host script renames the files for a service for easy processing
	Dim fso, fldr, fc, f
	Dim regex
	Dim disc, track
	Dim discarr(150,51) 'max 150 cds with max 50 tracks each. First item is reserved for the file prefix
	Dim delarray(49) 'up to 49 tracks can be removed, this array holds the track indexes to be deleted
	disc = 0 'new disc is added at this index
	
	
	oLog.WriteLine Now & " - Checking the size of the CDs... "
	
	set fso = CreateObject("Scripting.FileSystemObject")
	Set fldr = fso.GetFolder(sourcepath)
	set fc = fldr.Files
	
	set regex = New RegExp
	regex.Global = True
	regex.IgnoreCase = True

	For Each f In fc
		regex.Pattern = ".+track.+\.wav" 'match the wav extension of a file
		If regex.Test(f.name) Then
		
			regex.Pattern = "(.+)_track(.+)\.wav" 
			Dim oMatches, oMatch, oSubMatch 
			Set oMatches = regex.Execute(f.name) 
			If oMatches.Count > 0 Then
				Dim idx,key
				Set oMatch = oMatches(0)
				key = oMatch.SubMatches(0)
				idx = disc
				'look for this key in case it already exists
				For I = 0 To disc
					If discarr(I,0) = key Then
						idx = I
					End If
				Next
				
				If idx = disc Then
					disc = disc + 1
				End If
				
				'save the key
				discarr(idx,0) = key
				'store the file name for the track in the appropriate slot
				'store the duration of the track in the appropriate slot
				discarr(idx,int(oMatch.SubMatches(1))) = trackduration(f.name)
			End If
		End If
	Next
	'reset the disc high water mark if nothing was done after the disc was incremented
	If discarr(disc,0) = "" Then
		disc = disc - 1
	End If
	'wscript.stdout.writeline disc
	Dim maxcdlength
	maxcdlength = 4800 '(80 minutes) '1500 '(25 minutes)
	For I = 0 To disc
		'process one disc at a time
		'first thing we do is sum up our track lengths
		Dim curtrack, longesttracklength, longesttrackid, totaltracklength, trackcount
		longesttracklength = 0 'start with the smallest possible tracklength
		trackcount = 0 'we always have at least one
		'currtrack = 1 'start with the first track 
		totaltracklength = 0
		longesttrackid = currtrack 'set it to something sane to begin with
		'While discarr(I,currtrack ) <> "" 
		For currtrack = 1 To 50
			If  discarr(I,currtrack) <> "" Then
				trackcount = trackcount + 1
				'determine if this track is the longest track
				If  discarr(I,currtrack) > longesttracklength Then
					longesttracklength = discarr(I,currtrack)
					longesttrackid = currtrack
				End If
				'add this track's length to the total track length
				totaltracklength = totaltracklength + discarr(I,currtrack)
				'currtrack = currtrack + 1 'move to the next track slot
			End If
		'Wend
		Next
		
		oLog.WriteLine Now & " - Disc: " & I & " Key: " & discarr(I,0) & " Length: " & totaltracklength / 60 & " minutes."

		If  totaltracklength > maxcdlength Then
			Dim t
			For t = 1 To 50 
				If discarr(I,t) <> "" Then
					filename = sourcepath & "\" & discarr(I,0) & "_TRACK" & t & ".WAV"
					newfilename = rejectpath & "\" & discarr(I,0) & "_TRACK" & t & ".WAV"
					fso.movefile filename, newfilename
					'wscript.stdout.writeline "     " & filename & " -> " & newfilename
				End If
			Next
			oLog.WriteLine Now & " - Rejected Disc: " & I & " Key: " & discarr(I,0)  & ". Disc exceeds 80 minutes!" 
			notifyhuman(discarr(I,0) ) 'we send the key
			
		End If
'the lines below were my original intent: to let the computer decide which tracks to delete
'I have since decided to just move the files to a reject directory and send a notification for human intervention
'			
'		wscript.stdout.writeline "disc: " & I  & "  key: " & discarr(I,0) & "  length: " & totaltracklength
'		
		'next we determine if any tracks are to be discarded or if human intervention is needed
'		If trackcount > 1 Then
'			If totaltracklength > maxcdlength Then
				'start trying to remove a track at a time, leaving the longest track
'				Dim t, temptotaltracklength, counter
'				Erase delarray 'reset it for this invocation
'				temptotaltracklength = totaltracklength
'				counter = 0
'				For t = 1 To 50
'					If discarr(I,t) <> "" Then
						'wscript.stdout.writeline "  processing track: " & t & "..."
'						If longesttrackid <> t Then
							'attempt to subtract this track's time from the total and see if it is now in bounds
'							temptotaltracklength = temptotaltracklength - discarr(I,t)
							'wscript.stdout.writeline "------------delarray about to be used-------------"
'							delarray(counter) = t
							'wscript.stdout.writeline "------------delarray was used-------------"
'							counter = counter + 1
'							If  temptotaltracklength < maxcdlength Then
'								Exit For
'							End If
'						End If
'					End If
'				Next
'				
'				If temptotaltracklength > maxcdlength Then
'					notifyhuman(discarr(I,0) & "_TRACK" & longesttrackid & ".WAV" )
'				End If 
'				
				'do the actual deletions here
				'we always do the pending deletions even if the biggest file is still too big
'				Dim file, filename,newfilename
'				For t = 0 To counter - 1 
					'wscript.stdout.writeline "          Track: " & delarray(t) & " will be deleted."
'					filename = sourcepath & discarr(I,0) & "_TRACK" & delarray(t) & ".WAV"
'					Set file = fso.GetFile(filename)
'					file.delete
					'wscript.stdout.writeline "     file: " & filename & " will be deleted."
'					discarr(I,delarray(t)) = "" 'clear out the location of the old filename so we can use the files
'				Next
				'renumber the files ?
'				
'				counter = 1
'				For t = 1 To 50
'					If discarr(I,t) <> "" Then
'						filename = sourcepath & "\" & discarr(I,0) & "_TRACK" & t & ".WAV"
'						newfilename = sourcepath & "\" & discarr(I,0) & "_TRACK" & counter & ".WAV"
'						fso.movefile filename, newfilename
						'wscript.stdout.writeline "     " & filename & " -> " & newfilename
'						counter = counter + 1
'					End If
'				Next
'				
'			End If
'		Else
			'check to see if the single file will fit on a cd, if not send an error message - this requires human intervention
'			If totaltracklength > maxcdlength Then
'				notifyhuman(discarr(I,0) & "_TRACK1.WAV" ) 'we send the filename
'			End If
'		End If

		
		'If discarr(I,0) <> "" Then
		'	wscript.stdout.writeline discarr(I,1)
		'End If
	Next
	oLog.WriteLine Now & " - Checking the size of CDs completed. "
	'now that we have our 

End Sub

Public Function trackduration( track )
	Dim soxcmd, soxstat, duration, regex
	Dim oShell, oCmd
	Set oShell = WScript.CreateObject("WScript.Shell")
	
	set regex = New RegExp
	regex.Global = True
	regex.IgnoreCase = True

	'soxcmd = "G:\sox\sox\sox.exe "
	soxcmd = "c:\cd\bin\sox\sox.exe "
	soxstat = " -e stat"
	
	Set oCmd = oShell.Exec(soxcmd & sourcepath & track & soxstat)
	regex.Pattern = "Length.+:.+"
	While  Not oCmd.StdErr.AtEndOfStream
		line = oCmd.StdErr.ReadLine	
		If regex.Test(line) Then
			linearr = Split(line,":",-1,1)
			duration = linearr(1)
		End If
	Wend
	trackduration = duration
End Function

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

	Dim fso, fldr, fc, f 
	Dim regex 
	oLog.WriteLine Now & " - Moving Files to the final destination..."
	
	Set fso = CreateObject("Scripting.FileSystemObject") 
	Set fldr = fso.GetFolder(sourcepath) 
	Set fc = fldr.Files 
	
	Set regex = New RegExp 
	regex.Global = True 
	regex.IgnoreCase = True 


	For Each f In fc 
		regex.Pattern = ".+\.wav" 'match the wav extension of a file 
		If regex.Test(f.name) Then 
			fso.movefile sourcepath & f.name , destpath & f.name
		End If
	Next
	
	oLog.WriteLine Now & " - Moving Files Completed. "

End Sub

Public Sub normalize()
	
	Dim normalizecommand, fso, regex

	oLog.WriteLine Now & " - Normalizing Files... "
	
	Set fso = CreateObject("Scripting.FileSystemObject") 
	Set fldr = fso.GetFolder(sourcepath)  
	Set fc = fldr.Files  
	
	Set regex = New RegExp  
	regex.Global = True  
	regex.IgnoreCase = True  
	
	normalizecommand = "c:\cd\bin\normalize\normalize.exe --peak " 

	'encode each file in turn 
	For Each f In fc  
		regex.Pattern = ".+\.wav" 'match the wav extension of a file  
		If regex.Test(f.name) Then 
			Dim command, shell, oExec 
			command = normalizecommand & sourcepath & f.name
			'wscript.stdout.writeline command 	 
			Set shell = WScript.CreateObject("WScript.Shell") 
			Set oExec = shell.Exec(command) 
			While Not oExec.StdErr.AtEndOfStream 
				'wscript.stdout.writeline oExec.StdErr.Readline 
				oLog.WriteLine Now & " - " & oExec.StdErr.Readline
			Wend 
			
			
			
			'While oExec.Status = 0 
				'this makes it synchronous 
			'	wscript.sleep 500
			'Wend 

		End If
	Next
	
	oLog.WriteLine Now & " - Normalize Files Completed. "

End Sub

Public Sub openlog()
	Dim fso
	Set fso = CreateObject("Scripting.FileSystemObject")
	Set oLog = fso.CreateTextFile(logpath,True)
	oLog.WriteLine Now & " - ProcessFiles Started."
End Sub
openlog
rename
'convert
sizecds
normalize
'convert
movefiles
oLog.Writeline Now & " - ProcessFiles Ended. "
oLog.Close

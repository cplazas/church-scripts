'Purpose:
'  Check the length of the sound files that make up one CD to make sure their total length
'  does not exceed 80 minutes ( the size of a CD blank ). If one set of files does exceed
'  the 80 minute max, then all of the files in that set are moved into a reject folder
'  for review by someone who will decide how to bring the cd under 80 minutes in length.
'
'Arguments: 
'  sourcePath - the path to the files to be sized
'  rejectPath - the path to the reject folder, where files that are too large to fit are placed
'  SOXPath   - the path to the folder containing the sox.exe executable with no traling slash
'  MP3InfoPath - the path to the folder containg the mp3info.exe executable with no trailing slash
'  wavMode - boolean flag that tells us which type of files are being sized
'  oLog       - a Scripting.FileSystemObject to be used for logging progress
'
Public Sub sizecds(sourcePath, rejectPath, SOXPath, MP3InfoPath, wavMode, oLog)

	'this windows script host script renames the files for a service for easy processing 
	Dim fso, fldr, fc, f 
	Dim regex, pattern, dict', matchpattern 
	'Dim disc, track 
	'Dim discarr(150,51) 'max 150 cds with max 50 tracks each. First item is reserved for the file prefix 
	'disc = 0 'new disc is added at this index 
	
	
	oLog.WriteLine Now & " - Checking the size of the CDs... " 

	Set dict = CreateObject("Scripting.Dictionary")
	Set fso = CreateObject("Scripting.FileSystemObject") 
	Set fldr = fso.GetFolder(sourcePath) 
	Set fc = fldr.Files 
	
	Set regex = New RegExp 
	regex.Global = True 
	regex.IgnoreCase = True 
	
	If ( wavMode ) Then
	  	pattern = "(.+)_track.+\.wav" 'match the wav extension of a file
	  	'matchpattern = "(.+)_track(.+)\.wav" 
	Else
		pattern = "(.+)_track.+\.mp3" 'match the mp3 extension of a file
		'matchpattern = "(.+)_track(.+)\.mp3"
	End If

	For Each f In fc 
		regex.Pattern = pattern 
		If regex.Test(f.name) Then ' make sure each file is either an mp3 or wav file

			Dim oMatches, oMatch, oSubMatch  
			Set oMatches = regex.Execute(f.name)  ' grab the first part of the file name using a regex
			If oMatches.Count > 0 Then ' only do this part if the file matched the pattern
				Dim key, duration
				Set oMatch = oMatches(0) 
				key = oMatch.SubMatches(0) ' this gets the actual matched part of the regex

				If ( wavMode ) Then
					duration = trackdurationwav( sourcePath, f.name, SOXPath, oLog)
				Else
				   	duration = trackdurationmp3( sourcePath, f.name, MP3InfoPath, oLog)
				End If

				dict.Item(key) = CDbl(dict.Item(key)) + CDbl(duration)

			End If
		End If
	Next
	' once we have gotten the durations of the tracks into the dictionary it is time to process
	' each one to determine if it exceeds the maximum cd length
	Dim maxcdlength 
	maxcdlength = 4800 '(80 minutes) '1500 '(25 minutes) 
	
	For Each key In dict.keys()'keys
		If ( dict.Item(key) > maxcdlength ) Then
			' reject the whole cd and move it to the reject folder
			oLog.WriteLine Now & " - CD with key: " & key & " too long. Length: " & dict.Item(key) & " seconds. Rejecting."
			fso.movefile sourcePath & key & "*" , rejectPath
			notifyhuman(key)
		Else
			oLog.WriteLine Now & " - CD with key: " & key & " correct length. Length: " & dict.Item(key) & " seconds."
		End If
		'wscript.stdout.writeline key & " duration: " & dict.Item(key)
	Next

	oLog.WriteLine Now & " - Checking the size of CDs completed. " 

End Sub

'Function: trackdurationwav
'Purpose:
'  Gets the actual length of the track using the SOX open source program.
'  The file containing the track must be in wav format.
'
'Arguments: 
'  sourcePath - the path to the folder containing the track file
'  trackName - the name of the track file to be sized
'  SOXPath   - the path to the folder containing the sox.exe executable with no traling slash
'  oLog       - a Scripting.FileSystemObject to be used for logging progress 
'Return Value:
'  returns an integer representing the length of the track in seconds
Public Function trackdurationwav( sourcePath, trackName, SOXPath, oLog )
	Dim soxcmd, soxstat, duration, regex
	Dim oShell, oCmd
	Set oShell = WScript.CreateObject("WScript.Shell")
	
	set regex = New RegExp
	regex.Global = True
	regex.IgnoreCase = True

	'soxcmd = "G:\sox\sox\sox.exe "
	'soxcmd = "c:\cd\bin\sox\sox.exe "
	soxcmd = SOXPath & "\sox.exe " 
	soxstat = " -e stat"
	
	oLog.WriteLine Now & " - Getting track length using command: " & soxcmd & sourcePath & trackName & soxstat
	
	Set oCmd = oShell.Exec(soxcmd & sourcePath & trackName & soxstat)
	regex.Pattern = "Length.+:.+"
	While  Not oCmd.StdErr.AtEndOfStream
		line = oCmd.StdErr.ReadLine	
		If regex.Test(line) Then
			linearr = Split(line,":",-1,1)
			duration = linearr(1)
		End If
	Wend
	oLog.WriteLine Now & " - Track length for track " & sourcePath & trackName & ": " & duration & " seconds."

	trackdurationwav = duration
End Function

'Function: trackdurationmp3
'Purpose:
'  Gets the actual length of the track using the mp3info freeware program.
'  The file containing the track must be in mp3 format.
'
'Arguments: 
'  sourcePath - the path to the folder containing the track file
'  trackName - the name of the track file to be sized
'  MP3InfoPath   - the path to the folder containing the mp3info.exe executable with no traling slash
'  oLog       - a Scripting.FileSystemObject to be used for logging progress 
'Return Value:
'  returns an integer representing the length of the track in seconds
Public Function trackdurationmp3( sourcePath, trackName, MP3InfoPath, oLog )
	Dim mp3infocmd
 	Dim oShell, oCmd
 	Set oShell = WScript.CreateObject("WScript.Shell")
	
	mp3infocmd = MP3InfoPath & "\mp3info.exe -p %S "
	
	oLog.WriteLine Now & " - Getting track length using command: " & mp3infocmd & sourcePath & trackName

	
	Set oCmd = oShell.Exec(mp3infocmd & sourcePath & trackName )
	trackdurationmp3 = CLng( oCmd.StdOut.ReadLine )
End Function

Public Sub notifyhuman( filename )

	Set objMessage = CreateObject("CDO.Message") 
	objMessage.Subject = "CD Too Large Notification" 
	objMessage.From = "cplazas@thechurchofcolumbus.org" 
	objMessage.To = "cplazas@gmail.com" 
	objMessage.TextBody = "CD too large. Key: " & filename
	'==This section provides the configuration information for the remote SMTP server. 
	'==Normally you will only change the server name Or IP. 
	objMessage.Configuration.Fields.Item _ 
	  ("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2 

	'Name or IP of Remote SMTP Server 
	objMessage.Configuration.Fields.Item _ 
	  ("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "smtp.gmail.com" 

	'Server port (typically 25) 
	objMessage.Configuration.Fields.Item _ 
	  ("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 465 

        'Type of authentication, NONE, Basic (Base64 encoded), NTLM
        objMessage.Configuration.Fields.Item _
          ("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = 1 'Basic


        'Your UserID on the SMTP server
        objMessage.Configuration.Fields.Item _
          ("http://schemas.microsoft.com/cdo/configuration/sendusername") = "cplazas@thechurchofcolumbus.org"

        'Your password on the SMTP server
        objMessage.Configuration.Fields.Item _
          ("http://schemas.microsoft.com/cdo/configuration/sendpassword") = "lavon26"

        'Use SSL for the connection (False or True)
        objMessage.Configuration.Fields.Item _
          ("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = True

        'Connection Timeout in seconds (the maximum time CDO will try to establish a connection to the SMTP server)
        objMessage.Configuration.Fields.Item _
          ("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout") = 60

	objMessage.Configuration.Fields.Update 
	'==End remote SMTP server configuration section== 

	objMessage.Send 

	Set objMessage = nothing
End Sub

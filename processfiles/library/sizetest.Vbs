Public Function trackduration( track )
 	Dim soxcmd, soxstat, duration, regex
 	Dim oShell, oCmd
 	Set oShell = WScript.CreateObject("WScript.Shell")
	
	'soxcmd = "G:\sox\sox\sox.exe "
	soxcmd = "c:\cd\bin\sox\mp3info.exe "
	soxstat = " -p %S "
	
	
 	Set oCmd = oShell.Exec(soxcmd & soxstat & track)
	'While  Not oCmd.StdErr.AtEndOfStream
 		trackduration = CLng(oCmd.StdOut.ReadLine	)
 		'wscript.stdout.writeline ocmd.stdout.readline
 	'Wend
 	'trackduration = duration
 	'trackduration = 1
End Function
 

Dim dict, pattern, matchpattern
Dim fso, fldr, fc, f 
Dim regex
'Dim disc, track 
'Dim discarr(150,51) 'max 150 cds with max 50 tracks each. First item is reserved for the file prefix 
'disc = 0 'new disc is added at this index 


'oLog.WriteLine Now & " - Checking the size of the CDs... " 

Set fso = CreateObject("Scripting.FileSystemObject") 
Set fldr = fso.GetFolder(".") 
Set fc = fldr.Files 
Set dict = CreateObject("Scripting.Dictionary")

	Set regex = New RegExp 
	regex.Global = True 
	regex.IgnoreCase = True 

'pattern = ".+track.+\.mp3" 'match the mp3 extension of a file
'matchpattern = "(.+)_track(.+)\.mp3"
pattern = "(.+)_track.+\.mp3"

For Each f In fc 
	regex.Pattern = pattern 
	If regex.Test(f.name) Then 

		'regex.Pattern = matchpattern  
		Dim oMatches, oMatch, oSubMatch  
		Set oMatches = regex.Execute(f.name)  
		If oMatches.Count > 0 Then 
			'Dim idx,key 
			Set oMatch = oMatches(0) 
			dict.Item(oMatch.SubMatches(0)) = dict.Item(oMatch.SubMatches(0)) + trackduration(f.name)
'			key = oMatch.SubMatches(0) 
'			idx = disc 
			
'			trackduration(f.name)
'			oMatch.SubMatches(1)
		End If
	End If
Next

Dim keys
'keys = dict.keys()

For Each key In dict.keys()'keys
	wscript.stdout.writeline key & " duration: " & dict.Item(key)
Next
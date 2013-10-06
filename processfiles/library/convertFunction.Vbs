'Purpose:
'  Convert wav files named *track*.wav to mp3 files sing LAME encoder
'
'Arguments: 
'  sourcePath - the path To the files To be renamed
'  LAMEPath   - the path to the folder containing the lame.exe executable with no traling slash
'  oLog       - a Scripting.FileSystemObject to be used for logging progress
'
Public Sub convert(sourcePath, LAMEPath, oLog) 
	
	Dim encodercommand, fso, regex 

	oLog.WriteLine Now & " - Converting Files to mp3 format... " 

	Set fso = CreateObject("Scripting.FileSystemObject") 
	Set fldr = fso.GetFolder(sourcePath)  
	Set fc = fldr.Files  
	
	Set regex = New RegExp  
	regex.Global = True  
	regex.IgnoreCase = True  
	
	encodercommand = LAMEPath + "\lame.exe -S -h " 

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
			command = encodercommand & sourcePath & f.name & " " & sourcePath & filename & ".mp3"	 
			
			oLog.WriteLine Now & " - Processing file: " & f.name 
			
			Set shell = WScript.CreateObject("WScript.Shell") 
			Set oExec = shell.Exec(command) 

			While oExec.Status = 0 
				'this makes it synchronous 
				wscript.sleep 500 
			Wend 
			
			'once the encode is complete we can get rid of the original wav file 
			f.delete

		End If
	Next
	oLog.WriteLine Now & " - Converting Files Completed." 

End Sub

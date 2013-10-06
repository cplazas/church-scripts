'Purpose:
'  Normalize .wav files using the normalize open source program
'
'Arguments: 
'  sourcePath - the path to the files to be normalized
'  normalizePath   - the path to the folder containing the normalize.exe executable with no traling slash
'  oLog       - a File object to be used for logging progress
'
Public Sub normalize( sourcePath, normalizePath, oLog)
	
	Dim normalizecommand, fso, regex

	oLog.WriteLine Now & " - Normalizing Files... "
	
	Set fso = CreateObject("Scripting.FileSystemObject") 
	Set fldr = fso.GetFolder(sourcePath)  
	Set fc = fldr.Files  
	
	Set regex = New RegExp  
	regex.Global = True  
	regex.IgnoreCase = True  
	
	normalizecommand = normalizePath & "\normalize.exe --peak " 

	'normalize each file
	For Each f In fc  
		regex.Pattern = ".+\.wav" 'match the wav extension of a file  
		If regex.Test(f.name) Then 
			Dim command, shell, oExec 
			command = normalizecommand & sourcepath & f.name
			oLog.WriteLine Now & " - Normalizing wav file with command: " & command
			Set shell = WScript.CreateObject("WScript.Shell") 
			Set oExec = shell.Exec(command) 
			While Not oExec.StdErr.AtEndOfStream 
				oLog.WriteLine Now & " - " & oExec.StdErr.Readline
			Wend 
		End If
	Next
	
	oLog.WriteLine Now & " - Normalize Files Completed. "

End Sub

'Purpose:
'  rename files from this format: mm-dd-[am|pm]-song[song number].wav
'                 to this format: mddyyy[am|pm]_track[track number].wav
'
'Arguments: 
'  sourcePath - the path To the files To be renamed
'  oLog       - a Scripting.FileSystemObject to be used for logging progress
'
Public Sub rename ( sourcePath, oLog) 
	Dim fso, fldr, fc, f 
	Dim regex 
	
	oLog.WriteLine Now & " - Renaming Files... " 
	
	Set fso = CreateObject("Scripting.FileSystemObject") 
	Set fldr = fso.GetFolder(sourcePath) 
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

				dyint = Int(oMatch.SubMatches(1))  
				If dyint > 0 And dyint < 10 Then   
					dystr = "0" & CStr(dyint)  
				Else  
					dystr = CStr(dyint)  
				End If  

				yrstr = right(cstr(year(f.datelastmodified)),2)  
				filename = ucase (mostr & dystr &	yrstr & oMatch.SubMatches(2) & "_TRACK" & oMatch.SubMatches(3) & ".wav") 		  
						oLog.WriteLine Now & " - " & f.name & " -> " & filename 
				fso.MoveFile sourcePath &  f.name , sourcePath & filename  
 
			End If 
		End If 
	Next  
	oLog.WriteLine Now & " - Renaming Files Completed. " 
End Sub

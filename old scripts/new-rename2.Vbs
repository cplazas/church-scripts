'this windows script host script renames the files for a service for easy processing
Dim fso, fldr, fc, f
Dim regex
Dim disc, track
Dim sourcepath, destpath
Dim discarr(30,101) 'max 30 cds with max 100 tracks each. First item is reserved for the file prefix
'Dim dict

'set dict = CreateObject("Scripting.Dictionary")
disc = 0 'new disc is added at this index

sourcepath = "c:\cd\data"
destpath = "c:\temp\cdmastering\cooked"
tocdestpath = "c:/temp/cdmastering/cooked"

set fso = CreateObject("Scripting.FileSystemObject")
Set fldr = fso.GetFolder(sourcepath)
set fc = fldr.Files

set regex = New RegExp
regex.Global = True
regex.IgnoreCase = True


For Each f In fc
	regex.Pattern = ".+\.wav" 'match the wav extension of a file
	If regex.Test(f.name) Then
		'Dim elements
		'elements = Split(f.name,"_",-1,1)
		'If UBound(elements)  = 1 Then
			regex.Pattern = "(.+)\-(.+)\-(.+)\-song(.+)\.wav"
			Dim oMatches, oMatch, oSubMatch
			Set oMatches = regex.Execute(f.name)
			Set oMatch = oMatches(0)
			Dim filename
			Dim key, prefix, idx, moint, dyint, mostr, dystr, yrstr 
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
			fso.MoveFile sourcepath & "\"  & f.name , sourcepath & "\" & filename
			'wscript.stdout.writeline f.name & vbTab & filename
		'End If
	End If
Next
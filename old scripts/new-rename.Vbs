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
	regex.Pattern = ".+_.+\.mp3" 'match the wav extension of a file
	If regex.Test(f.name) Then
		Dim elements
		elements = Split(f.name,"_",-1,1)
		If UBound(elements)  = 1 Then
			regex.Pattern = "(....)([AP]M)"
			Dim oMatches, oMatch, oSubMatch
			Set oMatches = regex.Execute(elements(0))
			Set oMatch = oMatches(0)
			Dim filename
			filename = oMatch.SubMatches(0) & "03" & oMatch.SubMatches(1) & "_" & elements(1)
			fso.MoveFile sourcepath & "\"  & f.name , sourcepath & "\" & filename
			'wscript.stdout.writeline f.name
		End If
	End If
Next
'
			'WScript.StdOut.WriteLine f.name
			' all this strips out any leading zeros in filename parts
'			Dim key, prefix, idx, moint, dyint, mostr, dystr
'			idx = disc
'			moint = Int(elements(0))
'			If moint > 0 And moint < 10 Then
'				 mostr = "0" & CStr(moint)
'			Else
'				mostr = CStr(moint)
'			End If
			'Wscript.StdOut.WriteLine mostr
'			dyint = Int(elements(1))
'			If dyint > 0 And dyint < 10 Then 
'				dystr = "0" & CStr(dyint)
'			Else
'				dystr = CStr(dyint)
'			End If
			'Wscript.StdOut.WriteLine dystr
'			key = mostr & dystr & UCase(elements(2))
			'Wscript.StdOut.WriteLine key			
'			For I = 0 To disc
'				If discarr(I,0) = key Then
'					idx = I
'				End If
'			Next
'			
'			If idx = disc Then
'				disc = disc + 1
'			End If
'
			'save the key
'			discarr(idx,0) = key
'			
'			regex.Pattern = ".*preaching.*"
'			If regex.Test(elements(3)) Then 'preaching track
'				discarr(idx,100) = f.name
'			Else 'song track
'				Dim oMatches, oMatch, oSubMatch
'				regex.Pattern = "[0-9]+"
'				Set oMatches = regex.Execute(elements(3))
'				For Each oMatch In oMatches
'					discarr(idx,int(oMatch.value)) = f.name					
'					Exit For
'				Next
'			End If
'			
'		End If
		'WScript.StdOut.WriteLine f.name
'	End If
'Next	
'
'If discarr(disc,0) = "" Then
'	disc = disc - 1
'End If
'
' don't do anything if there were no files
'If disc >= 0 Then
'	
'	For i = 0 To disc
'		Dim tocfile, tocname, discname
'		discname = discarr(i,0)
'		tocname = destpath & "\DISC_" & discname & ".toc"
'		WScript.StdOut.WriteLine disc & " --> " & i
'		WScript.StdOut.WriteLine tocname
'		Set tocfile = fso.CreateTextFile( tocname, True )
'		tocfile.WriteLine "CD_DA"
'		
'		Dim trackno
'		trackno = 1
'		
'		For j = 1 To 100
'	
'			If discarr(i,j) <> "" Then
'				Dim filename
				'rename each file
'				filename = discname & "_TRACK" & trackno & ".wav"
				'WScript.StdOut.WriteLine sourcepath & "\"  & discarr(i,j) & " --> " &  sourcepath & "\" & filename
'				fso.MoveFile sourcepath & "\"  & discarr(i,j) , sourcepath & "\" & filename
				'write toc
'				tocfile.WriteLine "TRACK AUDIO"
'				If ( trackno > 1 ) Then
'					tocfile.WriteLine "PREGAP 00:02:00"
'				End If
'				tocfile.WriteLine "FILE " & Chr(34) & tocdestpath & "/" & filename & Chr(34) & " 0"
'				trackno = trackno + 1
	'			WScript.StdOut.Write discarr(i,j) & " "
	'			WScript.StdOut.WriteLine " "
'			End If
'	
'		Next
'		tocfile.Close
'	Next
'End If

'dim file
'file = fso.CreateTextFile("PATH")

' toc file spec
'
' CD_DA
' TRACK AUDIO
' FILE "<path-to-file">
' TRACK AUDIO
' PREGAP 00:02:00
' FILE "<path-to-file">

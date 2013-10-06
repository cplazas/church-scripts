dim fso,f,fc,fl,regex
Set regex = New RegExp
'regex.Pattern = ".+\-" & copiedSuffix & "\.wav" 
regex.Pattern = ".+t\.wsf" 

set fso = CreateObject("Scripting.FileSystemObject")
Set f = fso.GetFolder(".")
   Set fc = f.Files
   For Each fl in fc
If regex.Test(fl.name) Then
  wscript.stdout.writeline "File Exists"
end if
   Next

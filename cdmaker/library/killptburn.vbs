'here we make sure ptburn is running before we do anything else 
Set WshShell = WScript.CreateObject("WScript.Shell")
Set ProcessSet = GetObject("winmgmts:{impersonationLevel=impersonate}").ExecQuery("select * from Win32_Process where name ='ptburn.exe' ")  
If  ProcessSet.Count > 0 Then 
	'ptburn is already running 
	WScript.Sleep(50) 
	For Each process In ProcessSet 
		If lcase(process.name) = "ptburn.exe" Then
			rc = process.terminate
			If rc = 0 Then
				Wshshell.LogEvent 4, "Terminated ptburn process."
			Else
				Wshshell.LogEvent 1, "Failed to terminate ptburn process." 
			End If
		End If
	
	Next
	WshShell.Run """C:\Program Files\Primera Technology\PTBurn Server\Server\ptburn.exe"""  
	WScript.Sleep(1000)

End If 

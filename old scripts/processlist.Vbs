Set ProcessSet = GetObject("winmgmts:{impersonationLevel=impersonate}").ExecQuery("select * from Win32_Process where name ='ptburn.exe' ")
If  processset.Count > 0 Then
wscript.echo "found it"
Else
'wscript.echo "it is not running"
Set WshShell = WScript.CreateObject("WScript.Shell") 
WshShell.Run """C:\Program Files\Primera Technology\PTBurn Server\Server\ptburn.exe""" 

End If

'For each Process in ProcessSet
'        WScript.Echo Process.Description
'Next

'ProcessName = InputBox("Enter the running process you want stopped")
'
'For Each Process In GetObject("winmgmts:{impersonationLevel=impersonate}!//localhost").ExecQuery("select * from Win32_Process where Name='" & ProcessName & "'")
'        Process.Terminate
        'wscript.echo Process.Name & " is " & Process.ProcessId
'Next

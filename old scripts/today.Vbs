Dim smonth,sday,service 
If hour(now) < 18 Then
	service = "AM"
Else
	service = "PM"
End If

smonth = cstr(month(now))
If month(now) < 10 Then
	smonth = "0" & smonth
End If

sday = cstr(day(now))
If day(now) < 10 Then
	sday = "0" & sday
End If



msgbox smonth & sday & right(cstr(year(now) ),2) & service
'wscript.stdout.writeline cstr(month(now)) & cstr(day(now)) & right(cstr(year(now) ),2) & service
Class Label
	Private nID, dDate, sDay, sService, sMinister, sSermonTitle
	
	Public Property Get ID
		ID = nID
	End Property

	Public Property Get ServiceDate
		ServiceDate = dDate
	End Property
	
	Public Property Get ServiceDay
		ServiceDay = sDay
	End Property
	
	Public Property Get ServiceNumber
		ServiceNumber = nService
	End Property
	
	Public Property Get ServiceMinister
		ServiceMinister = sMinister
	End Property
	
	Public Property Get ServiceTitle
		ServiceTitle = sSermonTitle
	End Property
	
	
	Public Sub LoadFromDB ( nID, byref oConn )
		Dim oRS, sSQL
		Set oRS = CreateObject("ADODB.Recordset")
		sSQL = "SELECT * FROM ""Tapes"" WHERE ""ID"" = '" & nID & "'"
		oRS.Open sSQL,oConn,adOpenKeyset
		If oRS.RecordCount > 0 Then
			nID = oRS.Fields("ID")
			dDate = CDate(oRS.Fields("Month") & "/" & oRS.Fields("Date") & "/" & oRS.Fields("Year"))
			sDay = oRS.Fields("Day")
			sService = oRS.Fields("Service#")
			sMinister = oRS.Fields("Minister")
			sSermonTitle = oRS.Fields("Sermon Title")
		End If
		oRS.Close
		Set oRS = Nothing
	End Sub
	
	Public Sub CreateLabelFile ( sTemplateFile, sTargetPath, sDVD )
		Dim PRNFile, MSWord
		
		If  sDVD Then
			PRNFile = sTargetPath & GetLabelKey & "_DVD.PRN" 
		Else
			PRNFile = sTargetPath & GetLabelKey & ".PRN"
		End If
		'Dim wordapp, w 

		Set MSWord = CreateObject("Word.Application") 
		MSWord.Visible = False 
		MSWord.Documents.Open sTemplateFile

		MSWord.ActiveDocument.Shapes(6).TextFrame.TextRange.Text = sSermonTitle
		MSWord.ActiveDocument.Shapes(7).TextFrame.TextRange.Text = dDate
		MSWord.ActiveDocument.Shapes(8).TextFrame.TextRange.Text = sDay
			MSWord.ActiveDocument.Shapes(9).TextFrame.TextRange.Text = sMinister

		'MSWord.ActiveDocument.SaveAs "c:\cd\data\testlabel.doc"

		MSWord.ActiveDocument.PrintOut ,,,PRNFile,,,,,,,True
		wscript.sleep(3000) 'Wait for 3 seconds for the file to be generated
		MSWord.Quit 0
		Set MSWord = Nothing
	
		'write out the newly modified file
		'FileStream.SaveToFile sTargetPath & STFile, adSaveCreateOverWrite
		
	End Sub
	
	Public Function GetLabelKey()
		Dim sDate, sMonth, sYear,sAMPM
		'MergeFile = "080803PM.TXT"
		If month(dDate) < 10 Then
			sMonth = "0" & CStr(month(dDate))
		Else
			sMonth = CStr(month(dDate))
		End If
		
		If day(dDate) < 10 Then
			sDate = "0" & CStr(day(dDate))
		Else
			sDate = CStr(day(dDate))
		End If
		
		sYear = right(Cstr(year(dDate)),2)
		sAMPM = ucase(right(sDay,2))
		
		GetLabelKey = sMonth & sDate & sYear & sAMPM

	End Function
	
End class
	
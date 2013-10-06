		Dim adTypeBinary,adTypeText,adSaveCreateOverWrite 
		adTypeBinary = 1 
		adTypeText  = 2 
		adSaveCreateOverWrite = 2 
		
		Dim FileStream, FSO, MergeFileObject 
		Dim MergeFile, STFile 
		'Dim sDate, sMonth, sYear,sAMPM 
		
		Set FileStream = CreateObject("ADODB.Stream") 
		
		FileStream.Type = adTypeText 
		FileStream.CharSet = "us-ascii" 
		FileStream.Open 
		FileStream.LoadFromFile "c:\cd\data\label\church-logo-good.std"
		

		wscript.stdout.writeline "size: " & FileStream.Size
		While Not FileStream.EOS
			wscript.stdout.writeline FileStream.Position
			FileStream.Position  = FileStream.Position + 1
		Wend
		FileStream.Close

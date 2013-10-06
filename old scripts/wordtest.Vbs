Dim wordapp, w

Set wordapp = CreateObject("Word.Application")
wordapp.Visible = False
wordapp.Documents.Open "C:\test2.doc"
wordapp.ActiveDocument.Shapes(1).TextFrame.TextRange.Text = "Changed The Text To A Very long String That I Hope Wraps"
wordapp.ActiveDocument.PrintOut ,,,"C:\test.prn",,,,,,,True
wscript.sleep(2000)
'wordapp.ActiveDocument.PrintOut
'expression.PrintOut(Background, Append, Range, OutputFileName, From, To, Item, Copies, Pages, PageType, PrintToFile, Collate, FileName, ActivePrinterMacGX, ManualDuplexPrint, PrintZoomColumn, PrintZoomRow, PrintZoomPaperWidth, PrintZoomPaperHeight)

'wordapp.ActiveDocument.Save
wordapp.Quit 0
Set wordapp = Nothing


Attribute VB_Name = "Macros1C"
Sub ¬ставитьЁлемент”казател€—номером—тандарта()
Attribute ¬ставитьЁлемент”казател€—номером—тандарта.VB_ProcData.VB_Invoke_Func = "Project.NewMacros.¬ставитьЁлемент”казател€—номером—тандарта"
'
' ¬ставитьЁлемент”казател€—номером—тандарта ћакрос
'
'
    Selection.Find.ClearFormatting
    With Selection.Find
        .Text = "#STD"
        .Forward = True
        .Wrap = wdFindStop
        .Format = False
        .MatchCase = False
        .MatchWholeWord = False
        .MatchWildcards = False
        .MatchSoundsLike = False
        .MatchAllWordForms = False
    End With
    Selection.Find.Execute
    Selection.Paragraphs(1).Range.Select
    Selection.MoveLeft Unit:=wdCharacter, Count:=1, Extend:=wdExtend
    strLongText = Selection.Text
    strKeyText = Left(strLongText, 7)
    ActiveWindow.ActivePane.View.ShowAll = True
    ActiveDocument.TablesOfAuthorities.MarkCitation Range:=Selection.Range, _
        ShortCitation:=strKeyText, LongCitation:=strLongText, _
        LongCitationAutoText:="MarkCitation1", Category:=8
End Sub

Sub Ќайти√иперссылку()
Static curHL As LongLong
Dim lastHL As LongLong, aHyperLink As Hyperlink
'curHL = 1
    If IsEmpty(curHL) Or (curHL = 0) Then curHL = 1
'    For Each aHyperLink In ActiveDocument.Hyperlinks
    lastHL = ActiveDocument.Hyperlinks.Count - 1
    For i = curHL To lastHL
        Set aHyperLink = ActiveDocument.Hyperlinks(i)
        If InStr(LCase(aHyperLink.Address), "https://its.1c.ua/db/content/v8std") <> 0 Then
            aHyperLink.Range.Select
            ActiveWindow.ScrollIntoView Selection.Range
            curHL = i + 1
            aHyperLink.Follow
            Exit For
        End If
'    Next aHyperLink
    Next i
End Sub

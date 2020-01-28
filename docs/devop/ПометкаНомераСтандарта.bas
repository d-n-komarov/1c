Attribute VB_Name = "NewMacros"
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

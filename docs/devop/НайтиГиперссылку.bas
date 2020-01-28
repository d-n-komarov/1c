Attribute VB_Name = "NewMacros"
Sub НайтиГиперссылку()
    For Each ahyperlink In ActiveDocument.Hyperlinks
        If InStr(LCase(ahyperlink.Address), "https://its.1c.ua/db/content/v8std") <> 0 Then
            ahyperlink.Range.Select
            ActiveWindow.ScrollIntoView Selection.Range
            ahyperlink.Follow
            Exit For
        End If
    Next ahyperlink
End Sub

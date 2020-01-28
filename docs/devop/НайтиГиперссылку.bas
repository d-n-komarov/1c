Attribute VB_Name = "NewMacros1"
Sub НайтиГиперссылку()
Static lastHL As LongLong, aHyperLink As Hyperlink
'lastHL = 1
    If IsEmpty(lastHL) Then lastHL = 1
'    For Each aHyperLink In ActiveDocument.Hyperlinks
    For i = lastHL To ActiveDocument.Hyperlinks.Count - 1
        Set aHyperLink = ActiveDocument.Hyperlinks(i)
        If InStr(LCase(aHyperLink.Address), "https://its.1c.ua/db/content/v8std") <> 0 Then
            aHyperLink.Range.Select
            ActiveWindow.ScrollIntoView Selection.Range
            lastHL = i + 1
            aHyperLink.Follow
            Exit For
        End If
'    Next aHyperLink
    Next i
End Sub

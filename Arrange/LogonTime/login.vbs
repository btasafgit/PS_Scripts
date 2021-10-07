On Error Resume Next
Dim Handle
Dim ExplorerStartTime
Dim Process2Look4 
Dim ComputerName
Dim UserName
Dim strNameOfUser
Dim strUserDomain
Dim ObjectFound
Dim OwnerFound
Dim Verbose
Dim CountLoops
Dim ProceesFound
Dim LogonInSecs
Dim MySessionID2
Dim ParentSearchMethod 'how to look for the parent process for date diff
Dim ParentSearchString
Dim TimeStamp
Dim MaxLoops

Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
Set wshNetwork = WScript.CreateObject( "WScript.Network" )
Set WshShell = CreateObject("WScript.Shell")


ComputerName = LCase(wshNetwork.ComputerName)
UserName = LCase(wshNetwork.UserName)

LogonInSecs = 0
Verbose = 1
MaxLoops = 10
ProceesFound = False
ParentSearchMethod = "Associators" 'how to look for the parent process for date diff



'Define the instance that the users sees as he can start to work.
If Left(ComputerName,5) = "COMP1"  then
	Process2Look4 = "explorer.exe"
	ParentSearchMethod = "Associators"
	MaxLoops = 30

Else
	Process2Look4 = "None"
	ParentSearchMethod = "DontLook"

End If

If Verbose = 1 Then wscript.echo "Looking for process: " & Process2Look4
If Verbose = 1 Then wscript.echo "Parent Search Method: " & ParentSearchMethod


If ParentSearchMethod <> "DontLook" then
	ObjectFound = 0
	OwnerFound = 0
	CountLoops = 0
	MySessionID2 = 0
	ProceesFound = False

	While OwnerFound = 0 
		ObjectFound = 0 
		While ObjectFound = 0 
			Set colProcessList = objWMIService.ExecQuery ("Select * from Win32_Process Where Name = '" & Process2Look4 & "'")
			ObjectFound = colProcessList.count
			If Verbose = 1 Then wscript.echo "Looking for process: " & Process2Look4 & " Found results: " & colProcessList.count
		Wend
	'For every Explorer.exe find Username,Domain,
		For Each objProcess in colProcessList
			colProperties = objProcess.GetOwner(strNameOfUser,strUserDomain)
			If Verbose = 1 Then wscript.echo "Owner Retrived: " & strNameOfUser & " for Process: " & objProcess.SessionId
			If LCase(strNameOfUser) = UserName Then
				If Verbose = 1 Then wscript.echo "Owner Match found: " & strNameOfUser & " = " & UserName
				If Verbose = 1 Then Wscript.Echo "Process Creation Date: " & WMIDateStringToDate(objProcess.CreationDate) & vbcrlf _
													 & "Proccess ID: " & objProcess.ProcessID & vbcrlf _
													 & "Parent Process ID: " & objProcess.ParentProcessID  & vbcrlf _
													 & "Handle: " & objProcess.Handle &vbcrlf _
													 & "Session: " & objProcess.SessionId & vbcrlf _
													 & "Process Nmae: " & objProcess.Name & vbcrlf _
													 & "==================================================================================="
				Handle = objProcess.Handle
				MySessionID2 = objProcess.SessionId
				WorkingStartTime =  WMIDateStringToDate(objProcess.CreationDate)
				ProceesFound = True
				OwnerFound = 1
				Exit for
			End if
		Next
		
		
		If CountLoops >= MaxLoops Then
			ProceesFound = False
			OwnerFound = 2
		Else
			If ProceesFound = False Then WScript.Sleep 10000
			CountLoops = CountLoops + 1
		End If
		If Verbose = 1 Then wscript.echo "*****************************************************************"
		set	colProcessList = Nothing
		Set colProperties = nothing
	Wend 'Wheather the owner found or not - exit loop after x retries

	If Verbose = 1 Then wscript.echo "Handle: " & Handle 
	If Verbose = 1 Then wscript.echo "SessionID: " & MySessionID2 

	If ProceesFound = True Then
		If ParentSearchMethod = "Associators" Then 
			ParentSearchString = "associators of {Win32_Process.Handle='" & Handle & "'} where ResultClass = Win32_LogonSession"

			Set colProcessList = objWMIService.ExecQuery(ParentSearchString)
			For Each objProcess in colProcessList
				LogonInSecs = DateDiff("s",WMIDateStringToDate(objProcess.StartTime),WorkingStartTime)
				If Verbose = 1 Then Wscript.Echo "Logon duration in Seconds: " & LogonInSecs
			Next


		ElseIf ParentSearchMethod = "Winlogon" then
			ParentSearchString = "Select * from Win32_Process where Name = 'winlogon.exe' and sessionid = " & MySessionID2

			Set colProcessList = objWMIService.ExecQuery(ParentSearchString)
			For Each objProcess in colProcessList
				LogonInSecs = DateDiff("s",WMIDateStringToDate(objProcess.CreationDate),WorkingStartTime)
				If Verbose = 1 Then Wscript.Echo "Logon duration in Seconds: " & LogonInSecs
			Next

		End If
		
	Else
		If Verbose = 1 Then Wscript.Echo "Can Not Find Parent Process. Quiting...."
		LogonInSecs = 9997
	End If
	
Else 'ParentSearchMethod = "DontLook" 
	'nothing to do here....
	LogonInSecs = 9998
End if


InsertString =				 "Update [UserActivities].[dbo].[tbl_LogonLogoff]" 
InsertString= InsertString & " Set [LogonDuration] = " & LogonInSecs
InsertString= InsertString & " Where 1 = 1"
InsertString= InsertString & " and [TimeStamp] = '" & TimeStamp & "'"
InsertString= InsertString & " and lower([UserName]) = '" & UserName & "'"
InsertString= InsertString & " and lower([ComputerName]) = '" & ComputerName & "'"
InsertString= InsertString & " and [Process] = 'Logon'"

If verbose = 1 Then WScript.Echo InsertString 

Set SQL_Conn = CreateObject("ADODB.Connection")
SQL_DSN = "Provider=SQLOLEDB;Integrated Security=SSPI;Persist Security Info=True;Initial Catalog=SQLTABLE;Data Source=tcp:SQLSERVER,1433"
SQL_Conn.Open SQL_DSN
SQL_Conn.Execute(InsertString)


Function WMIDateStringToDate(dtmStart)
On Error Resume next
    WMIDateStringToDate = CDate(Mid(dtmStart, 7, 2) & "/" & _
        Mid(dtmStart, 5, 2) & "/" & Left(dtmStart, 4) _
            & " " & Mid (dtmStart, 9, 2) & ":" & _
                Mid(dtmStart, 11, 2) & ":" & Mid(dtmStart,13, 2))
End Function



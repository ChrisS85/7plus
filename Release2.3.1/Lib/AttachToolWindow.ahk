AttachToolWindow(hParent, GUINumber, AutoClose)
{
		global ToolWindows
		if(!IsObject(ToolWindows))
			ToolWindows := Object()
		if(!WinExist("ahk_id " hParent))
			return false
		Gui %GUINumber%: +LastFoundExist
		if(!(hGui := WinExist()))
			return false
		DllCall("SetWindowLongPtr", "Ptr", hGui, "int", -8, "PTR", hParent) ;This line actually sets the owner behavior
		ToolWindows.Insert(Object("hParent", hParent, "hGui", hGui,"AutoClose", AutoClose))
		hidden := A_DetectHiddenWindows
		DetectHiddenWindows, On
		ToolWindows.hAHK := WinExist(A_ScriptFullPath " ahk_class AutoHotkey")
		if(!hidden)
			DetectHiddenWindows, Off
		if(ToolWindows.hAHK && AutoClose)
		{
			DllCall("RegisterShellHookWindow", "Ptr", ToolWindows.hAHK )
			ShellHookMsgNum := DllCall("RegisterWindowMessage", Str,"SHELLHOOK" )
			ToolWindows.ShellHookMsgNum := ShellHookMsgNum
			Monitor := OnMessage(ShellHookMsgNum)
			if(Monitor && Monitor != "ToolWindow_ShellMessage")
				ToolWindows.Monitor := Monitor
			OnMessage( ShellHookMsgNum, "ToolWindow_ShellMessage" )
		}
		return true
}

DeAttachToolWindow(GUINumber)
{
	global ToolWindows
	Gui %GUINumber%: +LastFoundExist
	if(!(hGui := WinExist()))
		return false
	Loop % ToolWindows.MaxIndex()
	{
		if(ToolWindows[A_Index].hGui = hGui)
		{
			DllCall("SetWindowLongPtr", "Ptr", hGui, "int", -8, "PTR", 0) ;Remove tool window behavior
			ToolWindows.Remove(A_Index)
			if(ToolWindows.MaxIndex() = "") ;No more tool windows, remove shell hook
			{
				if(ToolWindows.Monitor)
					OnMessage(ToolWindows.ShellHookMsgNum, ToolWindows.Monitor)
				else
					DllCall("DeRegisterShellHookWindow", "Ptr", ToolWindows.hAHK)
			}
		}
	}
}
ToolWindow_ShellMessage(wParam, lParam, msg, hwnd)
{
	global ToolWindows
	if(wParam = 2) ;Window Destroyed
	{
		Loop % ToolWindows.MaxIndex()
		{
			if(ToolWindows[A_Index].hParent = lParam && ToolWindows[A_Index].AutoClose)
			{
				WinClose % "ahk_id " ToolWindows[A_Index].hGui
				ToolWindows.Remove(A_Index)
				if(ToolWindows.MaxIndex() = "") ;No more tool windows, remove shell hook
				{
					if(ToolWindows.Monitor)
						OnMessage(msg, ToolWindows.Monitor)
					else
						DllCall("DeRegisterShellHookWindow", "Ptr", ToolWindows.hAHK)
				}
				break
			}
		}
	}
	if(ToolWindows.Monitor)
	{
		Monitor := ToolWindows.Monitor
		%Monitor%(wParam, lParam, msg, hwnd) ;This is allowed even if the function uses less parameters
	}
}
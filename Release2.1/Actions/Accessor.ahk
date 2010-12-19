Action_Accessor_Init(Action)
{
	static once
	Action.Category := "Window"
	Action.FlashingWindows := 1
	if(!once)
	{		
		once := 1
		Accessor_Init()
	}
}
Action_Accessor_ReadXML(Action, XMLAction)
{
	Action.FlashingWindows := XMLAction.FlashingWindows
}
Action_Accessor_Execute(Action,Event)
{
	if(!Action.tmpGuiNum)
	{		
		if(Action.FlashingWindows)
		{
			result:=FlashingWindows(Action) ;Since FlashingWindows function also uses an object value called FlashingWindows, it can straightly use this action here
			if(result)
				return 1
		}
		result := CreateAccessorWindow(Action)
		return result > 1 ? -1 : (result = 1 ? 1 : 0)
	}
	else
	{
		GuiNum := Action.tmpGuiNum
		Gui,%GuiNum%:+LastFound 
		WinGet, hwnd,ID
		DetectHiddenWindows, Off
		If(WinExist("ahk_id " hwnd)) ;window not closed yet, need more processing time
			return -1
		else
			return 1 ;window closed, all fine
	}
}

Action_Accessor_DisplayString(Action)
{
	return "Show accessor"
}

Action_Accessor_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	SubEventGUI_Add(Action, ActionGUI, "Checkbox", "FlashingWindows", "Activate flashing windows first")
	; SubEventGUI_Add(Action, ActionGUI, "Edit", "LauncherHotkey", "","","Launcher Hotkey:")
}

Action_Accessor_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
} 
Action_Accessor_OnExit(Action)
{
	global Accessor
	Accessor.OnExit()
}
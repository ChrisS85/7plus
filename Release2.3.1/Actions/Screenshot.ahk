Action_Screenshot_Init(Action)
{
	Action.Category := "System"
	Action.Area := "Screen"
	Action.Quality := 95
	Action.TargetFolder := ""
	Action.TargetFile := ""
}

Action_Screenshot_ReadXML(Action, XMLAction)
{
	Action.ReadVar(XMLAction, "Area")
	Action.ReadVar(XMLAction, "Quality")
	Action.ReadVar(XMLAction, "TargetFolder")
	Action.ReadVar(XMLAction, "TargetFile")
}
; Action_Screenshot_LButton_Block:
; return
Action_Screenshot_Execute(Action, Event)
{
	global ImageExtensions
	TargetFolder := Event.ExpandPlaceholders(Action.TargetFolder)
	TargetFile := Event.ExpandPlaceholders(Action.TargetFile)
	if(Action.Area = "Screen")
		pBitmap := Gdip_BitmapFromScreen()
	else if(Action.Area = "Window")
		pBitmap := Gdip_BitmapFromHWND(WinExist("A"))
	else if(Action.Area = "User selection")
	{
		if(!Action.tmpState)
		{
			Action.tmpState := 1
			;Credits of code below go to sumon/Learning one
			CoordMode, Mouse ,Screen 
			Action.tmpGuiNum0 := GetFreeGUINum(10)
			Gui % Action.tmpGuiNum0 ": Default"
			Gui, +AlwaysOnTop -caption -Border +ToolWindow +LastFound 
			Gui, Color, White
			Gui, Font, s50 c0x5090FF, Verdana
			Gui, Add, Text, % "x0 y" (A_ScreenHeight/10) " w" A_ScreenWidth " Center", Drag a rectangle around the area you want to capture!
			WinSet, TransColor, White
			Action.tmpGuiNum := GetFreeGUINum(10)
			Gui % Action.tmpGuiNum ": Default"
			SysGet, VirtualX, 76
			SysGet, VirtualY, 77
			SysGet, VirtualW, 78
			SysGet, VirtualH, 79
			Gui, +AlwaysOnTop -caption +Border +ToolWindow +LastFound 
			WinSet, Transparent, 1
			Gui % Action.tmpGuiNum0 ":Show", X%VirtualX% Y%VirtualY% W%VirtualW% H%VirtualH%
			Gui, Show, X%VirtualX% Y%VirtualY% W%VirtualW% H%VirtualH%
			Action.tmpGuiNum1 := GetFreeGUINum(10)
			Gui % Action.tmpGuiNum1 ": Default"
			Gui, +AlwaysOnTop -caption +Border +ToolWindow +LastFound 
			WinSet, Transparent, 120 
			Gui, Color, 0x5090FF
			return -1
		}
		else if(Action.tmpState = 1) ;Wait for mouse down
		{
			if(GetKeyState("LButton", "p"))
			{
				Action.tmpState := 2				
				MouseGetPos, MX, MY
				Action.tmpMX := MX
				Action.tmpMY := MY
			}
			return -1
		}
		else if(Action.tmpState = 2) ;Dragging
		{
			 MouseGetPos, MXend, MYend 
		   w := abs(Action.tmpMX - MXend) 
		   h := abs(Action.tmpMY - MYend) 
		   If ( Action.tmpMX < MXend ) 
		   X := Action.tmpMX 
		   Else 
		   X := MXend 
		   If ( Action.tmpMY < MYend ) 
		   Y := Action.tmpMY 
		   Else 
		   Y := MYend 
		   Gui, % Action.tmpGuiNum1 ": Show", x%X% y%Y% w%w% h%h% 
			if(GetKeyState("LButton", "p")) ;Resize selection rectangle
			   return -1
			else ;Mouse release
			{
				Gui, % Action.tmpGuiNum1 ": Destroy"
				If ( Action.tmpMX > MXend ) 
				{ 
				   temp := Action.tmpMX 
				   Action.tmpMX := MXend 
				   MXend := temp 
				} 
				If ( Action.tmpMY > MYend ) 
				{ 
				   temp := Action.tmpMY 
				   Action.tmpMY := MYend 
				   MYend := temp 
				} 
				Gui, % Action.tmpGuiNum0 ": Destroy"
				Gui, % Action.tmpGuiNum ": Destroy"
				outputdebug % (Action.tmpMX "|" Action.tmpMY "|" w "|" h)
				pBitmap := Gdip_BitmapFromScreen(Action.tmpMX "|" Action.tmpMY "|" w "|" h)
				; Area = %MX%, %MY%, %MXend%, %MYend%
				Action.Remove("tmpMX")
				Action.Remove("tmpMY")
				Action.Remove("tmpGuiNum")
				Action.Remove("tmpGuiNum0")
				Action.Remove("tmpGuiNum1")
				Action.Remove("tmpState")
			}
		}
	}
	Gdip_SaveBitmapToFile(pBitmap, TargetFolder "\" TargetFile, Action.Quality)
	Gdip_DisposeImage(pBitmap)
	return 1
} 

Action_Screenshot_DisplayString(Action)
{
	if(Action.Area = "Screen")
		return "Take screenshot"
	else if(Action.Area = "Window")
		return "Take screenshot of active window"
	else if(Action.Area = "User selection")
		return "Take screenshot of user selected area"
}

Action_Screenshot_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "DropDownList", "Area", "Screen|Window|User selection", "", "Area:")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Quality", "", "", "Quality:","","","","","0-100")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "TargetFolder", "", "", "Target folder:", "Browse", "Action_Screenshot_Browse", "Placeholders", "Action_Screenshot_Placeholders_TargetFolder")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "TargetFile", "", "", "Target file:", "Placeholders", "Action_Screenshot_Placeholders_TargetFile")
	}
	else if(GoToLabel = "Browse")
		SubEventGUI_Browse(sActionGUI, "TargetFolder")
	else if(GoToLabel = "Placeholders_TargetFolder")
		SubEventGUI_Placeholders(sActionGUI, "TargetFolder")
	else if(GoToLabel = "Placeholders_TargetFile")
		SubEventGUI_Placeholders(sActionGUI, "TargetFile")
}
Action_Screenshot_Browse:
Action_Screenshot_GuiShow(Action, ActionGUI, "Browse")
return

Action_Screenshot_Placeholders_TargetFolder:
Action_Screenshot_GuiShow(Action, ActionGUI, "Placeholders_TargetFolder")
return

Action_Screenshot_Placeholders_TargetFile:
Action_Screenshot_GuiShow(Action, ActionGUI, "Placeholders_TargetFile")
return

Action_Screenshot_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}
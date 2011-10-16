Action_MD5_Init(Action)
{
	Action.Category := "File"
	Action.Files := "${SelNM}"
}	
Action_MD5_ReadXML(Action, XMLAction)
{
	Action.ReadVar(XMLAction, "Files")
}
Action_MD5_Execute(Action,Event)
{
	if(!Action.tmpGuiNum)
	{
		result := MD5Dialog(Event.ExpandPlaceHolders(Action.Files))
		if(result) ;
		{
			Action.tmpGuiNum := result
			Action.Time := A_TickCount
			return -1
		}
		else
			return 0 ;Msgbox wasn't created
	}
	else
	{
		GuiNum := Action.tmpGuiNum
		Gui,%GuiNum%:+LastFound 
		WinGet, MD5_hwnd,ID
		DetectHiddenWindows, Off
		If(WinExist("ahk_id " MD5_hwnd)) ;Box not closed yet, need more processing time
			return -1
		else
			return 1 ;Box closed, all fine
	}
} 
Action_MD5_DisplayString(Action)
{
	return "Calculate MD5 Checksum on " Action.Files
}

Action_MD5_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Files", "", "", "Files:", "Placeholders", "Action_MD5_Files_Placeholders")
	}
	else if(GoToLabel = "Files_Placeholders")
		SubEventGUI_Placeholders(sActionGUI, "Files")
}
Action_MD5_Files_Placeholders:
Action_MD5_GuiShow("", "", "Files_Placeholders")
return

Action_MD5_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}

;Non blocking MD5 box (can wait for closing in event system though)
MD5Dialog(Files) 
{
	static MD5ListView, l_GUI, sFiles
	outputdebug files %files%
	if(!IsObject(Files))
		Files := ToArray(Files)
	if(!(Files.len() > 0))
	{
		Msgbox MD5 Checksums: Invalid Files specified!
		return 0
	}
	WasCritical := A_IsCritical
	Critical, Off
	;Check if MD5Checksum window is already open
	if(l_GUI)
	{		
		Gui, ListView, MD5ListView
		Loop % Files.len()
		{
			if(sFiles.IndexOf(Files[A_Index]) = 0)
			{
				LV_Add("",Files[A_Index], FileMD5(Files[A_Index]))
				sFiles.Insert(Files[A_Index])
			}
		}
		Gui, %l_GUI%:Show
		return
	}
	l_GUI:=GetFreeGUINum(10)
	sFiles := Files.DeepCopy()
	if(!l_GUI)
		return
	
	Gui, %l_GUI%:Default
	Gui, Destroy 
	Gui, Add,ListView,vMD5ListView w600 R20,File|MD5 Checksum
         
	Gui, Add,Button,% "Default y+10 x420 w100 gMD5Copy",Copy checksums
	Gui, Add,Button,% "Default x+10 w80 gMD5Close",Close
         
	Gui, -MinimizeBox -MaximizeBox +LabelMD5 +AlwaysOnTop
	Gui, Show,,MD5 Checksums
	Loop % sFiles.len()
	{
		if(!InStr(FileExist(sFiles[A_Index]), "D"))
		{
			Gui, ListView, MD5ListView
			LV_Add("", sFiles[A_Index], FileMD5(sFiles[A_Index]))
		}
	}
	LV_ModifyCol(1, 370)
	LV_ModifyCol(2, "AutoHdr")
	if(WasCritical)
		Critical
	;return Gui number to indicate that the MD5 box is still open
	return l_GUI
	
	MD5Close:
	MD5Escape:
	Gui, Destroy
	sFiles := ""
	l_GUI := ""
	return
	MD5Copy:
	Gui, ListView, MD5ListView
	Clip := ""
	Loop % LV_GetCount()
	{
		LV_GetText(File, A_Index, 1)
		LV_GetText(MD5, A_Index, 2)
		Clip .= (A_Index = 1 ? "" : "`n") File " : " MD5
	}
	if(Clip != "")
		Clipboard := Clip
	return
}
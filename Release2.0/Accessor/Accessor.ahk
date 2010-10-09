Accessor_Init()
{
	global AccessorPlugins, Accessor, ConfigPath
	SplitPath, ConfigPath,,path
	path .= "\Accessor.xml"
	AccessorPluginsList := "WindowSwitcher,FileSystem,Google,Calc,ProgramLauncher,NotepadPlusPlus,Notes,FastFolders,Uninstall,Weather" ;The order here partly determines the order in the window, so choose carefully
	AccessorPlugins := Array()
	Accessor := Object("Base", Object("OnExit", "Accessor_OnExit"))
	if(FileExist(path))
	{
		FileRead, xml, %path%
		XMLObject := XML_Read(xml)
	}
	Loop, Parse, AccessorPluginsList, `,,%A_Space%
	{		
		outputdebug plugin %a_loopfield%
		tmpobject := RichObject()
		tmpobject.Type := A_LoopField
		tmpobject.Init := "Accessor_" A_LoopField "_Init"
		tmpobject.ReadXML := "Accessor_" A_LoopField "_ReadXML"
		tmpobject.IsInSinglePluginContext := "Accessor_" A_LoopField "_IsInSinglePluginContext"
		tmpobject.FillAccessorList := "Accessor_" A_LoopField "_FillAccessorList"
		tmpobject.OnAccessorOpen := "Accessor_" A_LoopField "_OnAccessorOpen"
		tmpobject.OnAccessorClose := "Accessor_" A_LoopField "_OnAccessorClose"
		tmpobject.GetDisplayStrings := "Accessor_" A_LoopField "_GetDisplayStrings"
		tmpobject.ListViewEvents := "Accessor_" A_LoopField "_ListViewEvents"
		tmpobject.EditEvents := "Accessor_" A_LoopField "_EditEvents"
		tmpobject.PerformAction := "Accessor_" A_LoopField "_PerformAction"
		tmpobject.SetupContextMenu := "Accessor_" A_LoopField "_SetupContextMenu"
		tmpobject.OnKeyDown := "Accessor_" A_LoopField "_OnKeyDown"
		tmpobject.OnExit := "Accessor_" A_LoopField "_OnExit"
		tmpobject.ShowSettings := "Accessor_" A_LoopField "_ShowSettings"
		tmpobject.SaveSettings := "Accessor_" A_LoopField "_SaveSettings"
		tmpobject.GUISubmit := "Accessor_" A_LoopField "_GUISubmit"
		tmpobject.Priority := 0
		tmpobject.OKName := "OK"
		tmpobject.Settings := RichObject()
		tmpobject.Settings.BasePriority := XMLObject ? XMLObject[A_LoopField].Settings.BasePriority : 1
		tmpobject.Enabled := XMLObject ? XMLObject[A_LoopField].Enabled : 1
		Accessor_%A_LoopField%_Init(tmpobject, XMLObject[A_LoopField].Settings)
		if(XMLObject[A_LoopField].Settings.Keyword) ;Set keyword automatically for each plugin to save some lines
			tmpobject.Settings.Keyword := XMLObject[A_LoopField].Settings.Keyword
		if(XMLObject[A_LoopField].Settings.BasePriority) ;Set keyword automatically for each plugin to save some lines
			tmpobject.Settings.Keyword := XMLObject[A_LoopField].Settings.BasePriority	
		AccessorPlugins.append(Object("Base",tmpobject))
	}
	Accessor.GenericIcons := Object()
	; hInstance := DllCall("GetModuleHandle", UInt, 0)
	Accessor.GenericIcons.Application := ExtractIcon("shell32.dll", 3, 64)
	Accessor.GenericIcons.Folder := ExtractIcon("shell32.dll", 4, 64)
	Accessor.GenericIcons.URL := ExtractIcon("shell32.dll", 14, 64)
	; DllCall("ExtractIcon", "uint", hInstance, "str", "shell32.dll", "uint", 3)
	; Accessor.GenericIcons.Folder := DllCall("ExtractIcon", "uint", hInstance, "str", "shell32.dll", "uint", 4)
	outputdebug % "folder " Accessor.GenericIcons.Folder
}
Accessor_OnExit(Accessor)
{
	global AccessorPlugins, ConfigPath
	if(Accessor.GUINum)
		AccessorClose()
	
	SplitPath, ConfigPath,,path
	path .= "\Accessor.xml"
	FileDelete, %path%
	XMLObject := Object()
	Loop % AccessorPlugins.len()
	{
		XMLObject[AccessorPlugins[A_Index].Type] := Object("Enabled", AccessorPlugins[A_Index].Enabled, "Keyword", AccessorPlugins[A_Index].Settings.Keyword, "Settings", AccessorPlugins[A_Index].Settings)
		AccessorPlugins[A_Index].OnExit()
	}	
	XML_Save(XMLObject,path)
	
	DestroyIcon(Accessor.GenericIcons.Application)
	DestroyIcon(Accessor.GenericIcons.Folder)
	DestroyIcon(Accessor.GenericIcons.URL)
}
;Non blocking window switcher box (can wait for closing in event system though)
CreateAccessorWindow(Action)
{
	global AccessorListView, Accessor, AccessorPlugins, AccessorOKButton
	WasCritical := A_IsCritical
	Critical, Off
	if(AccessorGUINum := Accessor.GUINum)
	{
		gui %AccessorGUINum%:+LastFoundExist
		If(WinExist())
			return AccessorGUINum
	}
	AccessorGUINum:=10
	DetectHiddenWindows, On
    loop
	{
		;-- Window available?
		gui %AccessorGUINum%:+LastFoundExist
		If(!WinExist())
			break

		;-- Nothing available?
		if(AccessorGUINum=99)
		{
			MsgBox 262160
				,HotkeyGUI Error
				,Unable to create Accessor window. GUI windows 10 to 99 are already in use.
			ErrorLevel=9999
			return ""
		}

		;-- Increment window
		AccessorGUINum++
	}
	active := WinExist("A") ;Active window for fastfolder purposes later
	Gui, %AccessorGUINum%: Default
	Gui, Destroy 
	Gui, Add,Edit, w800 y10 -Multi gAccessorEdit vAccessorEdit hwndHWNDEdit
	Gui, Add,ListView, w800 y+10 AltSubmit 0x8 -Multi R15 NoSortHdr gAccessorListView vAccessorListView hwndHWNDListView, #| |Title|Path| | |
	Gui, Add,Button, Default y10 x+10 w75 gAccessorOK vAccessorOKButton, OK
	Gui, Add,Button,y+8 w75 gAccessorCancel, Cancel
	Gui, Add,StatusBar
	Gui, -MinimizeBox -MaximizeBox +LabelAccessor +AlwaysOnTop -Caption +Border
	Action.tmpGuiNum := AccessorGUINum
	Accessor.WindowTitle := "7Plus Accessor"
	Gui, Show,, % Accessor.WindowTitle
	if(!IsObject(Accessor))
		Accessor := Object()
	Accessor.GUINum := AccessorGUINum
	Accessor.hwndEdit := hwndEdit
	Accessor.hwndListView := hwndListView	
	Accessor.PreviousWindow := Active
	Accessor.LauncherHotkey := Action.LauncherHotkey
	Loop % AccessorPlugins.len()
		AccessorPlugins[A_Index].OnAccessorOpen(Accessor)
	;Check if a plugin set a custom filter
	GuiControlGet, Filter, , AccessorEdit
	if(!Filter)
		FillAccessorList()
	OnMessage(0x06,"WM_ACTIVATE")
	old := OnMessage(0x100)
	Accessor.OldKeyDown := old
	OnMessage(0x100, "Accessor_WM_KEYDOWN")
	;return Gui number to indicate that the Accessor box is still open
	return AccessorGUINum
}

FillAccessorList()
{
	global AccessorPlugins,Accessor,AccessorListView,AccessorEdit
	if(Accessor.SuppressListViewUpdate)
	{
		Accessor.SuppressListViewUpdate := false
		return
	}
	LastFilter := Accessor.LastFilter
	guinum := Accessor.GUINum
	if(!guinum)
		return
	Gui, %guinum%: Default
	Gui, ListView, AccessorListView	
	GuiControlGet, Filter, , AccessorEdit
	; if(filter = "run ")
	; {
		; Send % "$" Accessor.LauncherHotkey
		; AccessorClose()
		; return
	; }
	outputdebug lv not ready
	Accessor.ListViewReady := false
	GuiControl, -Redraw, AccessorListView
	LV_Delete()
	if(Accessor.ImageListID)
		IL_Destroy(Accessor.ImageListID)
	Accessor.ImageListID := IL_Create(10,5,1) ; Create an ImageList so that the ListView can display some icons
	IconCount := 3
	DllCall("ImageList_ReplaceIcon", UInt, Accessor.ImageListID, Int, -1, UInt, Accessor.GenericIcons.Application)
	DllCall("ImageList_ReplaceIcon", UInt, Accessor.ImageListID, Int, -1, UInt, Accessor.GenericIcons.Folder)
	DllCall("ImageList_ReplaceIcon", UInt, Accessor.ImageListID, Int, -1, UInt, Accessor.GenericIcons.URL)
	Accessor.List := Array()
	;Find out if we are in a single plugin context, and add only those items
	Loop % AccessorPlugins.len()
		if(AccessorPlugins[A_Index].Enabled && SingleContext := ((AccessorPlugins[A_Index].Settings.Keyword && Filter && KeywordSet := strStartsWith(Filter, AccessorPlugins[A_Index].Settings.Keyword " ")) || AccessorPlugins[A_Index].IsInSinglePluginContext(Filter, LastFilter))) 
		{
			Filter := strTrim(Filter, AccessorPlugins[A_Index].Settings.Keyword " ")
			AccessorPlugins[A_Index].FillAccessorList(Accessor, Filter, LastFilter, IconCount, KeywordSet)
			break
		}
	outputdebug singlecontext : %singlecontext%
	;If we aren't, let all plugins add the items we want according to their priorities
	if(!SingleContext)
	{
		Pluginlist := ""
		Loop % AccessorPlugins.len()
			Pluginlist .= (Pluginlist ? "," : "") A_Index
		outputdebug Pluginlist %Pluginlist%
		Sort, Pluginlist, F AccessorPrioritySort D`,
		outputdebug sorted %Pluginlist%
		Loop, Parse, Pluginlist, `,
			if(AccessorPlugins[A_Index].Enabled && !AccessorPlugins[A_LoopField].KeywordOnly && StrLen(Filter) >= AccessorPlugins[A_LoopField].MinChars)
				AccessorPlugins[A_LoopField].FillAccessorList(Accessor, Filter, LastFilter, IconCount, False)
	}
	;Now that items are added, add them to the listview
	LV_SetImageList(Accessor.ImageListID, 1) ; Attach the ImageLists to the ListView so that it can later display the icons
	outputdebug % "len: " Accessor.List.len()
	Loop % Accessor.List.len()
	{
		AccessorListEntry := Accessor.List[A_Index]
		AccessorPlugin := AccessorPlugins[AccessorPlugins.indexOfSubItem("Type", AccessorListEntry.Type)]
		AccessorPlugin.GetDisplayStrings(AccessorListEntry, Title := AccessorListEntry.Title, Path := AccessorListEntry.Path, Detail1 := AccessorListEntry.Detail1, Detail2 := AccessorListEntry.Detail2)
		LV_Add("Icon" AccessorListEntry.Icon, "", A_Index, Title, Path, Detail1, Detail2)
	}
	outputdebug lv ready
	Accessor.ListViewReady := true
	Accessor.LastFilter := Filter	
	selected := LV_GetNext()
	if(!selected)
		LV_Modify(1,"Select")
	LV_ModifyCol()
	LV_ModifyCol(1, "Auto") ; icon column
    LV_ModifyCol(2, 0) ; hidden column for row number    
    LV_ModifyCol(3, "460") ;Col_3_w) ; resize title column
	; SendMessage, 0x1000+29, 2, 0,, % "ahk_id " Accessor.hwndListView ; LVM_GETCOLUMNWIDTH is 0x1000+29
	; Width_Column_3 := ErrorLevel
	; If Width_Column_3 > 430
		; LV_ModifyCol(3, 430) ; resize title column
    ; LV_ModifyCol(4, "Auto") ; exe
    ; SendMessage, 0x1000+29, 3, 0,, % "ahk_id " Accessor.hwndListView ; LVM_GETCOLUMNWIDTH is 0x1000+29
	; Width_Column_4 := ErrorLevel
	; If Width_Column_4 > 200
	LV_ModifyCol(4, 170) ; resize title column
	LV_ModifyCol(5, 55)
	LV_ModifyCol(6, "AutoHdr") ; OnTop
	; LV_ModifyCol(7, 0) ; OnTop
	GuiControl, +Redraw, AccessorListView
}

AccessorPrioritySort(First,Second)
{
	global AccessorPlugins
	return AccessorPlugins[First].Priority = AccessorPlugins[Second].Priority ? First > Second ? 1 : First < Second ? -1 : 0 : AccessorPlugins[First].Priority < AccessorPlugins[Second].Priority ? 1 : -1
}
AccessorEdit:
AccessorEditEvents()
return
return
AccessorListView:
AccessorListViewEvents()
return

AccessorEditEvents()
{
	global Accessor, AccessorPlugins, AccessorEdit	
	outputdebug edit events
	GuiControlGet, Filter, , AccessorEdit
	LV_GetText(id,A_EventInfo,2)
	AccessorListEntry := Accessor.List[id]
	NeedsUpdate := 1
	Loop % AccessorPlugins.len() ;Check if single context plugin requests an update
	{
		if(AccessorPlugins[A_Index].Enabled && ((AccessorPlugins[A_Index].Settings.Keyword && Filter && strStartsWith(Filter, AccessorPlugins[A_Index].Settings.Keyword)) || AccessorPlugins[A_Index].IsInSinglePluginContext(Filter, Accessor.LastFilter)))
		{
			NeedsUpdate := AccessorPlugins[A_Index].EditEvents(AccessorListEntry, Filter, LastFilter)
			break
		}
	}
	if(!NeedsUpdate) ;Check if any plugin requests an update
		Loop % AccessorPlugins.len()
		{
			if(AccessorPlugins[A_Index].Enabled && !AccessorPlugins[A_Index].KeywordOnly)
				NeedsUpdate := AccessorPlugins[A_Index].EditEvents(AccessorListEntry, Filter, LastFilter)
			if(NeedsUpdate)
				break
		}
	if(NeedsUpdate)
		FillAccessorList()
}
AccessorListViewEvents()
{
	global Accessor, AccessorPlugins, AccessorEdit, AccessorOKButton
	GuiControlGet, Filter, , AccessorEdit
	SplitPath, Filter, name, dir,,,drive
	LV_GetText(id,A_EventInfo,2)
	AccessorListEntry := Accessor.List[id]
	Loop % AccessorPlugins.len()
	{
		if(AccessorPlugins[A_Index].Enabled && AccessorListentry.Type = AccessorPlugins[A_Index].Type)
		{	
			handled := AccessorPlugins[A_Index].ListViewEvents(AccessorListEntry)
			GUIControlGet, name, , AccessorOKButton
			if(name != AccessorPlugins[A_Index].OKName)
				GuiControl,,AccessorOKButton, % AccessorPlugins[A_Index].OKName
			break
		}
	}	
	if(!handled)
	{
		if(A_GUIEvent = "DoubleClick")
		{
			AccessorOK()
			AccessorClose()
		}
	}
	return
}

AccessorOK:
AccessorOK()
AccessorClose:
AccessorClose()
return
AccessorEscape:
AccessorClose()
return
AccessorCancel:
AccessorClose()
return
AccessorOK()
{
	global Accessor, AccessorPlugins
	GUINum := Accessor.GUINum
	Gui, %GUINum%: Default
	GUI, ListView, AccessorListView
	selected := LV_GetNext()
	LV_GetText(id,selected,2)
	Loop % AccessorPlugins.len()
	{
		if(AccessorPlugins[A_Index].Type = Accessor.List[id].Type)
		{
			AccessorPlugins[A_Index].PerformAction(Accessor, Accessor.List[id])
			break
		}
	}
}
AccessorClose()
{
	global Accessor, AccessorPlugins
	WasCritical := A_IsCritical
	Critical
	if(Accessor.GUINum)
	{
		GUINum := Accessor.GUINum
		Gui, %GUINum%: Default
		GUI, ListView, AccessorListView
		Loop % AccessorPlugins.len()
			AccessorPlugins[A_Index].OnAccessorClose(Accessor)
		Accessor.GUINum := 0
		Accessor.LastFilter := ""
		OnMessage(0x100, Accessor.OldKeyDown) ; Restore previous KeyDown handler
		Gui, Destroy
	}
	if(!WasCritical)
		Critical, Off
}
WM_ACTIVATE(wParam,lParam)
{
	global Accessor
	if(wParam=0 && lParam=WinExist(Accessor.WindowTitle " ahk_class AutoHotkeyGUI"))
		AccessorClose()
	return 0
}
Accessor_WM_KEYDOWN(wParam,lParam)
{
	global Accessor,AccessorPlugins,AccessorEdit
	GUINum := Accessor.GUINum
	Gui, %GUINum%: Default
	GUI, ListView, AccessorListView
	
	GuiControlGet, Filter, , AccessorEdit
	if(count := LV_GetCount() > 0)
	{
		selected := LV_GetNext()
		LV_GetText(id, selected, 2)
		LV_GetText(path,selected,4)
		AccessorListEntry := Accessor.List[id]
	}
	
	Loop % AccessorPlugins.len()
		if(AccessorPlugins[A_Index].Enabled && SingleContext := ((AccessorPlugins[A_Index].Settings.Keyword && Filter && strStartsWith(Filter, AccessorPlugins[A_Index].Settings.Keyword)) || AccessorPlugins[A_Index].IsInSinglePluginContext(Filter, Accessor.LastFilter)))
		{
			outputdebug single context keydown
			handled := AccessorPlugins[A_Index].OnKeyDown(wParam, lParam, Filter, selected, AccessorListEntry)
			if(handled)
				return 1
		}
	if(!SingleContext)
		Loop % AccessorPlugins.len()
		{
			if(AccessorPlugins[A_Index].Enabled && AccessorPlugins[A_Index].Type = AccessorListEntry.Type && !AccessorPlugins[A_Index].KeywordOnly)
			{
				handled := AccessorPlugins[A_Index].OnKeyDown(wParam, lParam, Filter, selected, AccessorListEntry)
				if(handled)
					return 1
				break
			}
		}
	if(wParam = 9) ;Tab
	{
		if(count = 0)
			return 1
		Accessor_WM_KEYDOWN(40,0) ;Send down key
		return 1
	}	
	if(wParam = 38) ;Up arrow
	{
		selected := LV_GetNext()
		selected := Mod(selected - 1 + LV_GetCount() - 1, LV_GetCount()) + 1
		LV_Modify(selected,"Select Vis")
		return 1
	}
	else if(wParam = 40) ;Down arrow
	{
		selected := LV_GetNext()
		selected := Mod(selected + 1,LV_GetCount())
		LV_Modify(selected,"Select Vis")
		return 1
	}
	; return 0
}

AccessorContextMenu:
AccessorContextMenu()
return
AccessorContextMenu()
{
	global Accessor, AccessorPlugins
	if(A_GuiControl = "AccessorListView")
	{
		selected := A_EventInfo
		if(!selected)
			return
		
		Menu, AccessorMenu, add, 1,AccessorOK
		Menu, AccessorMenu, DeleteAll
		LV_GetText(id,selected,2)
		AccessorListEntry := Accessor.List[id]
		Loop % AccessorPlugins.len()
		{
			if(AccessorListEntry.Type = AccessorPlugins[A_Index].Type)
			{
				AccessorPlugins[A_Index].SetupContextMenu(AccessorListEntry)
				break
			}				
		}
		Menu, AccessorMenu, Show
	}
}

AccessorOpenExplorer:
AccessorOpenExplorer()
return
AccessorOpenCMD:
AccessorOpenCMD()
return
AccessorRunWithArgs:
AccessorRunWithArgs()
return
AccessorExplorerContextMenu:
AccessorExplorerContextMenu()
return
AccessorCopyPath:
AccessorCopyField("Path")
return
AccessorCopyTitle:
AccessorCopyField("Title")
return
AccessorCopyField(Field = "Path")
{
	global Accessor, AccessorListView
	GUINum := Accessor.GUINum
	Gui, %GUINum%: Default
	Gui, ListView, AccessorListView
	selected := LV_GetNext()
	if(!selected)
		return
	LV_GetText(id,selected,2)
	Clipboard := Accessor.List[id][Field]
}
AccessorExplorerContextMenu()
{
	global Accessor
	GUINum := Accessor.GUINum
	Gui, %GUINum%: Default
	GUI, ListView, AccessorListView
	selected := LV_GetNext()
	LV_GetText(id,selected,2)
	ShellContextMenu(Accessor.List[id].Path)
}
AccessorRunWithArgs()
{
	global EventSchedule, Accessor
	GUINum := Accessor.GUINum
	Gui, %GUINum%: Default
	GUI, ListView, AccessorListView
	selected := LV_GetNext()
	LV_GetText(id,selected,2)
	Event := EventSystem_CreateEvent("")
	Event.ID := -1
	Event.Name := "Run with arguments"
	Event.Actions.append(EventSystem_CreateSubEvent("Action","Input"))
	Event.Actions[1].Text := "Enter program arguments"
	Event.Actions[1].Title := "Enter program arguments"
	Event.Actions.append(EventSystem_CreateSubEvent("Action","Run"))
	Event.Actions[2].Command := """" Accessor.List[id].Path """ ${Input}"
	EventSchedule.append(Event)
	AccessorClose()
}
AccessorOpenExplorer()
{
	global Accessor, AccessorListView
	GUINum := Accessor.GUINum
	Gui, %GUINum%: Default
	Gui, ListView, AccessorListView
	selected := LV_GetNext()
	if(!selected)
		return
	LV_GetText(id,selected,2)
	path := Accessor.List[id].Path
	if(!InStr(FileExist(path),"D"))
		Run(A_WinDir "\explorer.exe /Select," path)
	else
		Run(A_WinDir "\explorer.exe /n,/e," path)
	AccessorClose()
}
AccessorOpenCMD()
{
	global Accessor, AccessorListView
	GUINum := Accessor.GUINum
	Gui, %GUINum%: Default
	Gui, ListView, AccessorListView
	selected := LV_GetNext()
	if(!selected)
		return
	LV_GetText(id,selected,2)
	path := Accessor.List[id].Path
	if(!InStr(FileExist(path),"D"))
		SplitPath, path,, path
	Run("cmd.exe /k cd /D """ path """")
	AccessorClose()
}
GUI_EditAccessorPlugin(Settings,GoToLabel="")
{
	static PluginSettings, result, PluginGUI, Plugin
	global AccessorPlugins
	if(GoToLabel = "")
	{
		;Don't show more than once
		if(PluginSettings)
			return ""
		PluginSettings := Settings
		result := ""
		PluginGUI := object("x",38,"y",80)
		Plugin := AccessorPlugins[AccessorPlugins.indexOfSubItem("Type", PluginSettings.Type)]
		outputdebug % "type " PluginSettings.type
		Gui 1:+LastFoundExist
		IfWinExist		
			Gui, 1:+Disabled
		Gui, 4:Default
		Gui, +LabelEditAccessorPlugin +Owner1 +ToolWindow +OwnDialogs
		width := 500
		height := 500
		;Gui, 4:Add, Button, ,OK
		x := Width - 174
		y := Height - 34
		Gui, Add, Button, gEditAccessorPluginOK x%x% y%y% w70 h23, &OK
		x := Width - 94
		Gui, Add, Button, gEditAccessorPluginCancel x%x% y%y% w80 h23, &Cancel
		
		;Fill tabs
		x := 40
		y := 18
		
		Gui, Add, Text, x%x% y%y%, % Plugin.Description
		
		x := 28
		y += 40 + 4
		w := width - 54
		h := height - 158 - 28 
		Gui, Add, GroupBox, x%x% y%y% w%w% h%h%, Options
		
		Plugin.ShowSettings(PluginSettings.Settings, PluginGUI)
		Gui, Show, w%width% h%height%, Edit Plugin
		
		Gui, +LastFound
		WinGet, EditAccessorPlugin_hWnd,ID
		DetectHiddenWindows, Off
		loop
		{
			sleep 250
			IfWinNotExist ahk_id %EditAccessorPlugin_hWnd% 
				break
		}
		Plugin := ""
		PluginSettings := ""
		PluginGUI := ""
		Gui 1:+LastFoundExist
		IfWinExist
			Gui, 1:Default
		return result
	}
	else if(GoToLabel = "EditAccessorPluginOK")
	{
		Plugin.SaveSettings(PluginSettings.Settings, PluginGUI)
		SubEventGUI_GUISubmit(PluginSettings.Settings, PluginGUI)
		Gui, Submit, NoHide
		outputdebug % " keyword: " PluginSettings.Settings.Keyword " Default: " Plugin.DefaultKeyword
		if(PluginSettings.Settings.Keyword = "" && Plugin.DefaultKeyword != "")
			PluginSettings.Settings.Keyword := Plugin.DefaultKeyword
		result := PluginSettings
		Gui 1:+LastFoundExist
		IfWinExist		
			Gui, 1:-Disabled
		Gui, Destroy
		return
	}
	else if(GoToLabel = "EditAccessorPluginClose")
	{
		Gui 1:+LastFoundExist		
		result := ""
		IfWinExist		
			Gui, 1:-Disabled
		Gui, Cancel
		Gui, destroy
		Gui 1:+LastFoundExist
		IfWinExist		
			Gui, 1:Default
		return
	}
} 
EditAccessorPluginOK:
GUI_EditAccessorPlugin("","EditAccessorPluginOK")
return

EditAccessorPluginClose:
EditAccessorPluginEscape:
EditAccessorPluginCancel:
GUI_EditAccessorPlugin("","EditAccessorPluginClose")
return
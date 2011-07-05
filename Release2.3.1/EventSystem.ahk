#include %A_ScriptDir%\Event.ahk
#include %A_ScriptDir%\Events.ahk

#include %A_ScriptDir%\Triggers\ContextMenu.ahk
#include %A_ScriptDir%\Triggers\DoubleClickDesktop.ahk
#include %A_ScriptDir%\Triggers\DoubleClickTaskbar.ahk
#include %A_ScriptDir%\Triggers\ExplorerButton.ahk
#include %A_ScriptDir%\Triggers\ExplorerPathChanged.ahk
#include %A_ScriptDir%\Triggers\ExplorerDoubleClickSpace.ahk
#include %A_ScriptDir%\Triggers\Hotkey.ahk
#include %A_ScriptDir%\Triggers\MenuItem.ahk
#include %A_ScriptDir%\Triggers\OnMessage.ahk
#include %A_ScriptDir%\Triggers\ScreenCorner.ahk
#include %A_ScriptDir%\Triggers\Trigger.ahk
#include %A_ScriptDir%\Triggers\Timer.ahk
#include %A_ScriptDir%\Triggers\WindowActivated.ahk
#include %A_ScriptDir%\Triggers\WindowClosed.ahk
#include %A_ScriptDir%\Triggers\WindowCreated.ahk
#include %A_ScriptDir%\Triggers\WindowStateChange.ahk
#include %A_ScriptDir%\Triggers\7plusStart.ahk

#include %A_ScriptDir%\Conditions\If.ahk
#include %A_ScriptDir%\Conditions\IsDialog.ahk
#include %A_ScriptDir%\Conditions\IsFullScreen.ahk
#include %A_ScriptDir%\Conditions\IsContextMenuActive.ahk
#include %A_ScriptDir%\Conditions\IsDragable.ahk
#include %A_ScriptDir%\Conditions\IsRenaming.ahk
#include %A_ScriptDir%\Conditions\KeyIsDown.ahk
#include %A_ScriptDir%\Conditions\MouseOver.ahk
#include %A_ScriptDir%\Conditions\MouseOverFileList.ahk
#include %A_ScriptDir%\Conditions\MouseOverTaskList.ahk
#include %A_ScriptDir%\Conditions\MouseOverTabButton.ahk
#include %A_ScriptDir%\Conditions\WindowActive.ahk
#include %A_ScriptDir%\Conditions\WindowExists.ahk

#include %A_ScriptDir%\Actions\Accessor.ahk
#include %A_ScriptDir%\Actions\AeroFlip.ahk
#include %A_ScriptDir%\Actions\Autoupdate.ahk
#include %A_ScriptDir%\Actions\Clipboard.ahk
#include %A_ScriptDir%\Actions\Clipmenu.ahk
#include %A_ScriptDir%\Actions\ClipPaste.ahk
#include %A_ScriptDir%\Actions\ControlEvent.ahk
#include %A_ScriptDir%\Actions\ControlTimer.ahk
#include %A_ScriptDir%\Actions\Exit7plus.ahk
#include %A_ScriptDir%\Actions\ExplorerReplaceDialog.ahk
#include %A_ScriptDir%\Actions\FastFoldersClear.ahk
#include %A_ScriptDir%\Actions\FastFoldersMenu.ahk
#include %A_ScriptDir%\Actions\FastFoldersRecall.ahk
#include %A_ScriptDir%\Actions\FastFoldersStore.ahk
#include %A_ScriptDir%\Actions\FileCopy.ahk
#include %A_ScriptDir%\Actions\FileDelete.ahk
#include %A_ScriptDir%\Actions\FileMove.ahk
#include %A_ScriptDir%\Actions\FileWrite.ahk
#include %A_ScriptDir%\Actions\FilterList.ahk
#include %A_ScriptDir%\Actions\FlashingWindows.ahk
#include %A_ScriptDir%\Actions\FlatView.ahk
#include %A_ScriptDir%\Actions\FocusControl.ahk
#include %A_ScriptDir%\Actions\FTPUpload.ahk
#include %A_ScriptDir%\Actions\ImageConverter.ahk
#include %A_ScriptDir%\Actions\ImageUpload.ahk
#include %A_ScriptDir%\Actions\Input.ahk
#include %A_ScriptDir%\Actions\InvertSelection.ahk
#include %A_ScriptDir%\Actions\MergeTabs.ahk
#include %A_ScriptDir%\Actions\Message.ahk
#include %A_ScriptDir%\Actions\MD5Checksum.ahk
#include %A_ScriptDir%\Actions\MouseClick.ahk
#include %A_ScriptDir%\Actions\MouseCloseTab.ahk
#include %A_ScriptDir%\Actions\MouseWindowDrag.ahk
#include %A_ScriptDir%\Actions\MouseWindowResize.ahk
#include %A_ScriptDir%\Actions\NewFile.ahk
#include %A_ScriptDir%\Actions\NewFolder.ahk
#include %A_ScriptDir%\Actions\OpenInNewFolder.ahk
#include %A_ScriptDir%\Actions\PlaySound.ahk
#include %A_ScriptDir%\Actions\Restart7plus.ahk
#include %A_ScriptDir%\Actions\RestoreSelection.ahk
#include %A_ScriptDir%\Actions\Run.ahk
#include %A_ScriptDir%\Actions\RunOrActivate.ahk
#include %A_ScriptDir%\Actions\Screenshot.ahk
#include %A_ScriptDir%\Actions\SelectFiles.ahk
#include %A_ScriptDir%\Actions\SendKeys.ahk
#include %A_ScriptDir%\Actions\SendMessage.ahk
#include %A_ScriptDir%\Actions\SetDirectory.ahk
#include %A_ScriptDir%\Actions\SetWindowTitle.ahk
#include %A_ScriptDir%\Actions\SlideWindowOut.ahk
#include %A_ScriptDir%\Actions\ShortenURL.ahk
#include %A_ScriptDir%\Actions\ShowMenu.ahk
#include %A_ScriptDir%\Actions\ShowSettings.ahk
#include %A_ScriptDir%\Actions\ShutDown.ahk
#include %A_ScriptDir%\Actions\TaskButtonClose.ahk
#include %A_ScriptDir%\Actions\ToggleWallpaper.ahk
#include %A_ScriptDir%\Actions\Tooltip.ahk
#include %A_ScriptDir%\Actions\ViewMode.ahk
#include %A_ScriptDir%\Actions\Volume.ahk
#include %A_ScriptDir%\Actions\Wait.ahk
#include %A_ScriptDir%\Actions\WindowActivate.ahk
#include %A_ScriptDir%\Actions\WindowClose.ahk
#include %A_ScriptDir%\Actions\WindowHide.ahk
#include %A_ScriptDir%\Actions\WindowMove.ahk
#include %A_ScriptDir%\Actions\WindowResize.ahk
#include %A_ScriptDir%\Actions\WindowSendToBottom.ahk
#include %A_ScriptDir%\Actions\WindowShow.ahk
#include %A_ScriptDir%\Actions\WindowState.ahk

#include %A_ScriptDir%\Generic\WindowFilter.ahk
#include %A_ScriptDir%\Generic\FileOperation.ahk

EventSystem_Startup()
{
	global Events, EventSchedule, TemporaryEvents, IniPath, ShowEvents
	
	IniRead, ShowEvents, %IniPath%, General, ShowEvents, 0
	
	;TODO: Why does this need to be here?
	Action_Upload_ReadFTPProfiles()
	
	;Create list object for events
	EventsBase := object("base", Array(), "Categories", Array(), "GlobalPlaceholders", Array(), "HighestID", -1, "CreateEvent", "EventSystem_CreateEvent","RegisterEvent", "EventSystem_RegisterEvent", "Add", "Events_Add", "Delete", "Events_Delete", "SubItem", "Events_SubItem", "indexOfSubItem", "Events_indexOfSubItem")
	Events := object("base", EventsBase)
	
	;Temporary events are not visible in settings GUI and won't be saved. See ControlEvent -> Copy Event for usage example.
	TemporaryEvents := object("base", object("base", Array(), "HighestID", -1, "Add", "Events_Add","RegisterEvent", "EventSystem_RegisterEvent"))
	
	;Create base objects for triggers, conditions and actions
	EventSystem_CreateBaseObjects()
	
	;Event log logs the execution flow of events
	if(DebugEnabled)
		FileDelete, %A_Temp%\7plus\EventLog.log
	
	;Load main events file. This will create event objects for all stored event configs in Events object.
	ReadMainEventsFile()
	
	;EventSchedule (contains copies of the event objects in the Events list ) is a list of events that are currently being processed.
	EventSchedule := Array()
	
	;Make sure the subevents can enabled themselves
	Loop % Events.len()
	{
		Event := Events[A_Index]	
		if(Event.Enabled)
			Event.Enable()
	}
	
	;Trigger events with 7plusStart trigger
	Trigger := EventSystem_CreateSubEvent("Trigger","7plusStart")
	OnTrigger(Trigger)
	
	;If 7plus was started with a commandline parameter through an Explorer Button trigger, process it here.
	if(1 = "-id")
	{
		Trigger := EventSystem_CreateSubEvent("Trigger", "ExplorerButton")
		ID = %2%
		Trigger.ID := ID
		OnTrigger(Trigger)
	}
	
	;Setup the message handler for receiving triggers from other instances of 7plus (and possibly other programs) and from the Shell extension.
	OnMessage(55555, "TriggerFromOtherInstance")
	
	;Setup the message handler for receiving image upload progress notifications
	OnMessage(55556, "Action_ImageUpload_ProgressHandler")
	
	;Make sure that non-elevated processes can send this messages to the elevated 7plus process.
	;Keyword: UIPI
	DllCall("ChangeWindowMessageFilter", "UInt", 55555, "UInt", 1) 
	DllCall("ChangeWindowMessageFilter", "UInt", 55556, "UInt", 1) 
}
TriggerFromOtherInstance(wParam, lParam)
{
	global ContextMenu_EventCount, ContextMenu_ID, Events
	Critical, On
	outputdebug lParam %lParam%
	if(lParam = 0) ;0 = Single trigger from something else than context menus
	{
		Trigger := EventSystem_CreateSubEvent("Trigger", "Trigger")
		Trigger.TargetID := wParam
		OnTrigger(Trigger)
	}
	else if(lParam = 1) ;1 = Trigger from context menu
	{		
		;Read list of selected files written by shell extension
		if(FileExist(A_Temp "\7plus\files.txt"))
			FileRead, files, % "*t " A_Temp "\7plus\files.txt"
		outputdebug files %files%
		FileDelete, % A_Temp "\7plus\files.txt"
		;if it failed (because static context menu is used), try to get it from explorer window
		Events.GlobalPlaceholders.Context := files ? files : ArrayToList(GetSelectedFiles())
		
		Trigger := EventSystem_CreateSubEvent("Trigger", "Trigger")
		Trigger.TargetID := wParam
		OnTrigger(Trigger)
	}
	Critical, Off
}
;Creates an event and registers it for lEvents list (-->Assigns an ID that is based on the max ID of the default Events list and its settings copy, and increases HighestID count of lEvents and adds it to lEvents)
EventSystem_RegisterEvent(lEvents, Event = "", Enable = 1)
{
	global EventBase, Events, Settings_Events, TemporaryEvents
	;Temporary events use negative ID for find functions
	if(lEvents = TemporaryEvents)
		HighestID := TemporaryEvents.HighestID - 1
	else
		HighestID := max(Events.HighestID, Settings_Events.HighestID) + 1 ;Make sure highest ID is used from both event arrays
	lEvents.HighestID := HighestID	
	if(!IsObject(Event))
		Event := EventSystem_CreateEvent()
	Event.ID := HighestID
	lEvents.Add(Event)
	if(Enable)
		Event.SetEnabled(true)
	return Event
}
EventSystem_CreateEvent()
{
	global EventBase
	Event := Object("base",EventBase.DeepCopy()) ;Need to use base to make functions work
	Event.ID := -1
	Event.Name := "New event"
	Event.Category := "Uncategorized"
	Event.Enabled := 1
	Event.EventComplexityLevel := 0
	Event.OneInstance := 0
	Event.DeleteAfterUse := 0
	Event.DisableAfterUse := 0
	Event.Trigger := EventSystem_CreateSubEvent("Trigger", "Hotkey")
	Event.Conditions := Array()
	Event.Actions := Array()
	Event.PlaceHolders := object()
	return Event
}
EventSystem_CreateBaseObjects()
{
	global
	local tmpobject
	EventSystem_Triggers := "ContextMenu,DoubleClickDesktop,DoubleClickTaskbar,ExplorerButton,ExplorerDoubleClickSpace,ExplorerPathChanged,Hotkey,None,MenuItem,OnMessage,ScreenCorner,Timer,Trigger,WindowActivated, WindowClosed, WindowCreated,WindowStateChange,7plusStart"
	EventSystem_Conditions := "If,IsContextMenuActive,IsDialog,IsDragable,IsFullScreen,KeyIsDown,IsRenaming,MouseOver,MouseOverFileList,MouseOverTabButton,MouseOverTaskList,WindowActive,WindowExists"
	EventSystem_Actions := "Accessor,AutoUpdate,Clipboard,Clipmenu,ClipPaste,ControlEvent,ControlTimer,Copy,Delete,ExplorerReplaceDialog,Exit7plus,FastFoldersClear,FastFoldersMenu,FastFoldersRecall,FastFoldersStore,FilterList,FlashingWindows,FlatView,FocusControl,ImageConverter,ImageUpload,Input,InvertSelection,MD5,MergeTabs,Message,Move,MouseClick,MouseCloseTab,MouseWindowDrag,MouseWindowResize,NewFile,NewFolder,OpenInNewFolder,PlaySound,Restart7plus,RestoreSelection,Run,RunOrActivate,Screenshot,SelectFiles,SetWindowTitle,SendKeys,SendMessage,SetDirectory,SlideWindowOut,ShortenURL,ShowAeroFlip,ShowMenu,ShowSettings,Shutdown,TaskButtonClose,ToggleWallpaper,Tooltip,Upload,ViewMode,Volume,Wait,WindowActivate,WindowClose,WindowHide,WindowMove,WindowResize,WindowSendToBottom,WindowShow,WindowState,Write"
	Trigger_Categories := object("Explorer", Array(), "Hotkeys", Array(), "Other", Array(), "System", Array(), "Window", Array(), "7plus", Array())
	Condition_Categories := object("Explorer", Array(), "Mouse", Array(), "Other", Array(), "Window", Array())
	Action_Categories := object("Explorer", Array(), "FastFolders", Array(), "File", Array(), "Window", Array(), "Input", Array(), "System", Array(), "7plus", Array(), "Other", Array())
	
	Loop, Parse, EventSystem_Triggers, `,,%A_Space%
	{		
		tmpobject := RichObject()
		tmpobject.Init := "Trigger_" A_LoopField "_Init"
		tmpobject.ReadXML := "Trigger_" A_LoopField "_ReadXML"
		tmpobject.Enable := "Trigger_" A_LoopField "_Enable"
		tmpobject.Disable := "Trigger_" A_LoopField "_Disable"
		tmpobject.Matches := "Trigger_" A_LoopField "_Matches"
		tmpobject.DisplayString := "Trigger_" A_LoopField "_DisplayString"
		tmpobject.GuiShow := "Trigger_" A_LoopField "_GuiShow"
		tmpobject.GuiSubmit := "Trigger_" A_LoopField "_GuiSubmit"
		tmpobject.Delete := "Trigger_" A_LoopField "_Delete"
		tmpobject.PrepareCopy := "Trigger_" A_LoopField "_PrepareCopy"
		tmpobject.PrepareReplacement := "Trigger_" A_LoopField "_PrepareReplacement"
		tmpobject.OnExit := "Trigger_" A_LoopField "_OnExit"
		Trigger_%A_LoopField%_Base := object("base",tmpobject)	
		Trigger_%A_LoopField%_Base.Type := A_LoopField
		Trigger_%A_LoopField%_Init(Trigger_%A_LoopField%_Base)	
		;Add type to category
		Trigger_Categories[Trigger_%A_LoopField%_Base.Category].append(Trigger_%A_LoopField%_Base.Type)
	
		;Trigger_%A_LoopField%_Base := tmpobject.DeepCopy()
	}
	
	Loop, Parse, EventSystem_Conditions, `,,%A_Space%
	{		
		tmpobject := RichObject()
		tmpobject.Init := "Condition_" A_LoopField "_Init"
		tmpobject.ReadXML := "Condition_" A_LoopField "_ReadXML"
		tmpobject.Evaluate := "Condition_" A_LoopField "_Evaluate"
		tmpobject.DisplayString := "Condition_" A_LoopField "_DisplayString"
		tmpobject.GuiShow := "Condition_" A_LoopField "_GuiShow"
		tmpobject.GuiSubmit := "Condition_" A_LoopField "_GuiSubmit"
		Condition_%A_LoopField%_Base := object("base",tmpobject) ;.DeepCopy()
		Condition_%A_LoopField%_Base.Type := A_LoopField
		Condition_%A_LoopField%_Init(Condition_%A_LoopField%_Base)
		;Add type to category
		Condition_Categories[Condition_%A_LoopField%_Base.Category].append(Condition_%A_LoopField%_Base.Type)
	}
	Loop, Parse, EventSystem_Actions, `,,%A_Space%
	{
		tmpobject := RichObject()
		tmpobject.Init := "Action_" A_LoopField "_Init"
		tmpobject.ReadXML := "Action_" A_LoopField "_ReadXML"
		tmpobject.Execute := "Action_" A_LoopField "_Execute"
		tmpobject.DisplayString := "Action_" A_LoopField "_DisplayString"
		tmpobject.GuiShow := "Action_" A_LoopField "_GuiShow"
		tmpobject.GuiSubmit := "Action_" A_LoopField "_GuiSubmit"
		tmpobject.OnExit := "Action_" A_LoopField "_OnExit"
		Action_%A_LoopField%_Base := object("base", tmpobject) ;.DeepCopy()
		Action_%A_LoopField%_Base.Type := A_LoopField
		Action_%A_LoopField%_Init(Action_%A_LoopField%_Base)
		;Add type to category
		Action_Categories[Action_%A_LoopField%_Base.Category].append(Action_%A_LoopField%_Base.Type)
	}
	EventBase := RichObject()
	EventBase.Enable := "Event_Enable"
	EventBase.Disable := "Event_Disable"
	EventBase.Delete := "Event_Delete"
	EventBase.ExpandPlaceHolders := "Event_ExpandPlaceholders"
	EventBase.SetEnabled := "Event_SetEnabled"
	EventBase.ApplyPatch := "Event_ApplyPatch"
}

EventSystem_End()
{
	global Events, TemporaryEvents
	WriteMainEventsFile()
	Loop % Events.len()
	{
		Event := Events[A_Index]
		Event.Trigger.OnExit()
		Loop % Event.Actions.len()
			Event.Actions[A_Index].OnExit()
	}
	Loop % TemporaryEvents.len()
	{
		Event := TemporaryEvents[A_Index]
		Event.Trigger.OnExit()
		Loop % Event.Actions.len()
			Event.Actions[A_Index].OnExit()
	}
}

EventSystem_CreateSubEvent(Category,Type)
{
	global
	local tmp
	tmp := %Category%_%Type%_Base
	copy := tmp.DeepCopy()
	copy.Init()
	return copy ;Object("base", %tmp%, "Type", Type)
}

ReadMainEventsFile()
{
	global ConfigPath, Events
	ReadEvents := ReadEventsFile(Events, ConfigPath "\Events.xml")
}	

WriteMainEventsFile()
{
	global ConfigPath, Events
	WriteEventsFile(Events, ConfigPath "\Events.xml")
}

ReadEventsFile(Events, path,OverwriteCategory="", Update="")
{
	global MajorVersion, MinorVersion, BugfixVersion, PatchVersion, XMLMajorVersion, XMLMinorVersion, XMLBugfixVersion, ConfigPath, Debug
	FileRead, xml, %path%
	XMLObject := XML_Read(xml)
	XMLMajorVersion := XMLObject.MajorVersion
	XMLMinorVersion := XMLObject.MinorVersion
	XMLBugfixVersion := XMLObject.BugfixVersion
	if(CompareVersion(XMLMajorVersion,MajorVersion,XMLMinorVersion,MinorVersion,XMLBugfixVersion,BugfixVersion) > 0)
		Msgbox Events file was made with a newer version of 7plus. Compatibility is not guaranteed. Please update, or use at own risk!
	
	if(Update)
		Update.Message := Update.Message (XMLObject.Message? "`n" XMLObject.Message : "")
	if(path = ConfigPath "\Events.xml") ;main config file, read patch version
		PatchVersion := XMLObject.PatchVersion ? XMLObject.PatchVersion : 0
	
	count := Events.len()
	lowestID := 999999999999
	HighestID := Events.HighestID
	len := max(XMLObject.Events.Event.len(), XMLObject.Events.HasKey("Event"))
	Loop % len
	{
		i := A_Index
		;Check if end of Events is reached
		if(len = 1)
			XMLEvent := XMLObject.Events.Event
		else
			XMLEvent := XMLObject.Events.Event[i]
		
		if(!XMLEvent)
			continue
		
		;Create new Event
		Event := EventSystem_CreateEvent()
		
		;Event ID
		if(XMLEvent.HasKey("ID"))
		{
			Event.ID := XMLEvent.ID
			if(Event.ID < lowestID)
				lowestID := Event.ID
		}
		else
			Event.Remove("ID")
		
		;Event Name
		if(XMLEvent.HasKey("Name"))
			Event.Name := XMLEvent.Name
		else
			Event.Remove("Name")
		
		;Event Description
		if(XMLEvent.HasKey("Description"))
			Event.Description := XMLEvent.Description
		else
			Event.Remove("Description")
		
		;Event Category
		if(XMLEvent.HasKey("Category") || OverwriteCategory)
		{
			Event.Category := OverwriteCategory ? OverwriteCategory : XMLEvent.Category ? XMLEvent.Category : "Uncategorized"
		
			if(!Events.Categories.indexOf(Event.Category))
				Events.Categories.append(Event.Category)
		}
		else
			Event.Remove("Category")
		
		;Event state
		if(XMLEvent.HasKey("Enabled"))
			Event.Enabled := XMLEvent.Enabled
		else
			Event.Remove("Enabled")
			
		;Disable after use
		if(XMLEvent.HasKey("DisableAfterUse"))
			Event.DisableAfterUse := XMLEvent.DisableAfterUse
		else
			Event.Remove("DisableAfterUse")
		
		;Delete after use
		if(XMLEvent.HasKey("DeleteAfterUse"))
			Event.DeleteAfterUse := XMLEvent.DeleteAfterUse
		else
			Event.Remove("DeleteAfterUse")
		
		;One Instance
		if(XMLEvent.HasKey("OneInstance"))
			Event.OneInstance := XMLEvent.OneInstance
		else
			Event.Remove("OneInstance")+
		
		;Official event identifier for update processes
		if(XMLEvent.HasKey("OfficialEvent"))
			Event.OfficialEvent := XMLEvent.OfficialEvent
		
		;Complexity level indicates if an event may be hidden from the user to avoid confusion(1) or if it is always shown(0)
		if(XMLEvent.HasKey("EventComplexityLevel"))
			Event.EventComplexityLevel := XMLEvent.EventComplexityLevel
		else
			Event.Remove("EventComplexityLevel")
		
		;Read trigger values
		if(XMLEvent.HasKey("Trigger"))
		{			
			Event.Trigger := EventSystem_CreateSubEvent("Trigger", XMLEvent.Trigger.Type)
			Event.Trigger.ReadXML(XMLEvent.Trigger)
		}
		else
			Event.Remove("Trigger")
		
		;Read conditions
		if(XMLEvent.Conditions.HasKey("Condition") && !IsFunc(XMLEvent.Conditions.Condition.len)) ;Single condition
		{
			XMLConditions := Array()
			XMLConditions.append(XMLEvent.Conditions.Condition)
			XMLEvent.Conditions.Condition := XMLConditions
		}
		
		Loop % XMLEvent.Conditions.Condition.len()
		{
			j := A_Index
			
			;Check if end of Events is reached
			XMLCondition := XMLEvent.Conditions.Condition[j]
			if(!XMLCondition)
				break
			;Create new cndition
			Condition := EventSystem_CreateSubEvent("Condition", XMLCondition.Type)
			
			;Read Negation
			Condition.Negate := XMLCondition.Negate
			
			;Read condition values
			Condition.ReadXML(XMLCondition)
						
			Event.Conditions.append(Condition)
		}
		
		;Read actions
		if(XMLEvent.Actions.HasKey("Action") && !IsFunc(XMLEvent.Actions.Action.len)) ;Single Action
		{
			XMLActions := Array()
			XMLActions.append(XMLEvent.Actions.Action)
			XMLEvent.Actions.Action := XMLActions
		}
		
		Loop % XMLEvent.Actions.Action.len()
		{
			j := A_Index
			
			;Check if end of Events is reached
			XMLAction := XMLEvent.Actions.Action[j]
			if(!XMLAction)
				break
			;Create new action
			Action := EventSystem_CreateSubEvent("Action", XMLAction.Type)
			
			;Read action values
			Action.ReadXML(XMLAction)
						
			Event.Actions.append(Action)
		}
		
		if(Event.HasKey("OfficialEvent") && (OldEvent := Events.SubItem("OfficialEvent", Event.OfficialEvent))) ;If an official event already exists, apply this as patch
		{			
			if(!XMLEvent.HasKey("Conditions"))
				Event.Remove("Conditions")
			if(!XMLEvent.HasKey("Actions"))
				Event.Remove("Actions")
			Event.Remove("PlaceHolders")
			OldEvent.ApplyPatch(Event) ;No update messages are generated here, those are handled manually
		}
		else if(!Event.PatchOnly)
		{
			if(Update)
				Update.Message := Update.Message "`n- Added Event: " Event.Name
			Events.append(Event)
		}
	}
	;fix IDs from import
	;Loop over all new events
	pos := count + 1
	count := Events.len()
	Loop
	{
		if(pos > count)
			break
		Event := Events[pos]
		;Make sure Event ID is higher than all previous IDs, but conserve relative differences between IDs
		offset := (highestID - lowestID) + 1
		Event.ID := Event.ID + offset
		
		;Find highest ID
		if(Event.ID > Events.HighestID)
			Events.HighestID := Event.ID
		
		;Now adjust Event ID references
		enum := Event.Trigger._newEnum()
		while enum[k,v]
		{
			if(strEndsWith(k, "ID") && IsNumeric(v))
				Event.Trigger[k] := Event.Trigger[k] + offset
		}
		Loop % Event.Conditions.len()
		{
			enum := Event.Conditions[A_Index]._newEnum()
			Condition := Event.Conditions[A_Index]
			while enum[k,v]
			{
				if(strEndsWith(k, "ID") && IsNumeric(v))
					Condition[k] := Condition[k] + offset
			}
		}
		Loop % Event.Actions.len()
		{
			enum := Event.Actions[A_Index]._newEnum()
			Action := Event.Actions[A_Index]
			while enum[k,v]
			{
				if(strEndsWith(k, "ID") && IsNumeric(v))
					Action[k] := Action[k] + offset
			}
		}
		pos++
	}
	if(XMLObject.HasKey("Remove")) ;If Objects are to be removed
	{
		len := max(XMLObject.Remove.OfficialEvent.len(), XMLObject.Remove.HasKey("OfficialEvent"))
		Loop % len
		{
			i := A_Index
			;Check if end of Events is reached
			if(len = 1)
				OfficialEvent := XMLObject.Remove.OfficialEvent
			else
				OfficialEvent := XMLObject.Remove.OfficialEvent[i]
			
			if(!OfficialEvent)
				continue
			
			if((Index := Events.indexOfSubItem("OfficialEvent", OfficialEvent)))
			{
				if(Update) ;Should be true if we are here
					Update.Message := Update.Message "`n- Removed Event: " Events[index].Name
				Events.Delete(Events[index], false)
			}
		}
	}
	return Events
}


WriteEventsFile(Events, path)
{
	global MajorVersion, MinorVersion, BugfixVersion, PatchVersion, ConfigPath
	; return
	;Create Events node
	xmlObject := Object()
	xmlObject.MajorVersion := MajorVersion
	xmlObject.MinorVersion := MinorVersion
	xmlObject.BugfixVersion := BugfixVersion
	if(path = ConfigPath "\Events.xml")
		xmlObject.PatchVersion := PatchVersion
	xmlObject.Events := Object()
	xmlEvents := Array()
	xmlObject.Events.Event := xmlEvents
	;Write Events entries
	Loop % Events.len()
	{
		xmlEvent := Object()
		xmlEvents.append(xmlEvent)
		i := A_Index
		Event := Events[i]
		
		;Don't save temporary events that are only used during runtime
		if(Event.Temporary)
			continue
		
		;Write ID
		xmlEvent.ID := Event.ID
		
		;Write name
		xmlEvent.Name := Event.Name
		
		;Write description
		xmlEvent.Description := Event.Description
		
		;Write category
		xmlEvent.Category := Event.Category
		
		;Write state
		xmlEvent.Enabled := Event.Enabled
		
		;Disable after use
		xmlEvent.DisableAfterUse := Event.DisableAfterUse
		
		;Delete after use
		xmlEvent.DeleteAfterUse := Event.DeleteAfterUse
		
		;One Instance
		xmlEvent.OneInstance := Event.OneInstance
		
		;Complexity level
		xmlEvent.EventComplexityLevel := Event.EventComplexityLevel
		
		if(Event.Officialevent)
			xmlEvent.OfficialEvent := Event.OfficialEvent
		
		
		;Uncomment the lines below to save events with an "official" tag that allows to identify them in update processes
		; if(!Event.OfficialEvent) ;Find an unused Event ID to be used as Official Event ID
		; {			
			; Loop
			; {
				; if(Events.IndexOfSubItem("OfficialEvent", A_Index))
					; continue ;Alread in use
				; xmlEvent.OfficialEvent := A_Index ;Not used
				; Event.OfficialEvent := A_Index
				; break
			; }
		; }
		
		
		xmlTrigger := Object()
		xmlEvent.Trigger := xmlTrigger
		xmlTrigger.Type := Event.Trigger.Type
		enum := Event.Trigger._newEnum()
		while enum[key,value]
		{
			if(key = "Category" || strStartsWith(key, "tmp"))
				continue				
			xmlTrigger[key] := value
		}
		
		;Since some triggers might have to do special preprocessing, lets allow them to overwrite the values read above
		;Event.Trigger.WriteXML(EventsFileHandle, "/Events/Event[" i "]/Trigger/")
		
		;Write Conditions
		xmlEvent.Conditions := Object()
		xmlConditions := Array()
		xmlEvent.Conditions.Condition := xmlConditions
		Loop % Event.Conditions.len()
		{
			j := A_Index
			Condition := Event.Conditions[j]
			xmlCondition := Object()
			xmlConditions.append(xmlCondition)
			
			;Write condition type, since it's stored in base object, and isn't iterated below
			xmlCondition.Type := Condition.Type
			
			enum := Condition._newEnum()
			while enum[key,value]
			{
				if(key = "Category" || strStartsWith(key, "tmp"))
					continue
				xmlCondition[key] := value
			}
			
			;Since some triggers might have to do special preprocessing, lets allow them to overwrite the values read above
			;Condition.WriteXML(EventsFileHandle, "/Events/Event[" i "]/Conditions/Condition[" j "]/")
		}
		xmlEvent.Actions := Object()
		xmlActions := Array()
		xmlEvent.Actions.Action := xmlActions
		Loop % Event.Actions.len()
		{
			j := A_Index
			Action := Event.Actions[j]
			xmlAction := Object()
			xmlActions.append(xmlAction)
			
			;Write action type, since it's stored in base object, and isn't iterated below
			xmlAction.Type := Action.Type
			
			enum := Action._newEnum()
			while enum[key,value]
			{
				if(key = "Category" || strStartsWith(key, "tmp"))
					continue
				xmlAction[key] := value
			}
		}
	}
	XML_Save(xmlObject, Path)
	return
}

;This function is called when a trigger event is received. Trigger contains information about 
OnTrigger(Trigger)
{
	global Events,EventSchedule, TemporaryEvents
	;Find matching triggers
	Loop % Events.len()
		TriggerSingleEvent(Events[A_Index], Trigger)
	Loop % TemporaryEvents.len()	
		TriggerSingleEvent(TemporaryEvents[A_Index], Trigger)
	return
}
;Tests if an event matches to a trigger and may be appended to event schedule (and appends it)
;This function can also be used to specifically trigger a single event
;To just trigger it without performing trigger matching, leave Trigger Parameter empty
TriggerSingleEvent(Event, Trigger="")
{
	global EventSchedule
	;Order of this if condition is important here, because Event.Trigger.Matches() can disable the event for timers
	if(Event.Enabled && (!IsObject(Trigger) || (Event.Trigger.Type = Trigger.Type && Event.Trigger.Matches(Trigger, Event)) || (Trigger.Type = "Trigger" && Event.ID = Trigger.TargetID)))
	{
		;Test if the event is already running and mustn't be run multiple times
		if(!Event.OneInstance || !EventSchedule.IndexOfSubItem("ID", Event.ID))
			EventSchedule.append(Event.DeepCopy())
	}
	return
}
EventScheduler:
SetTimer, EventScheduler, Off
EventScheduler()
SetTimer, EventScheduler, 100
return
EventScheduler()
{
	global Events, EventSchedule, Profiler, TemporaryEvents, DebugEnabled, ShowEvents
	Critical, Off
	; loop
	; {
		StartTime := A_TickCount
		;First, check the conditions of all events in the queue to make sure an event can't influence the result of a condition check of another event.
		EventPos := 1
		Loop % EventSchedule.len()
		{			
			Event := EventSchedule[EventPos]
			index := Events.indexOfSubItem("ID", Event.ID) ;Will return the index of the event in Events or TemporaryEvents
			OriginalEvent := Event.ID < 0 ? TemporaryEvents[index] : Events[index]
			;Check conditions
			if(Event.Conditions.Success != 1) ;Check if conditions have been evaluated before
			{
				Success := (!index && Event.Enabled) || OriginalEvent.Enabled || Event.Trigger.Type = "Timer" ;Check enabled state again here, because it might have changed since it was appended to queue
				ConditionPos := 1
				if(Success)
				{
					Loop % Event.Conditions.len()
					{
						result := Event.Conditions[ConditionPos].Evaluate(Event)
						if( result = -1) ;Not decided yet, check later
						{
							Success := -1
							break
						}
						else if(Event.Conditions[ConditionPos].Negate) ;Result is 0 or 1 before, now invert it
						{
							result := 1 - result
						}
						if(result = 0) ;Condition did not match
						{
							if(DebugEnabled)
								EventLog(Event.ID ": Condition " ConditionPos ": " Event.Conditions[ConditionPos].Type " was not fulfilled.")
							Success := 0
							break
						}
						else if(result = 1) ;This condition was fulfilled, remove it from conditions
						{
							Event.Conditions.Delete(ConditionPos)
							continue
						}
						ConditionPos++
					}
				}
				else
					outputdebug % "event disabled while in queue: ID:" Event.ID " Name: " event.name
				if(Success = 0) ;Condition was not fulfilled, remove this event
				{
					EventSchedule.Delete(EventPos)
					outputdebug % "Conditions of event " event.id " were not fulfilled."
					continue
				}
				else
					Event.Conditions.Result := 1 ;Set result so conditions don't have to be checked again when this event has a waiting action.
			}
			EventPos++
		}
		
		;Now the event queue contains only those events which passed the condition check. These can be processed now.
		EventPos := 1
		Loop % EventSchedule.len()
		{
			Event := EventSchedule[EventPos]
			outputdebug % "Process event ID: " Event.ID " Name: " Event.Name
			if(DebugEnabled)
				EventLog("Process event ID: " Event.ID " Name: " Event.Name)
			; outputdebug conditions fulfilled
			Loop % Event.Actions.len()
			{
				index := Events.indexOfSubItem("ID", Event.ID) ;Will return the index of the event in Events or TemporaryEvents
				OriginalEvent := Event.ID < 0 ? TemporaryEvents[index] : Events[index]
				if(index && !OriginalEvent.Enabled && Event.Trigger.Type != "Timer") ;Check enabled state again here, because it might have changed since in one of the previous actions during waiting
				{
					outputdebug % "disable " Event.ID " during execution"
					Event.Actions := Array()
					break
				}
				; outputdebug % "perform " Event.Actions[1].DisplayString()
				result := Event.Actions[1].Execute(Event)
				if(result = 0) ;Action was cancelled, stop all further actions
				{
					Event.Actions := Array()
					if(ShowEvents)
						Notify("Event Cancelled", "The execution of event" Event.ID ": " Event.Name " was cancelled", "5", "GC=555555 TC=White MC=White",24)
					break
				}
				else if(result = -1) ;Action needs more time to finish, check back in next main loop
					break
				else
					Event.Actions.Delete(1)
				if(ShowEvents)
					Notify("Event Executed", "The event" Event.ID ": " Event.Name " was executed", "5", "GC=555555 TC=White MC=White",24)
			}
			if(Event.Actions.len() = 0) ;No more actions in this event, consider it processed and remove it from queue
			{
				EventSchedule.Delete(EventPos)
				index := Events.indexOfSubItem("ID", Event.ID) ;Will return the index of the event in Events or TemporaryEvents
				OriginalEvent := Event.ID < 0 ? TemporaryEvents[index] : Events[index]
				if(Event.DisableAfterUse && index)
					OriginalEvent.SetEnabled(false)
				if(Event.DeleteAfterUse && index)
					Events.Delete(OriginalEvent)
				outputdebug % "Finished execution of event ID: " event.id " Name:" event.name
				continue
			}
			EventPos++
		}
		Profiler.Total.EventLoop := Profiler.Total.EventLoop + A_TickCount - StartTime
		Profiler.Current.EventLoop := Profiler.Current.EventLoop + A_TickCount - StartTime
		; Sleep 100
	; }
}

EventLog(text)
{
	FileAppend, %A_Now%: %text%`n, %A_Temp%\7plus\EventLog.log
}

;Finds the event and action of a running event of specified type by its gui number
;This function assumes that the gui number is stored as "tmpGUINum" in the action of the specified type.
;The action should remove the value after it has finished so the gui number may be used again by other actions in this event.
EventFromGUINumber(number, type, ByRef Event, ByRef Action)
{
	global EventSchedule
	Loop % EventSchedule.len()
	{
		pos := A_Index
		Loop % EventSchedule[pos].Actions.len()
		{
			if(EventSchedule[pos].Actions[A_Index].Type = type && EventSchedule[pos].Actions[A_Index].tmpGUINum = number)
			{
				Event := EventSchedule[pos]
				Action := EventSchedule[pos].Actions[A_Index]
				return EventSchedule[pos]
			}
		}
	}
	return 0
}
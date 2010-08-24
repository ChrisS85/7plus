EventSystem_Startup()
{
	global Events, EventSchedule
	EventsBase := object("base",Array(), "HighestID", -1, "CreateEvent", "EventSystem_CreateEvent", "FindID", "Events_FindID", "Add", "Events_Add", "Remove", "Events_Remove")
	Events := object("base", EventsBase)
	EventSystem_CreateBaseObjects()
	
	ReadMainEventsFile()
	EventSchedule := Array()
	Loop % Events.len()
	{
		Event := Events[A_Index]	
		if(Event.Enabled)
			Event.Enable()
	}
	Trigger := EventSystem_CreateSubEvent("Trigger","7plusStart")
	OnTrigger(Trigger)
	EventScheduler()
}

Events_FindID(Events,ID)
{
	Loop % Events.len()
		if(Events[A_Index].ID = ID)
			return A_Index
	return 0
}

;Enabled state needs to be set through this function, to allow syncing with settings window
Event_SetEnabled(Event,Value) 
{
	global Events, Settings_Events, SettingsActive
	Event.Enabled := Value
	if(SettingsActive && Settings_Events && Events[Events.FindID(Event.ID)]) ;if settings are open and updating a regular event, update its counterpart in settings_events
	{	
		Settings_Events[Settings_Events.FindID(Event.ID)].Enabled := Value
		Settings_SetupEvents()
	}
}

;This function needs to be used to add events, to allow syncing with settings window
Events_Add(Events, Event) 
{
	global Settings_Events
	outputdebug addEvent()
	Events.append(Event)
	if(Settings_Events && Events != Settings_Events)
	{
		outputdebug add event to settings
		Settings_Events.append(Event.DeepCopy())
		Settings_SetupEvents()
	}
}

;This function needs to be used to remove events, to allow syncing with settings window
Events_Remove(Events, Event) 
{
	global Settings_Events
	Events.Delete(Events.FindID(Event.ID))
	Events[Events.FindID(Event.ID)].Delete()
	if(Settings_Events && Events != Settings_Events)
	{
		Settings_Events.Delete(Settings_Events.FindID(Event.ID))
		Settings_SetupEvents()
	}
}

EventSystem_CreateEvent(lEvents)
{
	global EventBase, Events, Settings_Events
	outputdebug createevent()
	HighestID := max(Events.HighestID, Settings_Events.HighestID) + 1 ;Make sure highest ID is used from both event arrays
	lEvents.HighestID := HighestID
	Event := Object("base",EventBase.DeepCopy()) ;Need to use base to make functions work
	Event.ID := HighestID
	lEvents.Add(Event)
	Event.SetEnabled(true)
	return Event
}
EventSystem_CreateBaseObjects()
{
	global
	local tmpobject
	EventSystem_Triggers := "DoubleClickDesktop,DoubleClickTaskbar,ExplorerDoubleClickSpace,ExplorerPathChanged,Hotkey,None,OnMessage,Timer,Trigger,WindowActivated, WindowClosed, WindowCreated,WindowStateChange,7plusStart"
	EventSystem_Conditions := "MouseOver,If,IsContextMenuActive,IsDialog,IsFullScreen,KeyIsDown,IsRenaming,WindowActive,WindowExists"
	EventSystem_Actions := "AutoUpdate,Clipboard,Clipmenu,ControlEvent,ControlTimer,Copy,Delete,Exit7plus,FastFoldersClear,FastFoldersMenu,FastFoldersRecall,FastFoldersStore,FilterList,FlashingWindows,FocusControl,SetWindowTitle, Input,Message,MinimizeToTray,Move,MouseClick,NewFile,NewFolder,PlaySound,Restart7plus,Run,Screenshot,SelectFiles,SendKeys,SendMessage,SetDirectory,ShowSettings,Shutdown,Tooltip,Upload,Volume,WindowActivate,WindowClose,WindowHide,WindowMove,WindowResize,WindowShow,WindowState,Write"
	Trigger_Categories := object("Explorer", Array(), "Hotkeys", Array(), "Other", Array(), "System", Array(), "Window", Array(), "7plus", Array())
	Condition_Categories := object("Explorer", Array(), "Mouse", Array(), "Other", Array(), "Window", Array())
	Action_Categories := object("Explorer", Array(), "FastFolders", Array(), "File", Array(), "Window", Array(), "Input", Array(), "System", Array(), "7plus", Array(), "Other", Array())
	
	Loop, Parse, EventSystem_Triggers, `,,%A_Space%
	{		
		tmpobject := RichObject()
		tmpobject.Type := A_LoopField
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
		Trigger_%A_LoopField%_Init(tmpobject)
		Trigger_%A_LoopField%_Base := object("base",tmpobject)		
		;Add type to category
		Trigger_Categories[tmpobject.Category].append(tmpobject.Type)
	
		;Trigger_%A_LoopField%_Base := tmpobject.DeepCopy()
	}
	
	Loop, Parse, EventSystem_Conditions, `,,%A_Space%
	{		
		tmpobject := RichObject()
		tmpobject.Type := A_LoopField
		tmpobject.Init := "Condition_" A_LoopField "_Init"
		tmpobject.ReadXML := "Condition_" A_LoopField "_ReadXML"
		tmpobject.Evaluate := "Condition_" A_LoopField "_Evaluate"
		tmpobject.DisplayString := "Condition_" A_LoopField "_DisplayString"
		tmpobject.GuiShow := "Condition_" A_LoopField "_GuiShow"
		tmpobject.GuiSubmit := "Condition_" A_LoopField "_GuiSubmit"
		Condition_%A_LoopField%_Init(tmpobject)
		Condition_%A_LoopField%_Base := object("base",tmpobject) ;.DeepCopy()
		;Add type to category
		Condition_Categories[tmpobject.Category].append(tmpobject.Type)
	}
	Loop, Parse, EventSystem_Actions, `,,%A_Space%
	{
		tmpobject := RichObject()
		tmpobject.Type := A_LoopField
		tmpobject.Init := "Action_" A_LoopField "_Init"
		tmpobject.ReadXML := "Action_" A_LoopField "_ReadXML"
		tmpobject.Execute := "Action_" A_LoopField "_Execute"
		tmpobject.DisplayString := "Action_" A_LoopField "_DisplayString"
		tmpobject.GuiShow := "Action_" A_LoopField "_GuiShow"
		tmpobject.GuiSubmit := "Action_" A_LoopField "_GuiSubmit"
		Action_%A_LoopField%_Init(tmpobject)
		Action_%A_LoopField%_Base := object("base", tmpobject) ;.DeepCopy()
		;Add type to category
		Action_Categories[tmpobject.Category].append(tmpobject.Type)
	}
	EventBase := RichObject()
	EventBase.ID := -1
	EventBase.Name := "New event"
	EventBase.Enabled := 1
	EventBase.Enable := "Event_Enable"
	EventBase.Disable := "Event_Disable"
	EventBase.Delete := "Event_Delete"
	EventBase.ExpandPlaceHolders := "Event_ExpandPlaceholders"
	EventBase.SetEnabled := "Event_SetEnabled"
	EventBase.PlaceHolders := object()
	EventBase.Trigger := EventSystem_CreateSubEvent("Trigger", "Hotkey")
	EventBase.Conditions := Array()
	EventBase.Actions := Array()
}
Event_Delete(Event)
{
	Event.Trigger.Delete(Event)
}
EventSystem_End()
{
	WriteMainEventsFile()
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
Event_Enable(Event)
{
	Event.SetEnabled(true)
	Event.Trigger.Enable(Event)
}

Event_Disable(Event)
{
	Event.SetEnabled(false)
	Event.Trigger.Disable(Event)
}

ReadMainEventsFile()
{
	global ConfigPath, Events
	;Event file is in same dir as settings.ini
	SplitPath, ConfigPath,,path
	path .= "\Events.xml"	
	ReadEvents := ReadEventsFile(Events, path)
}	

WriteMainEventsFile()
{
	global ConfigPath, Events
	;Events file is in same dir as settings.ini
	SplitPath, ConfigPath,,path
	path .= "\Events.xml"	;TODO: Save to different file during development
	WriteEventsFile(Events, path)
}

ReadEventsFile(Events, path)
{
	global EventBase, MajorVersion, MinorVersion, BugfixVersion
	FileRead, xml, %path%
	XMLObject := XML_Read(xml)
	Major := XMLObject.MajorVersion
	Minor := XMLObject.MinorVersion
	Bugfix := XMLObject.BugfixVersion
	if(CompareVersion(major,MajorVersion,minor,MinorVersion,bugfix,BugfixVersion) > 0)
		Msgbox Events file was made with a newer version of 7plus. Compatibility is not guaranteed. Please update, or use at own risk!
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
		{
			msgbox event break
			break
		}
		;Create new Event
		Event := Object("base",EventBase.DeepCopy())
		
		;Event ID
		Event.ID := XMLEvent.ID
		if(Event.ID < lowestID)
			lowestID := Event.ID
		;Event Name
		Event.Name := XMLEvent.Name
		
		;Event state
		Event.Enabled := XMLEvent.Enabled
		
		;Disable after use
		Event.DisableAfterUse := XMLEvent.DisableAfterUse
		
		;Delete after use
		Event.DeleteAfterUse := XMLEvent.DeleteAfterUse
		
		;One Instance
		Event.OneInstance := XMLEvent.OneInstance
		
		;Read trigger values
		Event.Trigger := EventSystem_CreateSubEvent("Trigger", XMLEvent.Trigger.Type)
		Event.Trigger.ReadXML(XMLEvent.Trigger)
		
		;Read conditions
		if(!IsFunc(XMLEvent.Conditions.Condition.len) && XMLEvent.Conditions.HasKey("Condition"))
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
			{
				msgbox condition break
				break
			}
			;Create new cndition
			Condition := EventSystem_CreateSubEvent("Condition", XMLCondition.Type)
			
			;Read Negation
			Condition.Negate := XMLCondition.Negate
			
			;Read condition values
			Condition.ReadXML(XMLCondition)
						
			Event.Conditions.append(Condition)
		}
		
		;Read actions
		if(!IsFunc(XMLEvent.Actions.Action.len) && XMLEvent.Actions.HasKey("Action"))
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
			{
				msgbox action break
				break
			}	
			;Create new action
			Action := EventSystem_CreateSubEvent("Action", XMLAction.Type)
			
			;Read action values
			Action.ReadXML(XMLAction)
						
			Event.Actions.append(Action)
		}
		Events.append(Event)
	}
	;fix IDs from import
	pos := count + 1
	count := Events.len()
	Loop
	{
		if(pos > count)
			break
		Event := Events[pos]
		offset := (highestID - lowestID) + 1
		Event.ID := Event.ID + offset
		if(Event.ID > Events.HighestID)
			Events.HighestID := Event.ID
		;Now adjust Event ID references
		enum := Event.Trigger._newEnum()
		while enum[k,v]
		{
			if(strEndsWith(k, "ID"))
				Event.Trigger[k] := Event.Trigger[k] + offset
		}
		Loop % Event.Conditions.len()
		{
			enum := Event.Conditions[A_Index]._newEnum()
			Condition := Event.Conditions[A_Index]
			while enum[k,v]
			{
				if(strEndsWith(k, "ID"))
					Condition[k] := Condition[k] + offset
			}
		}
		Loop % Event.Actions.len()
		{
			enum := Event.Actions[A_Index]._newEnum()
			Action := Event.Actions[A_Index]
			while enum[k,v]
			{
				if(strEndsWith(k, "ID"))
				{
					Action[k] := Action[k] + offset
				}
			}
		}
		pos++
	}
	return Events
}
WriteEventsFile(Events, path)
{
	global MajorVersion, MinorVersion, BugfixVersion
	; return
	;Create Events node
	xmlObject := Object()
	xmlObject.MajorVersion := MajorVersion
	xmlObject.MinorVersion := MinorVersion
	xmlObject.BugfixVersion := BugfixVersion
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
		
		;Write ID
		xmlEvent.ID := Event.ID
		
		;Write name
		xmlEvent.Name := Event.Name
		
		;Write state
		xmlEvent.Enabled := Event.Enabled
		
		;Disable after use
		xmlEvent.DisableAfterUse := Event.DisableAfterUse
		
		;Delete after use
		xmlEvent.DeleteAfterUse := Event.DeleteAfterUse
		
		;One Instance
		xmlEvent.OneInstance := Event.OneInstance
		
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
	global Events,EventSchedule
	;Find matching triggers
	Loop % Events.len()
	{
		Event := Events[A_Index]
		;Order of this if condition is important here, because Event.Trigger.Matches() can disable the event for timers
		if(Event.Enabled && (Event.Trigger.Type = Trigger.Type && Event.Trigger.Matches(Trigger, Event)) || (Trigger.Type = "Trigger" && Event.ID = Trigger.TargetID))
		{
			running := false
			if(Event.OneInstance)
			{
				Loop % EventSchedule.len()
				{
					if(EventSchedule[A_Index].ID = Event.ID)
					{
						running := true
						break
					}
				}
			}
			outputdebug % "schedule event: " Event.Name
			
			if(!running)
				EventSchedule.append(Event.DeepCopy())
		}
	}
}

EventScheduler()
{
	global Events, EventSchedule
	Critical, Off
	loop
	{
		EventPos := 1
		len := EventSchedule.len()
		Loop % EventSchedule.len()
		{			
			Event := EventSchedule[EventPos]
			outputdebug % "process event " Event.Name
			;Check conditions
			Success := Events[Events.FindID(Event.ID)].Enabled || Event.Trigger.Type = "Timer" ;Check enabled state again here, because it might have changed since it was appended to queue
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
				outputdebug % "disable " Event.ID " in queue"
			if(Success = 0) ;Condition was not fulfilled, remove this event
			{
				EventSchedule.Delete(EventPos)
				continue
			}
			else if(Success = 1) ;if conditions are fulfilled, execute all actions
			{
				outputdebug conditions fulfilled
				Loop % Event.Actions.len()
				{
					if(!Events[Events.FindID(Event.ID)].Enabled && Event.Trigger.Type != "Timer") ;Check enabled state again here, because it might have changed since in one of the previous actions during waiting
					{
						outputdebug % "disable " Event.ID " during execution"
						Event.Actions := Array()
						break
					}
					outputdebug % "perform " Event.Actions[1].DisplayString()
					result := Event.Actions[1].Execute(Event)
					if(result = 0) ;Action was cancelled, stop all further actions
					{
						Event.Actions := Array()
						break
					}
					else if(result = -1) ;Action needs more time to finish, check back in next main loop
						break
					else
						Event.Actions.Delete(1)
				}
			}
			if(Event.Actions.len() = 0) ;No more actions in this event, consider it processed and remove it from queue
			{
				EventSchedule.Delete(EventPos)
				if(Event.DisableAfterUse)
					Events[Events.FindID(Event.ID)].SetEnabled(false)
				if(Event.DeleteAfterUse)
				{
					Events[Events.FindID(Event.ID)].Delete()
					Events.Remove(Events[Events.FindID(Event.ID)])
				}
				continue
			}
			EventPos++
		}			
		Sleep 100
	}
}
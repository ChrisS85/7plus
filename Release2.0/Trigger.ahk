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
	global Events, Settings_Events
	Event.Enabled := Value
	if(Settings_Events && Events[Events.FindID(Event.ID)]) ;if settings are open and updating a regular event, update its counterpart in settings_events
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
	EventSystem_Triggers := "ExplorerPathChanged,Hotkey,Timer,Trigger,WindowActivated, WindowClosed, WindowCreated,7plusStart"
	EventSystem_Conditions := "MouseOver,If,IsRenaming,WindowActive,WindowExists"
	EventSystem_Actions := "Clipboard,Clipmenu,ControlEvent,Copy,Delete,FastFoldersMenu,FastFoldersRecall,FastFoldersStore,Input,Message,MinimizeToTray,Move,NewFile,NewFolder,PlaySound,Run,Screenshot,SendKeys,SetDirectory,Shutdown,Upload,WindowActivate,WindowClose,WindowHide,WindowShow"
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
	outputdebug createsubevent %type%
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
	global EventBase
	xpath_load(EventsFileHandle, path)
	count := Events.len()
	lowestID := 999999999999
	HighestID := Events.HighestID
	outputdebug highest id is originally %HighestID%
	Loop
	{
		i := A_Index
		;Check if end of Events is reached
		EventFileHandle:=xpath(EventsFileHandle, "/Events/Event[" i "]/*")
		if(!EventFileHandle)
			break
		xpath_load(EventFileHandle)
		TriggerHandle :=  xpath(EventFileHandle, "/Trigger/*")
		xpath_load(TriggerHandle)
		
		;Create new Event
		Event := Object("base",EventBase.DeepCopy())
		
		;Event ID
		Event.ID := xpath(EventFileHandle,"/ID/Text()")
		if(Event.ID < lowestID)
			lowestID := Event.ID
		;Event Name
		Event.Name := xpath(EventFileHandle,"/Name/Text()")
		Event.Name := StringReplace(Event.Name,"&lt;","<",1)
		Event.Name := StringReplace(Event.Name,"&gt;",">",1)
		
		;Event state
		Event.Enabled := xpath(EventFileHandle, "/Enabled/Text()")
		
		;Disable after use
		Event.DisableAfterUse := xpath(EventFileHandle, "/DisableAfterUse/Text()")
		
		;Delete after use
		Event.DeleteAfterUse := xpath(EventFileHandle, "/DeleteAfterUse/Text()")
		
		;One Instance
		Event.OneInstance := xpath(EventFileHandle, "/OneInstance/Text()")
		
		;Read trigger values		
		Trigger_type := xpath(TriggerHandle, "/Type/Text()")
		Event.Trigger := EventSystem_CreateSubEvent("Trigger", Trigger_Type)
		Event.Trigger.ReadXML(TriggerHandle)
		
		enum := Event.Trigger._newEnum()
		while enum[key,value]
		{			
			Event.Trigger[key] := StringReplace(Event.Trigger[key],"&lt;","<",1)
			Event.Trigger[key] := StringReplace(Event.Trigger[key],"&gt;",">",1)
		}
		
		;Read conditions
		Loop
		{
			j := A_Index
			
			;Check if end of Events is reached
			ConditionFileHandle:=xpath(EventFileHandle, "/Conditions/Condition[" j "]/*")
			if(!ConditionFileHandle)
				break
			xpath_load(ConditionFileHandle)
			
			
			;Read condition type
			Condition_type := xpath(ConditionFileHandle, "/Type/Text()")
			
			;Create new cndition
			Condition := EventSystem_CreateSubEvent("Condition", Condition_type)
			
			;Read Negation
			Condition.Negate := xpath(ConditionFileHandle, "/Negate/Text()")
			
			;Read condition values
			Condition.ReadXML(ConditionFileHandle)
			
			enum := Condition._newEnum()
			while enum[key,value]
			{			
				Condition[key] := StringReplace(Condition[key],"&lt;","<",1)
				Condition[key] := StringReplace(Condition[key],"&gt;",">",1)
			}
			
			Event.Conditions.append(Condition)
		}
		
		;Read actions
		Loop
		{
			j := A_Index
			
			;Check if end of Events is reached
			ActionFileHandle:=xpath(EventFileHandle, "/Actions/Action[" j "]/*")			
			if(!ActionFileHandle)
				break
			xpath_load(ActionFileHandle)
						
			;Read action type
			Action_type := xpath(ActionFileHandle, "/Type/Text()")
			
			;Create new action
			Action := EventSystem_CreateSubEvent("Action", Action_type)
			
			;Read action values
			Action.ReadXML(ActionFileHandle)
			
			enum := Action._newEnum()
			while enum[key,value]
			{			
				Action[key] := StringReplace(Action[key],"&lt;","<",1)
				Action[key] := StringReplace(Action[key],"&gt;",">",1)
			}
			
			Event.Actions.append(Action)
		}
		Events.append(Event)
	}
	;fix IDs from import
	pos := count + 1
	outputdebug loop from %pos%
	count := Events.len()
	outputdebug to %count%
	Loop
	{
		if(pos > count)
			break
		Event := Events[pos]
		offset := (highestID - lowestID) + 1
		outputdebug add offset %offset%
		outputdebug("old id " Event.ID)
		Event.ID := Event.ID + offset
		outputdebug("new id " Event.ID)
		if(Event.ID > Events.HighestID)
			Events.HighestID := Event.ID
		outputdebug("Highest id is now " Events.HighestID)
		;Now adjust Event ID references
		enum := Event.Trigger._newEnum()
		while enum[k,v]
		{
			if(strEndsWith(k, "ID"))
				Event.Trigger[k] += offset
		}
		Loop % Event.Conditions.len()
		{
			enum := Event.Conditions[A_Index]._newEnum()
			c := A_Index
			while enum[k,v]
			{
				if(strEndsWith(k, "ID"))
					Event.Conditions[c][k] += offset
			}
		}
		Loop % Event.Actions.len()
		{
			enum := Event.Actions[A_Index]._newEnum()
			a := A_Index
			while enum[k,v]
			{
				if(strEndsWith(k, "ID"))
					Event.Actions[a][k] += offset
			}
		}
		pos++
	}
	return Events
}
WriteEventsFile(Events, path)
{
	;Create Events node
	xpath(EventsFileHandle, "/Events[+1]") 
	;Write Events entries
	Loop % Events.len()
	{
		i := A_Index
		Event := Events[i]
		
		;Write ID
		xpath(EventsFileHandle, "/Events/Event[+1]/ID[+1]/Text()", Event.ID)
		
		;Write name		
		Name := StringReplace(Event.Name,"<","&lt;",1)
		Name := StringReplace(Name,">","&gt;",1)
		xpath(EventsFileHandle, "/Events/Event[" i "]/Name[+1]/Text()", Name)
		
		;Write state
		xpath(EventsFileHandle, "/Events/Event[" i "]/Enabled[+1]/Text()", Event.Enabled)
		
		;Disable after use
		xpath(EventsFileHandle, "/Events/Event[" i "]/DisableAfterUse[+1]/Text()", Event.DisableAfterUse)
		
		;Delete after use
		xpath(EventsFileHandle, "/Events/Event[" i "]/DeleteAfterUse[+1]/Text()", Event.DeleteAfterUse)
		
		;One Instance
		xpath(EventsFileHandle, "/Events/Event[" i "]/OneInstance[+1]/Text()", Event.OneInstance)
		
		;Write Trigger type, since it's stored in base object, and isn't iterated below
		xpath(EventsFileHandle, "/Events/Event[" i "]/Trigger[+1]/Type[+1]/Text()", Event.Trigger.Type)
		
		enum := Event.Trigger._newEnum()
		while enum[key,value]
		{
			if(key = "Category" || strStartsWith(key, "tmp"))
				continue				
			escaped := StringReplace(value,"<","&lt;",1)
			escaped := StringReplace(escaped,">","&gt;",1)
			xpath(EventsFileHandle, "/Events/Event[" i "]/Trigger/" key "[+1]/Text()", escaped)
		}
		;Since some triggers might have to do special preprocessing, lets allow them to overwrite the values read above
		;Event.Trigger.WriteXML(EventsFileHandle, "/Events/Event[" i "]/Trigger/")
		
		;Write Conditions
		xpath(EventsFileHandle, "/Events/Event[" i "]/Conditions[+1]")
		Loop % Event.Conditions.len()
		{
			j := A_Index
			Condition := Event.Conditions[j]
			
			;Write condition type, since it's stored in base object, and isn't iterated below
			xpath(EventsFileHandle, "/Events/Event[" i "]/Conditions/Condition[+1]/Type[+1]/Text()", Condition.Type)
			
			enum := Condition._newEnum()
			while enum[key,value]
			{
				if(key = "Category" || strStartsWith(key, "tmp"))
					continue
						
				escaped := StringReplace(value,"<","&lt;",1)
				escaped := StringReplace(escaped,">","&gt;",1)
				xpath(EventsFileHandle, "/Events/Event[" i "]/Conditions/Condition[" j "]/" key "[+1]/Text()", escaped)
			}
			;Since some triggers might have to do special preprocessing, lets allow them to overwrite the values read above
			;Condition.WriteXML(EventsFileHandle, "/Events/Event[" i "]/Conditions/Condition[" j "]/")
		}
		
		;Write Actions
		xpath(EventsFileHandle, "/Events/Event[" i "]/Actions[+1]")
		Loop % Event.Actions.len()
		{
			j := A_Index
			Action := Event.Actions[j]
			
			;Write action type, since it's stored in base object, and isn't iterated below
			xpath(EventsFileHandle, "/Events/Event[" i "]/Actions/Action[+1]/Type[+1]/Text()", Action.Type)
			
			enum := Action._newEnum()
			while enum[key,value]
			{
				if(key = "Category" || strStartsWith(key, "tmp"))
					continue
				
				escaped := StringReplace(value,"<","&lt;",1)
				escaped := StringReplace(escaped,">","&gt;",1)
				xpath(EventsFileHandle, "/Events/Event[" i "]/Actions/Action[" j "]/" key "[+1]/Text()", escaped)
			}
			;Action.WriteXML(EventsFileHandle, "/Events/Event[" i "]/Actions/Action[" j "]/")
		}
	}
	;Save File
	xpath_save(EventsFileHandle,path)
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
			;Check conditions
			Success := 1 ;Always enabled here, as enabled state is checked on triggering already
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
			if(Success = 0) ;Condition was not fulfilled, remove this event
			{
				EventSchedule.Delete(EventPos)
				continue
			}
			else if(Success = 1) ;if conditions are fulfilled, execute all actions
			{
				Loop % Event.Actions.len()
				{
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
		Sleep 20
	}
}
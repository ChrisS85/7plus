EventSystem_Startup()
{
	global Events, EventSchedule
	EventsBase := object("base",Array(), "HighestID", -1, "CreateEvent", "EventSystem_CreateEvent", "FindID", "Events_FindID")
	Events := object("base", EventsBase)
	EventSystem_CreateBaseObjects()
	
	ReadEventsFile()
	outputdebug(Events.len())
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
	{
		if(Events[A_Index].ID = ID)
			return A_Index
	}
	return 0
}
EventSystem_CreateEvent(Events)
{
	global EventBase
	Events.HighestID := Events.HighestID + 1
	Event := Object("base",EventBase.DeepCopy()) ;Need to use base to make functions work
	Event.ID := Events.HighestID
	Events.append(Event)
	return Event
}
EventSystem_CreateBaseObjects()
{
	global
	local tmpobject
	EventSystem_Triggers := "None,WindowActivated, WindowClosed, WindowCreated, Hotkey,7plusStart,ExplorerPathChanged"
	EventSystem_Conditions := "WindowActive,WindowExists,MouseOver"
	EventSystem_Actions := "Run, Message,SendKeys,SetDirectory,Shutdown,WindowActivate,WindowClose,WindowHide,WindowShow"
	Trigger_Categories := object("Explorer", Array(), "Window", Array(), "Hotkeys", Array(), "7plus", Array(), "Other", Array())
	Condition_Categories := object("Window", Array(), "Mouse", Array(), "Other", Array())
	Action_Categories := object("Explorer", Array(), "Window", Array(), "Input", Array(), "System", Array(), "7plus", Array(), "Other", Array())
	
	Loop, Parse, EventSystem_Triggers, `,,%A_Space%
	{		
		tmpobject := RichObject()
		tmpobject.Type := A_LoopField
		tmpobject.ReadXML := "Trigger_" A_LoopField "_ReadXML"
		tmpobject.WriteXML := "Trigger_" A_LoopField "_WriteXML"
		tmpobject.Enable := "Trigger_" A_LoopField "_Enable"
		tmpobject.Matches := "Trigger_" A_LoopField "_Matches"
		tmpobject.DisplayString := "Trigger_" A_LoopField "_DisplayString"
		tmpobject.GuiShow := "Trigger_" A_LoopField "_GuiShow"
		tmpobject.GuiSubmit := "Trigger_" A_LoopField "_GuiSubmit"
		tmpobject.Init := "Trigger_" A_LoopField "_Init"
		tmpobject.Delete := "Trigger_" A_LoopField "_Delete"
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
		tmpobject.ReadXML := "Condition_" A_LoopField "_ReadXML"
		tmpobject.WriteXML := "Condition_" A_LoopField "_WriteXML"
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
		tmpobject.ReadXML := "Action_" A_LoopField "_ReadXML"
		tmpobject.WriteXML := "Action_" A_LoopField "_WriteXML"
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
	EventBase.ExpandPlaceHolders := "Event_ExpandPlaceholders"
	EventBase.PlaceHolders := Array()
	EventBase.Trigger := EventSystem_CreateSubEvent("Trigger", "None")
	EventBase.Conditions := Array()
	EventBase.Actions := Array()
}
EventSystem_End()
{
	WriteEventsFile()
}

EventSystem_CreateSubEvent(Category,Type)
{
	global
	local tmp
	tmp := %Category%_%Type%_Base
	return tmp.DeepCopy() ;Object("base", %tmp%, "Type", Type)
}
Event_Enable(Event)
{
	Event.Enabled := true
	Event.Trigger.Enable()
}
ReadEventsFile()
{
	global ConfigPath, Events, EventBase
	;Event file is in same dir as settings.ini
	SplitPath, ConfigPath,,path
	path .= "\Events.xml"	
	xpath_load(EventsFileHandle, path)   
	Loop
	{
		i := A_Index
		;Check if end of Events is reached
		EventFileHandle:=xpath(EventsFileHandle, "/Events/Event[" i "]/*")
		if(!EventFileHandle)
			break
		outputdebug read event
		xpath_load(EventFileHandle)
		TriggerHandle :=  xpath(EventFileHandle, "/Trigger/*")
		xpath_load(TriggerHandle)
		
		;Create new Event
		Event := Object("base",EventBase.DeepCopy())
		
		;Event ID
		Event.ID := xpath(EventFileHandle,"/ID/Text()")
		if(Event.ID > Events.HighestID)
			Events.HighestID := Event.ID

		;Event Name
		Event.Name := xpath(EventFileHandle,"/Name/Text()")
		
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
			
			Event.Actions.append(Action)
		}
		Event.Trigger.Init()
		Events.append(Event)
	}
}
WriteEventsFile()
{
	global ConfigPath, Events
	;Events file is in same dir as settings.ini
	SplitPath, ConfigPath,,path
	path .= "\Events.xml"	;TODO: Save to different file during development
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
		xpath(EventsFileHandle, "/Events/Event[" i "]/Name[+1]/Text()", Event.Name)
		
		;Write state
		xpath(EventsFileHandle, "/Events/Event[" i "]/Enabled[+1]/Text()", Event.Enabled)
		
		;Disable after use
		xpath(EventsFileHandle, "/Events/Event[" i "]/DisableAfterUse[+1]/Text()", Event.DisableAfterUse)
		
		;Delete after use
		xpath(EventsFileHandle, "/Events/Event[" i "]/DeleteAfterUse[+1]/Text()", Event.DeleteAfterUse)
		
		;One Instance
		xpath(EventsFileHandle, "/Events/Event[" i "]/OneInstance[+1]/Text()", Event.OneInstance)
		
		;Write Trigger
		xpath(EventsFileHandle, "/Events/Event[" i "]/Trigger[+1]/Type[+1]/Text()", Event.Trigger.Type)
		Event.Trigger.WriteXML(EventsFileHandle, "/Events/Event[" i "]/Trigger/")
		
		;Write Conditions
		xpath(EventsFileHandle, "/Events/Event[" i "]/Conditions[+1]")
		Loop % Event.Conditions.len()
		{
			j := A_Index
			Condition := Event.Conditions[j]
			
			;Write condition type
			xpath(EventsFileHandle, "/Events/Event[" i "]/Conditions/Condition[+1]/Type[+1]/Text()", Condition.Type)
			
			;Write Negation
			xpath(EventsFileHandle, "/Events/Event[" i "]/Conditions/Condition[" j "]/Negate[+1]/Text()", Condition.Negate)
			
			Condition.WriteXML(EventsFileHandle, "/Events/Event[" i "]/Conditions/Condition[" j "]/")
		}
		
		;Write Actions
		xpath(EventsFileHandle, "/Events/Event[" i "]/Actions[+1]")
		Loop % Event.Actions.len()
		{
			j := A_Index
			Action := Event.Actions[j]
			xpath(EventsFileHandle, "/Events/Event[" i "]/Actions/Action[+1]/Type[+1]/Text()", Action.Type)
			Action.WriteXML(EventsFileHandle, "/Events/Event[" i "]/Actions/Action[" j "]/")
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
		if(Event.Trigger.Type = Trigger.Type && Event.Trigger.Matches(Trigger))
		{
			running := false
			if(Event.OneInstance)
			{
				outputdebug one instance
				Loop % EventSchedule.len()
				{
					if(EventSchedule[A_Index].ID = Event.ID)
					{
						outputdebug found running event
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
			Success := Event.Enabled
			ConditionPos := 1
			if(Success)
			{
				Loop % Event.Conditions.len()
				{
					result := Event.Conditions[ConditionPos].Evaluate()
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
					if(result = -1) ;Action needs more time to finish, check back in next main loop
						break
					Event.Actions.Delete(1)
				}
			}
			if(Event.Actions.len() = 0) ;No more actions in this event, consider it processed and remove it from queue
			{
				EventSchedule.Delete(EventPos)
				if(Event.DisableAfterUse)
					Events[Events.FindID(Event.ID)].Enabled := false
				if(Event.DeleteAfterUse)
				{
					Events[Events.FindID(Event.ID)].Delete()
					Events.Delete(Events.FindID(Event.ID))
				}
				continue
			}
			EventPos++
		}			
		Sleep 20
	}
}
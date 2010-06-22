EventSystem_Startup()
{
	global EventEvents
	EventEvents := Array()
	EventSystem_CreateBaseObjects()
	
	ReadEventsFile()
	Loop % EventEvents.len()
	{
		Event := EventEvents[A_Index]	
		if(Event.Enabled)
			Event.Enable()
	}
}
EventSystem_CreateBaseObjects()
{
	global
	EventSystem_Triggers := "WindowActivated"
	EventSystem_Conditions := "WindowActive"
	EventSystem_Actions := "Run, Message"
	
	EventBase := Object("ID",-1,"Enabled", 1, "Enable", "Event_Enable", "Trigger","","Conditions",Array(),"Actions",Array())
	
	Loop, Parse, EventSystem_Triggers, `,,%A_Space%
	{
		Trigger_%A_LoopField%_Base := Object( "ReadXML","Trigger_" A_LoopField "_ReadXML", "WriteXML"
						, "Trigger_" A_LoopField "_WriteXML"
						, "Enable", "Trigger_" A_LoopField "_Enable"
						, "Matches", "Trigger_" A_LoopField "_Matches")
	}
	Loop, Parse, EventSystem_Conditions, `,,%A_Space%
	{
		Condition_%A_LoopField%_Base := Object( "ReadXML","Condition_" A_LoopField "_ReadXML"
						, "WriteXML", "Condition_" A_LoopField "_WriteXML"
						, "Evaluate", "Condition_" A_LoopField "_Evaluate")
	}
	Loop, Parse, EventSystem_Actions, `,,%A_Space%
	{
		Action_%A_LoopField%_Base := Object( "ReadXML","Action_" A_LoopField "_ReadXML"
						, "WriteXML", "Action_" A_LoopField "_WriteXML"
						, "Execute", "Action_" A_LoopField "_Execute")
	}
}
EventSystem_End()
{
	WriteEventsFile()
}

CreateEventObject(Category,Type)
{
	global
	local tmp
	tmp = %Category%_%Type%_Base
	return Object("base", %tmp%, "Type", Type)
}
Event_Enable(Event)
{
	Event.Enabled := true
	Event.Trigger.Enable()
}
ReadEventsFile()
{
	global ConfigPath, EventEvents, EventBase
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
		xpath_load(EventFileHandle)
		TriggerHandle :=  xpath(EventFileHandle, "/Trigger/*")
		xpath_load(TriggerHandle)
		
		;Create new Event
		Event := Object("base",EventBase)
		
		;Event ID
		Event.ID := xpath(EventFileHandle,"/ID/Text()")
		
		;Event state
		Event.Enabled := xpath(EventFileHandle, "/Enabled/Text()")
		
		;Read trigger values		
		Trigger_type := xpath(TriggerHandle, "/Type/Text()")
		Event.Trigger := CreateEventObject("Trigger", Trigger_Type)
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
			Condition := CreateEventObject("Condition", Condition_type)
			
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
			Action := CreateEventObject("Action", Action_type)
			
			;Read action values
			Action.ReadXML(ActionFileHandle)
			
			Event.Actions.append(Action)
		}
		
		EventEvents.append(Event)
	}
}

WriteEventsFile()
{
	global ConfigPath, EventEvents
	;Events file is in same dir as settings.ini
	SplitPath, ConfigPath,,path
	path .= "\EventsOut.xml"	;TODO: Save to different file during development
	
	;Create Events node
	xpath(EventsFileHandle, "/Events[+1]") 
	
	;Write Events entries
	Loop % EventEvents.len()
	{
		i := A_Index
		Event := EventEvents[i]
		
		;Write ID
		xpath(EventsFileHandle, "/Events/Event[+1]/ID[+1]/Text()", Event.ID)
		
		;Write state
		xpath(EventsFileHandle, "/Events/Event[" i "]/Enabled[+1]/Text()", Event.Enabled)
		
		;Write Trigger
		xpath(EventsFileHandle, "/Events/Event[" i "]/Trigger[+1]/Type[+1]/Text()", Event.Trigger.Type)
		Event.Trigger.WriteXML(EventsFileHandle, "/Events/Event[" i "]/Trigger/")
		
		;Write Conditions
		xpath(EventsFileHandle, "/Events/Event[" i "]/Conditions[+1]")
		Loop % Event.Conditions.len()
		{
			j := A_Index
			Condition := Event.Conditions[j]
			xpath(EventsFileHandle, "/Events/Event[" i "]/Conditions/Condition[+1]/Type[+1]/Text()", Condition.Type)
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

;This function is called when a trigger event is received
OnTrigger(Trigger)
{
	global EventEvents
	;Find matching triggers
	Loop % EventEvents.len()
	{
		Event := EventEvents[A_Index]
		if(Event.Trigger.Matches(Trigger))
		{
			;Check conditions
			Success := true
			Loop % Event.Conditions.len()
			{
				Condition := Event.Conditions[A_Index]
				if( !Condition.Evaluate() )
				{
					Success := false
					break
				}
			}
			;if conditions are fulfilled, execute all actions
			if(Success)
			{
				Loop % Event.Actions.len()
				{
					Action := Event.Actions[A_Index]
					Action.Execute()
				}
			}
		}
	}
}
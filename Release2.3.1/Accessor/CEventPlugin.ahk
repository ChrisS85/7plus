Class CEventPlugin extends CAccessorPlugin
{
	;Register this plugin with the Accessor main object
	static Type := CAccessor.RegisterPlugin("Event Plugin", CEventPlugin)
	
	Description := "Makes it possible to implement an Accessor function by using the event system.`nThe parameters after the keyword of an event can be accessed`nthrough the ${Acc1} - ${Acc9} placeholders."
	
	AllowDelayedExecution := true

	Class CSettings extends CAccessorPlugin.CSettings
	{
		Keyword := "Event"
		KeywordOnly := false
		MinChars := 2
	}
	Class CResult extends CAccessorPlugin.CResult
	{
		Class CActions extends CArray
		{
			DefaultAction := new CAccessor.CAction("Execute", "TriggerEvent")
		}
		Type := "Event Plugin"
		Actions := new this.CActions()
		Priority := CEventPlugin.Instance.Priority
		__Delete()
		{
			if(this.Icon && !CAccessor.Instance.GenericIcons.IndexOf(this.Icon))
				DestroyIcon(this.Icon)
		}
	}
	IsInSinglePluginContext(Filter, LastFilter)
	{
		return false
	}
	RefreshList(Accessor, Filter, LastFilter, KeywordSet, Parameters)
	{
		Results := Array()
		for index, Event in EventSystem.Events
		{
			if(Event.Trigger.Is(CAccessorTrigger) && InStr(Filter, Event.Trigger.Keyword) = 1)
			{
				Result := new this.CResult()
				Result.Title := Event.Trigger.Title
				Result.Path := Event.ExpandPlaceholders(Event.Trigger.Path)
				Result.Detail1 := Event.ExpandPlaceholders(ListEntry.Event.Trigger.Detail1)
				Result.Event := Event
				Result.Parameters := Parameters
				if(Icon := Event.Trigger.Icon)
				{
					StringSplit, icon, icon, `,,%A_Space%
					Result.Icon := ExtractIcon(icon1, icon2 + 1, 64)
				}
				else
					Result.Icon := Accessor.GenericIcons.Application
				Results.Insert(Result)
			}
		}
		return Results
	}
	TriggerEvent(Accessor, ListEntry)
	{
		ScheduledEvent := ListEntry.Event.TriggerThisEvent()
		for index, Parameter in ListEntry.Parameters
			ScheduledEvent.Placeholders["Acc" index] := Parameter
	}
}
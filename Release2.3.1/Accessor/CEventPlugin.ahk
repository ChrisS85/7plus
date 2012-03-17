Class CEventPlugin extends CAccessorPlugin
{
	;Register this plugin with the Accessor main object
	static Type := CAccessor.RegisterPlugin("Event Plugin", CEventPlugin)
	
	Description := "Makes it possible to implement an Accessor function by using the event system.`nThe parameters after the keyword of an event can be accessed`nthrough the ${Acc1} - ${Acc9} placeholders."
		
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
			if(Event.Trigger.Is(CAccessorTrigger) && Filter = Event.Trigger.Keyword)
			{
				Result := new this.CResult()
				Result.Title := Event.Trigger.Title
				Result.Path := Event.Trigger.Path
				Result.Detail1 := ListEntry.Event.Trigger.Detail1
				Result.Detail2 := ListEntry.Event.Trigger.Detail2
				Result.Event := Event
				Result.Parameters := Parameters
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
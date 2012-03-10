Class CRunPlugin extends CAccessorPlugin
{
	;Register this plugin with the Accessor main object
	static Type := CAccessor.RegisterPlugin("Run", CRunPlugin)
	
	Description := "This plugin tries to execute the entered text directly. You can press CTRL+Enter`n in the Accessor window to execute this action even if it is not selected.`nCTRL+SHIFT+Enter will run it with admin permissions."
		
	Class CSettings extends CAccessorPlugin.CSettings
	{
		Keyword := "run"
		KeywordOnly := false
		MinChars := 1
	}
	Class CResult extends CAccessorPlugin.CResult
	{
		Class CActions extends CArray
		{
			DefaultAction := CAccessorPlugin.CActions.Run
			__new()
			{
				this.Insert(CAccessorPlugin.CActions.RunAsAdmin)
			}
		}
		Type := "Run"
		Actions := new this.CActions()
	}
	IsInSinglePluginContext(Filter, LastFilter)
	{
		return false
	}
	GetDisplayStrings(ListEntry, ByRef Title, ByRef Path, ByRef Detail1, ByRef Detail2)
	{
		Detail1 := "Run command"
	}
	RefreshList(Accessor, Filter, LastFilter, KeywordSet, Parameters)
	{
		Results := Array()
		Result := new this.CResult()
		Result.Title := Filter
		Result.Path := Filter
		outputdebug % isobject(Accessor.GenericIcons)
		Result.Icon := Accessor.GenericIcons.Application
		Results.Insert(Result)
		return Results
	}
}

#if (Accessor.GUI)
^Enter::
^NumpadEnter::
Accessor.Instance.PerformAction(CAccessorPlugin.CActions.Run, Accessor.Instance.List.GetItemWithValue("Type", "Run"))
return
+Enter::
+NumpadEnter::
Accessor.Instance.PerformAction(CAccessorPlugin.CActions.RunAsAdmin, Accessor.Instance.List.GetItemWithValue("Type", "Run"))
return
#if
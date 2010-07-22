Action_Volume_Init(Action)
{
	Action.Category := "System"
	Action.Action := "Set Volume"
	Action.Volume := 100
}

Action_Volume_ReadXML(Action, ActionFileHandle)
{
	Action.Action := xpath(ActionFileHandle, "/Action/Text()")
	Action.Volume := xpath(ActionFileHandle, "/Volume/Text()")
}

Action_Volume_Execute(Action, Event)
{
	global Vista7
	Volume := Event.ExpandPlaceholders(Action.Volume)
	if(Vista7)
	{
		if(Action.Action = "Mute")
			VA_SetMasterMute(1)
		else if(Action.Action = "Unmute")
			VA_SetMasterMute(0)
		else if(Action.Action = "Toggle mute/unmute" && VA_GetMasterMute())
			VA_SetMasterMute(0)
		else if(Action.Action = "Toggle mute/unmute")
			VA_SetMasterMute(1)
		else
		{
			if(InStr(Volume, "+") = 1 || InStr(Volume, "-") = 1)
				Volume := VA_GetMasterVolume() + Volume
			VA_SetMasterVolume(Volume)
		}
	}
	else
	{
		if(Action.Action = "Mute")
			SoundSet, 1,, Mute
		else if(Action.Action = "Unmute")
			SoundSet, 0,, Mute
		else if(Action.Action = "Toggle mute/unmute" && SoundGet("","Mute"))
			SoundSet, 1,, Mute
		else if(Action.Action = "Toggle mute/unmute")
			SoundSet, 0,, Mute
		else
			SoundSetWaveVolume, %Volume%
	}
	return 1
}
 
Action_Volume_DisplayString(Action)
{
	return Action.Action (Action.Action = "Set Volume" ? " to " Action.Volume : "")
}

Action_Volume_GuiShow(Action, ActionGUI)
{
	SubEventGUI_Add(Action, ActionGUI, "DropDownList", "Action", "Mute|Unmute|Toggle mute/unmute|Set volume", "", "Action:")
	SubEventGUI_Add(Action, ActionGUI, "Text", "tmpText", "Use +/- to increase/decrease volume")
	SubEventGUI_Add(Action, ActionGUI, "Edit", "Volume", "", "", "Volume (%):")
}

Action_Volume_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}  
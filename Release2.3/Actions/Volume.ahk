Action_Volume_Init(Action)
{
	Action.Category := "System"
	Action.Action := "Set Volume"
	Action.Volume := 100
	Action.ShowVolume := true
}

Action_Volume_ReadXML(Action, XMLAction)
{
	Action.Action := XMLAction.Action
	Action.Volume := XMLAction.Volume
	Action.ShowVolume := XMLAction.HasKey("ShowVolume") ? XMLAction.ShowVolume : 1
}

Action_Volume_Execute(Action, Event)
{
	global Vista7, VolumeNotifyID
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
		if(Action.ShowVolume)
		{
			if(!VolumeNotifyID)
			{
				if(VA_GetMasterMute())
					VolumeNotifyID := Notify("Volume","","","PG=100 PW=250 GC=555555 SI=0 SC=0 ST=0 TC=White MC=White AC=ToggleMute", 220)
				else
					VolumeNotifyID := Notify("Volume","","","PG=100 PW=250 GC=555555 SI=0 SC=0 ST=0 TC=White MC=White AC=ToggleMute", 169)
			}
			
			Notify("","",VA_GetMasterVolume(),"Progress",VolumeNotifyID)
			SetTimer, ClearNotifyID, -1500
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
			SoundSet, %Volume%
		if(Action.ShowVolume)
		{
			if(!VolumeNotifyID)
			{
				if(SoundGet("","Mute"))
					VolumeNotifyID := Notify("Volume","","","PG=100 PW=250 GC=555555 SI=0 ST=0 TC=White MC=White AC=ToggleMute", 169)
				else
					VolumeNotifyID := Notify("Volume","","","PG=100 PW=250 GC=555555 SI=0 ST=0 TC=White MC=White AC=ToggleMute", 110)
			}
			;msgbox % SoundGet("","Volume")
			Notify("","",SoundGet("","Volume"),"Progress",VolumeNotifyID)
			SetTimer, ClearNotifyID, -1500
		}
	}
	return 1
}
ClearNotifyID:
Notify("","",0,"Wait",VolumeNotifyID)
VolumeNotifyID := ""
return
ToggleMute:
VolumeNotifyID := ""
if(Vista7)
{
	if(VA_GetMasterMute())
		VA_SetMasterMute(0)
	else
		VA_SetMasterMute(1)
}
else
{
	if(SoundGet("","Mute"))
		SoundSet, 1,, Mute
	else
		SoundSet, 0,, Mute
}
return

Action_Volume_DisplayString(Action)
{
	return Action.Action (Action.Action = "Set Volume" ? " to " Action.Volume : "")
}

Action_Volume_GuiShow(Action, ActionGUI)
{
	SubEventGUI_Add(Action, ActionGUI, "DropDownList", "Action", "Mute|Unmute|Toggle mute/unmute|Set volume", "", "Action:")
	SubEventGUI_Add(Action, ActionGUI, "Text", "tmpText", "Use +/- to increase/decrease volume")
	SubEventGUI_Add(Action, ActionGUI, "Edit", "Volume", "", "", "Volume (%):")
	SubEventGUI_Add(Action, ActionGUI, "Checkbox", "ShowVolume", "Show Volume")
}

Action_Volume_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
}  
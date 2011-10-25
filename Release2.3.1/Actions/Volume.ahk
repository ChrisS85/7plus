Class CVolumeAction Extends CAction
{
	static Type := RegisterType(CVolumeAction, "Change sound volume")
	static Category := RegisterCategory(CVolumeAction, "System")	
	static Action := "Set Volume"
	static Volume := 100
	static ShowVolume := true

	Execute(Event)
	{
		Volume := Event.ExpandPlaceholders(this.Volume)
		if(Vista7)
		{
			if(this.Action = "Mute")
				VA_SetMasterMute(1)
			else if(this.Action = "Unmute")
				VA_SetMasterMute(0)
			else if(this.Action = "Toggle mute/unmute" && VA_GetMasterMute())
				VA_SetMasterMute(0)
			else if(this.Action = "Toggle mute/unmute")
				VA_SetMasterMute(1)
			else
			{
				if(InStr(Volume, "+") = 1 || InStr(Volume, "-") = 1)
					Volume := VA_GetMasterVolume() + Volume
				VA_SetMasterVolume(Volume)
			}
			if(this.ShowVolume)
			{
				if(!ApplicationState.VolumeNotifyID)
				{
					if(VA_GetMasterMute())
						ApplicationState.VolumeNotifyID := Notify("Volume","","","PG=100 PW=250 GC=555555 SI=0 SC=0 ST=0 TC=White MC=White AC=ToggleMute", NotifyIcons.SoundMute)
					else
						ApplicationState.VolumeNotifyID := Notify("Volume","","","PG=100 PW=250 GC=555555 SI=0 SC=0 ST=0 TC=White MC=White AC=ToggleMute", NotifyIcons.Sound)
				}
				
				Notify("","",VA_GetMasterVolume(),"Progress", ApplicationState.VolumeNotifyID)
				SetTimer, ClearNotifyID, -1500
			}
		}
		else
		{
			if(this.Action = "Mute")
				SoundSet, 1,, Mute
			else if(this.Action = "Unmute")
				SoundSet, 0,, Mute
			else if(this.Action = "Toggle mute/unmute" && SoundGet("","Mute"))
				SoundSet, 1,, Mute
			else if(this.Action = "Toggle mute/unmute")
				SoundSet, 0,, Mute
			else
				SoundSet, %Volume%
			if(this.ShowVolume)
			{
				if(!ApplicationState.VolumeNotifyID)
				{
					if(SoundGet("","Mute"))
						ApplicationState.VolumeNotifyID := Notify("Volume","","","PG=100 PW=250 GC=555555 SI=0 ST=0 TC=White MC=White AC=ToggleMute", NotifyIcons.SoundMute)
					else
						ApplicationState.VolumeNotifyID := Notify("Volume","","","PG=100 PW=250 GC=555555 SI=0 ST=0 TC=White MC=White AC=ToggleMute", NotifyIcons.Sound)
				}
				;msgbox % SoundGet("","Volume")
				Notify("","",SoundGet("","Volume"),"Progress", ApplicationState.VolumeNotifyID)
				SetTimer, ClearNotifyID, -1500
			}
		}
		return 1
	}

	DisplayString()
	{
		return this.Action (this.Action = "Set Volume" ? " to " this.Volume : "")
	}

	GuiShow(GUI)
	{
		this.AddControl(GUI, "DropDownList", "Action", "Mute|Unmute|Toggle mute/unmute|Set volume", "", "Action:")
		this.AddControl(GUI, "Text", "tmpText", "Use +/- to increase/decrease volume")
		this.AddControl(GUI, "Edit", "Volume", "", "", "Volume (%):")
		this.AddControl(GUI, "Checkbox", "ShowVolume", "Show Volume")
	}
}

ClearNotifyID:
Notify("","",0,"Wait", ApplicationState.VolumeNotifyID)
ApplicationState.VolumeNotifyID := ""
return

ToggleMute:
ApplicationState.VolumeNotifyID := ""
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
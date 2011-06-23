Action_ToggleWallpaper_Init(Action)
{
	Action.Category := "Window"
}
Action_ToggleWallpaper_ReadXML(Action, XMLAction)
{
}
Action_ToggleWallpaper_Execute(Action, Event)
{
	ToggleWallpaper()
}
Action_ToggleWallpaper_DisplayString(Action)
{
	return "Toggle wallpaper (mouse needs to be on desktop)"
}
Action_ToggleWallpaper_GuiShow(Action, ActionGUI, GoToLabel = "")
{
}
Action_ToggleWallpaper_GuiSubmit(Action, ActionGUI)
{
}

ToggleWallpaper()
{
	global
	if(!IsMouseOverDesktop() || A_OSVersion != "WIN_7")
		return false
	ShellContextMenu("Desktop",1)
	return true
}
Class CExplorerDoubleClickSpaceTrigger Extends CTrigger
{
	static Type := RegisterType(CExplorerDoubleClickSpaceTrigger, "Double click on empty space")
	static Category := RegisterCategory(CExplorerDoubleClickSpaceTrigger, "Explorer")
	Matches(Filter)
	{
		return true ;type is checked elsewhere
	}
	DisplayString()
	{
		return "Explorer: Double click on empty space"
	}
	GuiShow(GUI)
	{
		this.AddControl(GUI, "Text", "Desc", "This trigger executes when an empty space in the explorer file list is double-clicked.")
	}
}
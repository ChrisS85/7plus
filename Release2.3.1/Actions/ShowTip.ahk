Class CShowTipAction Extends CAction
{
	static Type := RegisterType(CShowTipAction, "Show Tip")
	static Category := RegisterCategory(CShowTipAction, "7plus")
	static TipIndex := 1
	static Min := 0
	static Max := 0

	Execute(Event)
	{
		ShowTip(this.Min && this.Max ? {Min : this.Min, Max : this.Max} : this.TipIndex)
		return true
	}

	DisplayString()
	{
		return "Show Tip"
	}

	GuiShow(ActionGUI)
	{
		this.AddControl(ActionGUI, "Edit", "TipIndex", "", "", "Tip Index:")
		this.AddControl(ActionGUI, "Edit", "Min", "", "", "Min Index:")
		this.AddControl(ActionGUI, "Edit", "Max", "", "", "Max Index:")
	}
	
}
Class CTips
{
	static 1  := new CTips.Tip("Clipboard Manager", "You can press WIN + V to open the clipboard manager, which can be used to paste recently copied text, persistent clips or recently used directories")
	static 2  := new CTips.Tip("Pasting in CMD", "The command prompt now also supports CTRL + V to paste text.")
	static 3  := new CTips.Tip("Pasting text or images as files", "You can paste a copied text or image directly as file in Explorer and file dialogs.")
	static 4  := new CTips.Tip("Window features", "You can move a window by holding the ALT key and dragging it with the left mouse button without using the title bar.")
	static 5  := new CTips.Tip("Window features", "You can resize a window by holding the ALT key and dragging it with the right mouse button without using its borders.")
	static 6  := new CTips.Tip("Window features", "You can minimize or maximize the window under the cursor with ALT and the mouse wheel.")
	static 7  := new CTips.Tip("Window features", "You can toggle the ""Always on Top"" state of a window by right clicking its title bar or pressing WIN + A.")
	static 8  := new CTips.Tip("Volume", "You can quickly change the volume by using the mouse wheel over the taskbar.")
	static 9  := new CTips.Tip("File renaming", "You can toggle between the selection of the name, the extension and the complete filename by pressing F2 again.")
	static 10 := new CTips.Tip("File selecting", "You can quickly select a number of files by pressing WIN + S and entering a part of their name.")
	static 11 := new CTips.Tip("File selecting", "You can undo an unwanted change in the selected files by pressing CTRL + SHIFT + Z.")
	static 12 := new CTips.Tip("Activating flashing windows", "You can activate windows that are flashing in the task bar by pressing CAPSLOCK.")
	static 13 := new CTips.Tip("Toggling between windows", "You can toggle between the current and the previous window by pressing CAPSLOCK.")
	static 14 := new CTips.Tip("Copying file paths", "You can also copy the filename (or filepath) of the selected file(s) by pressing (CTRL +) ALT + C.`nIf you additionally hold SHIFT the text will be appended to the current clipboard.")
	static 15 := new CTips.Tip("Adding files to the clipboard", "By pressing SHIFT + C or SHIFT + X you can add the selected files to the files which are already in the clipboard.")
	static 16 := new CTips.Tip("Taking screenshots of a specific area", "By pressing WIN + PrintScreen you can select an area of which a screenshot will be made.")

	Class Tip
	{
		__new(Title, Text)
		{
			this.Title := Title
			this.Text := Text
		}
	}
}
HasTipBeenShown(TipIndex)
{
	return SubStr(Settings.General.ShownTips, TipIndex, 1) = 1
}
;Tip index can be {Min : 1, Max : 10} for random index between these values
ShowTip(TipIndex, Probability = 1)
{
	Random, r, 0.0, 1.0
	if(r > Probability)
		return
	;Possibly choose a random tip in a specific interval
	if(IsObject(TipIndex))
		Random, TipIndex, % TipIndex.Min, % TipIndex.Max
	if(Settings.General.ShowTips && !HasTipBeenShown(TipIndex))
	{
		tip := CTips[TipIndex]
		Notify(tip.Title, tip.Text, 10, NotifyIcons.Info)

		;Mark the tip as shown
		Settings.General.ShownTips := SubStr(Settings.General.ShownTips, 1, TipIndex - 1) "1" (StrLen(Settings.General.ShownTips) > TipIndex ? SubStr(Settings.General.ShownTips, TipIndex + 1) : "")
	}
}
/*
Class: CButtonControl
A button control.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CButtonControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Type := "Button"
		this._.Insert("ControlStyles", {Center : 0x300, Left : 0x100, Right : 0x200, Default : 0x1, Wrap : 0x2000, Flat : 0x8000})
		this._.Insert("Events", ["Click"])
	}	
	
	/*
	Event: Introduction
	To handle control events you need to create a function with this naming scheme in your window class: ControlName_EventName(params)
	The parameters depend on the event and there may not be params at all in some cases.
	Additionally it is required to create a label with this naming scheme: GUIName_ControlName
	GUIName is the name of the window class that extends CGUI. The label simply needs to call CGUI.HandleEvent(). 
	For better readability labels may be chained since they all execute the same code.
	
	Event: Click()
	Invoked when the user clicked on the button.
	*/
	HandleEvent()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		ErrLevel := ErrorLevel
		if(IsFunc(CGUI.GUIList[this.GUINum][this.Name "_Click"]))
		{
			ErrorLevel := ErrLevel
			`(CGUI.GUIList[this.GUINum])[this.Name "_Click"]()
		}
	}
}
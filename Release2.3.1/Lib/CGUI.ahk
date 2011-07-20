
/*
   Class: CGUI
   The main GUI class. User created GUIs need to extend this class and call Base.__New() in their constructor before doing anything related to this class.
*/
Class CGUI
{
	/*
	Variable: GUIList
	This static array contains a list of all GUIs created with this library.
	It is maintained automatically and should not be used directly.
	*/
	static GUIList := Object()
	
	;Get only:
	/*
	Variable: Controls
	This object holds all controls of this GUI. The controls are stored with their window handle as key. This object is not setable
	*/
	/*
	Variable: hwnd
	The window handle of this window. This can not be set to a different value.
	*/
	/*
	Variable: GUINum
	The AHK GUI number of this window. The gui number may be used to find this window object: CGUI.GUIList[GUINum]. It's also useful for commands like GuiControl. But these commands should not be used where possible to ensure that the window object maintains the correct state.
	*/
	/*
	Variable: MinMax
	Retrieves the window's minimized/maximized state.
	*/
	/*
	Variable: Instances
	Retrieves a list of instances of the current window class.
	*/
	
	/*
	var Controls := Object()
	var hwnd := 0
	var GUINum := 0
	MinMax
	Instances ;Returns a list of instances of this window class
	*/
	
	;Set only:
	/*
	Variable: LastFound
	Sets the window to be the last found window (though this is unnecessary in a Gui thread because it is done automatically). This is rarely needed since most properties are accessible through CGUI.
	*/
	/*
	var LastFound := 0 ;Sets the window to be the last found window (though this is unnecessary in a Gui thread because it is done automatically). This is rarely needed since most properties are accessible through CGUI.
	*/
	;Get/Set:
	/*
	Variable: AlwaysOnTop
	Makes the window stay on top of all other windows.
	*/
	/*
	Variable: Border
	Provides a thin-line border around the window. This is not common.
	*/
	/*
	Variable: Caption
	Provides a title bar and a thick window border/edge.
	*/
	/*
	Variable: x
	X-position of the window on the screen
	*/
	/*
	Variable: y
	Y-position of the window on the screen
	*/
	/*
	Variable: width
	Width of the window
	*/
	/*
	Variable: height
	height of the window
	*/
	/*
	Variable: Position
	Position of the window. This object has two members, x and y. They can not be set separately here, instead use the x or y property of CGUI if you need to set only one coordinate.
	*/
	/*
	Variable: Size
	Size of the window. This object has two members, width and height. They can not be set separately here, instead use the width or height property of CGUI if you need to set only one coordinate.
	*/
	/*
	Variable: Title
	Title of the window.
	*/
	/*
	Variable: ActiveControl
	The control that is currently focused. This returns the control object that is also accessible under this.Controlname and this.Controls.ControlHWND. To set the active control, set this value to either the name of the control or to the control object.
	*/
	/*
	Variable: Enabled
	Determines wether the window is currently enabled.
	*/
	/*
	Variable: Visible
	Determines wether the window is currently visible. This can also be changed by calling this.Show() or this.Hide().
	*/
	/*
	Variable: Style
	The style of this window. Setting it works like the WinSet command. You can add a style by setting this.Style := "+0x8000000" ;(WS_DISABLED).
	*/
	/*
	Variable: ExStyle
	The extended style of this window. Setting it works like the WinSet command. You can add a style by setting this.ExStyle := "+0x8" ;(Always on top).
	*/
	/*
	Variable: Resize
	Makes the window resizable.
	*/
	/*
	Variable: SysMenu
	Provides a system menu button on the left side of the title bar.
	*/
	/*
	Variable: CloseOnEscape
	If true, pressing escape will call the PreClose() event function if defined. Otherwise, it will call Escape() if it is defined.
	*/
	/*
	Variable: DestroyOnClose
	If true, the gui will be destroyed instead of being hidden when it gets closed by the user.
	*/
	/*
	Variable: TransColor
	A color that will be made invisible/see-through on the window. Values: RGB|ColorName|Off
	*/
	/*
	Variable: Transparent
	Transparency of the window. Values: 0 = invisible, 255 = opaque, "Off" = no transparency at all (preferred over 255 for speed).
	*/
	/*
	Variable: MaximizeBox
	Enables the maximize button in the title bar. This is also included as part of Resize.
	*/
	/*
	Variable: MinimizeBox
	Enables the minimize button in the title bar.
	*/
	/*
	Variable: MinSize
	Minimum size of the window.
	*/
	/*
	Variable: MaxSize
	Maximum size of the window.
	*/
	/*
	Variable: Theme
	Determines wether controls are themed.
	*/
	/*
	Variable: ToolWindow
	Provides a narrow title bar.
	*/
	/*
	Variable: Owner
	Makes this window owned by another. This is currently not properly supported because it must be set before the window gets created.
	*/
	/*
	Variable: OwnDialogs
	OwnDialogs should be specified in each thread (such as a ButtonOK subroutine) for which subsequently displayed MsgBox, InputBox, FileSelectFile, and FileSelectFolder dialogs should be owned by the window.
	*/
	/*
	Variable: Region
	Changes the shape of a window to be the specified rectangle, ellipse, or polygon. If the parameter is blank, the window is restored to its original/default display area. See the WinSet command for details.
	*/
	
	/*
	Event functions that can be defined in the class that extends CGUI:
	*/
	/*
	Function: Size
	Called when window size changes.
	
	Parameters:
		Event - Possible values for Event:
				o 0: The window has been restored, or resized normally such as by dragging its edges.
				o 1: The window has been minimized.
				o 2: The window has been maximized.
	*/
	/*
	Function: ContextMenu
	Called when a context menu is about to be invoked. This is mostly useless for now because the control can not get identified properly.
	*/
	/*
	Function: DropFiles
	Called when files were dropped on the gui. This is mostly useless for now because the control can not get identified properly.
	*/
	/*
	Function: PreClose
	Called when the window is about to be closed or when Escape was pressed and CloseOnEscape = true. If it returns true, the window is kept open. Otherwise it will be hidden or destroyed depending on the value of DestroyOnClose.
	*/
	/*
	Function: PostDestroy
	Called when the window was destroyed. Attention: Many variables and functions in this object aren't usable anymore. This function is mostly used to release additional resources or to exit the program.
	*/
	/*
	Function: Escape
	Called when escape is pressed and this.CloseOnEscape = false. The window is not automatically hidden/destroyed when this.CloseOnEscape = false.
	*/
	
	
	
	
	
	/*
	var AlwaysOnTop := 0 ;Makes the window stay on top of all other windows.
	var Border := 0 ;Provides a thin-line border around the window. This is not common.
	var Caption := 1 ;Provides a title bar and a thick window border/edge
	var x	
	var y
	var width
	var height
	var Position 	;Same as x and y, Position := {x:x, y:y}
	var Size		;Same as width and height, Size := {width:width, height:height}
	var Title
	var ActiveControl
	var Enabled
	var Visible
	var Style
	var ExStyle
	var Resize
	var SysMenu
	var CloseOnEscape := 0 ;If true, pressing escape will call the PreClose() event function if defined. Otherwise, it will call Escape() if it is defined.
	var DestroyOnClose := 0 ;If true, the gui will be destroyed instead of being hidden when it gets closed by the user.
	var TransColor := "Off" ;A color that will be made invisible/see-through on the window. Values: RGB|ColorName|Off
	var Transparent := "Off" ;Transparency of the window. Values: 0 = invisible, 255 = opaque, "Off" = no transparency at all (preferred over 255 for speed).
	var MaximizeBox := 0 ;Enables the maximize button in the title bar. This is also included as part of Resize below.
	var MinimizeBox := 1 ;Enables the minimize button in the title bar.	
	var MinSize
	var MaxSize
	var Theme
	var ToolWindow
	var Owner
	var OwnDialogs	
	var Region
		
	Not supported:	
	var Delimiter := "|" ;It's always | for now
	var Label := "CGUI_" ;Labels are handled internally and get rerouted to event functions defined in the class which extends CGUI
	var LastFoundExist := 0 ;This is not needed because the GUI is created anyway when the class gets instantiated.
	
	Event functions that can be defined in the class that extends CGUI:
	Size(Event) ;Called when window size changes
				;Possible values for Event:
				;0: The window has been restored, or resized normally such as by dragging its edges.
				;1: The window has been minimized.
				;2: The window has been maximized.

	ContextMenu() ;Called when a context menu is about to be invoked. This is mostly useless for now because the control can not get identified properly
	DropFiles() ;Called when files were dropped on the gui. This is mostly useless for now because the control can not get identified properly
	PreClose() ;Called when the window is about to be closed or when Escape was pressed and CloseOnEscape = true. If it returns true, the window is kept open. Otherwise it will be hidden or destroyed depending on the value of DestroyOnClose
	PostDestroy() ;Called when the window was destroyed. Attention: Many variables and functions in this object aren't usable anymore. This function is mostly used to release additional resources or to exit the program.
	Escape() ;Called when escape is pressed and CloseOnEscape = false. The window is not automatically hidden/destroyed when CloseOnEscape = false.
	*/
	
	
	/*
	Constructor: __New
	Initializes and creates the window. This should be called at the beginning of the constructor of the class that extends CGUI like this: Base.__New()
	*/
	__New()
	{
		global CGUI
		start := 10 ;Let's keep some gui numbers free for other uses
		loop {
			Gui %start%:+LastFoundExist
			IfWinNotExist
			{
				this.GUINum := start
				break
			}
			start++
			if(start = 100)
				break
		}
		if(!this.GUINum)
			return ""
		this.Controls := Object()
		this.Insert("_", {}) ;Create proxy object to store some keys in it and still trigger __Get and __Set
		CGUI.GUIList[this.GUINum] := this
		GUI, % this.GUINum ":+LabelCGUI_ +LastFound"		
		this.hwnd := WinExist()
	}
	__Delete()
	{
	}
	
	/*
	Function: Destroy
	
	Destroys the window. Any possible references to this class should be removed so its __Delete() function may get called. Make sure not attempt to use this window anymore!
	*/
	Destroy()
	{
		global CGUI
		if(this.IsDestroyed)
			return
		;~ for hwnd, Control in this.Private.Controls ;Break circular references to allow object release
			;~ Control.GUI := ""
		CGUI.GUIList.Remove(this.GUINum, "") ;make sure not to alter other GUIs here
		this.IsDestroyed := true		
		;Destroy the GUI and remove it from gui lists
		Gui, % this.GUINum ":Destroy"
		if(IsFunc(this.PostDestroy))
			this.PostDestroy()
	}
	
	/*
	Function: Show
	
	Shows the window.
	
	Parameters:
	
		Options - Same as in Gui, Show command
	*/
	Show(Options="")
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Show",%Options%, % this.Title
	}
	
	/*
	Function: Activate
	
	Activates the window.
	*/
	Activate()
	{
		if(this.IsDestroyed)
			return
		WinActivate, % "ahk_id " this.hwnd
	}
	
	/*
	Function: Hide
	
	Hides the window.
	*/
	Hide()
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Hide"
	}
	
	/*
	Function: Minimize
	
	Minimizese the window.
	*/
	Minimize()
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Minimize"
	}
	
	/*
	Function: Maximize
	
	Maximizes the window.
	*/
	Maximize()
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Maximize"
	}
	
	/*
	Function: Restore
	
	Restores the window.
	*/
	Restore()
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Restore"
	}
	/*
	Function: Redraw
	
	Attempts to redraw the window.
	*/
	Redraw()
	{
		if(this.IsDestroyed)
			return
		WinSet, Redraw,,% "ahk_id " this.hwnd
	}
	
	/*
	Function: Font
	
	Changes the default font used for controls from here on.
	
	Parameters:
		Options - Font options, size etc. See http://www.autohotkey.com/docs/commands/Gui.htm#Font
		Fontname - Name of the font. See http://www.autohotkey.com/docs/commands/Gui.htm#Font
	*/
	Font(Options, Fontname)
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Font", %Options%, %Fontname%
	}
	
	/*
	Function: Color
	
	Changes the default font used for controls from here on.
	
	Parameters:
		WindowColor - Color of the window background. See http://www.autohotkey.com/docs/commands/Gui.htm#Color
		ControlColor - Color for controls. See http://www.autohotkey.com/docs/commands/Gui.htm#Color
	*/
	Color(WindowColor, ControlColor)
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Color", %WindowColor%, %ControlColor%
	}
	
	/*
	Function: Margin
	
	Changes the margin used between controls. Previously added controls are not affected.
	
	Parameters:
		x - Distance between controls on the x-axis.
		y - Distance between controls on the y-axis.
	*/
	Margin(x, y)
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Margin", %x%, %y%
	}
	
	/*
	Function: Flash
	
	Flashes the taskbar button of this window.
	
	Parameters:
		Off - Leave empty to flash the taskbar. Use "Off" to disable flashing and restore normal state.
	*/
	Flash(Off = "")
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Flash", %Off%
	}
	
	/*
	Function: Menu
	
	Attaches a menu bar to the window.
	
	Parameters:
		Menuname - The name of a menu which was previously created with the Menu (<http://www.autohotkey.com/docs/commands/Menu.htm>) command. Leave empty to remove the menu bar.
	*/
	Menu(Menuname="")
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Menu", %Menname%
	}
	
	/*
	Function: Add
	
	Creates and adds a control to the window.
	
	Parameters:
		Control - The type of the control. The control needs to be a name that can be translated to a class inheriting from CControl, e.g. "Text" -> "CTextControl". Valid values are:
					- Text
					- Edit
					- Button
					- Checkbox
					- Radio
					- ListView
					- ComboBox
					- DropDownList
					- ListBox
		Name - The name of the control. The control can be accessed by its name directly from the GUI object, i.e. GUI.MyEdit1 or similar. Names must be unique and must not be empty.
		Options - Default options to be used for the control. These are in default AHK syntax according to <http://www.autohotkey.com/docs/commands/Gui.htm#OtherOptions> and <http://www.autohotkey.com/docs/commands/GuiControls.htm>.
		Text - Text of the control. For some controls, this parameter has a special meaning. It can be a list of items or a collection of column headers separated by "|".
	*/
	Add(Control, Name, Options, Text)
	{
		global
		local hControl, type
		if(this.IsDestroyed)
			return
		if(!Name)
		{
			Msgbox No name specified. Please supply a proper control name.
			return
		}
		if(IsObject(this[Name]))
		{
			Msgbox The control %Name% already exists. Please choose another name!
			return
		}
		if(Control = "DropDownList" || Control = "ComboBox" || Control = "ListBox")
		{
			type := Control
			Control := object("base", CChoiceControl)
			Control.__New(Name, Options, Text, this.GUINum, type)
		}
		else if(Control = "Checkbox" || Control = "Radio" )
		{
			type := Control
			Control := object("base", CCheckboxControl)
			Control.__New(Name, Options, Text, this.GUINum, type)
		}
		else
		{
			Control := "C" Control "Control"
			if(IsObject(%Control%))
			{
				Control := object("base", %Control%)
				Control.__New(Name, Options, Text, this.GUINum)
			}
			else
			{
				Msgbox The control %Control% was not found!
				return
			}
		}
		
		if(IsFunc(this[Control.Name]) && ! IsLabel(this.__Class "_" Control.Name))
			Msgbox % "Event notification function found for " Control.Name ", but the appropriate label " this.__Class "_" Control.Name " does not exist!"
		Gui, % this.GUINum ":Add", % Control.Type, % Control.Options " hwndhControl " (IsLabel(this.__Class "_" Control.Name) ? "g" this.__Class "_" Control.Name : ""), % Control.Content ;Create the control and get its window handle and setup a g-label
		Control.Remove("Content")
		Control.hwnd := hControl ;Window handle is used for all further operations on this control
		this.Controls[hControl] := Control ;Add to list of controls
		this[Control.Name] := Control
		return Control
	}
	__Get(Name)
	{
		global CGUI	
			
		DetectHidden := A_DetectHiddenWindows
		DetectHiddenWindows, On
		if(Name = "IsDestroyed" && this.GUINum) ;Extra check in __Get for this property because it might be destroyed through an old-style Gui, Destroy command
		{
			GUI, % this.GUINum ":+LastFoundExist"
			Value := WinExist() = 0
		}
		else if(Name != "IsDestroyed" && Name != "GUINum" && !this.IsDestroyed)
		{
			if Name in x,y,width, height
			{
				WinGetPos, x,y,width,height,% "ahk_id " this.hwnd
				Value := %Name%
			}
			else if(Name = "Position")
			{
				WinGetPos, x,y,,,% "ahk_id " this.hwnd
				Value := {x:x,y:y}
			}
			else if(Name = "Size")
			{
				WinGetPos,,,width,height,% "ahk_id " this.hwnd
				Value := {width:width, height:height}
			}
			else if(Name = "Title")
				WinGetTitle, Value, % "ahk_id " this.hwnd
			else if Name in Style,ExStyle, TransColor, Transparent, MinMax
				WinGet, Value, %Name%, % "ahk_id " this.hwnd
			else if(Name = "ActiveControl") ;Returns the control object that has keyboard focus
			{
				ControlGetFocus, Value, % "ahk_id " this.hwnd
				ControlGet, Value, Hwnd,, %Value%, % "ahk_id " this.hwnd
				Value := this.Controls[Value]
			}
			else if(Name="Enabled")
				Value := !(this.Style & 0x8000000) ;WS_DISABLED
			else if(Name = "Visible")
				Value :=  this.Style & 0x10000000
			else if(Name = "AlwaysOnTop")
				Value := this.ExStyle & 0x8
			else if(Name = "Border")
				Value := this.Style & 0x800000
			else if(Name = "Caption")
				Value := this.Style & 0xC00000
			else if(Name = "MaximizeBox")
				Value := this.Style & 0x10000
			else if(Name = "MinimizeBox")
				Value := this.Style & 0x10000
			else if(Name = "Resize")
				Value := this.Style & 0x40000
			else if(Name = "SysMenu")
				Value := this.Style & 0x80000
		}
		if(Value = "" && Name = "Instances") ;Returns a list of instances of this window class
		{
			Value := Array()
			for GuiNum,GUI in CGUI.GUIList
				if(GUI.__Class = this.__Class)
					Value.Insert(GUI)
		}
		else if(Value = "" && Name = "MinSize")
			Value := this._.MinSize
		else if(Value = "" && Name = "MaxSize")
			Value := this._.MaxSize
		else if(Value = "" && Name = "Theme")
			Value := this._.Theme
		else if(Value = "" && Name = "ToolWindow")
			Value := this._.ToolWindow
		else if(Value = "" && Name = "Owner")
			Value := this._.Owner
		else if(Value = "" && Name = "OwnDialogs")
			Value := this._.OwnDialogs
		else if(Value = "" && Name = "Region")
			Value := this._.Region
		if(!DetectHidden)
			DetectHiddenWindows, Off
		if(Value != "")
			return Value
	}
	__Set(Name, Value)
	{
		DetectHidden := A_DetectHiddenWindows
		DetectHiddenWindows, On
		Handled := true
		if(!this.IsDestroyed)
		{
			if Name in AlwaysOnTop,Border,Caption,LastFound,LastFoundExist,MaximizeBox,MaximizeBox,MinimizeBox,Resize,SysMenu
				Gui, % this.GUINum ":" (Value = 1 ? "+" : "-") Name
			else if Name in OwnDialogs, Theme, ToolWindow
			{
				Gui, % this.GUINum ":" (Value = 1 ? "+" : "-") Name
				this._[Name] := Value = 1
			}
			else if Name in MinSize, MaxSize
			{
				Gui, % this.GUINum ":+" Name Value
				if(!IsObject(this._[Name]))
					this._[Name] := {}
				Loop, Parse, Value, x
				{
					if(!A_LoopField)
						this._[Name][A_Index = 1 ? "width" : "height"] := A_Index = 1 ? this.width : this.height
					else
						this._[Name][A_Index = 1 ? "width" : "height"] := A_LoopField
				}
			}
			else if(Name = "Owner")
			{
				Gui, % this.GUINum ":" (Value > 0 && Value < 100 && Value != this.GUINum ? "+" : "-") "Owner" Value
				this._.Owner := Value
			}
			else if Name in Style, ExStyle, Transparent, TransColor
				WinSet, %Name%, %Value%, % "ahk_id " this.hwnd
			else if(Name = "Region")
			{
				WinSet, Region, %Value%, % "ahk_id " this.hwnd
				this._.Region := Value
			}
			else if Name in x,y,width, height
				WinMove,% "ahk_id " this.hwnd,,% Name = "x" ? Value : "", % Name = "y" ? Value : "", % Name = "width" ? Value : "", % Name = "height" ? Value : ""
			else if(Name = "Position")
				WinMove,% "ahk_id " this.hwnd,,% Value.x, % Value.y
			else if(Name = "Size")
				WinMove,% "ahk_id " this.hwnd,,,, % Value.width, % Value.height
			else if(Name = "Title")
				WinSetTitle, % "ahk_id " this.hwnd,,%Value%
			else if(Name = "ActiveControl")
			{
				if(!IsObject(Value))
					Value := this[Value]
				if(IsObject(Value))
					ControlFocus,,% "ahk_id " Value.hwnd
			}
			else if(Name = "Enabled")
				this.Style := (Value ? "-" : "+") 0x8000000 ;WS_DISABLED
			else if(Name = "Visible")
				this.Style := (Value ? "+" : "-") 0x10000000 ;WS_VISIBLE			
			else if(Name = "_") ;Prohibit setting the proxy object
				Handled := true
			else
				Handled := false
		}
		else
			Handled := false
		if(!DetectHidden)
			DetectHiddenWindows, Off
		if(Handled)
			return Value
	}
	/*
	Main event rerouting function. It identifies the associated window/control and calls the related event function if it is defined. It also handles some things on its own, such as window closing.
	*/
	HandleEvent()
	{
		global CGUI
		if(this.IsDestroyed)
			return
		ErrLevel := ErrorLevel
		ControlName := SubStr(A_ThisLabel, InStr(A_ThisLabel, "_") + 1)
		GUI := CGUI.GUIList[A_GUI]
		if(IsObject(GUI))
		{
			if(InStr(A_ThisLabel, "CGUI_")) ;Handle default gui events (Close, Escape, DropFiles, ContextMenu)
			{
				func := SubStr(A_ThisLabel, InStr(A_ThisLabel, "_") + 1)
				func := func = "Escape" && GUI.CloseOnEscape ? "PreClose" : func
				func := func = "Close" ? "PreClose" : func
				if(IsFunc(GUI[func]))
				{				
					ErrorLevel := ErrLevel
					result := `(GUI)[func]()
				}
				if(!this.IsDestroyed)
				{
					if(func = "PreClose" && !result && !GUI.DestroyOnClose) ;Hide the GUI
						GUI.Hide()
					else if(func = "PreClose" && !result)
						GUI.Destroy()
				}
			}
			else
			{
				for Hwnd, Control in GUI.Controls
				{
					if(Control.Name = ControlName)
					{
						ErrorLevel := ErrLevel
						Control.HandleEvent()
						return
					}
				}
			}
		}
	}
}

;Event handlers for gui and control events:
CGUI_Size:
CGUI_ContextMenu:
CGUI_DropFiles:
CGUI_Close:
CGUI_Escape:
CControl_Event:
CGUI.HandleEvent()
return
/*
Ideas:
Anchor
Dock
ShowDialog (modal to another CGUI)
All kinds of events, some maybe through OnMessage
*/
#include <CControls>
#include <CDialogs>
#include <CEnumerator>
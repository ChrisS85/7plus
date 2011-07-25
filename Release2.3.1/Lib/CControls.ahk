Class CControl ;Never created directly
{
	__New(Name, Options, Text, GUINum) ;Basic constructor for all controls. The control is created in CGUI.Add()
	{
		global CFont
		this.Name := Name
		this.Options := Options
		this.Content := Text
		this.GUINum := GUINum ;Store link to gui for GuiControl purposes (and possibly others later
		this.Insert("_", {}) ;Create proxy object to enable __Get and __Set calls for existing keys (like ClassNN which stores a cached value in the proxy)
		this.Font := new CFont(GUINum, Name)
	}
	Show()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		Control, Show,,,% "ahk_id " this.hwnd
	}
	Hide()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		Control, Hide,,,% "ahk_id " this.hwnd
	}
	Enable()
	{
		Control, Enable,,,% "ahk_id " this.hwnd
	}
	Disable()
	{
		Control, Disable,,,% "ahk_id " this.hwnd
	}
	Focus()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		ControlFocus,,% "ahk_id " this.hwnd
	}
	;~ Font(Options, Font="")
	;~ {
		;~ global CGUI
		;~ if(CGUI.GUIList[this.GUINum].IsDestroyed)
			;~ return
		;~ Gui, % this.GUINum ":Font", %Options%, %Font%
		;~ GuiControl, % this.GUINum ":Font", % this.ClassNN
		;~ Gui, % this.GUINum ":Font", % CGUI.GUIList[this.GUINum].Font.Options, % CGUI.GUIList[this.GUINum].Font.Font ;Restore current font
	;~ }
	__Get(Name)
    {
		global CGUI
		if(Name != "_" && Name != "GUINum" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if(Name = "Text")
				GuiControlGet, Value,% this.GuiNum ":", % this.ClassNN
				;~ ControlGetText, Value,, % "ahk_id " this.hwnd
			;~ else if(Name = "GUI")
				;~ value := CGUI.GUIList[this.GUINum]
			else if(Name = "x" || Name = "y"  || Name = "width" || Name = "height")
			{
				ControlGetPos, x,y,width,height,,% "ahk_id " this.hwnd
				Value := %Name%
			}
			else if(Name = "Position")
			{
				ControlGetPos, x,y,,,,% "ahk_id " this.hwnd
				Value := {x:x, y:y}
			}
			else if(Name = "Size")
			{
				ControlGetPos,,,width,height,,% "ahk_id " this.hwnd
				Value := {width:width, height:height}
			}
			else if(Name = "ClassNN")
			{
				if(this._.ClassNN != "" && this.hwnd && WinExist("ahk_class " this._.ClassNN) = this.hwnd) ;Check for cached value first
					return this._.ClassNN
				else
				{
					win := DllCall("GetParent", "PTR", this.hwnd, "PTR")
					WinGet ctrlList, ControlList, ahk_id %win%
					Loop Parse, ctrlList, `n 
					{
						ControlGet hwnd, Hwnd, , %A_LoopField%, ahk_id %win%
						if(hwnd=this.hwnd)
						{
							Value := A_LoopField
							break
						}
					}
					this._.ClassNN := value
				}
			}
			else if(Name = "Enabled")
				ControlGet, Value, Enabled,,,% "ahk_id " this.hwnd
			else if(Name = "Visible")
				ControlGet, Value, Visible,,,% "ahk_id " this.hwnd
			else if(Name = "Style")
				ControlGet, Value, Style,,,% "ahk_id " this.hwnd
			else if(Name = "ExStyle")
				ControlGet, Value, ExStyle,,,% "ahk_id " this.hwnd
			else if(Name = "Focused")
			{
				ControlGetFocus, Value, % "ahk_id " CGUI.GUIList[this.GUINum].hwnd
				ControlGet, Value, Hwnd,, %Value%, % "ahk_id " CGUI.GUIList[this.GUINum].hwnd
				Value := Value = this.hwnd
			}
			else if(key := {Left : "Left", Center : "Center", Right : "Right", TabStop : "TabStop", Wrap : "Wrap", HScroll : "HScroll", VScroll : "VScroll", BackgroundTrans : "BackgroundTrans", Background : "Background", Border : "Border"}[Name])
				GuiControl, % this.GUINum ":", (Value ? "+" : "-") key
			else if(Name = "Color")
				GuiControl, % this.GUINum ":", "+c" Value
			else if(this._.HasKey("ControlStyles") && Style := this._.ControlStyles[Name])
			{
				if(SubStr(Style, 1,1) = "-")
				{
					Negate := true
					Style := SubStr(Style, 2)
				}
				ControlGet, Value, Style,,,% "ahk_id " this.hwnd
				Value = Value & Style > 0
				if(Negate)
					Value := !Value
			}
			else if(this._.HasKey("ControlExStyles") && ExStyle := this._.ControlExStyles[Name])
			{
				if(SubStr(ExStyle, 1,1) = "-")
				{
					Negate := true
					ExStyle := SubStr(ExStyle, 2)
				}
				ControlGet, Value, ExStyle,,,% "ahk_id " this.hwnd
				Value = Value & ExStyle > 0
				if(Negate)
					Value := !Value
			}
			else if(Name = "Tooltip")
				Value := this._.Tooltip
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Value != "")
				return Value
		}
    }
    __Set(Name, Value)
    {
		global CGUI
		if(Name != "_" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			Handled := true
			if(Name = "Text")
				GuiControl, % this.GUINum ":",% this.ClassNN, %Value% ;Use GuiControl because of line endings
			else if(Name = "x" || Name = "y"  || Name = "width" || Name = "height")
				ControlMove,, % (Name = "x" ? Value : ""),% (Name = "y" ? Value : ""),% (Name = "width" ? Value : ""),% (Name = "height" ? Value : ""),% "ahk_id " this.hwnd
			else if(Name = "Position")
				ControlMove,, % Value.x,% Value.y,,,% "ahk_id " this.hwnd
			else if(Name = "Size")
				ControlMove,, % Value.width,% Value.height,% "ahk_id " this.hwnd
			else if(Name = "Enabled")
				Control, % (Value = 0 ? "Disable" : "Enable"),,,% "ahk_id " this.hwnd
			else if(Name = "Visible")
				Control,  % (Value = 0 ? "Hide" : "Show"),,,% "ahk_id " this.hwnd
			else if(Name = "Style")
				Control, Style, %Value%,,,% "ahk_id " this.hwnd
			else if(Name = "ExStyle")
				Control, ExStyle, %Value%,,,% "ahk_id " this.hwnd
			else if(Name = "_") ;Prohibit setting the proxy object
				Handled := true
			else if(this._.HasKey("ControlStyles") && Style := this._.ControlStyles[Name])
			{
				if(SubStr(Style, 1,1) = "-")
				{
					Value := !Value
					Style := SubStr(Style, 2)
				}
				Style := (Value ? "+" : "-") Style
				Control, Style, %Style%,, % "ahk_id " this.hwnd
			}
			else if(this._.HasKey("ControlExStyles") && ExStyle := this._.ControlExStyles[Name])
			{
				if(SubStr(ExStyle, 1,1) = "-")
				{
					Value := !Value
					ExStyle := SubStr(ExStyle, 2)
				}
				ExStyle := (Value ? "+" : "-") ExStyle
				Control, ExStyle, %ExStyle%,, % "ahk_id " this.hwnd
			}
			else if(Name = "Tooltip") ;Thanks art http://www.autohotkey.com/forum/viewtopic.php?p=452514#452514
			{
				TThwnd := CGUI.GUIList[this.GUINum]._.TThwnd
				Guihwnd := CGUI.GUIList[this.GUINum].hwnd
				Controlhwnd := [this.hwnd]
				if(this.type = "ComboBox") ;'ComboBox' = Drop-Down button + Edit
				{
					VarSetCapacity(CBBINFO, 52, 0)
					NumPut(52, CBBINFO,0, "UINT")
					result := DllCall("GetComboBoxInfo", "UInt", Controlhwnd[1], "PTR", &CBBINFO)
					Controlhwnd.Insert(Numget(CBBINFO,44))
				}
				else if(this.type = "ListView")
					Controlhwnd.Insert(DllCall("SendMessage", "UInt", Controlhwnd[1], "UInt", 0x101f, "PTR", 0, "PTR", 0))
				; - 'Text' and 'Picture' Controls requires a g-label to be defined. 
				if(!TThwnd){         
					; - 'ListView' = ListView + Header       (Get hWnd of the 'Header' control using "ControlGet" command). 
					TThwnd := CGUI.GUIList[this.GUINum]._.TThwnd := DllCall("CreateWindowEx","Uint",0,"Str","TOOLTIPS_CLASS32","Uint",0,"Uint",2147483648 | 3,"Uint",-2147483648 
									,"Uint",-2147483648,"Uint",-2147483648,"Uint",-2147483648,"Uint",GuiHwnd,"Uint",0,"Uint",0,"Uint",0) 
					DllCall("uxtheme\SetWindowTheme","Uint",TThwnd,Ptr,0,"UintP",0)   ; TTM_SETWINDOWTHEME 
				}
				for index, chwnd in Controlhwnd
				{
					Varsetcapacity(TInfo,44,0), Numput(44,TInfo), Numput(1|16,TInfo,4), Numput(GuiHwnd,TInfo,8), Numput(chwnd,TInfo,12), Numput(&Value,TInfo,36) 
					!this._.Tooltip   ? (DllCall("SendMessage",Ptr,TThwnd,"Uint",1028,Ptr,0,Ptr,&TInfo,Ptr))         ; TTM_ADDTOOL = 1028 (used to add a tool, and assign it to a control) 
					. (DllCall("SendMessage",Ptr,TThwnd,"Uint",1048,Ptr,0,Ptr,A_ScreenWidth))      ; TTM_SETMAXTIPWIDTH = 1048 (This one allows the use of multiline tooltips) 
					DllCall("SendMessage",Ptr,TThwnd,"UInt",(A_IsUnicode ? 0x439 : 0x40c),Ptr,0,Ptr,&TInfo,Ptr)   ; TTM_UPDATETIPTEXT (OLD_MSG=1036) (used to adjust the text of a tip)
				}
			}
			else
				Handled := false
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Handled)
				return Value
		}
    }
	Class CImageListManager
	{
		__New(GUINum, ControlName)
		{
			this.Insert("_", {})
			this._.GUINum := GUINum
			this._.ControlName := ControlName
			this._.IconList := {}
		}
		SetIcon(ID, Path, IconNumber)
		{
			global CGUI
			GUI := CGUI.GUIList[this._.GUINum]
			Control := GUI[this._.ControlName]
			GUI, % this._.GUINum ":Default"
			if(Control.Type = "ListView")
				GUI, ListView, % Control.ClassNN
			else if(Control.Type = "TreeView")
				Gui, TreeView, % Control.ClassNN
			if(!this._.IconList.SmallIL_ID)
			{
				if(Control.Type = "ListView") ;Listview also has large icons
				{
					this._.IconList.LargeIL_ID := IL_Create(5,5,1)
					LV_SetImageList(this._.IconList.LargeIL_ID)
				}
				this._.IconList.SmallIL_ID := IL_Create(5,5,0)
				if(Control.Type = "ListView")
					LV_SetImageList(this._.IconList.SmallIL_ID)
				else if(Control.Type = "TreeView")
				{
					SendMessage, 0x1109, 0, this._.IconList.SmallIL_ID, % Control.ClassNN, % "ahk_id " GUI.hwnd  ; 0x1109 is TVM_SETIMAGELIST
					if ErrorLevel  ; The TreeView had a previous ImageList.
						IL_Destroy(ErrorLevel)
				}
			}
			if(Path != "")
			{
				Loop % this._.IconList.MaxIndex() ;IDs and paths and whatnot are identical in both lists so one is enough here
					if(this._.IconList[A_Index].Path = Path && this._.IconList[A_Index].IconNumber = IconNumber)
					{
						Icon := this._.IconList[A_Index]
						break
					}
				
				if(!Icon)
				{
					IID := IL_Add(this._.IconList.SmallIL_ID, Path, IconNumber, 1)
					if(Control.Type = "ListView")
						IID := IL_Add(this._.IconList.LargeIL_ID, Path, IconNumber, 1)
					this._.IconList.Insert(Icon := {Path : Path, IconNumber : IconNumber, ID : IID})
				}
			}
			if(Control.Type = "ListView")
				LV_Modify(ID, "Icon" (Icon ? Icon.ID : -1))
			else if(Control.Type = "TreeView")
				TV_Modify(ID, "Icon" (Icon ? Icon.ID : -1))
		}
	}
}
;Idea: Link?
Class CTextControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Type := "Text"
		this._.Insert("ControlStyles", {Center : 0x1, Left : 0, Right : 0x2, Wrap : -0xC})
		this._.Insert("Events", ["Click", "DoubleClick"])
	}
	__Set(Name, Value)
	{
		if(Name = "Link")
		{
			WM_SETCURSOR := 0x20
			WM_MOUSEMOVE := 0x200
			WM_NCMOUSELEAVE := 0x2A2
			WM_MOUSELEAVE := 0x2A3
			if(Value)
			{
				OnMessage(WM_SETCURSOR, "CGUI.HandleMessage")
				OnMessage(WM_MOUSEMOVE, "CGUI.HandleMessage")
			}
			this._.Link := Value > 0
			this.Font.Options := "cBlue"
		}
	}
	__Get(Name)
	{
		if(Name = "Link")
			return this._.Link
	}
	HandleMessage(wParam, lParam, msg)
	{
		static WM_SETCURSOR := 0x20, WM_MOUSEMOVE := 0x200, WM_NCMOUSELEAVE := 0x2A2, WM_MOUSELEAVE := 0x2A3
		static   URL_hover, h_cursor_hand, CtrlIsURL, LastCtrl
		if(!this.Link)
			return
		If (msg = WM_SETCURSOR)
		{
			tooltip setcursor
			If(this._.Hovering)
				Return true
		}
		Else If (p_m = WM_MOUSEMOVE)
		{
			; Mouse cursor hovers URL text control
			If URL_hover=
			{
				Gui, 1:Font, cBlue underline
				GuiControl, 1:Font, %A_GuiControl%
				LastCtrl = %A_GuiControl%

				h_cursor_hand := DllCall("LoadCursor", "Ptr", 0, "uint", 32649, "Ptr")

				URL_hover := true
			}
			this._.h_old_cursor := DllCall("SetCursor", "Ptr", h_cursor_hand, "Ptr")
			; Mouse cursor doesn't hover URL text control
			;~ Else
			;~ {
				;~ If URL_hover
				;~ {
					;~ Gui, 1:Font, norm cBlue
					;~ GuiControl, 1:Font, %LastCtrl%

					;~ DllCall("SetCursor", "Ptr", h_old_cursor)

					;~ URL_hover=
				;~ }
			;~ }
		}
	}
	HandleEvent()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		ErrLevel := ErrorLevel
		if(A_GUIEvent = "DoubleClick")
		{
			if(IsFunc(CGUI.GUIList[this.GUINum][this.Name "_DoubleClick"]))
			{
				ErrorLevel := ErrLevel
				`(CGUI.GUIList[this.GUINum])[this.Name "_DoubleClick"]()
			}
		}
		else
		{
			if(IsFunc(CGUI.GUIList[this.GUINum][this.Name "_Click"]))
			{
				ErrorLevel := ErrLevel
				`(CGUI.GUIList[this.GUINum])[this.Name "_Click"]()
			}
		}
	}
}
Class CEditControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Type := "Edit"
		this._.Insert("ControlStyles", {Center : 0x1, LowerCase : 0x10, Number : 0x2000, Multi : 0x4, Password : 0x20, ReadOnly : 0x800, Right : 0x2, Uppercase : 0x8, WantReturn : 0x1000})
		this._.Insert("Events", ["TextChanged"])
	}
	AddUpDown(Min, Max)
	{
		WM_USER := 0x0400 
		UDM_SETBUDDY := WM_USER + 105
		Gui, % this.GUINum ":Add", UpDown, -16 Range%Min%-%Max% hwndhUpDown, % this.Text
		hwnd := this.hwnd
		SendMessage, UDM_SETBUDDY, hwnd, 0,, % "ahk_id " hwnd
		this._.UpDownHwnd := hUpDown
		this._.Min := Min
		this._.Max := Max
	}
	__Get(Name)
    {
		global CGUI
		if(Name != "GUINum" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			if(Name = "Text" && this._.UpDownHwnd)
				GuiControlGet, Value, % this.GUINum ":", % this.ClassNN
		}
		if(Value)
			return Value
	}
	HandleEvent()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		ErrLevel := ErrorLevel
		if(IsFunc(CGUI.GUIList[this.GUINum][this.Name "_TextChanged"]))
		{
			ErrorLevel := ErrLevel
			`(CGUI.GUIList[this.GUINum])[this.Name "_TextChanged"]()
		}
	}
}
Class CButtonControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Type := "Button"
		this._.Insert("ControlStyles", {Center : 0x300, Left : 0x100, Right : 0x200, Default : 0x1, Wrap : 0x2000, Flat : 0x8000})
		this._.Insert("Events", ["Click"])
	}	
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
Class CCheckBoxControl Extends CControl ;This class is a radio control as well
{
	__New(Name, Options, Text, GUINum, Type)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Type := Type
		this._.Insert("ControlStyles", {Center : 0x300, Left : 0x100, Right : 0x200, RightButton : 0x20, Default : 0x1, Wrap : 0x2000, Flat : 0x8000})
		this._.Insert("Events", ["CheckedChanged"])
	}
	__Get(Name)
    {
		global CGUI
		if(Name != "GUINum" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if(Name = "Checked")
				ControlGet, Value, Checked,,,% "ahk_id " this.hwnd
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Value != "")
				return Value
		}
	}
	__Set(Name, Value)
	{
		global CGUI
		if(!CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			Handled := true
			if(Name = "Checked")
				GuiControl, % this.GuiNum ":", % this.ClassNN,% (Value = 0 ? 0 : 1)
				;~ Control, % (Value = 0 ? "Uncheck" : "Check"),,,% "ahk_id " this.hwnd ;This lines causes weird problems. Only works sometimes and might change focus
			else
				Handled := false
		if(!DetectHidden)
			DetectHiddenWindows, Off
		if(Handled)
			return Value
		}
	}
	HandleEvent()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		ErrLevel := ErrorLevel
		if(IsFunc(CGUI.GUIList[this.GUINum][this.Name "_CheckedChanged"]))
		{
			ErrorLevel := ErrLevel
			`(CGUI.GUIList[this.GUINum])[this.Name "_CheckedChanged"]()
		}
	}
}
Class CChoiceControl Extends CControl ;This class is a ComboBox, ListBox and DropDownList
{
	__New(Name, Options, Text, GUINum, Type)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Type := Type
		if(Type = "Combobox")
			this._.Insert("ControlStyles", {LowerCase : 0x400, Uppercase : 0x2000, Sort : 0x100, Simple : 0x1})
		else if(Type = "DropDownList")
			this._.Insert("ControlStyles", {LowerCase : 0x400, Uppercase : 0x2000, Sort : 0x100})
		else if(Type = "ListBox")
			this._.Insert("ControlStyles", {Multi : 0x800, ReadOnly : 0x4000, Sort : 0x2, ToggleSelection : 0x8})
		this._.Insert("Events", ["SelectionChanged"])
		this._.Items := new this.CItems(GUINum, Name)
	}
	__Get(Name, Params*)
    {
		global CGUI
		if(Name != "GUINum" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if(Name = "SelectedItem")
				ControlGet, Value, Choice,,,% "ahk_id " this.hwnd
			else if(Name = "SelectedIndex")
			{
				SendMessage, 0x147, 0, 0,,% "ahk_id " this.hwnd
				Value := ErrorLevel + 1
			}
			else if(Name = "Items")
				Value := this._.Items
			;~ else if(Name = "Items")
			;~ {
				;~ ControlGet, List, List,,, % " ahk_id " this.hwnd
				;~ Value := Array()
				;~ Loop, Parse, List, `n
					;~ Value.Insert(A_LoopField)			
			;~ }
			Loop % Params.MaxIndex()
				if(IsObject(Value)) ;Fix unlucky multi parameter __GET
					Value := Value[Params[A_Index]]
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Value != "")
				return Value
		}
	}
	__Set(Name, Params*)
	{
		global CGUI
		if(!CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			Value := Params[Params.MaxIndex()]
			Params.Remove(Params.MaxIndex())
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			Handled := true
			if(Name = "SelectedItem")
			{
				Items := this.Items
				Loop % Items.MaxIndex()
					if(Items[A_Index] = Value)
						Control, Choose, %A_Index%,,% "ahk_id " this.hwnd
			}
			else if(Name = "SelectedIndex" && Value >= 1)
				Control, Choose, %Value%,,% "ahk_id " this.hwnd
			else if(Name = "Items" && !Params[1])
			{
				Items := this.Items
				if(!IsObject(Value))
				{
					if(InStr(Value, "|") = 1) ;Overwrite current items
						Items := []
					Loop, Parse, Value,|
						if(A_LoopField)
							Items.Insert(A_LoopField)
				}
				else
				{
					Items := []
					Loop % Value.MaxIndex()
						Items.Insert(Value[A_Index])
				}
				ItemsString := ""
				Loop % Items.MaxIndex()
					ItemsString .= "|" Items[A_Index]
				GuiControl, % this.GUINum ":", % this.ClassNN, %ItemsString%
				if(!IsObject(Value) && InStr(Value, "||"))
				{
					if(RegExMatch(Value, "(?:^|\|)(..*?)\|\|", SelectedItem))
						Control, ChooseString, %SelectedItem1%,,% "ahk_id " this.hwnd
				}
			}
			else if(Name = "Items" && Params[1] > 0)
			{
				this._.Items[Params[1]] := Value
				;~ msgbox should not be here
				;~ Items := this.Items
				;~ Items[Params[1]] := Value
				;~ ItemsString := ""
				;~ Loop % Items.MaxIndex()
					;~ ItemsString .= "|" Items[A_Index]
				;~ SelectedIndex := this.SelectedIndex
				;~ GuiControl, % this.GUINum ":", % this.ClassNN, %ItemsString%
				;~ GuiControl, % this.GUINum ":Choose", % this.ClassNN, %SelectedIndex%
			}
			else if(Name = "Text" && this.Type != "DropDownList")
				Handled := false ;Do nothing
			else
				Handled := false
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Handled)
				return Value
		}
	}
	HandleEvent()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		ErrLevel := ErrorLevel
		if(IsFunc(CGUI.GUIList[this.GUINum][this.Name "_SelectionChanged"]))
		{
			ErrorLevel := ErrLevel
			`(CGUI.GUIList[this.GUINum])[this.Name "_SelectionChanged"]()
		}
	}
	Class CItems
	{
		__New(GUINum, ControlName)
		{
			this.Insert("_", {})
			this._.GUINum := GUINum
			this._.ControlName := ControlName
		}
		__Get(Name)
		{
			global CGUI
			if Name is Integer
			{
				if(Name <= this.MaxIndex())
				{
					DetectHidden := A_DetectHiddenWindows
					DetectHiddenWindows, On
					GUI := CGUI.GUIList[this._.GUINum]
					Control := GUI[this._.ControlName]
					ControlGet, List, List,,, % " ahk_id " Control.hwnd
					Loop, Parse, List, `n
						if(A_Index = Name)
						{
							Value := A_LoopField
							break
						}
					if(!DetectHidden)
						DetectHiddenWindows, Off
					return Value
				}
			}
		}
		__Set(Name, Value)
		{
			global CGUI
			if Name is Integer
			{
				GUI := CGUI.GUIList[this._.GUINum]
				Control := GUI[this._.ControlName]
				ItemsString := ""
				SelectedIndex := Control.SelectedIndex
				for index, item in this
					ItemsString .= "|" (index = Name ? Value : this[A_Index])
				GuiControl, % this._.GUINum ":", % Control.ClassNN, %ItemsString%
				GuiControl, % this._.GUINum ":Choose", % Control.ClassNN, %SelectedIndex%
				return Value
			}
		}
		MaxIndex()
		{
			global CGUI
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			GUI := CGUI.GUIList[this._.GUINum]
			Control := GUI[this._.ControlName]
			ControlGet, List, List,,, % " ahk_id " Control.hwnd
			count := 0
			Loop, Parse, List, `n
				count++
			if(!DetectHidden)
				DetectHiddenWindows, Off
			return count
		}
		_NewEnum()
		{
			global CEnumerator
			return new CEnumerator(this)
		}
	}
}
Class CListViewControl Extends CControl
{
	__New(Name, ByRef Options, Text, GUINum)
	{
		global CGUI		
		Events := ["Click", "RightClick", "ItemActivated", "MouseLeave", "EditingStart", "FocusReceived", "FocusLost", "ItemSelected", "ItemDeselected", "ItemFocused", "ItemDefocused", "ItemChecked",  "ItemUnChecked", "SelectionChanged", "CheckedChanged", "FocusedChanged", "KeyPress", "Marquee", "ScrollingStart", "ScrollingEnd"]
		if(!InStr(Options, "AltSubmit")) ;Automagically add AltSubmit when necessary
		{
			for index, function in Events
			{
				if(IsFunc(CGUI.GUIList[GUINum][Name "_" Function]))
				{
					Options .= " AltSubmit"
					break
				}
			}
		}
		base.__New(Name, Options, Text, GUINum)
		this._.Insert("Items", new this.CItems(GUINum, Name))
		this._.Insert("ControlStyles", {ReadOnly : -0x200, Header : -0x4000, NoSortHdr : 0x8000, AlwaysShowSelection : 0x8, Multi : -0x4, Sort : 0x10, SortDescending : 0x20})
		this._.Insert("ControlExStyles", {Checked : 0x4, FullRowSelect : 0x20, Grid : 0x1, AllowHeaderReordering : 0x10, HotTrack : 0x8})
		this._.Insert("Events", ["DoubleClick", "DoubleRightClick", "ColumnClick", "EditingEnd", "Click", "RightClick", "ItemActivate", "EditingStart", "KeyPress", "FocusReceived", "FocusLost", "Marquee", "ScrollingStart", "ScrollingEnd", "ItemSelected", "ItemDeselected", "ItemFocused", "ItemDefocused", "ItemChecked", "ItemUnChecked", "SelectionChanged", "CheckedChanged", "FocusedChanged"])
		this._.Insert("ImageListManager", new this.CImageListManager(GUINum, Name))
		this.Type := "ListView"
	}
	__Delete()
	{
		msgbox delete listview
	}
	ModifyCol(ColumnNumber="", Options="", ColumnTitle="")
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		Gui, % this.GUINum ":Default"
		Gui, ListView, % this.ClassNN
		LV_ModifyCol(ColumnNumber, Options, ColumnTitle)
	}
	InsertCol(ColumnNumber, Options="", ColumnTitle="")
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		Gui, % this.GUINum ":Default"
		Gui, ListView, % this.ClassNN
		LV_InsertCol(ColumnNumber, Options, ColumnTitle)
	}
	DeleteCol(ColumnNumber)
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		Gui, % this.GUINum ":Default"
		Gui, ListView, % this.ClassNN
		LV_DeleteCol(ColumnNumber)
	}
	__Get(Name, Params*)
	{
		global CGUI
		if(Name != "GUINum" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if(Name = "Items")
				Value := this._.Items
			else if(Name = "SelectedIndices" || Name = "SelectedItems" || Name = "CheckedIndices" || Name = "CheckedItems")
			{
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				Value := []
				Loop % this.Items.Count
					if(LV_GetNext(A_Index - 1, InStr(Name, "Checked") ? "Checked" : "") = A_Index)
					{
						Index := (this._.Items.IndependentSorting ? this.CItems.CRow.GetUnsortedIndex(A_Index, this.hwnd) : A_Index)
						Value.Insert(InStr(Name, "Indices") ? Index : this._.Items[Index]) ;new this.CItems.CRow(this.CItems.GetSortedIndex(A_Index, this.hwnd), this.GUINum, this.Name))
					}
			}
			else if(Name = "SelectedIndex" || Name = "SelectedItem" || Name = "CheckedIndex" || Name = "CheckedItem")
			{
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				Loop % this.Items.Count
					if(LV_GetNext(A_Index - 1, InStr(Name, "Checked") ? "Checked" : "") = A_Index)
					{
						Index := (this._.Items.IndependentSorting ? this.CItems.CRow.GetUnsortedIndex(A_Index, this.hwnd) : A_Index)
						Value := InStr(Name, "Index") ? Index : this._.Items[Index] ;new this.CItems.CRow(this.CItems.GetSortedIndex(A_Index, this.hwnd), this.GUINum, this.Name))
						break
					}
			}
			else if(Name = "FocusedItem" || Name = "FocusedIndex")
			{
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				Value := LV_GetNext(0, "Focused")
				if(this._.Items.IndependentSorting)
					Value := this.CItems.CRow.GetUnsortedIndex(Value, this.hwnd)
				if(Name = "FocusedItem")
					Value := this._.Items[Value] ;new this.CItems.CRow(Value, this.GUINum, this.Name)
			}
			else if(Name = "IndependentSorting")
				Value := this._.Items.IndependentSorting
			Loop % Params.MaxIndex()
				if(IsObject(Value)) ;Fix unlucky multi parameter __GET
					Value := Value[Params[A_Index]]
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Value != "")
				return Value
		}
	}
	__Set(Name, Value, Params*)
	{
		global CGUI
		if(!CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			Handled := true
			if(Name = "SelectedIndices" || Name = "CheckedIndices")
			{
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				Indices := Value
				if(!IsObject(Value))
				{
					Indices := Array()
					Loop, Parse, Value,|
						if A_LoopField is Integer
							Indices.Insert(A_LoopField)
				}
				LV_Modify(0, Name = "SelectedIndices" ? "-Select" : "-Check")
				Loop % Indices.MaxIndex()
					if(Indices[A_Index] > 0)
						LV_Modify(this._.Items.IndependentSorting ? this.CItems.CRow.GetSortedIndex(Indices[A_Index], this.hwnd) : Indices[A_Index], Name = "SelectedIndices" ? "Select" : "Check")
			}
			else if(Name = "SelectedIndex" || Name = "CheckedIndex")
			{
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				LV_Modify(0, Name = "SelectedIndex" ? "-Select" : "-Check")
				if(Value > 0)
					LV_Modify(this._.Items.IndependentSorting ? this.CItems.CRow.GetSortedIndex(Value, this.hwnd) : Value, Name = "SelectedIndex" ? "Select" : "Check")
			}
			else if(Name = "FocusedIndex")
			{
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				LV_Modify(this._.Items.IndependentSorting ? this.CItems.CRow.GetSortedIndex(Value, this.hwnd) : Value, "Focused")
			}
			else if(Name = "Items" && IsObject(Value) && IsObject(this._.Items) && Params.MaxIndex() > 0)
			{
				Items := this._.Items
				Items[Params*] := Value
			}
			else if(Name = "IndependentSorting")
				this._.Items.IndependentSorting := Value
			else if(Name = "Items")
				Value := 0
			else
				Handled := false
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Handled)
				return Value
		}
	}
	Class CItems
	{
		__New(GUINum, ControlName)
		{
			this._Insert("_", {})
			this._.GUINum := GUINum
			this._.ControlName := ControlName
		}
		_NewEnum()
		{
			global CEnumerator
			return new CEnumerator(this)
		}
		MaxIndex()
		{
			global CGUI
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI[this._.ControlName]
			Gui, % this._.GUINum ":Default"
			Gui, ListView, % Control.ClassNN
			return LV_GetCount()
		}
		Add(Options, Fields*)
		{
			global CGUI
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI[this._.ControlName]
			Gui, % Control.GUINum ":Default"
			Gui, ListView, % Control.ClassNN
			SortedIndex := LV_Add(Options, Fields*)
			UnsortedIndex := LV_GetCount()
			this._.Insert(UnsortedIndex, new this.CRow(SortedIndex, UnsortedIndex, this._.GUINum, Control.Name))
		}
		Insert(RowNumber, Options, Fields*)
		{
			global CGUI
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI[this._.ControlName]
			Gui, % Control.GUINum ":Default"
			Gui, ListView, % Control.ClassNN
			SortedIndex := this.IndependentSorting ? this.CRow.GetSortedIndex(RowNumber, Control.hwnd) : RowNumber ;If independent sorting is off, the RowNumber parameter of this function is interpreted as sorted index
			if(SortedIndex = -1 || SortedIndex > LV_GetCount())
				SortedIndex := LV_GetCount() + 1
			
			UnsortedIndex := this.CRow.GetUnsortedIndex(SortedIndex, Control.hwnd)
			
			;move all unsorted indices >= the insertion point up by one to make place for the insertion
			Loop % LV_GetCount() - UnsortedIndex + 1
			{
				index := LV_GetCount() - A_Index + 1 ;loop backwards
				sIndex := this.CRow.GetSortedIndex(index, Control.hwnd) - 1
				this.CRow.SetUnsortedIndex(sIndex, index + 1, Control.hwnd)
			}
			
			SortedIndex := LV_Insert(SortedIndex, Options, Fields*)
			this._.Insert(UnsortedIndex, new this.CRow(SortedIndex, UnsortedIndex, this._.GUINum, Control.Name))
		}
		
		
		
		
		hex(ByRef data, vars)
		{
			string := ""
			offset := 0
			Loop, Parse, vars, |
			{
				string .= A_LoopField ": " NumGet(data,offset,A_LoopField) "`n"
				offset += A_LoopField = "PTR" ? A_PtrSize : 4
			}
			return string
		}
		Modify(RowNumber, Options, Fields*)
		{
			global CGUI
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI[this._.ControlName]
			Gui, % Control.GUINum ":Default"
			Gui, ListView, % Control.ClassNN
			SortedIndex := this.IndependentSorting ? this.CRow.GetSortedIndex(RowNumber, Control.hwnd) : RowNumber ;If independent sorting is off, the RowNumber parameter of this function is interpreted as sorted index
			LV_Modify(SortedIndex, Options, Fields*)
		}
		
		Delete(RowNumber)
		{
			global CGUI
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI[this._.ControlName]
			Gui, % Control.GUINum ":Default"
			Gui, ListView, % Control.ClassNN
			SortedIndex := this.IndependentSorting ? this.CRow.GetSortedIndex(RowNumber, Control.hwnd) : RowNumber ;If independent sorting is off, the RowNumber parameter of this function is interpreted as sorted index
			UnsortedIndex := this.CRow.GetUnsortedIndex(SortedIndex, Control.hwnd)
			;Decrease the unsorted indices after the deletion index by one
			Loop % LV_GetCount() - UnsortedIndex
				this.CRow.SetUnsortedIndex(this.CRow.GetSortedIndex(UnsortedIndex + A_Index, Control.hwnd), UnsortedIndex + A_Index - 1, Control.hwnd)
			LV_Delete(SortedIndex)
		}
		__Get(Name)
		{
			global CGUI
			if(Name != "_")
			{
				GUI := CGUI.GUIList[this._.GUINum]
				if(GUI.IsDestroyed)
					return
				Control := GUI[this._.ControlName]
				if Name is Integer
				{
					if(Name > 0 && Name <= this.Count)
						return this._[this.IndependentSorting ? Name : this.CRow.GetUnsortedIndex(Name, Control.hwnd)]
				}
				else if(Name = "Count")
					return this.MaxIndex()
			}
		}
		__Set(Name, Value, Params*)
		{
			global CGUI
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Value := Params[Params.MaxIndex()]
			Params.Remove(Params.MaxIndex())
			if Name is Integer
			{
				if(!Params.MaxIndex()) ;Setting a row directly is not allowed
					return
				else ;Set a column or other row property
				{			
					Row := this[Name]
					Row[Params*] := Value
					return
				}
			}
		}
		
		;CRow uses the unsorted row numbers internally, but it can switch to sorted row numbers depending on the setting of the listview
		Class CRow
		{
			__New(SortedIndex, UnsortedIndex, GUINum, ControlName)
			{
				global CGUI
				this.Insert("_", {})				
				this._.RowNumber := UnsortedIndex
				this._.GUINum := GUINum
				this._.ControlName := ControlName
				GUI := CGUI.GUIList[GUINum]
				if(GUI.IsDestroyed)
					return
				Control := GUI[ControlName]				
				;Store the real unsorted index in the custom property lParam field of the list view item so it can be reidentified later
				this.SetUnsortedIndex(SortedIndex, UnsortedIndex, Control.hwnd)
				this.SetIcon("")
			}
			/*
			typedef struct {
			  UINT   mask;
			  int    iItem;
			  int    iSubItem;
			  UINT   state;
			  UINT   stateMask;
			  LPTSTR pszText;
			  int    cchTextMax;
			  int    iImage;
			  LPARAM lParam;
			#if (_WIN32_IE >= 0x0300)
			  int    iIndent;
			#endif 
			#if (_WIN32_WINNT >= 0x0501)
			  int    iGroupId;
			  UINT   cColumns;
			  UINT   puColumns;
			#endif 
			#if (_WIN32_WINNT >= 0x0600)
			  int    piColFmt;
			  int    iGroup;
			#endif 
			} LVITEM, *LPLVITEM;
			*/
			SetUnsortedIndex(SortedIndex, lParam, hwnd)
			{
				;~ if(!this.IndependentSorting)
					;~ return
				VarSetCapacity(LVITEM, 13*4 + 2 * A_PtrSize, 0)
				mask := 0x4   ; LVIF_PARAM := 0x4
				NumPut(mask, LVITEM, 0, "UInt") 
				NumPut(SortedIndex - 1, LVITEM, 4, "Int")   ; iItem 
				NumPut(lParam, LVITEM, 7*4 + A_PtrSize, "PTR")
				;~ string := this.hex(LVITEM,  "UINT|INT|INT|UINT|UINT|PTR|INT|INT|PTR|INT|INT|UINT|UINT|INT|INT")
				SendMessage, % LVM_SETITEM := (A_IsUnicode ? 0x1000 + 76 : 0x1000 + 6), 0, &LVITEM,,% "ahk_id " hwnd
				;~ result := errorlevel
				;~ result := DllCall("SendMessage", "PTR", hwnd, "UInt", LVM_SETITEM := (A_IsUnicode ? 0x1000 + 76 : 0x1000 + 6), "PTR", 0, "PTRP", LVITEM, "PTR")
				;~ lParam2 := this.GetUnsortedIndex(RowNumber, hwnd)
				return ErrorLevel
			}
			;Returns the sorted index (by which AHK usually accesses listviews) by searching for a custom index that is independent of sorting
			/*
			typedef struct tagLVFINDINFO {
			  UINT    flags; 4
			  LPCTSTR psz; 4-8
			  LPARAM  lParam; 4- 8
			  POINT   pt; 8
			  UINT    vkDirection; 4
			} LVFINDINFO, *LPFINDINFO;
			*/
			GetSortedIndex(UnsortedIndex, hwnd)
			{
				;~ if(!this.IndependentSorting)
					;~ return UnsortedIndex
				;Create the LVFINDINFO structure
				VarSetCapacity(LVFINDINFO, 4*4 + 2 * A_PtrSize, 0)
				mask := 0x1   ; LVFI_PARAM := 0x1
				NumPut(mask, LVFINDINFO, 0, "UInt") 
				NumPut(UnsortedIndex, LVFINDINFO, 4 + A_PtrSize, "PTR")
				;~ string := hex(LVFINDINFO,  "UINT|INT|INT|UINT|UINT|PTR|INT|INT|PTR|INT|INT|UINT|UINT|INT|INT")
				SendMessage, % LVM_FINDITEM := (A_IsUnicode ? 0x1000 + 83 : 0x1000 + 13), -1, &LVFINDINFO,,% "ahk_id " hwnd
				;~ MsgReply := ErrorLevel > 0x7FFFFFFF ? -(~ErrorLevel) - 1 : ErrorLevel
				;~ result := DllCall("SendMessage", "PTR", hwnd, "UInt", LVM_FINDITEM := (A_IsUnicode ? 0x1000 + 83 : 0x1000 + 13), "PTR", -1, "UIntP", LVITEM, "PTR") + 1
				return ErrorLevel + 1
			}
			GetUnsortedIndex(SortedIndex, hwnd)
			{
				;~ if(!this.IndependentSorting)
					;~ return SortedIndex
				VarSetCapacity(LVITEM, 13*4 + 2 * A_PtrSize, 0)
				mask := 0x4   ; LVIF_PARAM := 0x4
				NumPut(mask, LVITEM, 0, "UInt") 
				NumPut(SortedIndex - 1, LVITEM, 4, "Int")   ; iItem 
				;~ NumPut(lParam, LVITEM, 7*4 + A_PtrSize, "PTR")
				;~ string := this.hex(LVITEM,  "UINT|INT|INT|UINT|UINT|PTR|INT|INT|PTR|INT|INT|UINT|UINT|INT|INT")
				SendMessage, % LVM_GETITEM := (A_IsUnicode ? 0x1000 + 75 : 0x1000 + 5), 0, &LVITEM,,% "ahk_id " hwnd
				;~ result := errorlevel
				;~ result := DllCall("SendMessage", "PTR", hwnd, "UInt", LVM_GETITEM := (A_IsUnicode ? 0x1000 + 75 : 0x1000 + 5), "PTR", 0, "PTRP", LVITEM, "PTR")
				;~ string := this.hex(LVITEM,  "UINT|INT|INT|UINT|UINT|PTR|INT|INT|PTR|INT|INT|UINT|UINT|INT|INT")
				UnsortedIndex := NumGet(LVITEM, 7*4 + A_PtrSize, "PTR")
				return UnsortedIndex
			}
			_NewEnum()
			{
				global CEnumerator
				return new CEnumerator(this)
			}
			MaxIndex()
			{				
				global CGUI
				GUI := CGUI.GUIList[this._.GUINum]
				if(GUI.IsDestroyed)
					return
				Control := GUI[this._.ControlName]
				Gui, % Control.GUINum ":Default"
				Gui, ListView, % Control.ClassNN
				Return LV_GetCount("Column")
			}
			SetIcon(Filename, IconNumberOrTransparencyColor = 1)
			{
				global CGUI
				GUI := CGUI.GUIList[this._.GUINum]
				if(GUI.IsDestroyed)
					return
				Control := GUI[this._.ControlName]
				Control._.ImageListManager.SetIcon(this.GetSortedIndex(this._.RowNumber, Control.hwnd), Filename, IconNumberOrTransparencyColor)
				this._.Icon := Filename
				this._.IconNumber := IconNumberOrTransparencyColor
			}
			__Get(Name)
			{
				global CGUI				
				GUI := CGUI.GUIList[this._.GUINum]
				if(!GUI.IsDestroyed)
				{
					Control := GUI[this._.ControlName]
					if Name is Integer
					{
						if(Name > 0 && Name <= this.Count) ;Setting default listview is already done by this.Count __Get
						{
							LV_GetText(value, this.GetSortedIndex(this._.RowNumber, Control.hwnd), Name)
							return value
						}
					}
					else if(Name = "Text")
						return this[1]
					else if(Name = "Count")
					{
						Gui, % Control.GUINum ":Default"
						Gui, ListView, % Control.ClassNN
						Return LV_GetCount("Column")
					}
					else if(Value := {Checked : "Checked", Focused : "Focused", "Selected" : ""}[Name])
					{
						Gui, % Control.GUINum ":Default"
						Gui, ListView, % Control.ClassNN
						return this.GetUnsortedIndex(LV_GetNext(this.GetSortedIndex(this._.RowNumber, Control.hwnd) - 1, Value), Control.hwnd) = this._.RowNumber
					}
					else if(Name = "Icon" || Name = "IconNumber")
						return this._[Name]
				}
			}
			__Set(Name, Value)
			{				
				global CGUI
				GUI := CGUI.GUIList[this._.GUINum]
				if(!GUI.IsDestroyed)
				{
					Control := GUI[this._.ControlName]
					if Name is Integer
					{
						if(Name <= this.Count) ;Setting default listview is already done by this.Count __Get
							LV_Modify(this.GetSortedIndex(this._.RowNumber, Control.hwnd), "Col" Name, Value)
						return Value
					}
					else if(Key := {Checked : "Check", Focused : "Focus", "Select" : ""}[Name])
					{
						Gui, % Control.GUINum ":Default"
						Gui, ListView, % Control.ClassNN
						LV_Modify(this.GetSortedIndex(this._.RowNumber, Control.hwnd), (Value = 0 ? "-" : "") Key)
						return Value
					}
					else if(Name = "Icon")
						this.SetIcon(Value)
				}
			}
		}
	}
	HandleEvent()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		Critical := A_IsCritical
		Critical, On
		ErrLevel := ErrorLevel
		;~ if(!events)
			;~ events := object()
		;~ events[mod(i,30) +1] := A_GuiEvent " " A_EventInfo " " ErrLevel
		;~ i++
		;~ loop 30
			;~ text .= events[A_Index] "`n"
		;~ tooltip %text%
		Mapping := {DoubleClick : "_DoubleClick", R : "_DoubleRightClick", ColClick : "_ColumnClick", eb : "_EditingEnd", Normal : "_Click", RightClick : "_RightClick",  A : "_ItemActivate", Ea : "_EditingStart", K : "_KeyPress"}
		for Event, Function in Mapping
			if((strlen(A_GuiEvent) = 1 && A_GuiEvent == SubStr(Event, 1, 1)) || A_GuiEvent == Event)
				if(IsFunc(CGUI.GUIList[this.GUINum][this.Name Function]))
				{
					ErrorLevel := ErrLevel
					`(CGUI.GUIList[this.GUINum])[this.Name Function]({DoubleClick : 1, R : 1, Normal : 1, RightClick : 1,  A : 1, E : 1}[A_GUIEvent] && this._.Items.IndependentSorting ? this.CItems.CRow.GetUnsortedIndex(A_EventInfo, this.hwnd) : A_EventInfo)
					if(!Critical)
						Critical, Off
					return
				}
		Mapping := {C : "_MouseLeave", Fa : "_FocusReceived", fb : "_FocusLost", M : "_Marquee", Sa : "_ScrollingStart", sb : "_ScrollingEnd"} ;Case insensitivity strikes back!
		for Event, Function in Mapping
			if(A_GuiEvent == SubStr(Event, 1, 1))
				if(IsFunc(CGUI.GUIList[this.GUINum][this.Name Function]))
				{
					ErrorLevel := ErrLevel
					`(CGUI.GUIList[this.GUINum])[this.Name Function]()
					if(!Critical)
						Critical, Off
					return
				}
		if(A_GuiEvent == "I")
		{
			Mapping := { Sa : "_ItemSelected", sb : "_ItemDeselected", Fa : "_ItemFocused", fb : "_ItemDefocused", Ca : "_ItemChecked", cb : "_ItemUnChecked"} ;Case insensitivity strikes back!
			for Event, Function in Mapping
				if(InStr(ErrLevel, SubStr(Event, 1, 1), true))
					if(IsFunc(CGUI.GUIList[this.GUINum][this.Name Function]))
					{
						ErrorLevel := ErrLevel
						`(CGUI.GUIList[this.GUINum])[this.Name Function](this._.Items.IndependentSorting ? this.CItems.CRow.GetUnsortedIndex(A_EventInfo, this.hwnd) : A_EventInfo)
						if(!Critical)
							Critical, Off
					}
			Mapping := {S : "_SelectionChanged", C : "_CheckedChanged", F : "_FocusedChanged"}
			for Event, Function in Mapping
				if(InStr(ErrLevel, Event, false) = 1)
					if(IsFunc(CGUI.GUIList[this.GUINum][this.Name Function]))
					{
						ErrorLevel := ErrLevel
						`(CGUI.GUIList[this.GUINum])[this.Name Function](this._.Items.IndependentSorting ? this.CItems.CRow.GetUnsortedIndex(A_EventInfo, this.hwnd) : A_EventInfo)
					}
			if(!Critical)
				Critical, Off
			return
		}
	}
}

Class CPictureControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		base.__New(Name, Options, Text, GUINum)
		this.Type := "Picture"
		this._.Picture := Text
		this._.Insert("ControlStyles", {Center : 0x200, ResizeImage : 0x40})
		this._.Insert("Events", ["Click", "DoubleClick"])
	}
	__Get(Name) 
    {
		global CGUI
		if(Name != "GUINum" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if(Name = "Picture")
				Value := this._.Picture
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Value != "")
				return Value
		}
	}
	__Set(Name, Value) ;Nothing here for now, delete later if not required
	{
		global CGUI
		if(!CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			Handled := true
			if(Name = "Picture")
			{
				Gui, % this.GUINum ":Default"
				GuiControl,, % this.ClassNN, %Value%
				this._.Picture := Value
			}
			else
				Handled := false
		if(!DetectHidden)
			DetectHiddenWindows, Off
		if(Handled)
			return Value
		}
	}
	*/
	/*
	Function: SetImageFromHBitmap
	Sets the image of this control.
	
	Parameters:
		hBitamp - The bitmap handle to which the picture of this control is set
	*/
	SetImageFromHBitmap(hBitmap)
	{
		SendMessage, 0x172, 0x0, hBitmap,, % "ahk_id " this.hwnd
		DllCall("gdi32\DeleteObject", "PTR", ErrorLevel)
	}
	HandleEvent()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		ErrLevel := ErrorLevel
		func := A_GUIEvent = "DoubleClick" ? "_DoubleClick" : "Click"
		if(IsFunc(CGUI.GUIList[this.GUINum][this.Name func]))
		{
			ErrorLevel := ErrLevel
			`(CGUI.GUIList[this.GUINum])[this.Name func]()
		}
	}
}
Class CGroupBoxControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		base.__New(Name, Options, Text, GUINum)
		this.Type := "GroupBox"
		;No styles here for now, why would you want them?
	}
}
Class CStatusBarControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		base.__New(Name, Options, Text, GUINum)
		this.Type := "StatusBar"
		this._.Parts := new this.CParts(this.GUINum, this.Name)
		this._.Insert("ControlStyles", {SizingGrip : 0x100})
		if(Text)
			this._.Parts._.Insert(1, new this.CParts.CPart(Text, 1, "", "", "", "", this.GUINum, this.Name))
		this._.Insert("Events", ["Click", "DoubleClick", "RightClick", "DoubleRightClick"])
	}
	__Get(Name, Params*)
	{
		if(Name = "Parts")
			Value := this._.Parts
		else if(Name = "Text")
			Value := this._.Parts[1].Text
		Loop % Params.MaxIndex()
				if(IsObject(Value)) ;Fix unlucky multi parameter __GET
					Value := Value[Params[A_Index]]
		if(Value != "")
			return Value
	}
	__Set(Name, Params*)
	{
		Value := Params[Params.MaxIndex()]
		Params.Remove(Params.MaxIndex())
		if(Name = "Text") ;Assign text -> assign text of first part
		{
			this._.Parts[1].Text := Value
			return true
		}
		if(Name = "Parts") ;Assign all parts at once
		{
			if(Params[1] >= 1 && Params[1] <= this._.Parts.MaxIndex()) ;Set a single part
			{
				if(IsObject(Value)) ;Set an object
				{
					Part := new this.CParts.CPart(Value.HasKey("Text") ? Value.Text : "", Params[1], Value.HasKey("Width") ? Value.Width : 50, Value.HasKey("Style") ? Value.Style : "", Value.HasKey("Icon") ? Value.Icon : "", Value.HasKey("IconNumber") ? Value.IconNumber : "", this.GUINum, this.Name)
					this._.Parts._.Remove(Params[1])
					this._.Parts._.Insert(Params[1], Part)
					this.RebuildStatusBar()
				}
				else ;Just set text directly
					this._Parts[Params[1]].Text := Value
				;~ PartNumber := Params[Params.MaxIndex()]
				;~ Params.Remove(Params.MaxIndex())
				;~ Part := this._.Parts[PartNumber]
				;~ Part := Value ;ASLDIHSVO)UGBOQWFH)=RFZS
				return Value
			}
			else
			{
				Data := Value
				if(!IsObject(Data))
				{
					Data := Object()
					Loop, Parse, Value, |
						Data.Insert({Text : A_LoopField})
				}
				this._.Insert("Parts", new this.CParts(this.GUINum, this.Name))
				Loop % Data.MaxIndex()
					this._.Parts._.Insert(new this.CParts.CPart(Data[A_Index].HasKey("Text") ? Data[A_Index].Text : "", A_Index, Data[A_Index].HasKey("Width") ? Data[A_Index].Width : 50, Data[A_Index].HasKey("Style") ? Data[A_Index].Style : "", Data[A_Index].HasKey("Icon") ? Data[A_Index].Icon : "", Data[A_Index].HasKey("IconNumber") ? Data[A_Index].IconNumber : "", this.GUINum, this.Name))
				this.RebuildStatusBar()
			}
			return Value
		}
	}
	/*
	Reconstructs the statusbar from the information stored in this.Parts
	*/
	RebuildStatusBar()
	{
		Widths := []
		for index, Part in this._.Parts
			if(index < this._.Parts._.MaxIndex()) ;Insert all but the last one
				Widths.Insert(Part.Width ? Part.Width : 50)
		
		Gui, % this.GUINum ":Default"
		SB_SetParts()
		SB_SetParts(Widths*)
		for index, Part in this._.Parts
		{
			SB_SetText(Part.Text, index, Part.Style)
			;~ if(Part.Icon)
				SB_SetIcon(Part.Icon, Part.IconNumber, index)
		}
	}
	HandleEvent()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		ErrLevel := ErrorLevel
		Mapping := {Normal : "_Click", DoubleClick : "_DoubleClick", Right : "_RightClick", R : "_DoubleRightClick"}
		func := this.Name Mapping[A_GuiEvent]
		if(IsFunc(CGUI.GUIList[this.GUINum][func]))
		{
			ErrorLevel := ErrLevel
			`(CGUI.GUIList[this.GUINum])[func](A_EventInfo)
		}
	}
	Class CParts
	{
		__New(GUINum, Name)
		{
			this.Insert("_", [])
			this.GUINum := GUINum
			this.Name := Name
		}
		__Get(Name, Params*)
		{
			if Name is Integer
			{
				if(Name <= this._.MaxIndex())
				{
					if(Params.MaxIndex() >= 1)
						return this._[Name][Params*]
					else						
						return this._[Name]
				}
			}
		}
		MaxIndex()
		{
			return this._.MaxIndex()
		}
		_NewEnum()
		{
			global CEnumerator
			return new CEnumerator(this._)
		}
		__Set(Name, Params*)
		{
			global CGUI
			Value := Params[Params.MaxIndex()]
			Params.Remove(Params.MaxIndex())
			if Name is Integer
			{
				if(Name <= this._.MaxIndex())
				{
					if(Params.MaxIndex() >= 1) ;Set a property of CPart
					{
						Part := this._[Name]
						Part[Params*] := Value
					}
					;~ else
					;~ {
						
					;~ }
					return Value
				}
			}
		}
		Add(Text, PartNumber = "", Width = 50, Style = "", Icon = "", IconNumber = "")
		{
			global CGUI
			if(PartNumber)
				this._.Insert(PartNumber, new this.CPart(Text, PartNumber, Width, Style, Icon, IconNumber, this.GUINum, this.Name))
			else
				this._.Insert(new this.CPart(Text, this._.MaxIndex() + 1, Width, Style, Icon, IconNumber, this.GUINum, this.Name))
			Control := CGUI.GUIList[this.GUINum][this.Name]
			Control.RebuildStatusBar()
		}
		Remove(PartNumber)
		{
			global CGUI
			if PartNumber is Integer
			{
				this._.Remove(PartNumber)
				Control := CGUI.GUIList[this.GUINum][this.Name]
				Control.RebuildStatusBar()
			}
		}
		Class CPart
		{
			__New(Text, PartNumber, Width, Style, Icon, IconNumber, GUINum, Name)
			{
				this.Insert("_", {})
				this._.Text := Text
				this._.PartNumber := PartNumber
				this._.Width := Width
				this._.Style := Style
				this._.Icon := Icon
				this._.IconNumber := IconNumber
				this._.GUINum := GUINum
				this._.Name := Name
			}
			__Get(Name)
			{
				if(Name != "_" && this._.HasKey(Name))
					return this._[Name]
			}
			__Set(Name, Value)
			{
				global CGUI
				Control := CGUI.GUIList[this.GUINum][this.Name]
				if(Name = "Width")
				{
					this._[Name] := Value
					Control.RebuildStatusBar()
					return Value
				}
				else if(Name = "Text" || Name = "Style")
				{
					this._[Name] := Value
					Gui, % this.GUINum ":Default"
					SB_SetText(Name = "Text" ? Value : this._.Text, this._.PartNumber, Name = "Style" ? Value : this._.Style)
				}
				else if(Name = "Icon" || Name = "IconNumber")
				{
					this._[Name] := Value
					if(this._.Icon)
					{
						Gui, % this.GUINum ":Default"
						SB_SetIcon(this._.Icon, this._.IconNumber, this._.PartNumber)
					}
					return Value
				}
			}
		}
	}
}
Class CTreeViewControl Extends CControl
{
	__New(Name, ByRef Options, Text, GUINum)
	{
		global CGUI
		Events := ["_Click", "_RightClick", "_EditingStart", "_FocusReceived", "_FocusLost", "_KeyPress", "_ItemExpanded", "_ItemCollapsed"]
		if(!InStr(Options, "AltSubmit")) ;Automagically add AltSubmit when necessary
		{
			for index, function in Events
			{
				if(IsFunc(CGUI.GUIList[GUINum][Name Function]))
				{
					Options .= " AltSubmit"
					break
				}
			}
		}
		base.__New(Name, Options, Text, GUINum)
		this._.Insert("Items", new this.CItem(0, GUINum, Name))
		this._.Insert("ControlStyles", {Checked : 0x100, ReadOnly : -0x8, FullRowSelect : 0x1000, Buttons : 0x1, Lines : 0x2, HScroll : -0x8000, AlwaysShowSelection : 0x20, SingleExpand : 0x400, HotTrack : 0x200})
		this._.Insert("Events", ["DoubleClick", "EditingEnd", "ItemSelected", "Click", "RightClick", "EditingStart", "KeyPress", "ItemExpanded", "ItemCollapsed", "FocusReceived", "FocusLost"])
		this._.Insert("ImageListManager", new this.CImageListManager(GUINum, Name))
		this.Type := "TreeView"
	}
	HandleEvent()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		Critical := A_IsCritical
		Critical, On
		ErrLevel := ErrorLevel
		Mapping := {DoubleClick : "_DoubleClick", eb : "_EditingEnd", S : "_ItemSelected", Normal : "_Click", RightClick : "_RightClick", Ea : "_EditingStart", K : "_KeyPress", "+" : "_ItemExpanded", "-" : "ItemCollapsed"}
		for Event, Function in Mapping
			if((strlen(A_GuiEvent) = 1 && A_GuiEvent == SubStr(Event, 1, 1)) || A_GuiEvent == Event)
				if(IsFunc(CGUI.GUIList[this.GUINum][this.Name Function]))
				{
					ErrorLevel := ErrLevel
					`(CGUI.GUIList[this.GUINum])[this.Name Function](this.FindItem(A_EventInfo))
					if(!Critical)
						Critical, Off
					return
				}
		Mapping := {Fa : "_FocusReceived", fb : "_FocusLost"} ;Case insensitivity strikes back!
		for Event, Function in Mapping
			if(A_GuiEvent == SubStr(Event, 1, 1))
				if(IsFunc(CGUI.GUIList[this.GUINum][this.Name Function]))
				{
					ErrorLevel := ErrLevel
					`(CGUI.GUIList[this.GUINum])[this.Name Function]()
					if(!Critical)
						Critical, Off
					return
				}
	}
	;Find an item by its ID
	FindItem(ID, Root = "")
	{
		if(!ID) ;Root node
			return this.Items
		if(!IsObject(Root))
			Root := this.Items
		if(ID = Root.ID)
			return Root
		Loop % Root.MaxIndex()
			if(result := this.FindItem(ID, Root[A_Index]))
				return result
		return 0
		
	}
	__Get(Name, Params*)
	{
		if(Name = "Items")
			Value := this._.Items
		Loop % Params.MaxIndex()
			if(IsObject(Value)) ;Fix unlucky multi parameter __GET
				Value := Value[Params[A_Index]]
		if(Value)
			return Value
	}
	Class CItem
	{
		__New(ID, GUINum, ControlName)
		{
			this.Insert("_", {})
			this._.Insert("GUINum", GUINum)
			this._.Insert("ControlName", ControlName)
			this._.Insert("ID", ID)
		}
		/*
			Function: Add
			Adds a new item to the TreeView.
			
			Parameters:
				Text - The text of the item.
				Options - Various options, see Autohotkey TreeView documentation
			
			Returns:
			An object of type CItem representing the newly added item.
		*/
		Add(Text, Options = "")
		{
			global CGUI, CTreeViewControl
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI[this._.ControlName]
			Gui, % this._.GUINum ":Default"
			Gui, TreeView, % Control.ClassNN
			ID := TV_Add(Text, this.ID, Options)
			Item := new CTreeViewControl.CItem(ID, this._.GUINum, this._.ControlName)
			Item.Icon := ""
			return Item
		}
		/*
			Function: Remove
			Removes an item.
			
			Parameters:
				ObjectOrIndex - The item object or the index of the child item of this.
		*/
		Remove(ObjectOrIndex)
		{
			global CGUI
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI[this._.ControlName]
			Gui, % this._.GUINum ":Default"
			Gui, TreeView, % Control.ClassNN
			if(!IsObject(ObjectOrIndex)) ;If index, get object and then handle
				ObjectOrIndex := this[ObjectOrIndex]
			TV_Delete(ObjectOrIndex.ID)
		}
		/*
		Function: Move
		Moves an Item to another position.
		
		Parameters:
			Position - The new (one-based) - position in the child items of Parent.
			Parent - The item will be inserted as child of the Parent item. Leave empty to use its current parent.
		*/
		Move(Position=1, Parent = "")
		{
			global CGUI
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI[this._.ControlName]
			Gui, % this._.GUINum ":Default"
			Gui, TreeView, % Control.ClassNN
			Text := this.Text
			Bold := this.bold
			Expanded := this.Expanded
			Checked := this.Checked
			Selected := this.Selected
			OldID := this.ID
			if(!Parent)
				Parent := this.Parent
			NewID := TV_Add(Text, Parent.ID, (Position = 1 ? "First" : Parent[Position-1].ID) " " (Bold ? "+Bold" : "") (Expanded ?  "Expand" : "") (Checked ? "Check" : "") (Selected ? "Select" : ""))
			Childs := []
			for index, Item in this
				Childs.Insert(Item)
			this._.ID := NewID
			for index, Item in Childs
				Item.Move(index, this)
			TV_Delete(OldID)
		}
		SetIcon(Filename, IconNumberOrTransparencyColor = 1)
		{
			global CGUI
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI[this._.ControlName]
			Control._.ImageListManager.SetIcon(this._.ID, Filename, IconNumberOrTransparencyColor)
			this._.Icon := {Filename : Filename, IconNumber : IconNumberOrTransparencyColor}
		}
		MaxIndex()
		{
			global CGUI
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI[this._.ControlName]
			Gui, % this._.GUINum ":Default"
			text := this.text
			Gui, TreeView, % Control.ClassNN
			current := this._.ID ? TV_GetChild(this._.ID) : TV_GetNext() ;Get first child or first top node
			if(!current)
				return 0 ;No children
			count := 0
			while(current && current := TV_GetNext(current))
				count++
			return count + 1
		}
		;Access a child item by its ID
		ItemByID(ID)
		{
			Loop % this.MaxIndex()
				if(this[A_Index]._.ID = ID)
					return this[A_Index]
		}
		_NewEnum()
		{
			global CEnumerator
			return new CEnumerator(this)
		}
		__Get(Name, Params*)
		{
			global CTreeViewControl, CGUI
			if(Name != "_")
			{
				GUI := CGUI.GUIList[this._.GUINum]
				if(!GUI.IsDestroyed)
				{					
					if Name is Integer ;get a child node
					{
						if(Name <= this.MaxIndex())
						{
							Control := GUI[this._.ControlName]
							Gui, % this._.GUINum ":Default"
							Gui, TreeView, % Control.ClassNN
							child := TV_GetChild(this._.ID) ;Find child node id
							Loop % Name - 1
								child := TV_GetNext(child)
							Value := new CTreeViewControl.CItem(child, this._.GUINum, this._.ControlName)
						}
					}
					else if(Name = "CheckedItems")
					{
						Value := []
						for index, Item in this
							if(Item.Checked)
								Value.Insert(Item)				
					}
					else if(Name = "CheckedIndices")
					{
						Value := []
						for index, Item in this
							if(Item.Checked)
								Value.Insert(index)				
					}
					else if(Name = "Parent")
					{
						Control := GUI[this._.ControlName]
						Gui, % this._.GUINum ":Default"
						Gui, TreeView, % Control.ClassNN
						VaLue := Control.FindItem(TV_GetParent(this._.ID))
					}
					else if(Name = "ID" || Name = "Icon")
						Value := this._[Name]
					else if(Name = "Count")
						Value := this.MaxIndex()
					else if(Name = "Text")
					{
						Control := GUI[this._.ControlName]
						Gui, % this._.GUINum ":Default"
						Gui, TreeView, % Control.ClassNN
						TV_GetText(Value, this._.ID)
					}
					else if(Name = "Checked" || Name = "Expanded" || Name = "Bold")
					{
						Control := GUI[this._.ControlName]
						Gui, % this._.GUINum ":Default"
						Gui, TreeView, % Control.ClassNN
						Value := TV_Get(this._.ID, Name) > 0
					}
					else if(Name = "Selected")
					{
						Control := GUI[this._.ControlName]
						Gui, % this._.GUINum ":Default"
						Gui, TreeView, % Control.ClassNN
						Value := TV_GetSelection() = this._.ID
					}
					Loop % Params.MaxIndex()
						if(IsObject(Value)) ;Fix unlucky multi parameter __GET
							Value := Value[Params[A_Index]]
					if(Value)
						return Value
				}
			}
		}
		__Set(Name, Params*)
		{
			global CGUI
			Value := Params[Params.MaxIndex()]
			Params.Remove(Params.MaxIndex())
			GUI := CGUI.GUIList[this._.GUINum]
			if(!GUI.IsDestroyed)
			{
				if(Name = "Text")
				{
					Control := GUI[this._.ControlName]
					Gui, % this._.GUINum ":Default"
					Gui, TreeView, % Control.ClassNN
					TV_Modify(this._.ID, "", Value)
					return Value
				}
				else if(Name = "Selected") ;Deselecting is not possible it seems
				{
					if(Value = 1)
					{
						Control := GUI[this._.ControlName]
						Gui, % this._.GUINum ":Default"
						Gui, TreeView, % Control.ClassNN
						TV_Modify(this._.ID)
					}
					return Value
				}
				else if(Option := {Checked : "Check", Expanded : "Expand", Bold : "Bold"}[Name]) ;Wee, check and remapping in one step
				{
					Control := GUI[this._.ControlName]
					Gui, % this._.GUINum ":Default"
					Gui, TreeView, % Control.ClassNN				
					TV_Modify(this._.ID, (Value = 1 ? "+" : "-") Option)
				}
				else if(Name = "Icon")
				{
					this.SetIcon(Value, 1)
					return Value
				}
			}
		}
	}
}

Class CTabControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		base.__New(Name, Options, Text, GUINum)
		this.Type := "Tab"
		this._.Tabs := new this.CTabs(GUINum, Name)
		Loop, Parse, Text, |
			this._.Tabs._.Insert(1, new this.CTabs.CTab(A_LoopField, 1, GUINum, Name))
		this._.Insert("ControlStyles", {Bottom : 0x2, HotTrack : 0x40, Buttons : 0x100, MultiLine : 0x200})
		this._.Insert("Events", ["Click", "DoubleClick", "RightClick", "DoubleRightClick"])
	}
	__Get(Name, Params*)
	{
		if(Name = "Tabs")
			Value := this._.Tabs
		else if(Name = "Text")
			Value := this._.Tabs[1].Text
		if(Params.MaxIndex() >= 1 && IsObject(value)) ;Fix unlucky multi parameter __GET
		{
			Value := Value[Params[1]]
			if(Params.MaxIndex() >= 2 && IsObject(value))
				Value := Value[Params[2]]
		}
		if(Value != "")
			return Value
	}
	__Set(Name, Params*)
	{
		Value := Params[Params.MaxIndex()]
		Params.Remove(Params.MaxIndex())
		if(Name = "Text") ;Assign text -> assign text of first Tab
		{
			this._.Tabs[1].Text := Value
			return true
		}
		if(Name = "Tabs") ;Assign all Tabs at once
		{
			if(Params[1] >= 1 && Params[1] <= this._.Tabs.MaxIndex()) ;Set a single Tab
			{
				if(IsObject(Value)) ;Set an object
				{
					this._.Tabs[Params[1]].Text := Value.Text
					;Maybe do this later when icons are available?
					;~ Tab := new this.CTabs.CTab(Value.HasKey("Text") ? Value.Text : "", Params[1], this.GUINum, this.Name)					
					;~ this._.Tabs._.Remove(Params[1])
					;~ this._.Tabs._.Insert(Params[1], Tab)
				}
				else ;Just set text directly
					this._Tabs[Params[1]].Text := Value
				return Value
			}
			return 0
		}
	}
	HandleEvent()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		ErrLevel := ErrorLevel
		Mapping := {Normal : "_Click", DoubleClick : "_DoubleClick", Right : "_RightClick", R : "_DoubleRightClick"}
		func := this.Name Mapping[A_GuiEvent]
		if(IsFunc(CGUI.GUIList[this.GUINum][func]))
		{
			ErrorLevel := ErrLevel
			`(CGUI.GUIList[this.GUINum])[func](A_EventInfo)
		}
	}
	Class CTabs
	{
		__New(GUINum, Name)
		{
			this.Insert("_", [])
			this.GUINum := GUINum
			this.Name := Name
		}
		__Get(Name, Params*)
		{
			if Name is Integer
			{
				if(Name <= this._.MaxIndex())
				{
					if(Params.MaxIndex() >= 1)
						return this._[Name][Params*]
					else						
						return this._[Name]
				}
			}
		}
		MaxIndex()
		{
			return this._.MaxIndex()
		}
		_NewEnum()
		{
			global CEnumerator
			return new CEnumerator(this._)
		}
		__Set(Name, Params*)
		{
			global CGUI
			Value := Params[Params.MaxIndex()]
			Params.Remove(Params.MaxIndex())
			if Name is Integer
			{
				if(Name <= this._.MaxIndex())
				{
					if(Params.MaxIndex() >= 1) ;Set a property of CTab
					{
						Tab := this._[Name]
						Tab[Params*] := Value
					}
					return Value
				}
			}
		}
		Add(Text)
		{
			global CGUI
			Tabs := []
			Loop, Parse, Text, |
			{
				Tab := new this.CTab(A_loopField, this._.MaxIndex() + 1, this.GUINum, this.Name)
				this._.Insert(Tab)
				Tabs.Insert(Tab)
				Control := CGUI.GUIList[this.GUINum][this.Name]
				GuiControl, % this.GUINum ":", % Control.ClassNN, %A_loopField%
			}
			return Tabs.MaxIndex() > 1 ? Tabs : Tabs[1]
		}
		
		;Removing tabs is unsupported for now because the controls will not be removed
		;~ Remove(TabNumber)
		;~ {
		;~ }
		Class CTab
		{
			__New(Text, TabNumber, GUINum, Name)
			{
				this.Insert("_", {})
				this._.Text := Text
				this._.TabNumber := TabNumber
				this._.GUINum := GUINum
				this._.Name := Name
				this._.Controls := {}
			}
			;Add a control to this tab
			Add(type, Name, Options, Text)
			{
				global CGUI
				if(type != "Tab")
				{
					GUI := CGUI.GUIList[this.GUINum]
					Gui, % this.GUINum ":Tab", % this._.TabNumber
					Control := GUI.Add(type, Name, Options, Text)
					this._.Controls.Insert(Name, Control)
					Gui, % this.GUINum ":Tab"
					return Control
				}
			}
			__Get(Name, Params*)
			{
				if(Name != "_" && this._.HasKey(Name))
					Value := this._[Name]
				Loop % Params.MaxIndex()
					if(IsObject(Value)) ;Fix unlucky multi parameter __GET
						Value := Value[Params[A_Index]]
				if(Value)
					return Value
			}
			__Set(Name, Value)
			{
				global CGUI
				if(Name = "Text")
				{
					Control := CGUI.GUIList[this.GUINum][this.Name]
					Tabs := ""
					for index, Tab in Control.Tabs
						if(index != this._.TabNumber)
							Tabs .= "|" Tab.Text
						else
							Tabs .= "|" Value
					this._[Name] := Value
					GuiControl, % this.GUINum ":", % Control.ClassNN, %Tabs%
				}
			}
		}
	}
}

/*
TODO:
Controls:
 - Progress 
 - Slider 
 - Hotkey 
 - MonthCal 
 - DateTime


Improvements on existing controls:
 - ListBox multi selection
 - TreeView/Tab ImageList manager
 - Listview hottracking
 - Fix UpDown
Other things:
 - Finish C# GUI converter to add support for the other controls 
 - Maybe include anchor and/or my ToolWindow function 
 - Complete documentation 
 - Provide some usage examples
 - Imagelist cache manager (recreate IL when N unused icons in list)
*/
Class CClipPasteAction Extends CAction
{
	static Type := RegisterType(CClipPasteAction, "Paste clipboard entry")
	static Category := RegisterCategory(CClipPasteAction, "System")
	static Index := 0
	
	Execute(Event)
	{
		ClipboardMenuClicked(this.Index)
	} 

	DisplayString()
	{
		return "Paste clipboard history entry"
	}
	
	GuiShow(GUI)
	{
		this.AddControl(GUI, "Edit", "Index", "", "", "Index:")
	}
	
	GuiSubmit(GUI)
	{
		Base.GuiSubmit(GUI)
		return !(this.Index >= 1 && this.Index <= 10)
	}
}

Class CClipboardList extends CQueue
{
	Persistent := Array()
	MaxSize := 10
	__new()
	{
		this.Load()
	}
	Load()
	{
		if(FileExist(Settings.ConfigPath "\Clipboard.xml"))
		{
			FileRead, xml, % Settings.ConfigPath "\Clipboard.xml"
			XMLObject := XML_Read(xml)
			;Convert empty and single arrays to real array
			if(!XMLObject.List.MaxIndex())
				XMLObject.List := IsObject(XMLObject.List) ? Array(XMLObject.List) : Array()	
			if(!XMLObject.Persistent.MaxIndex())
				XMLObject.Persistent := IsObject(XMLObject.Persistent) ? Array(XMLObject.Persistent) : Array()		

			Loop % min(XMLObject.List.MaxIndex(), 10)
				this.Insert(Decrypt(XMLObject.List[A_Index])) ;Read encrypted clipboard history
			Loop % XMLObject.Persistent.MaxIndex()
			{
				Clip := RichObject()
				Clip.Name := XMLObject.Persistent[A_Index].Name
				Clip.Text := XMLObject.Persistent[A_Index].Text
				this.Persistent.Insert(Clip)
			}
		}
	}
	Save()
	{
		FileDelete, % Settings.ConfigPath "\Clipboard.xml"
		for index, Event in EventSystem.Events ;Check if clipboard history is actually used and don't store the history when it isn't
		{
			Action := Event.Actions.GetItemWithValue("Type", "Show menu")
			if((Action.Menu = "ClipboardMenu" || Event.Actions.GetItemWithValue("Type", "ClipPaste")) && Event.Enabled)
			{
				XMLObject := Object("List", Array(), "Persistent", Array())
				Loop % min(this.MaxIndex(), 10)
					XMLObject.List.Insert(Encrypt(this[A_Index])) ;Store encrypted
				Loop % this.Persistent.MaxIndex()
					XMLObject.Persistent.Insert({Name : this.Persistent[A_Index].Name, Text : this.Persistent[A_Index].Text})
				XML_Save(XMLObject, Settings.ConfigPath "\Clipboard.xml")
				return
			}
		}
	}
}

;Need separate handlers because menu index doesn't have to match array index
ClipboardHandler1:
ClipboardMenuClicked(1)
return
ClipboardHandler2:
ClipboardMenuClicked(2)
return
ClipboardHandler3:
ClipboardMenuClicked(3)
return
ClipboardHandler4:
ClipboardMenuClicked(4)
return
ClipboardHandler5:
ClipboardMenuClicked(5)
return
ClipboardHandler6:
ClipboardMenuClicked(6)
return
ClipboardHandler7:
ClipboardMenuClicked(7)
return
ClipboardHandler8:
ClipboardMenuClicked(8)
return
ClipboardHandler9:
ClipboardMenuClicked(9)
return
ClipboardHandler10:
ClipboardMenuClicked(10)
return

ClipboardMenuClicked(index)
{
	global ClipboardList
	if(ClipboardList[index])
		PasteText(ClipboardList[index])
}

PersistentClipboardHandler:
PersistentClipboard()
return

PersistentClipboard()
{
	global ClipboardList
	text := ClipboardList.Persistent[A_ThisMenuItemPos].Text
	if(InStr(text, "%") && InStr(text, "%", false, 1, 2) && SubStr(text, InStr(text, "%") + 1, InStr(text, "%", false, 1, 2) - InStr(text, "%") - 1))
		ClipVariableWindow := new CClipVariableWindow(ClipboardList.Persistent[A_ThisMenuItemPos].DeepCopy())
	else
		PasteText(text)
}
Class CClipVariableWindow extends CGUI
{
	editText := this.AddControl("Edit", "editText", "x10 y10 w300", "")
	btnOK := this.AddControl("Button", "btnOK", "x180 y+10 Default w50", "&OK")
	btnCancel := this.AddControl("Button", "btnCancel", "x+10 w70", "&Cancel")
	__new(Clip)
	{
		static EM_SETSEL := 0x00B1
		this.Clip := Clip
		this.Variable := SubStr(Clip.Text, InStr(Clip.Text, "%") + 1, InStr(Clip.Text, "%", false, 1, 2) - InStr(Clip.Text, "%") - 1)
		this.ActiveControl := this.editText
		this.Show()
		this.editText.Text := "Text for """ this.Variable """"
		SendMessage, EM_SETSEL, 0, -1, , % "ahk_id " this.editText.hwnd
		this.DestroyOnClose := true
		this.CloseOnEscape := true
	}
	btnCancel_Click()
	{
		this.Close()
	}
	btnOK_Click()
	{
		text := this.Clip.Text
		StringReplace, text, text, % "%" this.Variable "%", % this.editText.Text
		this.Clip.Text := text
		this.Hide()
		this.Close()
		if(InStr(this.Clip.Text, "%") && InStr(this.Clip.Text, "%", false, 1, 2) && SubStr(this.Clip.Text, InStr(this.Clip.Text, "%") + 1, InStr(this.Clip.Text, "%", false, 1, 2) - InStr(this.Clip.Text, "%") - 1))
			ClipVariableWindow := new CClipVariableWindow(this.Clip)
		else
			PasteText(text)
	}
}
PasteText(Text)
{
	global MuteClipboardList
	outputdebug % WinGetClass("A")
	ClipboardBackup := ClipboardAll
	MuteClipboardList := true
	Clipboard := Text
	Clipwait,1,1
	if(!Errorlevel)
	{
		Sleep 100 ;Some extra sleep to increase reliability
		if(WinActive("ahk_class ConsoleWindowClass"))
		{
			CoordMode, Mouse, Screen
			MouseGetPos, mx,my
			CoordMode, Mouse, Relative
			Click Right 40, 40
			CoordMode, Mouse, Screen
			MouseMove, %mx%, %my%
			Send {Down 3}{Enter}
		}
		else	
			Send ^v
		Sleep 20
	}
	else
		Notify("Error pasting text", "Error pasting text", "5", "GC=555555 TC=White MC=White",NotifyIcons.Error)
	Clipboard:=ClipboardBackup
	Clipwait,1,1
	MuteClipboardList := false
}
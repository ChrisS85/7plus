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
	global ClipboardList,MuteClipboardList
	if(ClipboardList[index])
	{
		ClipboardBackup := ClipboardAll
		MuteClipboardList := true
		Clipboard := ClipboardList[index]
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
	Menu, ClipboardMenu, add, 1,ClipboardHandler1
	Menu, ClipboardMenu, DeleteAll
}

Class CClipboardList extends CArray
{
	__new()
	{
		this.Load()
	}
	;Stack Push function for clipboard manager stack
	Push(item)
	{
		itemPosition := this.IndexOf(item)
		if(!itemPosition)
		{
			this.Insert(1, item)
			if(this.MaxIndex()=11)
				this.Remove()
		}
		else
			this.Move(itemPosition, 1)
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

			Loop % min(XMLObject.List.MaxIndex(), 10)
				this.Insert(Decrypt(XMLObject.List[A_Index])) ;Read encrypted clipboard history
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
				XMLObject := Object("List",Array())
				Loop % min(this.MaxIndex(), 10)
					XMLObject.List.Insert(Encrypt(this[A_Index])) ;Store encrypted
				XML_Save(XMLObject, Settings.ConfigPath "\Clipboard.xml")
				return
			}
		}
	}
}
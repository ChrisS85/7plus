#include <CGUI>
#include <Regex>
Class ConverterGUI extends CGUI
{
	__New()
	{
		global CFileDialog
		this.Add("Edit", "EditPath", "x10", "")
		this.Add("Button", "BtnBrowse", "x+10", "Browse")
		this.Add("Edit", "EditSavePath", "x10 y+10", "")
		this.Add("Button", "BtnSaveBrowse", "x+10", "Browse")
		this.Add("Button", "BtnConvert", "x10 y+10", "Convert")
		this.FileDialog := new CFileDialog()
	}
	BtnBrowse_ButtonClicked()
	{
		this.FileDialog.Mode := "Open"
		if(this.FileDialog.Show())
			this.EditPath.Text := this.FileDialog.Filename
	}
	BtnSaveBrowse_ButtonClicked()
	{
		this.FileDialog.Mode := "Save"
		if(this.FileDialog.Show())
			this.EditSavePath.Text := this.FileDialog.Filename
	}
	BtnConvert_ButtonClicked()
	{
		this.Convert(this.EditPath.Text, this.EditSavePath.Text)
	}
	Convert(InPath, OutPath)
	{
		global Regex
		FileRead, InputFile, % "*t " InPath
		start := InStr(InputFile, "partial class ") + StrLen("partial class ")
		Class := SubStr(InputFile, start, InStr(InputFile, "`n", 0, start) - start)
		Controls := Array() ;array storing control definitions
		Window := {} ;Object storing window properties
		pos := 0
		StartString := "private System.Windows.Forms."
		EndString := ";"
		Loop, Parse, InputFile, `n, %A_Space%%A_Tab%
		{
			line := A_LoopField
			if(InStr(line, "private System.Windows.Forms."))
			{
				type := Regex.MatchSimple(line, "type", "\.Forms\.(?P<type>.*?) (?P<name>.*?)\;")
				name := Regex.MatchSimple(line, "name", "\.Forms\.(?P<type>.*?) (?P<name>.*?)\;")
				if(type && name)
				{
					SupportedControls := { TextBox : "Edit", Label : "Text", Button : "Button", CheckBox : "CheckBox", PictureBox : "Picture"}
					type := SupportedControls[type]
					if(type)
					{
						Controls.Insert({Type : Type, Name : name, Events : {}})
						found := true
					}
				}
			}
		}
		Loop, Parse, InputFile, `n, %A_Space%%A_Tab%
		{
			line := A_LoopField
			if(InStr(line, "// ") && !InStr(line, "///") && strlen(line) > 4)
			{
				found := false
				for index, Control in Controls
				{
					fileappend, % line "`n// " Control.Name "`n" (line = "// " Control.Name) "`n" InStr(line, "// " Control.Name) "`n" strlen(line) ":" strlen("// " Control.Name), C:\Users\csander\Desktop\debug.txt
					if(line = "// " Control.Name) ;Start of new control section
					{
						CurrentControl := Control
						found := true
						break
					}
				}
				if(!found && strLen(line) > 5 && !InStr(line, "///"))
				{
					if(!found && InStr(line, "// " Class))
					{
						CurrentControl := "Window"
					}
				}
			}
			if(CurrentControl = "Window")
			{
				if(InStr(line, "=")) ;window property assignments
				{
					if(InStr(line, "this.ClientSize"))
					{
						Width := Regex.MatchSimple(line, "width", "\.Size\((?P<width>\d+),.*?(?P<height>\d+)")
						Height := Regex.MatchSimple(line, "height", "\.Size\((?P<width>\d+),.*?(?P<height>\d+)")
						if(width)
							Window.Width := width
						if(height)
							Window.height := height
					}
					if(InStr(line, "this.MaximizeBox"))
						Window.MaximizeBox := InStr(line, "true")
					if(InStr(line, "this.MinimizeBox"))
						Window.MinimizeBox := InStr(line, "true")
					if(InStr(line, "this.Text"))
						Window.Title := Regex.MatchSimple(line, "text", """(?P<text>.*)""")
				}				
			}
			else if(IsObject(CurrentControl)) ;Process control property assignments
			{
				Handled := false
				if(InStr(line, "=")) ;control property assignments
				{
					if(InStr(line, "this." CurrentControl.Name ".Size")) ;Some basic ones first
					{
						Width := Regex.MatchSimple(line, "width", "\.Size\((?P<width>\d+),.*?(?P<height>\d+)")
						Height := Regex.MatchSimple(line, "height", "\.Size\((?P<width>\d+),.*?(?P<height>\d+)")
						if(width)
							CurrentControl.Width := width
						if(height)
							CurrentControl.height := height
						handled := true
					}
					if(InStr(line, "this." CurrentControl.Name ".Location"))
					{
						x := Regex.MatchSimple(line, "x", "\.Point\((?P<x>\d+),.*?(?P<y>\d+)")
						y := Regex.MatchSimple(line, "y", "\.Point\((?P<x>\d+),.*?(?P<y>\d+)")
						if(x)
							CurrentControl.x := x
						if(x)
							CurrentControl.y := y
						handled := true
					}
					if(InStr(line, "this." CurrentControl.Name ".Text"))
					{
						CurrentControl.Text := Regex.MatchSimple(line, "text", """(?P<text>.*)""")
						handled := true
					}
				}
				if(!handled && IsFunc(this[CurrentControl.Type])) ;Process special properties depending on type
					Handled := this[CurrentControl.Type](CurrentControl, line)
			}
		}
		
		;Now that all info is available, write the file
		OutputFile := "Class " Class " Extends CGUI`n{`n`t__New()`n`t{`n"
		for index, Control in Controls
		{
			Options := (Control.HasKey("x") ? "x" Control.x " " : "" ) (Control.HasKey("y") ? "y" Control.y " " : "" ) (Control.HasKey("width") ? "w" Control.width " " : "" ) (Control.HasKey("height") ? "h" Control.height : "" )
			OutputFile .= "`t`tthis.Add(""" Control.Type """, """ Control.Name """, """ Options """, """ Control.Text """)`n"
			for Property, Value in Control
				if Property not in x,y,width,height,name,type,Text,HasEvents,Events
				{
					if Value is Number
						OutputFile .= "`t`tthis." Control.Name "." Property " := " Value "`n"
					else if(Value = "true" || Value = "false")
						OutputFile .= "`t`tthis." Control.Name "." Property " := " Value "`n"
					else
						OutputFile .= "`t`tthis." Control.Name "." Property " := """ Value """`n"
				}
			OutputFile .= "`t`t`n"
		}
		for Property, Value in Window
		{
			if Value is Number
				OutputFile .= "`t`tthis." Property " := " Value "`n"
			else if(Value = "true" || Value = "false")
				OutputFile .= "`t`tthis." Property " := " Value "`n"
			else
				OutputFile .= "`t`tthis." Property " := """ Value """`n"
		}
		OutputFile .= "`t`tthis.Show()`n"		
		OutputFile .= "`t}"
		for index, Control in Controls
		{
			for index2, Event in Control.Events
			{
				OutputFile .= "`n`t" Control.Name Event "`n`t{`n`t`t`n`t}"
				AnyEvents := true
			}
		}
		;~ if(!AnyEvents)
			;~ OutputFile .= "`t}`n"
		OutputFile .= "`n}`n"
		for index, Control in Controls
		{
			if(Control.Events.MaxIndex() >= 1)
				OutputFile .= Class "_" Control.Name ":`n"
		}
		if(AnyEvents)
			OutputFile .= "CGUI.HandleEvent()`nreturn"
		FileDelete, % OutPath
		FileAppend, % OutputFile, % OutPath
	}
	Checkbox(CurrentControl, line)
	{
		if(InStr(line, "new System.EventHandler"))
		{
			EventHandled := true
			if(InStr(line, "_CheckedChanged);"))
				CurrentControl.Events.Insert("_CheckedChanged()")
			else
				EventHandled := false
			if(EventHandled)
				CurrentControl.HasEvents := true
		}
		else if(InStr(line, "this." CurrentControl.Name ".Checked"))
			CurrentControl.Checked := (InStr(line, "true") || InStr(line, "1;"))
	}
}
ConverterGUI_BtnBrowse:
ConverterGUI_BtnSaveBrowse:
ConverterGUI_BtnConvert:
CGUI.HandleEvent()
return
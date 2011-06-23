#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SetWorkingDir %a_scriptdir%
if(1 = "")
{
	FileSelectFile, OldFile , 1, %A_ScriptDir%, Select old file, *.xml
	if(Errorlevel)
		ExitApp
}
else
	OldFile = %1%
if(2 = "")
{
	FileSelectFile, NewFile , 1, %A_ScriptDir%, Select new file, *.xml
	if(Errorlevel)
		ExitApp
}
else
	NewFile = %2%
FileRead, OldXML, %OldFile%
FileRead, NewXML, %NewFile%
OldXMLObject := XML_Read(OldXML)
NewXMLObject := XML_Read(NewXML)
PatchXMLObject := Object("Events", Object("Event", Array()), "Remove", Object("OfficialEvent", Array()), "Message", "Automatically generated")
;Read current version from 7plus.ahk
Loop, Read, 7plus.ahk
{
	if(InStr(A_LoopReadLine, "MajorVersion := "))
		PatchXMLObject.MajorVersion :=  SubStr(A_LoopReadLine, InStr(A_LoopReadLine, " := ") + 4)
	else if(InStr(A_LoopReadLine, "MinorVersion := "))
		PatchXMLObject.MinorVersion := SubStr(A_LoopReadLine, InStr(A_LoopReadLine, " := ") + 4)
	else if(InStr(A_LoopReadLine, "BugfixVersion := "))
		PatchXMLObject.BugfixVersion := SubStr(A_LoopReadLine, InStr(A_LoopReadLine, " := ") + 4)
}
if(3="")
{
	InputBox, PatchVersion, Patch version, Enter patch version (0 for release)
	if(Errorlevel)
		ExitApp
}
else
	PatchVersion := 0
PatchXMLObject.PatchVersion := PatchVersion

;Convert to array
Loop % NewXMLObject.Events.Event.len()
{
	NewEvent := NewXMLObject.Events.Event[A_Index]
	if(!IsFunc(NewEvent.Conditions.Condition.len)) ;Single condition
	{
		XMLConditions := Array()
		if(NewEvent.Conditions.HasKey("Condition"))
			XMLConditions.append(NewEvent.Conditions.Condition)
		NewEvent.Conditions.Condition := XMLConditions
	}
	if(!IsFunc(NewEvent.Actions.Action.len)) ;Single action
	{
		XMLActions := Array()
		if(NewEvent.Actions.HasKey("Action"))
			XMLActions.append(NewEvent.Actions.Action)
		NewEvent.Actions.Action := XMLActions
	}
}
Loop % OldXMLObject.Events.Event.len()
{
	OldEvent := OldXMLObject.Events.Event[A_Index]
	;Convert to array
	if(!IsFunc(OldEvent.Conditions.Condition.len)) ;Single condition
	{
		XMLConditions := Array()
		if(OldEvent.Conditions.HasKey("Condition"))
			XMLConditions.append(OldEvent.Conditions.Condition)
		OldEvent.Conditions.Condition := XMLConditions
	}
	if(!IsFunc(OldEvent.Actions.Action.len)) ;Single Action
	{
		XMLActions := Array()
		if(OldEvent.Actions.HasKey("Action"))
			XMLActions.append(OldEvent.Actions.Action)
		OldEvent.Actions.Action := XMLActions
	}
	;Warn if official event is not set
	if(!OldEvent.HasKey("OfficialEvent"))
		Msgbox % OldEvent.ID ": " OldEvent.Name " doesn't have an official id!"
	if(NewEvent := NewXMLObject.Events.Event.SubItem("OfficialEvent", OldEvent.OfficialEvent)) ;Event exists in both files, look for changes
	{
		PatchEvent := Object("OfficialEvent", OldEvent.OfficialEvent)
		Updated := false
		if(!objEqual(OldEvent.Conditions, NewEvent.Conditions))
		{
			PatchEvent.Conditions := NewEvent.Conditions
			Updated := true
		}
		if(!objEqual(OldEvent.Actions, NewEvent.Actions))
		{
			PatchEvent.Actions := NewEvent.Actions
			Updated := true
		}
		enum := NewEvent._newEnum()
		while enum[key,value]
		{
			if(key = "OfficialEvent")
				continue
			if(key = "Actions" || key = "Conditions")
				continue
			if(key = "Trigger")
			{
				if(!objEqual(OldEvent.Trigger, NewEvent.Trigger))
				{
					PatchEvent.Trigger := NewEvent.Trigger
					Updated := true
				}
				continue
			}
			if(IsObject(value))
				msgbox found unexpected object: %key%
			if(!OldEvent.HasKey(key) || OldEvent[key] != value)
			{
				PatchEvent[key] := value
				Updated := true
			}
		}
		if(Updated)
			PatchXMLObject.Events.Event.Append(PatchEvent)
	}
	else ;Event was deleted
		PatchXMLObject.Remove.OfficialEvent.Append(OldEvent.OfficialEvent)
}
Loop % NewXMLObject.Events.Event.len()
{
	NewEvent := NewXMLObject.Events.Event[A_Index]
	if(!OldXMLObject.Events.Event.SubItem("OfficialEvent", NewEvent.OfficialEvent)) ;Event was added
		PatchXMLObject.Events.Event.Append(NewEvent)
}
XML_Save(PatchXMLObject, A_ScriptDir "\Events\ReleasePatch\" PatchXMLObject.MajorVersion "." PatchXMLObject.MinorVersion "." PatchXMLObject.BugfixVersion "." PatchXMLObject.PatchVersion ".xml")

#include %A_ScriptDir%\lib\richobject.ahk
#include %A_ScriptDir%\xml.ahk
#include %A_ScriptDir%\miscfunctions.ahk
#include %A_ScriptDir%\lib\array.ahk
#include %A_ScriptDir%\lib\functions.ahk
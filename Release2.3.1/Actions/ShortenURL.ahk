Action_ShortenURL_Init(Action)
{
	Action.Category := "7plus"
	Action.URL := "${Clip}"
	Action.Method := "Goo.gl"
	Action.WriteToClipboard := true
	Action.WriteToPlaceholder := "ShortURL"
}
Action_ShortenURL_ReadXML(Action, XMLAction)
{
	Action.ReadVar(XMLAction, "URL")
	Action.ReadVar(XMLAction, "Method")
	Action.ReadVar(XMLAction, "WriteToClipboard")
	Action.ReadVar(XMLAction, "WriteToPlaceholder")
}
Action_ShortenURL_Execute(Action, Event)
{
	URL := Event.ExpandPlaceholders(Action.URL)
	if(!IsURL(URL))
		return 0
	if(Action.Method = "Goo.gl")
		ShortURL := googl(URL)
	
	if(ShortURL)
	{
		if(Action.WriteToClipboard)
			Clipboard := ShortURL			
		if(Action.WriteToPlaceholder)
			Events.GlobalPlaceholders[Action.WriteToPlaceholder] := ShortURL
		Notify("URL shortened!", "URL shortened" (Action.WriteToClipboard ? " and copied to clipboard!" : "!"), 2, "GC=555555 TC=White MC=White",NotifyIcons.Success)
		return 1
	}
	return 0
} 

Action_ShortenURL_DisplayString(Action)
{
	return "Shorten URL: " Action.URL
}
Action_ShortenURL_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Text", "Desc", "This action shortens the URL in the clipboard by using the Goo.gl service. The shortened URL can be written back to clipboard or stored in a placeholder.")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "URL", "", "", "URL:", "Placeholders", "Action_ShortenURL_Placeholders")
		SubEventGUI_Add(Action, ActionGUI, "Edit", "WriteToPlaceholder", "", "", "hPlaceholder:")
		SubEventGUI_Add(Action, ActionGUI, "Checkbox", "WriteToClipboard", "Copy shortened URL to clipboard")
	}
	else if(GoToLabel = "Placeholders")
		SubEventGUI_Placeholders(sActionGUI, "URL")
}
Action_ShortenURL_Placeholders:
Action_ShortenURL_GuiShow("", "", "Placeholders")
return

Action_ShortenURL_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
} 

;Shortens a URL using goo.gl service
;Written By Flak
googl(url) 
{ 
  static apikey:="AIzaSyBXD-RmnD2AKzQcDHGnzZh4humG-7Rpdmg" 
  http:=ComObjCreate("WinHttp.WinHttpRequest.5.1") 
  main:="https://www.googleapis.com/urlshortener/v1/url" 
  params:="?key=" apikey 
  http.open("POST", main . params, false) 
  http.SetRequestHeader("Content-Type", "application/json") 
  http.send("{""longUrl"": """ url """}") 
  RegExMatch(http.ResponseText, """id"": ""(.*?)""", match) 
  return match1 
}
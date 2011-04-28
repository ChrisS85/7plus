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
	Action.URL := XMLAction.HasKey("URL") ? XMLAction.URL : Action.URL
	Action.Method := XMLAction.HasKey("Method") ? XMLAction.Method : Action.Method
	Action.WriteToClipboard := MLAction.HasKey("WriteToClipboard") ? XMLAction.WriteToClipboard : Action.WriteToClipboard
	Action.WriteToPlaceholder := MLAction.HasKey("WriteToPlaceholder") ? XMLAction.WriteToPlaceholder : Action.WriteToPlaceholder
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
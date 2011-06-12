Action_FlatView_Init(Action)
{
	Action.Category := "Explorer"
	Action.Paths := "${SelN}"
}

Action_FlatView_ReadXML(Action, XMLAction)
{
	Action.Paths := XMLAction.HasKey("Paths") ? XMLAction.Paths : Action.Paths
}
Action_FlatView_Execute(Action, Event)
{
	global Vista7
	if(Vista7)
		FlatView(ToArray(Event.ExpandPlaceholders(Action.Paths)))
	return 1
} 

Action_FlatView_DisplayString(Action)
{
	return "Show flat view of these files: " Action.Paths
}

Action_FlatView_GuiShow(Action, ActionGUI, GoToLabel = "")
{
	static sActionGUI
	if(GoToLabel = "")
	{
		sActionGUI := ActionGUI
		SubEventGUI_Add(Action, ActionGUI, "Edit", "Paths", "", "", "Paths:", "Placeholders", "Action_FlatView_Placeholders","","","This can be multiple, newline-delimited paths such as ${SelNM}")
	}
	else if(GoToLabel = "Placeholders")
		SubEventGUI_Placeholders(sActionGUI, "Paths")
}
Action_FlatView_Placeholders:
Action_FlatView_GuiShow("", "", "Placeholders")
return

Action_FlatView_GuiSubmit(Action, ActionGUI)
{
	SubEventGUI_GUISubmit(Action, ActionGUI)
	Action.Slot := min(max(Action.Slot, 0), 9)
}


;Makes a currently active explorer window show all files contained in "files" list. Only folders are used, files are ignored.
;files is a `n separated list of complete paths
FlatView(files)
{
	if(files = "")
		return
		
	Path := FindFreeFileName(A_Temp "\7plus\FlatView.search-ms")
	searchString=
	(
	<?xml version="1.0"?>
	<persistedQuery version="1.0">
		<viewInfo viewMode="details" iconSize="16" stackIconSize="0" displayName="Test" autoListFlags="0">
			<visibleColumns>
				<column viewField="System.ItemNameDisplay"/>
				<column viewField="System.ItemTypeText"/>
				<column viewField="System.Size"/>
				<column viewField="System.ItemFolderPathDisplayNarrow"/>
			</visibleColumns>
			<sortList>
				<sort viewField="System.Search.Rank" direction="descending"/>
				<sort viewField="System.ItemNameDisplay" direction="ascending"/>
			</sortList>
		</viewInfo>
		<query>
			<attributes/>
			<kindList>
				<kind name="item"/>
			</kindList>
			<scope>
	)
	Loop % files.len()
	{ 
		if(InStr(FileExist(files[A_Index]), "D"))
			searchString:=searchString "<include path=""" files[A_Index] """/>"
	}
	searchString.="</scope></query></persistedQuery>"
	Fileappend,%searchString%, %Path%
	SetDirectory(Path)
}
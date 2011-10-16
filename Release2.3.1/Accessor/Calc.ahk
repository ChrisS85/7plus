Class CCalc extends CAccessorPlugin
{
	__New(AccessorSettings)
	{
	}
	ShowSettings(PluginSettings, PluginGUI)
	{
	}
	IsInSinglePluginContext(Filter, LastFilter)
	{
	}
	GetDisplayStrings(AccessorListEntry, ByRef Title, ByRef Path, ByRef Detail1, ByRef Detail2)
	{
	}
	OnAccessorOpen(Accessor)
	{
	}
	OnAccessorClose(Accessor)
	{
	}
	OnExit()
	{
	}
	FillAccessorList(Accessor, Filter, LastFilter, ByRef IconCount, KeywordSet)
	{
	}
	PerformAction(Accessor, AccessorListEntry)
	{
	}
	ListViewEvents(AccessorListEntry)
	{
	}
	EditEvents(AccessorListEntry, Filter, LastFilter)
	{
	}
	OnKeyDown()
	{
	}
	SetupContextMenu(Calc, AccessorListEntry)
	{
	}
}
Accessor_Calc_Init(ByRef Calc, PluginSettings)
{
	Calc.Settings.Keyword := "="
	Calc.DefaultKeyword := "="
	Calc.KeywordOnly := false ;This is actually true, but there doesn't need to be a space after this keyword so it is handled manually
	Calc.MinChars := 0
	Calc.OKName := "Copy Result"
	Calc.Description := "Use Google Calc to make calculations `nand unit conversions (e.g. ""g in pounds"")."
	Calc.HasSettings := True
}
Accessor_Calc_ShowSettings(Calc, PluginSettings, PluginGUI)
{
	SubEventGUI_Add(PluginSettings, PluginGUI, "Edit", "Keyword", "", "", "Keyword:")
}
Accessor_Calc_IsInSinglePluginContext(Calc, Filter, LastFilter)
{
}
Accessor_Calc_GetDisplayStrings(Calc, AccessorListEntry, ByRef Title, ByRef Path, ByRef Detail1, ByRef Detail2)
{
	Path := AccessorListEntry.CalcString
	Detail1 := "Google"
}
Accessor_Calc_OnAccessorOpen(Calc, Accessor)
{
	Calc.List := Array()
}
Accessor_Calc_OnAccessorClose(Calc, Accessor)
{
	Loop % Calc.List.len()
		if(Calc.List[A_Index].Icon != Accessor.GenericIcons.Application)			
			DestroyIcon(Calc.List[A_Index].Icon)
}
Accessor_Calc_OnExit(Calc)
{
}
Accessor_Calc_FillAccessorList(Calc, Accessor, Filter, LastFilter, ByRef IconCount, KeywordSet)
{
	if(!strStartsWith(Filter, Calc.Settings.Keyword) && !KeywordSet)
		return
	Loop % Calc.List.len()
	{
		ImageList_ReplaceIcon(Accessor.ImageListID, -1, Calc.List[A_Index].Icon)
		IconCount++
		Accessor.List.append(Object("Title",Calc.List[A_Index].Result,"Path",Calc.List[A_Index].URL, "Type","Calc", "Icon", IconCount))
	}
}
Accessor_Calc_PerformAction(Calc, Accessor, AccessorListEntry)
{
	Clipboard := AccessorListEntry.Title
}
Accessor_Calc_ListViewEvents(Calc, AccessorListEntry)
{
}
Accessor_Calc_EditEvents(Calc, AccessorListEntry, Filter, LastFilter)
{
	SetTimer, QueryCalcResult, -500
	return false
}
Accessor_Calc_OnKeyDown(Calc, wParam, lParam, Filter, selected, AccessorListEntry)
{
	global Accessor
	if(wParam = 13)
		SetTimer, QueryCalcResult, -1
	if(wParam = 67 && GetKeyState("CTRL","P") && !Edit_TextIsSelected("","ahk_id " Accessor.HwndEdit))
	{
		AccessorCopyField("Title")
		return true
	}
	return 0
}
QueryCalcResult:
QueryCalcResult()
return
QueryCalcResult()
{
	global AccessorPlugins, AccessorEdit, Accessor
	CalcPlugin := AccessorPlugins.SubItem("Type", "Calc")
	GUINum := Accessor.GUINum
	if(!GUINum)
		return
	Gui, %GUINum%: Default
	GuiControlGet, Filter, , AccessorEdit	
	if(!strStartsWith(Filter, CalcPlugin.Settings.Keyword))
		return
	Filter := strTrimLeft(Filter, CalcPlugin.Settings.Keyword)
	outputdebug query Calc result for filter %filter%
	URL := uriEncode("http://www.google.com/search?q=" Filter)
	outputdebug url %url%
	FileDelete, %A_Temp%\7plus\GoogleQuery.htm
	URLDownloadToFile, %URL%, %A_Temp%\7plus\GoogleQuery.htm
	FileRead, GoogleQuery, %A_Temp%\7plus\GoogleQuery.htm
	
	Loop % CalcPlugin.List.len()
		if(CalcPlugin.List[A_Index].Icon)
			DestroyIcon(CalcPlugin.List[A_Index].Icon)
	CalcPlugin.List := Array()
	
	if(InStr(GoogleQuery, "More about calculator"))
	{
		RegexMatch(GoogleQuery, "<b>.*?=.*?</b>", result)
		result := strTrim(strTrim(result, "<b>"), "</b>")
		StringReplace, result, result, <sup>, ^
		outputdebug result %result%
		result := unhtml(Deref_Umlauts(result))
		if(result)
		{
			outputdebug calc result: %result%
			if(!FileExist( A_Temp "\7plus\calc_img.gif"))
				URLDownloadToFile, http://www.google.com/images/calc_img.gif, %A_Temp%\7plus\calc_img.gif
			pBitmap := Gdip_CreateBitmapFromFile(A_Temp "\7plus\calc_img.gif")
			hIcon := Gdip_CreateHICONFromBitmap(pBitmap)
			outputdebug hicon %hicon%
			CalcPlugin.List.append(Object("result",result,"URL", "http://www.google.com/search?q=" Filter, "Icon", hIcon))
			FillAccessorList()
		}
	}
	/*
	else if(InStr(GoogleQuery, "<b>Weather</b> for <b>"))
	{
		outputdebug weather detected
		RegexMatch(GoogleQuery, "<div>.*?<b>(.*?)</b>", result)
		RegexMatch(GoogleQuery, "<b>(\d+°C)</b>", result2)
		outputdebug result0 %result0% result20 %result20%
		if(result0 = 1 && result20 = 1)
		{
			
			StringReplace, result1, %A_Space%,_
			if(!FileExist( A_Temp "\7plus\" result1 ".gif"))
				URLDownloadToFile, http://www.google.com/images/weather/%result1%.gif, %A_Temp%\7plus\%result1%.gif
			pBitmap := Gdip_CreateBitmapFromFile(A_Temp "\7plus\" result1 ".gif")
			hIcon := Gdip_CreateHICONFromBitmap(pBitmap)
			outputdebug hicon %hicon%
			CalcPlugin.List.append(Object("result",result1,"Details",result21,"URL", "http://www.google.com/search?q=" Filter, "Icon", hIcon))
			FillAccessorList()
		}
	}
	*/
} 
Accessor_Calc_SetupContextMenu(Calc, AccessorListEntry)
{
	Menu, AccessorMenu, add, Copy Result (CTRL+C), AccessorCopyTitle
	Menu, AccessorMenu, Default,Copy Result (CTRL+C)
}
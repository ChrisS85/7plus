;Checks if a context menu is active and has focus
;Need to check if other context menus are active (trillian, browsers,...)
IsContextMenuActive() 
{ 
	GuiThreadInfoSize := 24 + 6 * A_PtrSize 
	VarSetCapacity(GuiThreadInfo, GuiThreadInfoSize) 
	NumPut(GuiThreadInfoSize, GuiThreadInfo, 0) 
	if not DllCall("GetGUIThreadInfo", uint, 0, "Ptr", &GuiThreadInfo) 
	{ 
	  MsgBox GetGUIThreadInfo() indicated a failure. 
	  return 
	} 
	; GuiThreadInfo contains a DWORD flags at byte 4 
	; Bit 4 of this flag is set if the thread is in menu mode. GUI_INMENUMODE = 0x4 
	if (NumGet(GuiThreadInfo, 4) & 0x4) 
		return true
	return false
}

;This stuff doesn't use COM.ahk yet :(
/*
Executes context menu entries of shell items without showing their menus
Usage:
ShellContextMenu("Desktop",1)			;Calls "Next Desktop background" in Win7
1st parameter can be "Desktop" for empty selection desktop menu, a path, or an idl
Leave 2nd parameter empty to show context menu and extract idn by clicking on an entry (shows up in debugview)
*/ 
ShellContextMenu(sPath,idn="") 
{ 
	global hAHK
	; DllCall("ole32\OleInitialize", "Ptr", 0) 
	if (spath="Desktop")
	{
		 DllCall("shell32\SHGetDesktopFolder", "UintP", psf)
		 DllCall(NumGet(NumGet(1*psf)+32), "Uint", psf, "Uint", 0, "Uint", COM_GUID4String(IID_IContextMenu,"{000214E4-0000-0000-C000-000000000046}"), "UintP", pcm)  ;IContextMenu
		 outputdebug pcm %pcm%
	 }
	else
	{
		 If   sPath Is Not Integer 
			DllCall("shell32\SHParseDisplayName", "Uint", sPath, "Uint", 0, "UintP", pidl, "Uint", 0, "Uint", 0) 
		Else   DllCall("shell32\SHGetFolderLocation", "Uint", 0, "int", sPath, "Uint", 0, "Uint", 0, "UintP", pidl) 
		DllCall("shell32\SHBindToParent", "Uint", pidl, "Uint", COM_GUID4String(IID_IShellFolder,"{000214E6-0000-0000-C000-000000000046}"), "UintP", psf, "UintP", pidlChild) 
		DllCall(NumGet(NumGet(1*psf)+40), "Uint", psf, "Uint", 0, "Uint", 1, "UintP", pidlChild, "Uint", COM_GUID4String(IID_IContextMenu,"{000214E4-0000-0000-C000-000000000046}"), "Uint", 0, "UintP", pcm) ; +40 IShellFolder->GetUIObjectOf()
		CoTaskMemFree(pidl) 
	 }
	 Release(psf) 

   hMenu := DllCall("CreatePopupMenu") 
   idnMIN=1
   DllCall(NumGet(NumGet(1*pcm)+12), "Uint", pcm, "Uint", hMenu, "Uint", 0, "Uint", idnMIN, "Uint", 0x7FFF, "Uint", 0)   ; QueryContextMenu
	  

   DetectHiddenWindows, On 
   Process, Exist 
   WinGet, hAHK, ID, ahk_pid %ErrorLevel% 
   if !idn
   {
	   WinActivate, ahk_id %hAHK% 	   
	   Global   pcm2 := QueryInterface(pcm,IID_IContextMenu2:="{000214F4-0000-0000-C000-000000000046}") 
	   Global   pcm3 := QueryInterface(pcm,IID_IContextMenu3:="{BCFCE0A0-EC17-11D0-8D10-00A0C90F2719}") 
	   Global   WPOld:= DllCall("SetWindowLong", "Ptr", hAHK, "int",-4, "int",RegisterCallback("WindowProc")) 
	   DllCall("GetCursorPos", "int64P", pt) 
	   DllCall("InsertMenu", "Ptr", hMenu, "Uint", 0, "Uint", 0x0400|0x800, "Uint", 2, "Uint", 0) 
	   DllCall("InsertMenu", "Ptr", hMenu, "Uint", 0, "Uint", 0x0400|0x002, "Uint", 1, "Uint", &sPath) 
	   idn2 := DllCall("TrackPopupMenu", "Ptr", hMenu, "Uint", 0x0100, "int", pt << 32 >> 32, "int", pt >> 32, "Uint", 0, "Ptr", hAHK, "Uint", 0)
	 }
	 else
	 	 idn2:=idn
	NumPut(VarSetCapacity(ici,64,0),ici)
	NumPut(0x4000|0x20000000,ici,4) 
	NumPut(1,NumPut(hAHK,ici,8),12)
	NumPut(idn2-idnMIN,NumPut(idn2-idnMIN,ici,12),24)
	if !idn
		NumPut(pt,ici,56,"int64") 
	DllCall(NumGet(NumGet(1*pcm)+16), "Uint", pcm, "Uint", &ici)   ; InvokeCommand 
	if !idn
	{
		VarSetCapacity(sName,259), DllCall(NumGet(NumGet(1*pcm)+20), "Uint", pcm, "Uint", idn2-idnMIN, "Uint", 1, "Uint", 0, "str", sName, "Uint", 260)   ; GetCommandString
		outputdebug command string: %sname% idn: %idn2%
		DllCall("GlobalFree", "Uint", DllCall("SetWindowLong", "Ptr", hAHK, "int", -4, "int", WPOld)) 

		Release(pcm3) 
		Release(pcm2) 
	}
   DllCall("DestroyMenu", "Ptr", hMenu) 
   Release(pcm) 
   DllCall("ole32\OleUnInitialize", "Ptr", 0) 
   if !idn
	 	pcm2:=pcm3:=WPOld:=0 
} 
WindowProc(hWnd, nMsg, wParam, lParam) 
{ 
	WasCritical := A_IsCritical
   Critical 
   Global   pcm2, pcm3, WPOld 
   If   pcm3 
   { 
      If   !DllCall(NumGet(NumGet(1*pcm3)+28), "Uint", pcm3, "Uint", nMsg, "Uint", wParam, "Uint", lParam, "UintP", lResult) 
         Return   lResult 
   } 
   Else If   pcm2 
   { 
      If   !DllCall(NumGet(NumGet(1*pcm2)+24), "Uint", pcm2, "Uint", nMsg, "Uint", wParam, "Uint", lParam) 
         Return   0 
   } 
   if(!WasCritical)
		Critical, Off
   Return   DllCall("user32.dll\CallWindowProc", "Uint", WPOld, "Uint", hWnd, "Uint", nMsg, "Uint", wParam, "Uint", lParam) 
} 
VTable(ppv, idx) 
{ 
   Return   NumGet(NumGet(1*ppv)+4*idx) 
} 
QueryInterface(ppv, ByRef IID) 
{ 
   If   StrLen(IID)=38 
      COM_GUID4String(IID,IID) 
   DllCall(NumGet(NumGet(1*ppv)), "Uint", ppv, "str", IID, "UintP", ppv) 
   Return   ppv 
} 
AddRef(ppv) 
{ 
   Return   DllCall(NumGet(NumGet(1*ppv)+4), "Uint", ppv) 
} 
Release(ppv)
{ 
   Return   DllCall(NumGet(NumGet(1*ppv)+8), "Uint", ppv) 
} 
CoTaskMemAlloc(cb) 
{ 
   Return   DllCall("ole32\CoTaskMemAlloc", "Uint", cb) 
} 
CoTaskMemFree(pv) 
{ 
   Return   DllCall("ole32\CoTaskMemFree", "Uint", pv) 
} 
Unicode4Ansi(ByRef wString, sString, nSize = "") 
{ 
   If (nSize = "") 
       nSize:=DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", 0, "int", 0) 
   VarSetCapacity(wString, nSize * 2 + 1) 
   DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", &wString, "int", nSize + 1) 
   Return   &wString 
}

API_GetMenuItemID( hMenu, nPos ) { 
   return DllCall("GetMenuItemID", "uint", hMenu, "int", nPos) 
} 
API_GetSubmenu( hMenu, nPos ) { 
   return DllCall("GetSubMenu", "uint", hMenu, "int", nPos) 
} 
API_GetMenuItemsCount(hMenu) 
{ 
   return DllCall("GetMenuItemCount", "Uint", hMenu, "Uint") 
}
;usage example:
;x:=TranslateMUI("shell32.dll",31236)
TranslateMUI(resDll, resID)
{
VarSetCapacity(buf, 256) 
hDll := DllCall("LoadLibrary", "str", resDll, "Ptr") 
Result := DllCall("LoadString", "Ptr", hDll, "uint", resID, "str", buf, "int", 128)
return buf
}

;Splits a command into command and arguments
SplitCommand(fullcmd, ByRef cmd, ByRef args)
{
	if(strStartsWith(fullcmd,""""))
	{
		pos:=InStr(fullcmd, """" ,0, 2)
		cmd:=SubStr(fullcmd,2,pos-2)
		args:=SubStr(fullcmd,pos+1)
		args:=strTrim(args," ")
	}
	else if(pos:=InStr(fullcmd, " " ,0, 1))
	{
		cmd:=SubStr(fullcmd,1,pos-1)
		args:=SubStr(fullcmd,pos+1)
		args:=strTrim(args," ")
	}
	else
	{
		cmd:=fullcmd
		args:=""
	}
}

/* Group: About
	o v0.81 by majkinetor.
	o Licenced under BSD <http://creativecommons.org/licenses/BSD/> 
*/
GetFreeGuiNum(start){
	loop {
		Gui %start%:+LastFoundExist
		IfWinNotExist
			return start
		start++
		if(start = 100)
			return 0
	}
	return 0
}

IsWindowUnderCursor(what)
{
	MouseGetPos, , , win
	if(InStr(WinGetClass("ahk_id " win),what))
		return true
	return false
}

IsControlUnderCursor(what)
{
	MouseGetPos, , , , control
	IfInString control, %what%
		return control
	return false
}

API_SetWinEventHook(eventMin, eventMax, hmodWinEventProc, lpfnWinEventProc, idProcess, idThread, dwFlags) { 
   DllCall("CoInitialize", "Ptr", 0) 
   return DllCall("SetWinEventHook", "uint", eventMin, "uint", eventMax, "Ptr", hmodWinEventProc, "uint", lpfnWinEventProc, "uint", idProcess, "uint", idThread, "uint", dwFlags, "Ptr") 
} 

API_UnhookWinEvent( hWinEventHook ) { 
   return DllCall("UnhookWinEvent", "Ptr", hWinEventHook) 
} 

;disables or restores original minimize anim setting
DisableMinimizeAnim(disable)
{
	static original,lastcall	
	if(disable && !lastcall) ;Backup original value if disabled is called the first time after a restore call
	{
		lastcall:=1
		RegRead, original, HKCU, Control Panel\Desktop\WindowMetrics , MinAnimate
	}
	else if(!disable) ;this is a restore call, on next disable backup may be created again
		lastcall:=0
	;Disable Minimize/Restore animation
	VarSetCapacity(struct, 8, 0)	
	NumPut(8, struct, 0, "UInt")
	if(disable || !original)
		NumPut(0, struct, 4, "Int")
	else
		NumPut(1, struct, 4, "UInt")
	DllCall("SystemParametersInfo", "UINT", 0x0049,"UINT", 8,"Ptr", &struct,"UINT", 0x0003) ;SPI_SETANIMATION            0x0049 SPIF_SENDWININICHANGE 0x0002
}
/* 
Performs a hittest on the window under the mouse and returns the WM_NCHITTEST Result
#define HTERROR             (-2) 
#define HTTRANSPARENT       (-1) 
#define HTNOWHERE           0 
#define HTCLIENT            1 
#define HTCAPTION           2 
#define HTSYSMENU           3 
#define HTGROWBOX           4 
#define HTSIZE              HTGROWBOX 
#define HTMENU              5 
#define HTHSCROLL           6 
#define HTVSCROLL           7 
#define HTMINBUTTON         8 
#define HTMAXBUTTON         9 
#define HTLEFT              10 
#define HTRIGHT             11 
#define HTTOP               12 
#define HTTOPLEFT           13 
#define HTTOPRIGHT          14 
#define HTBOTTOM            15 
#define HTBOTTOMLEFT        16 
#define HTBOTTOMRIGHT       17 
#define HTBORDER            18 
#define HTREDUCE            HTMINBUTTON 
#define HTZOOM              HTMAXBUTTON 
#define HTSIZEFIRST         HTLEFT 
#define HTSIZELAST          HTBOTTOMRIGHT 
#if(WINVER >= 0x0400) 
#define HTOBJECT            19 
#define HTCLOSE             20 
#define HTHELP              21 
*/ 
MouseHitTest()
{
	CoordMode, Mouse, Screen
	MouseGetPos, MouseX, MouseY, WindowUnderMouseID 
	WinGetClass, winclass , ahk_id %WindowUnderMouseID%
	if winclass in BaseBar,D2VControlHost,Shell_TrayWnd,WorkerW,ProgMan  ; make sure we're not doing this on the taskbar
		return -2
	; WM_NCHITTEST 
	SendMessage, 0x84,, ( (MouseY&0xFFFF) << 16 )|(MouseX&0xFFFF),, ahk_id %WindowUnderMouseID%
	return ErrorLevel
}
IsConnected(URL="http://code.google.com/p/7plus/")
{
	return DllCall("Wininet.dll\InternetCheckConnection", "Str", URL,"UInt", 1, "UInt",0, "UInt")
}
/*! TheGood (modified a bit by Fragman)
    Checks if a window is in fullscreen mode. 
    ______________________________________________________________________________________________________________ 
    sWinTitle       - WinTitle of the window to check. Same syntax as the WinTitle parameter of, e.g., WinExist(). 
    bRefreshRes     - Forces a refresh of monitor data (necessary if resolution has changed) 
    UseExcludeList  - returns false if window class is in FullScreenExclude (explorer, browser etc)
    UseIncludeList  - returns true if window class is in FullScreenInclude (applications capturing gamepad input)
    Return value    o If window is fullscreen, returns the index of the monitor on which the window is fullscreen. 
                    o If window is not fullscreen, returns False. 
    ErrorLevel      - Sets ErrorLevel to True if no window could match sWinTitle 
    
        Based on the information found at http://support.microsoft.com/kb/179363/ which discusses under what 
    circumstances does a program cover the taskbar. Even if the window passed to IsFullscreen is not the 
    foreground application, IsFullscreen will check if, were it the foreground, it would cover the taskbar. 
*/ 
IsFullscreen(sWinTitle = "A", UseExcludeList = true, UseIncludeList=true) { 
    Static 
    Local iWinX, iWinY, iWinW, iWinH, iCltX, iCltY, iCltW, iCltH, iMidX, iMidY, iMonitor, c, D, iBestD 
    global FullScreenExclude, FullScreenInclude
    ErrorLevel := False
	
	;Without admin mode processes launched with admin permissions aren't detectable, so better treat all windows as non-fullscreen.
	if(!A_IsAdmin)
		return false
		
    ;Get the active window's dimension 
    hWin := WinExist(sWinTitle) 
    If Not hWin { 
        ErrorLevel := True 
        Return False 
    }
    
    ;Make sure it's not desktop 
    WinGetClass, c, ahk_id %hWin% 
    If (hWin = DllCall("GetDesktopWindow", "Ptr") Or (c = "Progman") Or (c = "WorkerW")) 
        Return False 
    ;Fullscreen include list
    if(UseIncludeList)
    	if c in %FullscreenInclude%
			return true
    ;Fullscreen exclude list
    if(UseExcludeList)
    	if c in %FullscreenExclude%
			return false
    ;Resolution change would only need to be detected every few seconds or so, but since it doesn't add anything notably to cpu usage, just do it always
    SysGet, Mon0, MonitorCount 
    SysGet, iPrimaryMon, MonitorPrimary 
    Loop %Mon0% { ;Loop through each monitor 
        SysGet, Mon%A_Index%, Monitor, %A_Index% 
        Mon%A_Index%MidX := Mon%A_Index%Left + Ceil((Mon%A_Index%Right - Mon%A_Index%Left) / 2) 
        Mon%A_Index%MidY := Mon%A_Index%Top + Ceil((Mon%A_Index%Top - Mon%A_Index%Bottom) / 2) 
    }    
			
    ;Get the window and client area, and style 
    VarSetCapacity(iWinRect, 16), VarSetCapacity(iCltRect, 16) 
    DllCall("GetWindowRect", "Ptr", hWin, "Ptr", &iWinRect) 
	DllCall("GetClientRect", "Ptr", hWin, "Ptr", &iCltRect)
    WinGet, iStyle, Style, ahk_id %hWin% 
    
    ;Extract coords and sizes 
    iWinX := NumGet(iWinRect, 0), iWinY := NumGet(iWinRect, 4) 
    iWinW := NumGet(iWinRect, 8) - NumGet(iWinRect, 0) ;Bottom-right coordinates are exclusive 
    iWinH := NumGet(iWinRect, 12) - NumGet(iWinRect, 4) ;Bottom-right coordinates are exclusive 
    iCltX := 0, iCltY := 0 ;Client upper-left always (0,0) 
    iCltW := NumGet(iCltRect, 8), iCltH := NumGet(iCltRect, 12) 
    ; outputdebug iCltW %iCltW% iCltH %iCltH%
    ;Check in which monitor it lies 
    iMidX := iWinX + Ceil(iWinW / 2) 
    iMidY := iWinY + Ceil(iWinH / 2) 
    
   ;Loop through every monitor and calculate the distance to each monitor 
   iBestD := 0xFFFFFFFF 
    Loop % Mon0 { 
      D := Sqrt((iMidX - Mon%A_Index%MidX)**2 + (iMidY - Mon%A_Index%MidY)**2) 
      If (D < iBestD) { 
         iBestD := D
         iMonitor := A_Index 
      } 
   } 
	
    ;Check if the client area covers the whole screen 
    bCovers := (iCltX <= Mon%iMonitor%Left) And (iCltY <= Mon%iMonitor%Top) And (iCltW >= Mon%iMonitor%Right - Mon%iMonitor%Left) And (iCltH >= Mon%iMonitor%Bottom - Mon%iMonitor%Top) 
    If(bCovers)
		Return True
    ;Check if the window area covers the whole screen and styles 
    bCovers := (iWinX <= Mon%iMonitor%Left) And (iWinY <= Mon%iMonitor%Top) And (iWinW >= Mon%iMonitor%Right - Mon%iMonitor%Left) And (iWinH >= Mon%iMonitor%Bottom - Mon%iMonitor%Top) 
    If (bCovers) ;WS_THICKFRAME or WS_CAPTION 
	{
        bCovers &= Not (iStyle & 0x00040000) Or Not (iStyle & 0x00C00000) 
		Return bCovers ? iMonitor : False 
    } 
	Else 
		Return False 
}

;Returns the workspace area covered by the active monitor
GetActiveMonitorWorkspaceArea(ByRef MonLeft, ByRef MonTop, ByRef MonW, ByRef MonH,hWndOrMouseX, MouseY = "")
{
	mon := GetActiveMonitor(hWndOrMouseX, MouseY)
	if(mon>=0)
	{
		SysGet, Mon, MonitorWorkArea, %mon%
		MonW := MonRight - MonLeft
		MonH := MonBottom - MonTop
	}
}
;Returns the monitor the mouse or the active window is in
GetActiveMonitor(hWndOrMouseX, MouseY = "")
{
	if(MouseY="")
	{
		WinGetPos,x,y,w,h,ahk_id %hWndOrMouseX%
		if(!x && !y && !w && !h)
		{
			MsgBox GetActiveMonitor(): invalid window handle!
			return -1
		}
		x := x + Round(w/2)
		y := y + Round(h/2)
	}
	else
	{
		x := hWndOrMouseX
		y := MouseY
	}
	;Loop through every monitor and calculate the distance to each monitor 
	iBestD := 0xFFFFFFFF 
	SysGet, Mon0, MonitorCount
	Loop %Mon0% { ;Loop through each monitor 
        SysGet, Mon%A_Index%, Monitor, %A_Index% 
        Mon%A_Index%MidX := Mon%A_Index%Left + Ceil((Mon%A_Index%Right - Mon%A_Index%Left) / 2) 
        Mon%A_Index%MidY := Mon%A_Index%Top + Ceil((Mon%A_Index%Top - Mon%A_Index%Bottom) / 2) 
    }
    Loop % Mon0 { 
      D := Sqrt((x - Mon%A_Index%MidX)**2 + (y - Mon%A_Index%MidY)**2) 
      If (D < iBestD) { 
         iBestD := D 
         iMonitor := A_Index 
      } 
   }
   return iMonitor
}
;Returns the (signed) minimum of the absolute values of x and y 
absmin(x,y)
{
	return abs(x)>abs(y) ? y : x
}

;Returns the (signed) maximum of the absolute values of x and y
absmax(x,y)
{
	return abs(x)<abs(y) ? y : x
}

;Returns 1 if x is positive and -1 if x is negative
sign(x)
{
	return x<0 ? -1 : 1
}

;returns the maximum of xdir and y, but with the sign of xdir
dirmax(xdir,y)
{
	if(xdir=0)
		return 0
	if(abs(xdir)>y)
		return xdir
	return xdir/abs(xdir)*abs(y)
}

;returns the maximum of xdir and y, but with the sign of xdir
dirmin(xdir,y)
{
	if(xdir=0)
		return 0
	if(abs(xdir)<y)
		return xdir
	return xdir/abs(xdir)*abs(y)
}

min(x,y)
{
	return x>y ? y : x
}

max(x,y)
{
	return x<y ? y : x
}
DecToHex( ByRef var ) 
{ 
   SetFormat, Integer, Hex 
   var += 0
   SetFormat, Integer, Dec
   return var
} 
strStartsWith(string,start)
{	
	x:=(strlen(start)<=strlen(string)&&Substr(string,1,strlen(start))=start)
	return x
}

strEndsWith(string,end)
{
	return strlen(end)<=strlen(string) && Substr(string,-strlen(end)+1)=end
}

strTrim(string, trim)
{
	return strTrimLeft(strTrimRight(string,trim),trim)
}

strTrimLeft(string,trim)
{
	len:=strLen(trim)
	while(strStartsWith(string,trim))
	{
		StringTrimLeft, string, string, %len% 
	}
	return string
}

strTrimRight(string,trim)
{
	len:=strLen(trim)
	while(strEndsWith(string,trim))
	{					
		StringTrimRight, string, string, %len% 
	}
	return string
}

strStripLeft(string,strip)
{
	return substr(string,InStr(string, strip ,0, 0)+strLen(strip))
}

strStripRight(string,strip)
{
	StringGetPos, pos, string, %strip% ,R
	x:=substr(string,1,pos)
	return substr(string,1,pos)
}

strStrip(string, strip)
{
	return strStripLeft(strStripRight(string,strip),strip)
}

Quote(string, once=1)
{
	if(once)
	{
		if(!strStartsWith(string,""""))
			string:="""" string
		if(!strEndsWith(string,""""))
			string:=string """"
		return string
	}
	return """" string """"
}

UnQuote(string)
{
	if(strStartswith(string,"""") && strEndsWith(string,""""))
		return strTrim(string,"""")
	return string
}

SplitByExtension(ByRef files, ByRef SplitFiles,extensions)
{
	;Init string incase it wasn't resetted before or so
	SplitFiles := Array()
	newFiles := Array()
	Loop, Parse, files, `n,`r  ; Rows are delimited by linefeeds ('r`n). 
	{ 
		SplitPath, A_LoopField , , , OutExtension
		if (InStr(extensions, OutExtension) && OutExtension != "")
			SplitFiles.append(A_LoopField)
		else
			newFiles.append(A_LoopField)
	}
	files := newFiles
	return
}

FindWindow(title,class="",style="",exstyle="",processname="",allowempty=false)
{
	WinGet, id, list,,, Program Manager
	Loop, %id%
	{
		this_id := id%A_Index%
		WinGetClass, this_class, ahk_id %this_id%
		if(class && class!=this_class)
			Continue
		WinGetTitle, this_title, ahk_id %this_id%
		if(title && title!=this_title)
			Continue
		WinGet, this_style, style, ahk_id %this_id%
		if(style && style!=this_style)
			Continue
		WinGet, this_exstyle, exstyle, ahk_id %this_id%
		if(exstyle && exstyle!=this_exstyle)
			Continue			
		WinGetPos ,,,w,h,ahk_id %this_id%
		if(!allowempty && (w=0 || h=0))
			Continue		
		WinGet, this_processname, processname, ahk_id %this_id%
		if(processname && processname!=this_processname)
			Continue
		return this_id
	}
	return 0
}
GetActiveProcessName()
{
	return GetProcessName(WinExist("A"))
}
GetProcessName(hwnd)
{
	WinGet, ProcessName, processname, ahk_id %hwnd%
	return ProcessName
}
GetModuleFileNameEx( pid ) 
{ 
   if A_OSVersion in WIN_95,WIN_98,WIN_ME 
   { 
      MsgBox, This Windows version (%A_OSVersion%) is not supported. 
      return 
   } 

   /* 
      #define PROCESS_VM_READ           (0x0010) 
      #define PROCESS_QUERY_INFORMATION (0x0400) 
   */ 
   h_process := DllCall( "OpenProcess", "uint", 0x10|0x400, "int", false, "uint", pid, "Ptr") 
   if ( ErrorLevel or h_process = 0 ) 
   { 
      outputdebug [OpenProcess] failed. PID = %pid%
      return 
   } 
    
   name_size := A_IsUnicode ? 510 : 255 
   VarSetCapacity( name, name_size ) 
    
   result := DllCall( "psapi.dll\GetModuleFileNameEx", "Ptr", h_process, "uint", 0, "str", name, "uint", name_size ) 
   if ( ErrorLevel or result = 0 ) 
      outputdebug, [GetModuleFileNameExA] failed 
    
   DllCall( "CloseHandle", "Ptr", h_process )
   return, name 
}
; Extract an icon from an executable, DLL or icon file. 
ExtractIcon(Filename, IconNumber, IconSize = 64) 
{ 
    ; LoadImage is not used.. 
    ; ..with exe/dll files because: 
    ;   it only works with modules loaded by the current process, 
    ;   it needs the resource ordinal (which is not the same as an icon index), and 
    ; ..with ico files because: 
    ;   it can only load the first icon (of size %IconSize%) from an .ico file. 
    
    ; If possible, use PrivateExtractIcons, which supports any size of icon. 
	r:=DllCall("PrivateExtractIcons" , "str", Filename, "int", IconNumber-1, "int", IconSize, "int", IconSize, "Ptr*", h_icon, "uint*", 0, "uint", 1, "uint", 0, "int") 
	if !ErrorLevel 
		return h_icon 
    return h_icon ? h_icon : 0 
}
GetVisibleWindowAtPoint(x,y,IgnoredWindow)
{
	DetectHiddenWindows,off
	WinGet, id, list,,,
	Loop, %id%
	{
	    this_id := id%A_Index%
	    ;WinActivate, ahk_id %this_id%
	    WinGetClass, this_class, ahk_id %this_id%
	    WinGetPos , WinX, WinY, Width, Height, ahk_id %this_id%
	    if(IsInArea(x,y,WinX,WinY,Width,Height)&&this_class!=IgnoredWindow)
	    {
	    	DetectHiddenWindows,on
	    	return this_class
	    }
	}
	DetectHiddenWindows,on
}

IsInArea(px,py,x,y,w,h)
{
	return (px>x&&py>y&&px<x+w&&py<y+h)
}
WinGetPlacement(hwnd, ByRef x="", ByRef y="", ByRef w="", ByRef h="", ByRef state="") 
{ 
    VarSetCapacity(wp, 44), NumPut(44, wp) 
    DllCall("GetWindowPlacement", "Ptr", hwnd, "Ptr", &wp) 
    x := NumGet(wp, 28, "int") 
    y := NumGet(wp, 32, "int") 
    w := NumGet(wp, 36, "int") - x 
    h := NumGet(wp, 40, "int") - y
	state := NumGet(wp, 8, "UInt")
	;outputdebug get x%x% y%y% w%w% h%h% state%state%
}
WinSetPlacement(hwnd, x="",y="",w="",h="",state="")
{
	WinGetPlacement(hwnd, x1, y1, w1, h1, state1)
	if(x = "")
		x := x1
	if(y = "")
		y := y1
	if(w = "")
		w := w1
	if(h = "")
		h := h1
	if(state = "")
		state := state1
	VarSetCapacity(wp, 44), NumPut(44, wp)
	if(state = 6)
		NumPut(7, wp, 8) ;SW_SHOWMINNOACTIVE
	else if(state = 1)
		NumPut(4, wp, 8) ;SW_SHOWNOACTIVATE
	else if(state = 3)
		NumPut(3, wp, 8) ;SW_SHOWMAXIMIZED and/or SW_MAXIMIZE
	else
		NumPut(state, wp, 8)
	NumPut(x, wp, 28, "Int")
    NumPut(y, wp, 32, "Int")
    NumPut(x+w, wp, 36, "Int")
    NumPut(y+h, wp, 40, "Int")
	DllCall("SetWindowPlacement", "Ptr", hwnd, "Ptr", &wp) 
}
ExpandEnvVars(path)
{
	VarSetCapacity(dest, 2000) 
	DllCall("ExpandEnvironmentStrings", "str", path, "str", dest, int, 1999, "Cdecl int") 
	return dest
}

IsDoubleClick()
{	
	return A_TimeSincePriorHotkey < DllCall("GetDoubleClickTime") && A_ThisHotkey=A_PriorHotkey
}

IsControlActive(controlclass)
{
	if(A_OSVersion="WIN_7")
		ControlGetFocus active, A
	else
		active:=XPGetFocussed()
	if(InStr(active, controlclass))
		return true
	return false
}

; This script retrieves the ahk_id (HWND) of the active window's focused control. 
; This script requires Windows 98+ or NT 4.0 SP3+. 
/*
typedef struct tagGUITHREADINFO {
  DWORD cbSize;
  DWORD flags;
  HWND  hwndActive;
  HWND  hwndFocus;
  HWND  hwndCapture;
  HWND  hwndMenuOwner;
  HWND  hwndMoveSize;
  HWND  hwndCaret;
  RECT  rcCaret;
} GUITHREADINFO, *PGUITHREADINFO;
*/
GetFocusedControl() 
{ 
   guiThreadInfoSize := 8 + 6 * A_PtrSize + 16
   VarSetCapacity(guiThreadInfo, guiThreadInfoSize, 0) 
   NumPut(GuiThreadInfoSize, GuiThreadInfo, 0)
   ; DllCall("RtlFillMemory" , "PTR", &guiThreadInfo, "UInt", 1 , "UChar", guiThreadInfoSize)   ; Below 0xFF, one call only is needed 
   If(DllCall("GetGUIThreadInfo" , "UInt", 0   ; Foreground thread 
         , "PTR", &guiThreadInfo) = 0) 
   { 
      ErrorLevel := A_LastError   ; Failure 
      Return 0 
   } 
   focusedHwnd := NumGet(guiThreadInfo,8+A_PtrSize, "Ptr") ; *(addr + 12) + (*(addr + 13) << 8) +  (*(addr + 14) << 16) + (*(addr + 15) << 24) 
   Return focusedHwnd 
} 

; Force kill program on Alt+F5 and on right click close button
CloseKill(hwnd)
{
	WinGet, pid, pid, ahk_id %hwnd%
	WinKill ahk_id %hwnd%
	if(WinExist("ahk_id " hwnd))
		Process, close, %pid%
}

RemoveLineFeedsAndSurroundWithDoubleQuotes(files)
{
	if(isobject(files))
	{
		result := Array()
		Loop % files.len()
			if !InStr(FileExist(files[A_Index]), "D")
				result.append("""" files[A_Index] """")
		return result
	}
	else
	{
		result:=""
		Loop, Parse, files, `n,`r  ; Rows are delimited by linefeeds ('r`n). 
		{ 
			if !InStr(FileExist(A_LoopField), "D")
				result=%result% "%A_LoopField%"
		} 
		return result
	}
}

/*
To be parsed:

file a
file b

"file a"
"file b"

"file a" "file b"

"file a"|"file b"

file a|file b

*/
ToArray(SourceFiles, ByRef Separator = "`n", ByRef wasQuoted = 0)
{
	files := Array()
	pos := 1
	wasQuoted := 0
	Loop
	{
		if(pos > strlen(SourceFiles))
			break
			
		char := SubStr(SourceFiles, pos, 1)
		if(char = """" || wasQuoted) ;Quoted paths
		{
			file := SubStr(SourceFiles, InStr(SourceFiles, """", 0, pos) + 1, InStr(SourceFiles, """", 0, pos + 1) - pos - 1)
			if(!wasQuoted)
			{
				wasQuoted := 1
				Separator := SubStr(SourceFiles, InStr(SourceFiles, """", 0, pos + 1) + 1, InStr(SourceFiles, """", 0, InStr(SourceFiles, """", 0, pos + 1) + 1) - InStr(SourceFiles, """", 0, pos + 1) - 1)
			}
			if(file)
			{
				files.append(file)
				pos += strlen(file) + 3
				continue
			}
			else
				Msgbox Invalid source format %SourceFiles%
		}
		else
		{
			file := SubStr(SourceFiles, pos, max(InStr(SourceFiles, Separator, 0, pos + 1) - pos, 0)) ; separator
			if(!file)
				file := SubStr(SourceFiles, pos) ;no quotes or separators, single file
			if(file)
			{
				files.append(file)
				pos += strlen(file) + strlen(Separator)
				continue
			}
			else
				Msgbox Invalid source format
		}
		pos++ ;Shouldn't happen
	}
	return files
}

ArrayToList(array, separator = "`n", quote = 0)
{
	Loop % array.len()
		result .= (A_Index != 1 ? separator : "") (quote ? """" : "") array[A_Index] (quote ? """" : "")
	return result
}

;Compares two (already separated) version numbers. Returns 1 if 1st is greater, 0 if equal, -1 if second is greater
CompareVersion(major1,major2,minor1,minor2,bugfix1,bugfix2)
{
	if(major1 > major2)
		return 1
	else if(major1 = major2 && minor1 > minor2)
		return 1
	else if(major1 = major2 && minor1 = minor2 && bugfix1 > bugfix2)
		return 1
	else if(major1 = major2 && minor1 = minor2 && bugfix1 = bugfix2)
		return 0
	else
		return -1
}

IsNumeric(x)
{
   If x is number 
      Return 1 
   Return 0 
}

StringUnescape(String)
{
	return StringReplace(StringReplace(StringReplace(String, "\\", Chr(1), 1), "\""", """", 1), Chr(1), "\", 1)
}
StringEscape(String)
{
	return StringReplace(StringReplace(String, "\", "\\", 1), """", "\""", 1)
}
uriDecode(str) { 
   Loop 
      If RegExMatch(str, "i)(?<=%)[\da-f]{1,2}", hex) 
         StringReplace, str, str, `%%hex%, % Chr("0x" . hex), All 
      Else Break 
   Return, str 
} 
uriEncode(str, full=0) { 
   f = %A_FormatInteger% 
   SetFormat, Integer, Hex 
   If RegExMatch(str, "^\w+:/{0,2}", pr) 
      StringTrimLeft, str, str, StrLen(pr) 
   StringReplace, str, str, `%, `%25, All 
   Loop 
      If RegExMatch(str, full ? "i)[^a-zA-Z0-9_\.~%/:]" : "i)[^a-zA-Z0-9_\.~%/:?&=]", char) 
         StringReplace, str, str, %char%, % "%" . SubStr(Asc(char),3), All 
      Else Break 
   SetFormat, Integer, %f% 
   Return, pr . str 
}

Unicode2Ansi(ByRef wString, ByRef sString, CP = 0) 
{ 
	nSize := DllCall("WideCharToMultiByte" , "Uint", CP, "Uint", 0 , "UintP", wString , "int",  -1 , "Uint", 0 , "int",  0 , "Uint", 0 , "Uint", 0) 
	VarSetCapacity(sString, nSize) 
	DllCall("WideCharToMultiByte" , "Uint", CP , "Uint", 0 , "UintP", wString , "int",  -1 , "str",  sString , "int",  nSize , "Uint", 0 , "Uint", 0) 
}

Ansi2Unicode(ByRef sString, ByRef wString, CP = 0) 
{ 
	nSize := DllCall("MultiByteToWideChar" , "Uint", CP , "Uint", 0 , "UintP", sString , "int",  -1 , "Uint", 0 , "int",  0) 
	VarSetCapacity(wString, nSize * 2) 
	DllCall("MultiByteToWideChar" , "Uint", CP , "Uint", 0 , "UintP",  sString , "int",  -1 , "UintP", wString , "int",  nSize) 
}

FuzzySearch(string1, string2)
{
	lenl := StrLen(string1)
	lens := StrLen(string2)
	if(lenl > lens)
	{
		shorter := string2
		longer := string1
	}
	else if(lens > lenl)
	{
		shorter := string1
		longer := string2
		lens := lenl
		lenl := StrLen(string2)
	}
	else
		return StringDifference(string1, string2)
	min := 1
	Loop % lenl - lens + 1
	{
		distance := StringDifference(shorter, SubStr(longer, A_Index, lens))
		if(distance < min)
			min := distance
	}
	return min
}
;By Toralf:
;basic idea for SIFT3 code by Siderite Zackwehdex 
;http://siderite.blogspot.com/2007/04/super-fast-and-accurate-string-distance.html 
;took idea to normalize it to longest string from Brad Wood 
;http://www.bradwood.com/string_compare/ 
;Own work: 
; - when character only differ in case, LSC is a 0.8 match for this character 
; - modified code for speed, might lead to different results compared to original code 
; - optimized for speed (30% faster then original SIFT3 and 13.3 times faster than basic Levenshtein distance) 
;http://www.autohotkey.com/forum/topic59407.html 
StringDifference(string1, string2, maxOffset=3) {    ;returns a float: between "0.0 = identical" and "1.0 = nothing in common" 
  If (string1 = string2) 
    Return (string1 == string2 ? 0/1 : 0.2/StrLen(string1))    ;either identical or (assumption:) "only one" char with different case 
  If (string1 = "" OR string2 = "") 
    Return (string1 = string2 ? 0/1 : 1/1) 
  StringSplit, n, string1 
  StringSplit, m, string2 
  ni := 1, mi := 1, lcs := 0 
  While((ni <= n0) AND (mi <= m0)) { 
    If (n%ni% == m%mi%) 
      EnvAdd, lcs, 1 
    Else If (n%ni% = m%mi%) 
      EnvAdd, lcs, 0.8 
    Else{ 
      Loop, %maxOffset%  { 
        oi := ni + A_Index, pi := mi + A_Index 
        If ((n%oi% = m%mi%) AND (oi <= n0)){ 
            ni := oi, lcs += (n%oi% == m%mi% ? 1 : 0.8) 
            Break 
        } 
        If ((n%ni% = m%pi%) AND (pi <= m0)){ 
            mi := pi, lcs += (n%ni% == m%pi% ? 1 : 0.8) 
            Break 
        } 
      } 
    } 
    EnvAdd, ni, 1 
    EnvAdd, mi, 1 
  } 
  Return ((n0 + m0)/2 - lcs) / (n0 > m0 ? n0 : m0) 
}

IsURL(string)
{
	return RegexMatch(strTrim(string, " "), "(?:(?:ht|f)tps?://|www\.).+\..+") > 0
}
CouldBeURL(string)
{
	return RegexMatch(strTrim(string, " "), "(?:(?:ht|f)tps?://|www\.)?.+\..+") > 0
}
WriteAccess( F ) { 
  Return ((h:=DllCall("_lopen", AStr, F, Int, 1, "Ptr")) > 0 ? 1 : 0) (DllCall("_lclose","Ptr",h)+NULL) 
}
FileMD5( sFile="", cSz=4 ) { ; www.autohotkey.com/forum/viewtopic.php?p=275910#275910 
 cSz  := (cSz<0||cSz>8) ? 2**22 : 2**(18+cSz), VarSetCapacity( Buffer,cSz,0 ) 
 hFil := DllCall( "CreateFile", Str,sFile,UInt,0x80000000, Int,1,Int,0,Int,3,Int,0,Int,0, "Ptr") 
 IfLess,hFil,1, Return,hFil 
 DllCall( "GetFileSizeEx", Ptr,hFil, Ptr, &Buffer ),   fSz := NumGet( Buffer,0,"Int64" ) 
 VarSetCapacity( MD5_CTX,104,0 ),    DllCall( "advapi32\MD5Init", PTR, &MD5_CTX ) 
 Loop % ( fSz//cSz+!!Mod(fSz,cSz) ) 
   DllCall( "ReadFile", PTR,hFil, PTR, &Buffer, UInt,cSz, UIntP,bytesRead, UInt,0 ) 
 , DllCall( "advapi32\MD5Update", PTR, &MD5_CTX, PTR, &Buffer, UInt,bytesRead ) 
 DllCall( "advapi32\MD5Final", PTR, &MD5_CTX ), DllCall( "CloseHandle", PTR,hFil ) 
 Loop % StrLen( Hex:="123456789ABCDEF0" )
  N := NumGet( MD5_CTX,87+A_Index,"Char"), MD5 .= SubStr(Hex,N>>4,1) . SubStr(Hex,N&15,1) 
 Return MD5
}
FormatFileSize(Bytes, Decimals=2, Prefixes="B,KB,MB,GB,TB,PB,EB,ZB,YB")
{
	StringSplit, Prefix, Prefixes, `,
	Loop, Parse, Prefixes, `,
		if(Bytes < e := 1024**A_Index)
			return % Round(Bytes/(e/1024), decimals) . " " . Prefix%A_Index%
}
ExploreObj(Obj, NewRow="`n", Equal="  =  ", Indent="`t", Depth=12, CurIndent="") { 
    for k,v in Obj 
        ToReturn .= CurIndent . k . (IsObject(v) && depth>1 ? NewRow . ExploreObj(v, NewRow, Equal, Indent, Depth-1, CurIndent . Indent) : Equal . v) . NewRow 
    return RTrim(ToReturn, NewRow) 
}

GetFullPathName(SPath)
{ 
	VarSetCapacity(lPath,A_IsUnicode ? 520 : 260,0), DllCall("GetLongPathName", Str,SPath, Str,lPath, UInt,260 ) 
	Return lPath 
}

;This function calls a of an event on every key in it
objDeepPerform(obj, function, Event)
{
	if(!IsFunc(function))
		return
	if(obj.HasKey("base"))
		objDeepPerform(obj.base, function, Event)
	enum := obj._newenum() 
	while enum[key, value] 
	{
		if(IsObject(value))
			objDeepPerform(value, function, Event)
		else
			obj[key] := %function%(Event, value)
	}
}

; Write text at cursor position, overwriting selected text
WriteText(Text) 
{
	global MuteClipboardList
	MuteClipboardList := true
	ClipboardBackup := ClipboardAll
	Clipboard := Text
	Send ^v
	Sleep 100
	Clipboard := ClipboardBackup
	MuteClipboardList := false
	return
}

AddUninstallInformation()
{
	global MajorVersion, MinorVersion, BugfixVersion, PatchVersion, IsPortable
	if(IsPortable)
		return
	RegWrite, REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7plus, DisplayName, 7plus V.%MajorVersion%.%MinorVersion%.%BugfixVersion%.%PatchVersion%
	RegWrite, REG_DWORD, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7plus, NoModify, 1
	RegWrite, REG_DWORD, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7plus, NoRepair, 1
	RegWrite, REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7plus, UninstallString, 1, "%A_ScriptDir%\Uninstall.exe"
}

RemoveUninstallInformation()
{
	if(IsPortable)
		return
	RegDelete, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7plus
}
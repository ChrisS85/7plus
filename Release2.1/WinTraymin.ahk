;----------------------------------------------------------
;----------------------------------------------------------
; WinTraymin.ahk
; by Sean
;----------------------------------------------------------
;----------------------------------------------------------
; Adding a trayminned trayicon of hWnd:	WinTraymin(hWnd,0), where 0 can be omitted.
; Removing all trayminned trayicons:	WinTraymin(0,-1).
; Other values than 0 & -1 are reserved for internal use.
;----------------------------------------------------------

;#NoTrayIcon
TrayminOpen:
SetWinDelay, 0
SetFormat, Integer, D
CoordMode, Mouse, Screen
DetectHiddenWindows On
Menu, wtmMenu, Add, Restore, wtmRestore 
Menu, wtmMenu, Add, Exit, wtmExit 
Menu, wtmMenu, Default, Restore
/*
hAHK:=WinExist("ahk_class AutoHotkey ahk_pid " . DllCall("GetCurrentProcessId"))
ShellHook:=DllCall("RegisterWindowMessage","str","SHELLHOOK")
DllCall("RegisterShellHookWindow","Uint",hAHK)
*/
;OnExit, TrayminClose
Return
TrayminClose:
;DllCall("DeregisterShellHookWindow","Uint",hAHK)
WinTraymin(0,-1)
return
;OnExit
;ExitApp
/*
RButton Up::
If	h:=WM_NCHITTEST()
	WinTraymin(h)
Else	Click, % SubStr(A_ThisHotkey,1,1)	; for hotkey: LButton/MButton/RButton
Return
*/
wtmRestore: 
WinTraymin(wtmwParam,3)
Return 

wtmExit: 
hwnd:=hWnd_%wtmwParam% 
WinClose, ahk_id %hwnd% 
WinTraymin(wtmwParam,3)
Return

/*
WM_SHELLHOOKMESSAGE(wParam, lParam, nMsg)
{
	Critical
	If	nMsg=1028
	{
		If	wParam=1028
			Return
		Else If	(lParam=0x201||lParam=0x205||lParam=0x207)
			WinTraymin(wParam,3)
	}
	Else If	(wParam=1||wParam=2)
		WinTraymin(lParam,wParam)
	Return	0
}
*/
/*
typedef struct _NOTIFYICONDATA {
  DWORD cbSize;
  HWND  hWnd;
  UINT  uID;
  UINT  uFlags;
  UINT  uCallbackMessage;
  HICON hIcon;
  TCHAR szTip[64];
  DWORD dwState;
  DWORD dwStateMask;
  TCHAR szInfo[256];
  union {
    UINT uTimeout;
    UINT uVersion;
  } ;
  TCHAR szInfoTitle[64];
  DWORD dwInfoFlags;
  GUID  guidItem;
  HICON hBalloonIcon;
} NOTIFYICONDATA, *PNOTIFYICONDATA;    <--ni

typedef struct {
    unsigned long  Data1;
    unsigned short Data2;
    unsigned short Data3;
    byte           Data4[ 8 ];
} GUID;

typedef struct _SHFILEINFO {
  HICON hIcon;
  int   iIcon;
  DWORD dwAttributes;
  TCHAR szDisplayName[MAX_PATH];
  TCHAR szTypeName[80];
} SHFILEINFO;    <-- fi
*/
WinTraymin(hWnd = "", nFlags = "")
{
	Local	h, ni, fi, uid, pid, hProc, sClass, title
	Static	nMsg, nIcons:=0
	DetectHiddenWindows, On
	nMsg ? "" : OnMessage(nMsg:=1028,"ShellMessage")
	NumPut(hAHK,NumPut(VarSetCapacity(ni,A_PtrSize = 8 ? 456 : 444,0),ni)) ;Write cbSize and hWnd
	If Not	nFlags
	{
		If Not	((hWnd+=0)||hWnd:=GetForegroundWindow())||((h:=GetWindow(hWnd,4))&&IsWindowVisible(h)&&!hWnd:=h)||!(sClass := WinGetClass("ahk_id " hWnd))||sClass=="Shell_TrayWnd"||sClass=="Progman"
			Return
		OnMessage(MsgNum,"")
		WinMinimize,	ahk_id %hWnd%
		WinHide,	ahk_id %hWnd%
		Sleep,	100
		OnMessage(MsgNum,"ShellMessage")
		uID:=uID_%hWnd%
		if(!uID)
			uID_%hWnd%:=uID:=++nIcons=nMsg ? ++nIcons : nIcons
		if(!hIcon_%uID% )
		{
			VarSetCapacity(fi,A_PtrSize + 8 + (260+80) * (A_IsUnicode + 1),0)
			WinGet, pid, pid, ahk_id %hWnd%
			StrPut(GetModuleFileNameEx(pid),&fi + 8 + A_PtrSize, 260, A_IsUnicode ? "UTF-16" : "")
			; DllCall("psapi\GetModuleFileNameEx","Ptr",hProc:=DllCall("kernel32\OpenProcess","Uint",0x410,"int",0,"Uint",pid, "Ptr"),"Ptr",0,"Uint",&fi+8+A_PtrSize,"Uint",260)
			; DllCall("kernel32\CloseHandle","Ptr",hProc)
			return := DllCall("shell32\SHGetFileInfo","Uint",&fi + 8 + A_PtrSize,"Uint",0,"Ptr",&fi,"Uint",VarSetCapacity(fi),"Uint",0x101)
			msgbox return %return%
			hIcon_%uID%:=NumGet(fi)
			WinGetTitle, title, ahk_id %hWnd%
			; outputdebug file %file%
			; outputdebug % "icon " hIcon_%uID%
			addr := NumPut(uID, ni, 8)
			addr  :=NumPut(1|2|4, addr)
			addr := NumPut(nMsg, addr)
			addr := NumPut(hIcon_%uID%, addr)
			addr := StrPut(title, addr,  64, A_IsUnicode ? "UTF-16" : "")
			; DllCall("GetWindowText","Ptr",hWnd,"Uint",NumPut(hIcon_%uID%,NumPut(nMsg,NumPut(1|2|4,NumPut(uID,ni,8)))),"int",64)
		}
		Return	hWnd_%uID%:=DllCall("shell32\Shell_NotifyIcon","Ptr",hWnd_%uID% ? 1 : 0,"Ptr",&ni) ? hWnd : DllCall("ShowWindow","Ptr",hWnd,"int",5, "Ptr")*0
	}
	Else If	nFlags > 0
	{
		If	(nFlags=3&&uID:=hWnd)
			If	WinExist("ahk_id " . hWnd:=hWnd_%uID%)
			{
				WinShow,	ahk_id %hWnd%
				WinRestore,	ahk_id %hWnd%
			}
			Else	nFlags:=2
		Else	uID:=uID_%hWnd%s
		Return	uID ? (hWnd_%uID% ? (DllCall("shell32\Shell_NotifyIcon","Uint",2,"Ptr",NumPut(uID,ni,4 + A_PtrSize)-8 - A_PtrSize),hWnd_%uID%:="") : "",nFlags==2&&hIcon_%uID% ? (DllCall("DestroyIcon","Ptr",hIcon_%uID%),hIcon_%uID%:="") : "") : ""
	}
	Else
		Loop, % nIcons
			hWnd_%A_Index% ? (DllCall("shell32\Shell_NotifyIcon","Uint",2,"Ptr",NumPut(A_Index,ni,4 + A_PtrSize)-8 - A_PtrSize),DllCall("ShowWindow","Ptr",hWnd_%A_Index%,"int",5),hWnd_%A_Index%:="") : "",hIcon_%A_Index% ? (DllCall("DestroyIcon","Ptr",hIcon_%A_Index%),hIcon_%A_Index%:="") : ""
}

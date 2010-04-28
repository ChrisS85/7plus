;Call this to show settings dialog
SettingsHandler:
ShowSettings()
return
CreateHotkeys()
{
	global
	local yIt,x1,x2,x
	Gui, Add, Tab2, x156 y14 w410 h350 vExplorerHotkeys, 
	AddTab(1, "","SysTabControl321") 
	yIt:=yBase
	
	x1:=xHelp+10
	x2:=xBase+280
	x:=xBase+247
	y:=yIt+TextBoxCheckBoxOffset
	Gui, Add, CheckBox, x%x1% y%y% gEditor, F3: Open selected files in text/image editor
	Gui, Add, Text, y%y% x%xhelp% cBlue ghOpenEditor vURL_OpenEditor, ?
	y:=yIt+TextBoxTextOffset
	Gui, Add, Text, x%x% y%y%, Editor:
	y:=yIt
	Gui, Add, Edit, x%x2% y%y% w%wTBMedium% vTextEditor R1,%TextEditor% 
	x:=x2+wTBMedium+10
	y:=yIt+TextBoxButtonOffset
	Gui, Add, Button, x%x% y%y% w%wButton% gTextBrowse, ...
	yIt+=textboxstep
	x:=xBase+215
	y:=yIt+TextBoxTextOffset
	Gui, Add, Text, x%x% y%y%, Image editor:
	y:=yIt
	Gui, Add, Edit, x%x2% y%y% w%wTBMedium% vImageEditor R1,%ImageEditor% 
	x:=x2+wTBMedium+10
	y:=yIt+TextBoxButtonOffset
	Gui, Add, Button, x%x% y%y% w%wButton% gImageBrowse, ...
	yIt+=textboxstep
	
	x2:=x2-60
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghCreateNew vURL_CreateNew, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vHKCreateNewFile, F7: Create new file
	yIt+=checkboxstep
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghCreateNew vURL_CreateNew1, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vHKCreateNewFolder, F8: Create new folder
	yIt+=checkboxstep	
	
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghCopyFilenames vURL_CopyFilenames, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vHKCopyFilenames, ALT + C: Copy Filenames	
	yIt+=checkboxstep	
	
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghCopyFilenames vURL_CopyFilenames1, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vHKCopyPaths, CTRL + ALT + C: Copy paths + filenames
	yIt+=checkboxstep	
	
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghNavigation vURL_Navigation, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vHKProperBackspace, Backspace (Vista/7): Go upwards
	if(!Vista7)
		GuiControl, disable, HKProperBackspace
	x:=x2+80
	yIt+=checkboxstep	
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghNavigation vURL_Navigation1, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vHKMouseGestures, Hold right mouse and click left: Go back, Hold left mouse and click right: Go forward
	yIt+=checkboxstep	
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghNavigation vURL_Navigation2, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vHKDoubleClickUpwards, Double click on empty space in filelist: Go upwards
	yIt+=checkboxstep	
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghAppendClipboard vURL_AppendClipboard, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vHKAppendClipboard, Shift + X / Shift + C: Append files to clipboard instead of replacing (cut/copy)
	yIt+=checkboxstep	
	Gui, Add, Checkbox, x%x1% y%yIt% vHKInvertSelection, CTRL + I: Invert selection
	yIt+=checkboxstep	
	Gui, Add, Checkbox, x%x1% y%yIt% vHKOpenInNewFolder, Middle Mouse Button: Open in new window
	yIt+=checkboxstep	
	Gui, Add, Checkbox, x%x1% y%yIt% vHKFlattenDirectory, SHIFT + Enter: Show selected directories in flat view (Vista/7 only)
}
CreateBehavior()
{
	global
	local yIt,x1,x,y
	yIt:=yBase
	x1:=xHelp+10
	x2:=xBase+280
	
	Gui, Add, Tab2, x156 y14 w410 h350 vExplorerBehavior, 
	AddTab(0, "","SysTabControl322")

	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghSelectFirstFile vURL_SelectFirstFile, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vHKSelectFirstFile, Explorer automatically selects the first file when you enter a directory
	yIt+=checkboxstep	
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghSelectFirstFile vURL_SelectFirstFile1, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vHKImproveEnter, Files which are only focussed but not selected can be executed by pressing enter
	yIt+=checkboxstep		
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghScrollUnderMouse vURL_ScrollUnderMouse, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vScrollUnderMouse, Scroll explorer scrollbars with mouse over them
	yIt+=checkboxstep
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghShowSpaceAndSize vURL_ShowSpaceAndSize, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vHKShowSpaceAndSize, Show free space and size of selected files in status bar like in XP (7 only)
	if(A_OSVersion!="WIN_7")
		GuiControl, disable, HKShowSpaceAndSize
	yIt+=checkboxstep	
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghApplyOperation vURL_ApplyOperation, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vHKAutoCheck, Automatically check "Apply to all further operations" checkboxes in file operations (Vista/7 only)
	if(!Vista7)
		GuiControl, disable, HKAutoCheck
	yIt+=checkboxstep*2
		
	Gui, Add, Text, x%x1% y%yIt%, Text and images from clipboard can be pasted as file in explorer with these settings
	yIt+=checkboxstep
	
	y:=yIt+TextBoxCheckBoxOffset
	Gui, Add, CheckBox, x%x1% y%y% gtxt, Paste text as file
	Gui, Add, Text, y%y% x%xhelp% cBlue ghPasteAsFile vURL_PasteAsFile, ?
	
	x:=xBase+232
	Gui, Add, Text, x%x% y%y%, Filename:
	y:=yIt
	Gui, Add, Edit, x%x2% y%y% w%wTBMedium% vTxtName R1,%TxtName%
	yIt+=textboxstep
	
	y:=yIt+TextBoxCheckBoxOffset
	Gui, Add, CheckBox, x%x1% y%y% gimg, Paste image as file
	Gui, Add, Text, y%y% x%xhelp% cBlue ghPasteAsFile vURL_PasteAsFile1, ?
	y:=yIt+TextBoxTextOffset
	Gui, Add, Text, x%x% y%y%, Filename:
	y:=yIt
	Gui, Add, Edit, x%x2% y%y% w%wTBMedium% vImgName R1, %ImgName%	
	yIt+=textboxstep	
	
}
CreateFastFolders()
{
	global
	local yIt,x1,x,y
	yIt:=yBase
	xHelp:=xBase
	x1:=xHelp+10
	Gui, Add, Tab2, x156 y14 w410 h350 vFastFolders
	AddTab(0, "","SysTabControl323")
	
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghFastFolders1 vURL_FastFolders1, ?		
	Gui, Add, Checkbox, x%x1% y%yIt% gFastFolders,Use Fast Folders
	yIt+=checkboxstep	
	x:=x1+xCheckboxTextOffset
	xhelp+=xCheckboxTextOffset
	y:=yIt+yCheckboxTextOffset
	Gui, Add, Text, x%x% y%y% R2, In all kinds of file views you can store a path in one of ten slots by pressing CTRL`nand a numpad number key, and restore it by pressing the numpad number key again
	yIt+=checkboxstep*1.5
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghFastFolders1 vURL_FastFolders11, ?
	Gui, Add, Checkbox, x%x% y%yIt% vHKFolderBand, Integrate Fast Folders into explorer folder band bar (Vista/7 only)		
	if(!Vista7)
		GuiControl, disable, HKFolderBand
	yIt+=checkboxstep
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghFastFolders2 vURL_FastFolders2, ?
	Gui, Add, Checkbox, x%x% y%yIt% vHKCleanFolderBand, Remove windows folder band buttons (Vista/7 only)
	yIt+=checkboxstep
	x+=xCheckboxTextOffset
	y:=yIt+yCheckboxTextOffset
	text:="If you use the folder band as a favorites bar like in browsers, it is recommended that you get rid`nof the buttons predefined by windows whereever possible (such as Slideshow, Add to Library,...)"
	Gui, Add, Text, x%x% y%y% R2, %text%
	if(!Vista7)
	{
		GuiControl, disable, HKCleanFolderBand
		GuiControl, disable, %text%
	}
	x-=xCheckboxTextOffset
	yIt+=checkboxstep*1.5
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghFastFolders2 vURL_FastFolders21, ?
	Gui, Add, Checkbox, x%x% y%yIt% vHKPlacesBar, Integrate Fast Folders into open/save dialog places bar (First 5 Entries)
	yIt+=checkboxstep
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghFastFolders2 vURL_FastFolders22, ?
	Gui, Add, Checkbox, x%x% y%yIt% vHKFFMenu, Middle mouse button: Show Fast Folders move/copy menu
	yIt+=checkboxstep
	y:=yIt+yCheckboxTextOffset
	x+=xCheckboxTextOffset
	Gui, Add, Text, x%x% y%y% R3, When clicking with middle mouse button in a supported file view, a menu`nwith the stored Fast Folders will show up. Clicking an entry will move all`nselected files into that directory, holding CTRL while clicking will copy the files.
}
CreateWindowHandling1()
{
	global
	local yIt,x1,x,y
	xHelp:=xBase
	x1:=xHelp+10
	Gui, Add, Tab2, x156 y14 w410 h350 vWindowHandling1, 
	AddTab(0, "","SysTabControl324")
	yIt:=yBase

	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghTaskbar vURL_Taskbar3, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vHKTitleClose, Middle click on title bar: Close program
	yIt+=checkboxstep	
	
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghWindow vURL_Window, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vHKToggleAlwaysOnTop, Right click on title bar: Toggle "Always on top"
	yIt+=checkboxstep			
	
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghWindow vURL_Window1, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vHKKillWindows, Alt+F5/Right click on close button: Force-close active window (kill process)
	yIt+=checkboxstep		
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghSlideWindow vURL_SlideWindow, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vHKSlideWindows gSlideWindow, WIN + SHIFT + Arrow keys: Slide Window function
	yIt+=checkboxstep	
	y:=yIt+yCheckboxTextOffset
	x:=x1+xCheckboxTextOffset
	Gui, Add, Text, x%x% y%y% R4, A Slide Window is moved off screen, it will not be shown until you activate it through task bar /`nALT + TAB or move the mouse to the border where it was hidden. It will then slide into the screen,`nand slide out again when the mouse leaves the window or when another window gets activated.`nDeactivate this mode by moving the window or pressing WIN+SHIFT+Arrow key in another direction.
	yIt+=checkboxstep*2.5
	Gui, Add, Checkbox, x%x% y%yIt% vSlideWinHide, Hide Slide Windows in taskbar and from ALT + TAB
	yIt+=checkboxstep
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghCapslock vURL_Capslock, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vHKFlashWindow, Capslock: Activate flashing window (blinking on taskbar, e.g. instant messengers, ...)
	yIt+=checkboxstep
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghCapslock vURL_Capslock1, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vHKToggleWindows, Capslock: Switch between current and previous window
	yIt+=checkboxstep
	Gui, Add, Checkbox, x%x1% y%yIt% vHKAltDrag, ALT+Left Mouse Drag: Move windows
	yIt+=checkboxstep
	Gui, Add, Checkbox, x%x1% y%yIt% vHKAltMinMax, ALT + Mouse wheel: Minimize/Maximize/Restore window under mouse
	yIt+=checkboxstep
	Gui, Add, Checkbox, x%x1% y%yIt% vHKTrayMin, Right click minimize button or WIN + SHIFT + Arrow key in taskbar direction: Minimize to tray
	yIt+=checkboxstep
}
CreateWindowHandling2()
{
	global
	local yIt,x1,x,y
	xHelp:=xBase
	x1:=xHelp+10
	yIt:=yBase
	y:=yIt+TextBoxCheckBoxOffset
	Gui, Add, Tab2, x156 y14 w410 h350 vWindowHandling2, 
	AddTab(0, "","SysTabControl325")
	y:=yIt+TextBoxCheckBoxOffset
	Gui, Add, Text, y%y% x%xhelp% cBlue ghTaskbar vURL_Taskbar, ?
	Gui, Add, Checkbox, x%x1% y%y% gTaskbarLaunch, Double click on empty taskbar: Run
	x:=xBase+258
	Gui, Add, Edit, 		x%x% y%yIt% w%wTBLarge% R1 vTaskbarLaunchPath, %TaskbarLaunchPath%
	y:=yIt+TextBoxButtonOffset
	x:=x+wTBLarge+10
	Gui, Add, Button, x%x% y%y% w%wButton% gTaskbarLaunchBrowse, ...
	yIt+=textboxstep
	
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghTaskbar vURL_Taskbar1, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vHKMiddleClose, Middle click on taskbuttons: close task
	yIt+=checkboxstep	
	
	x:=x1+xCheckboxTextOffset
	y:=yIt+yCheckBoxTextOffset
	Gui, Add, Text, x%x% y%y%, Middle click on empty taskbar: Taskbar properties
	yIt+=checkboxstep	
	
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghTaskbar vURL_Taskbar2, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vHKActivateBehavior, Left click on task group button (7 only): cycle through windows		
	if(A_OsVersion!="WIN_7")
		GuiControl, disable, HKActivateBehavior
	yIt+=checkboxstep	
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghWindow vURL_Window2, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vHKToggleWallpaper, Middle mouse click on desktop: Toggle wallpaper (7 only)
	if(A_OsVersion!="WIN_7")
		GuiControl, disable, HKToggleWallpaper
	yIt+=checkboxstep	
	
	y:=yIt+TextBoxCheckBoxOffset
	Gui, Add, Text, y%y% x%xhelp% cBlue ghWindow vURL_Window3, ?
	Gui, Add, Checkbox, x%x1% y%y% gFlip3D, Mouse in upper left corner: Toggle Aero Flip 3D (Vista/7 only)
	x:=xBase+362
	y:=yIt+TextBoxTextOffset
	Gui, Add, Text, x%x% y%y%, Seconds in corner:
	x:=xBase+248+wTBLarge
	Gui, Add, Edit, 		x%x% y%yIt% w%wTBShort% R1 vAeroFlipTime, %AeroFlipTime%		
	if(!Vista7)
	{
		GuiControl, disable, AeroFlipTime
		GuiControl, disable, Mouse in upper left corner: Toggle Aero Flip 3D (Vista/7 only)
		GuiControl, disable, Seconds in corner:
	}
	y:=yIt+TextBoxButtonOffset
	yIt+=textboxstep
}
CreateFTP()
{
	global
	local yIt,x1,x,y
	yIt:=yBase
	xHelp:=xBase
	x1:=xHelp+10
	Gui, Add, Tab2, x156 y14 w410 h350 vFTP, 
	AddTab(0, "","SysTabControl326")
	Gui, Add, Text, x%x1% y%yIt% R4, You can upload selected files from explorer to an FTP server by`npressing CTRL + U. You can also take screenshots (ALT + Insert = fullscreen`,`nWIN + Insert = active window) and directly upload them. WIN + Delete will upload`nimage or text data from clipboard. URL(s) will be copied to the clipboard.
	yIt:=100
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghFTP vURL_FTP, ?
	Gui, Add, CheckBox, x%x1% y%yIt% gFTP, Use FTP
	yIt+=checkboxstep	
	x1:=xHelp+xCheckBoxTextOffset+10
	x2:=xHelp+122
	y:=yIt+TextBoxTextOffset
	Gui, Add, Text, x%x1% y%y%, Hostname
	Gui, Add, Edit, x%x2% y%yIt% w%wTBMedium% R1 vFTP_Host, %FTP_Host%
	yIt+=TextBoxStep	
	
	y:=yIt+TextBoxTextOffset
	Gui, Add, Text, x%x1% y%y%, Port
	Gui, Add, Edit, x%x2% y%yIt% w%wTBShort% R1 vFTP_PORT Number, %FTP_PORT%
	yIt+=TextBoxStep
	
	y:=yIt+TextBoxTextOffset
	Gui, Add, Text, x%x1% y%y%, Username
	Gui, Add, Edit, x%x2% y%yIt% w%wTBMedium% R1 vFTP_Username ,%FTP_Username% 
	yIt+=TextBoxStep	
	
	y:=yIt+TextBoxTextOffset
	Gui, Add, Text, x%x1% y%y%, Password
	Gui, Add, Edit, x%x2% y%yIt% w%wTBMedium% R1 vFTP_Password Password, %FTP_Password%
	yIt+=TextBoxStep	
	
	y:=yIt+TextBoxTextOffset
	Gui, Add, Text, x%x1% y%y%, Remote Folder
	Gui, Add, Edit, x%x2% y%yIt% w%wTBMedium% R1 vFTP_Path, %FTP_Path%
	yIt+=TextBoxStep
	
	Gui, Add, Text, x%x1% y%yIt%, URL under which the files can be accessed through HTTP
	yIt+=checkboxstep
	
	y:=yIt+TextBoxTextOffset
	Gui, Add, Text, x%x1% y%y%, URL
	Gui, Add, Edit, x%x2% y%yIt% w%wTBMedium% R1 vFTP_URL, %FTP_URL%
}
CreateMisc()
{
	global
	local yIt,x1
	Gui, Add, Tab2, x156 y14 w410 h350 vMisc, 
	AddTab(0, "","SysTabControl327")
	x1:=xBase+10
	xhelp:=xBase
	yIt:=yBase
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghImproveConsole vURL_ImproveConsole, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vHKImproveConsole, Open current folder in CMD by pressing WIN + C and enable CTRL + V and Alt + F4 in CMD
	yIt+=checkboxstep
	Gui, Add, Checkbox, x%x1% y%yIt% vHKPhotoViewer, Windows picture viewer: Rotate image with R and L
	yIt+=checkboxstep
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghJoyControl vURL_JoyControl, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vJoyControl, Use joystick/gamepad as remote control when not in fullscreen (optimized for XBOX360 gamepad)
	yIt+=checkboxstep
	Gui, Add, Text, y%yIt% x%xhelp% cBlue ghClipboardManager vURL_ClipboardManager, ?
	Gui, Add, Checkbox, x%x1% y%yIt% vClipboardManager, WIN + V: Clipboard manager (stores last 10 entries)
	
	
	yIt+=2*checkboxstep
	y:=yIt+TextBoxTextOffset
	x2:=x1+180
	Gui, Add, Text, x%x1% y%y% Number, Image compression quality:
	Gui, Add, Edit, x%x2% y%yIt% w%wTBShort% R1 vImageQuality ,%ImageQuality% 
	yIt+=TextBoxStep
	y:=yIt+TextBoxTextOffset
	Gui, Add, Text, x%x1% y%y%, Default image extension:
	Gui, Add, Edit, x%x2% y%yIt% w%wTBShort% R1 vImageExtension ,%ImageExtension% 
	yIt+=TextBoxStep
	y:=yIt+TextBoxTextOffset
	Gui, Add, Text, x%x1% y%y%, Fullscreen detection include list
	Gui, Add, Edit, x%x2% y%yIt% w%wTBHuge% R1 vFullscreenInclude ,%FullscreenInclude% 
	yIt+=TextBoxStep
	y:=yIt+TextBoxTextOffset
	Gui, Add, Text, x%x1% y%y%, Fullscreen detection exclude list
	Gui, Add, Edit, x%x2% y%yIt% w%wTBHuge% R1 vFullscreenExclude ,%FullscreenExclude% 
	yIt+=TextBoxStep
	
	yIt+=checkboxstep
	Gui, Add, Checkbox, x%x1% y%yIt% vAutorun, Autorun 7plus on windows startup
	yIt+=checkboxstep
	Gui, Add, Checkbox, x%x1% y%yIt% vHideTrayIcon, Hide Tray Icon (press WIN + H to show settings!)
	yIt+=checkboxstep
	Gui, Add, Checkbox, x%x1% y%yIt% vAutoUpdate, Automatically look for updates on startup
}
CreateAbout()
{
	global
	local yIt,x1,x2,x,y
	Gui, Add, Tab2, x156 y14 w410 h350 vAbout, 
	AddTab(0, "","SysTabControl328")
	yIt:=YBase
	x1:=XBase+10
	x2:=xBase+350
	if(A_IsCompiled)			
		Gui, Add, Picture, w128 h128 y%yIt% x%x2% Icon3 vLogo, %A_ScriptFullPath%
	else
		Gui, Add, Picture, w128 h128 y%yIt% x%x2% vLogo, %A_ScriptDir%\128.png
	
	gui, font, s20
	Gui, Add, Text, y%yIt% x%x1%, 7plus Version %CurrentVersion%
	gui, font
	yIt+=hText*3
	x2:=x1+100
	Gui, Add, Text, y%yIt% x%x1% , Project page:
	Gui, Add, Text, y%yIt% x%x2% cBlue gProjectpage vURL_Projectpage, http://code.google.com/p/7plus/
	yIt+=hText
	Gui, Add, Text, y%yIt% x%x1% , Report bugs:
	Gui, Add, Text, y%yIt% x%x2% cBlue gBugtracker vURL_Bugtracker, http://code.google.com/p/7plus/issues/list
	yIt+=hText
	Gui, Add, Text, y%yIt% x%x1% , Author:
	Gui, Add, Text, y%yIt% x%x2% , Christian Sander
	yIt+=hText
	Gui, Add, Text, y%yIt% x%x1% , E-Mail:
	Gui, Add, Text, y%yIt% x%x2% cBlue gMail vURL_Mail, fragman@gmail.com
	yIt+=hText*2
	Gui, Add, Text, y%yIt% x%x1%, To support the development of this project, please donate:
	yIt+=hText*1.5
	if(A_IsCompiled)			
		Gui, Add, Picture, y%yIt% x%x1% cBlue gDonate Icon4 vURL_Donate, %A_ScriptFullPath%
	else
		Gui, Add, Picture, y%yIt% x%x1% cBlue gDonate vURL_Donate, %A_ScriptDir%\Donate.png		
	yIt+=hText*2
	x2:=x1+200
	Gui, Add, Text, y%yIt% x%x1%, Proudly written in Autohotkey
	Gui, Add, Text, y%yIt% x%x2%, Updater uses
	x2+=66
	Gui, Add, Text, y%yIt% x%x2% vURL_7zip g7zip cBlue, 7-Zip
	x2+=24
	Gui, Add, Text, y%yIt% x%x2%, , which is licensed under the 
	x2+=136
	Gui, Add, Text, y%yIt% x%x2% vURL_LGPL gLGPL cBlue, LGPL
	yIt+=hText
	Gui, Add, Text, y%yIt% x%x1% cBlue gAhk vURL_AHK, www.autohotkey.com		
	yIt+=hText*2
	Gui, Add, Text, y%yIt% x%x1% , Licensed under  	
	x2:=x1+100
	Gui, Add, Text, y%yIt% x%x2% cBlue gGPL vURL_GPL, GNU General Public License v3
	yIt+=hText*2
	Gui, Add, Text, y%yIt% x%x1% , Credits for lots of code samples and help go out to:`nSean, HotKeyIt, majkinetor, Titan, Lexikos, TheGood, PhiLho, Temp01, Laszlo`nand the other guys and gals on #ahk and the forums.	
}
AddTab(IconNumber, TabName, TabControl) 
{  
   Gui 2: +LastFound
   VarSetCapacity(TCITEM, 100, 0)
	 NumPut(3, TCITEM ,0) ; Mask (3) comes from TCIF_TEXT(1) + TCIF_IMAGE(2). 
	 NumPut(&TabName, TCITEM ,12) ; pszText
	 NumPut(IconNumber - 1, TCITEM ,20) ; iImage: -1 to convert to zero-based. 
   SendMessage, 0x1307, 999, &TCITEM, %TabControl%  ; 0x1307 is TCM_INSERTITEM 
}
listbox: 
GuiControlGet,selected,,MyListBox
outputdebug listbox %selected%
Loop, Parse, TabList, | 
{
	StringReplace, stripped, A_LoopField, %A_Space% , , 1
  If (selected = A_LoopField) 
  {
  	outputdebug show %stripped%
     GuiControl, Show, %stripped%
     GuiControl, Text, GGroupBox, %A_LoopField% 
     test:=stripped

  } 
  else 
  {
		outputdebug hide %stripped% 
     GuiControl, Hide, %stripped%
  } 
}
GuiControl, MoveDraw, MyListBox
GuiControl, Movedraw, GGroupbox
GuiControl, Movedraw, %test% 
GuiControl, MoveDraw, BtnOK
GuiControl, MoveDraw, BtnCancel
GuiControl, MoveDraw, TutLabel
GuiControl, MoveDraw, Wait
return 
ShowSettings()
{
	global
	local x,y,yIt,x1,x2
	if(!SettingsActive)
	{			
		SettingsActive:=True
		;---------------------------------------------------------------------------------------------------------------
		; Create GUI
		;---------------------------------------------------------------------------------------------------------------
		Gui, 2:Default
		ybase:=36
		checkboxstep:=20
		textboxstep:=30
		TextBoxCheckBoxOffset:=4
		TextBoxTextOffset:=4
		TextBoxButtonOffset:=-1
		xCheckBoxTextOffset:=17
		yCheckBoxTextOffset:=-6
		hText:=16
		yIt:=yBase
		y:=yIt
		xBase:=170
		xHelp:=xBase
		x1:=xHelp+10
		x2:=xBase+280
		wTBShort:=50
		wTBMedium:=170
		wTBLarge:=210
		wTBHuge:=300
		wButton:=30
		hCheckbox:=16 
		TabList = Explorer Hotkeys|Explorer Behavior|Fast Folders|Window Handling 1|Window Handling 2|FTP|Misc|About 
		Gui, Add, ListBox, x16 y20 w120 h350 gListbox vMyListBox, %TabList%
		Gui, Add, GroupBox, x156 y14 w530 h350 vGGroupBox , Explorer Hotkeys  
		/*
		Gui, Add, Treeview, x0 y0 w120 h540 vTree gTree -Lines -Buttons -HScroll
		
		TV_Explorer:=TV_Add("Explorer","","Expand")
		TV_ExplorerHotkeys:=TV_Add("Hotkeys",TV_Explorer,"Select")
		TV_ExplorerBehavior:=TV_Add("Behavior",TV_Explorer)
		TV_ExplorerFastFolders:=TV_Add("Fast Folders",TV_Explorer)
		TV_WindowHandling:=TV_Add("Window handling","","Expand")
		TV_WindowHandling1:=TV_Add("Window handling 1",TV_WindowHandling)
		TV_WindowHandling2:=TV_Add("Window handling 2",TV_WindowHandling)
		TV_FTP:=TV_Add("FTP","","Expand")
		TV_Misc:=TV_Add("Misc","","Expand")
		TV_About:=TV_Add("About","","Expand")
		*/
		Gui, Add, Button, x606 y370 w80 h23 vBtnOK gCancel, Cancel
		Gui, Add, Button, x526 y370 w70 h23 vBtnCancel gOK, OK
		Gui, Add, Text, x16 y375 vTutLabel, Click on ? to see video tutorial help!
		Gui, Add, Text, y375 x370 vWait, Applying settings, please wait!
		CreateHotkeys()
		CreateBehavior()
		CreateFastFolders()
		CreateWindowHandling1()
		CreateWindowHandling2()
		CreateFTP()
		CreateMisc()
		CreateAbout()
		
		GuiControl, Hide, ExplorerBehavior 
		GuiControl, Hide, FastFolders
		GuiControl, Hide, WindowHandling1
		GuiControl, Hide, WindowHandling2
		GuiControl, Hide, FTP
		GuiControl, Hide, Misc
		GuiControl, Hide, About
		GuiControl, Hide, Wait
		Gui, Show, x338 y159 h404 w700, 7plus Settings
		Winwaitactive 7plus Settings
		/*
		Gui, Add, Tab2, x120 y10 w512 h350 , Explorer 1|Explorer 2|Windows|FTP|Misc|About
		;---------------------------------------------------------------------------------------------------------------
		
		;---------------------------------------------------------------------------------------------------------------
		Gui, Tab, Explorer 2
		
		;---------------------------------------------------------------------------------------------------------------
		Gui, Tab, Windows	
		
		;---------------------------------------------------------------------------------------------------------------
		Gui, Tab, FTP
		
		
		;---------------------------------------------------------------------------------------------------------------
		Gui, Tab, Misc
		
*/
		
		;---------------------------------------------------------------------------------------------------------------
		; Setup Control Status
		;---------------------------------------------------------------------------------------------------------------
		
		;Setup paste text as file
		if(txtName!="")
			GuiControl,,Paste text as file,1
		else
			GuiControl, disable ,TxtName
		;Setup paste image as file	
		if(imgName!="")
			GuiControl,,Paste image as file,1
		else
			GuiControl, disable,ImgName
		;Setup text editor
		if(TextEditor!=""||ImageEditor!="")
			GuiControl,,F3: Open selected files in text/image editor,1
		else
		{
			GuiControl, disable,TextEditor
			GuiControl, disable,Button5
			GuiControl, disable,ImageEditor
			GuiControl, disable,Button6
		}
		;Setup taskbar launch
		if(TaskbarLaunchPath!="")
			GuiControl,,Double click on empty taskbar: Run,1
		else
		{
			GuiControl, disable,TaskbarLaunchPath
			GuiControl, disable,Button29
		}		
		
		if HKCreateNewFile
			GuiControl,,HKCreateNewFile,1
		if HKCreateNewFolder
			GuiControl,,HKCreateNewFolder,1
		if HKCopyFilenames
			GuiControl,,HKCopyFilenames,1
		if HKCopyPaths
			GuiControl,,HKCopyPaths,1
		if HKDoubleClickUpwards
			GuiControl,,HKDoubleClickUpwards,1
		if HKAppendClipboard
			GuiControl,,HKAppendClipboard,1
		if HKFastFolders
			GuiControl,,HKFastFolders,1
		if HKProperBackspace
			GuiControl,,HKProperBackspace,1
		if HKSelectFirstFile
			GuiControl,,HKSelectFirstFile,1
		if HKImproveEnter
			GuiControl,,HKImproveEnter,1
		if HKImproveConsole
			GuiControl,,HKImproveConsole,1
		if HKTaskbarLaunch
			GuiControl,,HKTaskbarLaunch,1
		if HKMiddleClose
			GuiControl,,HKMiddleClose,1
		if HKTitleClose
			GuiControl,,HKTitleClose,1
		if HKToggleAlwaysOnTop
			GuiControl,,HKToggleAlwaysOnTop,1
		if HKActivateBehavior
			GuiControl,,HKActivateBehavior,1
		if HKShowSpaceAndSize
			GuiControl,,HKShowSpaceAndSize,1
		if HKMouseGestures
			GuiControl,,HKMouseGestures,1
		if HKKillWindows
			GuiControl,,HKKillWindows,1
		if HKToggleWallpaper
			GuiControl,,HKToggleWallpaper,1
		if HKPhotoViewer
			GuiControl,,HKPhotoViewer,1
		if HKAutoCheck
			GuiControl,,HKAutoCheck,1
		if HKSlideWindows
			GuiControl,,HKSlideWindows,1
		if SlideWinHide
			GuiControl,,SlideWinHide,1	
		if HKFlashWindow
			GuiControl,,HKFlashWindow,1
		if HKToggleWindows
			GuiControl,,HKToggleWindows,1
		if HKFolderBand
			GuiControl,,HKFolderBand,1
		if HKCleanFolderBand
		  GuiControl,,HKCleanFolderBand,1		
		if HKPlacesBar
			GuiControl,,HKPlacesBar,1
		if HKFFMenu
		  GuiControl,,HKFFMenu,1
		if HKFastFolders
		  GuiControl,,Use Fast Folders,1
		else
		{
			GuiControl, disable, HKFolderBand
			GuiControl, disable, HKCleanFolderBand
			GuiControl, disable, HKPlacesBar
			GuiControl, disable, HKFFMenu
		}
		if JoyControl
		  GuiControl,,JoyControl,1
		if ScrollUnderMouse
			GuiControl,,ScrollUnderMouse,1
		if ClipboardManager
			GuiControl,,ClipboardManager,1
		if HideTrayIcon
			GuiControl,,HideTrayIcon,1
		if AutoUpdate
			GuiControl,,AutoUpdate,1
		if HKInvertSelection
			GuiControl,,HKInvertSelection,1
		if HKOpenInNewFolder
			GuiControl,,HKOpenInNewFolder,1	
		if HKAltDrag
			GuiControl,,HKAltDrag,1	
		if HKFlattenDirectory
			GuiControl,,HKFlattenDirectory,1
		if HKAltMinMax
			GuiControl,,HKAltMinMax,1	
		if HKTrayMin
			GuiControl,,HKTrayMin,1	
		;Setup Aero Flip 3D
		if(AeroFlipTime>=0)
		{
			GuiControl,,Mouse in upper left corner: Toggle Aero Flip 3D,1
		}
		else
		{
			GuiControl,,AeroFlipTime,%A_SPACE%
			GuiControl, disable, AeroFlipTime
		}
		
		;Setup FTP
		if(FTP_Enabled)
			GuiControl,,Use FTP,1
		else
		{
			GuiControl, disable, FTP_Host
			GuiControl, disable, FTP_Username
			GuiControl, disable, FTP_Password
			GuiControl, disable, FTP_Port
			GuiControl, disable, FTP_Path
			GuiControl, disable, FTP_URL
		}
		
		;Figure out if Autorun is enabled
		RegRead, Autorun, HKCU, Software\Microsoft\Windows\CurrentVersion\Run , 7plus
		if(Autorun="""" A_ScriptFullPath """")
			GuiControl,, Autorun,1
			
		;Hand cursor over controls where the assigned variable starts with URL_
		; Retrieve scripts PID 
	  Process, Exist 
	  pid_this := ErrorLevel 
	  
	  ; Retrieve unique ID number (HWND/handle) 
	  WinGet, hw_gui, ID, ahk_class AutoHotkeyGUI ahk_pid %pid_this% 
	  
	  ; Call "HandleMessage" when script receives WM_SETCURSOR message 
	  WM_SETCURSOR = 0x20 
	  OnMessage(WM_SETCURSOR, "HandleMessage") 
	  
	  ; Call "HandleMessage" when script receives WM_MOUSEMOVE message 
	  WM_MOUSEMOVE = 0x200 
	  OnMessage(WM_MOUSEMOVE, "HandleMessage")
	  
	}
	Return
}
GuiClose: 
ExitApp 

;---------------------------------------------------------------------------------------------------------------
; Control Handlers
;---------------------------------------------------------------------------------------------------------------

txt:
GuiControlGet, txtenabled , , Paste text as file
if txtenabled
	GuiControl, enable,TxtName
else
	GuiControl, disable,TxtName
Return

img:
GuiControlGet, imgenabled , , Paste image as file
if imgenabled
	GuiControl, enable,ImgName
else
	GuiControl, disable,ImgName
Return

Editor:
GuiControlGet, editorenabled , , F3: Open selected files in text/image editor
if editorenabled
{
	GuiControl, enable,TextEditor
	GuiControl, enable,ImageEditor
	GuiControl, enable,Button5
	GuiControl, enable,Button6
}
else
{
	GuiControl, disable,TextEditor
	GuiControl, disable,ImageEditor
	GuiControl, disable,Button5
	GuiControl, disable,Button6
}
Return

TaskbarLaunch:
GuiControlGet, taskbarlaunchenabled , , Double click on empty taskbar: Run
if taskbarlaunchenabled
{
	GuiControl, enable,TaskbarLaunchPath
	GuiControl, enable,Button29
}
else
{
	GuiControl, disable,TaskbarLaunchPath
	GuiControl, disable,Button29
}
Return

TextBrowse:
FileSelectFile, editorpath , 3, , Select text editor executable, *.exe
if !ErrorLevel
	GuiControl, ,TextEditor,%editorpath%
Return
ImageBrowse:
FileSelectFile, imagepath , 3, , Select image editor executable, *.exe
if !ErrorLevel
	GuiControl, ,ImageEditor,%imagepath%
Return

FastFolders:
GuiControlGet, ffenabled , , Use Fast Folders
if(ffenabled)
{
	if(Vista7)
	{
		GuiControl, enable, HKFolderBand
		GuiControl, enable, HKCleanFolderBand
	}
	GuiControl, enable, HKPlacesBar
	GuiControl, enable, HKFFMenu
}
else
{
	GuiControl, disable, HKFolderBand
	GuiControl, disable, HKCleanFolderBand
	GuiControl, disable, HKPlacesBar
	GuiControl, disable, HKFFMenu
}
return

TaskbarLaunchBrowse:
FileSelectFile, TaskbarPath , 3, , Select taskbar executable, *.exe
if !ErrorLevel
{
	if(InStr(TaskbarPath," "))
		TaskbarPath:=Quote(TaskbarPath)
	GuiControl, ,TaskbarLaunchPath,%TaskbarPath%
}
Return

Flip3D:
GuiControlGet, flip , ,Mouse in upper left corner: Toggle Aero Flip 3D
if(flip)
{
	GuiControl, enable, AeroFlipTime
	GuiControlGet, flip , ,AeroFlipTime
	if(flip<0||flip="")
		flip=0
	GuiControl,,AeroFlipTime,%flip%
}
else
{
	GuiControl, disable, AeroFlipTime
}
return
SlideWindow:
GuiControlGet, slide, , HKSlideWindows
if(slide)
	GuiControl, enable, SlideWinHide
else
	GuiControl, disable, SlideWinHide
return

FTP:
GuiControlGet, ftp , ,Use FTP
if(ftp)
{
	GuiControl, enable, FTP_Host
	GuiControl, enable, FTP_Username
	GuiControl, enable, FTP_Password
	GuiControl, enable, FTP_Port
	GuiControl, enable, FTP_Path
	GuiControl, enable, FTP_URL
}
else
{
	GuiControl, disable, FTP_Host
	GuiControl, disable, FTP_Username
	GuiControl, disable, FTP_Password
	GuiControl, disable, FTP_Port
	GuiControl, disable, FTP_Path
	GuiControl, disable, FTP_URL
}
Return

;---------------------------------------------------------------------------------------------------------------
; Help Links
;---------------------------------------------------------------------------------------------------------------
hPasteAsFile:
run http://www.youtube.com/watch?v=yOJ8evyuVhY
return
hOpenEditor:
run http://www.youtube.com/watch?v=6bxiyNRh0dk
return
hCreateNew:
run http://www.youtube.com/watch?v=e3op-boVfOk
return
hCopyFilenames:
run http://www.youtube.com/watch?v=CA-W1i1bMmQ
return
hNavigation:
run http://www.youtube.com/watch?v=RZOdgDl2ujU
return
hScrollUnderMouse:
run http://www.youtube.com/watch?v=qJ_u4C3EuhU
return
hAppendClipboard:
run http://www.youtube.com/watch?v=je9zk1zy5Xk
return
hSelectFirstFile:
run http://www.youtube.com/watch?v=Bih7HEtpk0A
return
hShowSpaceAndSize:
run http://www.youtube.com/watch?v=-fnOBf3Ggoc
return
hApplyOperation:
run http://www.youtube.com/watch?v=flBnx2NETlc
return
hFastFolders1:
run http://www.youtube.com/watch?v=dTIGxue6WCY
return
hFastFolders2:
run http://www.youtube.com/watch?v=cC6cnG87j2M
return
hTaskbar:
run http://www.youtube.com/watch?v=v__ZiHFt7NE
return
hWindow:
run http://www.youtube.com/watch?v=JJ-kqjRY910
return
hCapslock:
run http://www.youtube.com/watch?v=im088NYiSvw
return
hSlideWindow:
run http://www.youtube.com/watch?v=e0yLqr8mjsg
return
hFTP:
run http://www.youtube.com/watch?v=d01Mjiny_E8
return
hImproveConsole:
run http://www.youtube.com/watch?v=irMu69t3kEg
return
hJoyControl:
run http://www.youtube.com/watch?v=MZiK7E98hOU
return
hClipboardManager:
run http://www.youtube.com/watch?v=Yq8HXOuSEiU
return
GPL:
run http://www.gnu.org/licenses/gpl.html
return
Mail:
run mailto://fragman@gmail.com
return
Ahk:
run http://www.autohotkey.com
return
Projectpage:
run http://code.google.com/p/7plus/
return
Bugtracker:
run http://code.google.com/p/7plus/issues/list
return
7zip:
run http://www.7-zip.org
Return
LGPL:
run http://www.gnu.org/licenses/lgpl.html
return
Donate:
run https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=CCDPER7Z2CHZW
return
;---------------------------------------------------------------------------------------------------------------
; OK/Cancel/Close
;---------------------------------------------------------------------------------------------------------------
OK:
;First process variables which require comparison with previous values
;Store explorer info settings
x:=HKShowSpaceAndSize

;Store Fast Folders settings and make everything consistent by backing up and restoring reg keys
wasActive:=HKFastFolders
GuiControlGet, active , , Use Fast Folders
HKFastFolders:=active
GuiControl, Show, Wait
GuiControl, MoveDraw, Wait
changed:=false
GuiControlGet, active , , HKFolderBand
if(active && HKFastFolders && (!HKFolderBand || !wasactive))
{
	PrepareFolderBand()
	;changed:=true
}
else if(HKFolderBand && ((wasActive && !HKFastFolders) || !active))
{
	RestoreFolderBand()
	changed:=true
}

GuiControlGet, active , , HKCleanFolderBand
if(active && HKFastFolders && (!HKCleanFolderBand || !wasactive))
{
	BackupAndRemoveFolderBandButtons()
}
else if(HKCleanFolderBand && ((wasActive && !HKFastFolders) || !active))
{
	RestoreFolderBandButtons()
}
		
GuiControlGet, active , , HKPlacesBar
if(active && HKFastFolders && (!HKPlacesBar || !wasactive))
{
	BackupPlacesBar()
}
else if(HKPlacesBar && ((wasActive && !HKFastFolders) || !active))
{
	RestorePlacesBar()
}
/*
if(changed)
	RefreshFastFolders()
*/
Autorun:=0 ;?
temp:=FTP_Password
;Store variables which can be stored directly
Gui Submit

if(JoyControl)
	JoystickStart()
else
	JoystickStop()
	
;Store paste text as file filename
GuiControlGet, txtenabled , , Paste text as file
GuiControlGet, pastename , , TxtName
if txtenabled
{
	TxtName:=pastename
	temp_txt:=A_Temp . "\" . TxtName
}
else
{
	TxtName:=""
	temp_txt:=""
}
outputdebug txtenabled:=%txtenabled% pastename=%pastename%
;Store paste image as file filename
GuiControlGet, imgenabled , , Paste image as file
GuiControlGet, pastename , , ImgName
if imgenabled
{
	ImgName:=pastename
	temp_img:=A_Temp . "\" . ImgName
}
else
{
	ImgName:=""
	temp_img:=""
}

;Store editor filename
GuiControlGet, editorenabled , , F3: Open selected files in text/image editor
GuiControlGet, editorpath , , TextEditor
if editorenabled
{
	TextEditor:=editorpath
}
else
{
	TextEditor:=""
}

;Store image editor filename
GuiControlGet, imageeditorpath , , ImageEditor
if editorenabled
{
	ImageEditor:=imageeditorpath
}
else
{
	ImageEditor:=""
}

		

;Store taskbar launch filename
GuiControlGet, taskbarlaunchenabled , , Double click on empty taskbar: Run
GuiControlGet, taskbarPath , , TaskbarLaunchPath
if taskbarlaunchenabled
{
	TaskbarLaunchPath:=taskbarPath
}
else
{
	TaskbarLaunchPath:=""
}

;Store Aero Flip time
GuiControlGet, flip,,Mouse in upper left corner: Toggle Aero Flip 3D
if(flip&&Vista7)
	SetTimer, hovercheck, 10
else
{
	AeroFlipTime:=-1
	SetTimer, hovercheck, Off
}
;UnSlide hidden windows
if(!HKSlideWindows)
	SlideWindows_Exit()
;Store FTP Settings
GuiControlGet, FTP_Enabled, ,Use FTP
if(FTP_Password!=temp)
	FTP_Password:=Encrypt(FTP_Password)
ValidateFTPVars()

;Store Autorun setting
if(Autorun)
	RegWrite, REG_SZ, HKCU, Software\Microsoft\Windows\CurrentVersion\Run , 7plus, "%A_ScriptFullPath%"
else
	RegDelete, HKCU, Software\Microsoft\Windows\CurrentVersion\Run, 7plus
if(HideTrayIcon)
{
	MsgBox You have chosen to hide the tray icon. This means that you will only be able to access the settings dialog by pressing WIN + H. Also, the program can only be ended by using the task manager then.
	Menu, Tray, NoIcon
}
else
	Menu, Tray, Icon
WriteIni()
SettingsActive:=False
Gui Destroy
Gui 1:Default
Return

2GuiEscape:
Cancel:
2GuiClose:
SettingsActive:=False
Gui Destroy
Gui 1:Default
Return

;Link hand cursor handling
HandleMessage(p_w, p_l, p_m, p_hw) 
{ 
  global   WM_SETCURSOR, WM_MOUSEMOVE, 
  static   URL_hover, h_cursor_hand, h_old_cursor, CtrlIsURL, LastCtrl 
  
  If (p_m = WM_SETCURSOR) 
    { 
      If URL_hover 
        Return, true 
    } 
  Else If (p_m = WM_MOUSEMOVE) 
    { 
      ; Mouse cursor hovers URL text control 
      StringLeft, CtrlIsURL, A_GuiControl, 3 
      If (CtrlIsURL = "URL") 
        { 
          If URL_hover= 
            { 
              Gui, Font, cBlue underline 
              GuiControl, Font, %A_GuiControl% 
              LastCtrl = %A_GuiControl% 
              
              h_cursor_hand := DllCall("LoadCursor", "uint", 0, "uint", 32649) 
              
              URL_hover := true 
            }
            h_old_cursor := DllCall("SetCursor", "uint", h_cursor_hand) 
        } 
      ; Mouse cursor doesn't hover URL text control 
      Else 
        { 
          If URL_hover 
            { 
              Gui, Font, norm cBlue 
              GuiControl, Font, %LastCtrl% 
              
              DllCall("SetCursor", "uint", h_old_cursor) 
              
              URL_hover= 
            } 
        } 
    } 
}

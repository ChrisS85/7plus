;Call this to show settings dialog
SettingsHandler:
ShowSettings()
return

;---------------------------------------------------------------------------------------------------------------
; The following functions create the GUI and are only called once at startup
;---------------------------------------------------------------------------------------------------------------
Settings_CreateEvents() {
	global
	local yIt,x1,x2,x,y
	xHelp:=xBase
	x1:=xHelp+10
	x2 := x1 + 410
	yIt:=yBase
	Gui, 1:Add, Tab2, x156 y14 w410 h350 vEventsTab, 
	AddTab(0, "","SysTabControl321")
	Gui, 1:Add, Text, x%x1% y%yIt% R3, You can add events here that are triggered under certain conditions. When triggered,`nthe event can launch a series of actions. This is a very powerful tool to add `nall kinds of features, and many features from 7plus are now implemented with this system.
	yIt+=50
	Gui, 1:Add, ListView, x%x1% y%yIt% w400 vGUI_EventsList gGUI_EventsList_SelectionChange Grid -LV0x10 -Multi R17 AltSubmit, ID|Trigger|Name
	OnMessage(0x100, "WM_KEYDOWN")
	Gui, 1:Add, Button, x%x2% y%yIt% w80 vGUI_EventsList_Add gGUI_EventsList_Add, Add Event
	yIt += textboxstep
	Gui, 1:Add, Button, x%x2% y%yIt% w80 vGUI_EventsList_Remove gGUI_EventsList_Remove, Delete Event
	yIt += textboxstep
	Gui, 1:Add, Button, x%x2% y%yIt% w80 vGUI_EventsLisit_Edit gGUI_EventsList_Edit, Edit Event
	yIt += 208 - textboxstep -4
	Gui, 1:Add, Button, x%x2% y%yIt% w80 gGUI_EventsLisit_Help, Help
	yIt += textboxstep + 4
	y := yIt + TextBoxTextOffset
}
Settings_CreateHotkeys() {
	global
	local yIt,x1,x2,x
	Gui, 1:Add, Tab2, x156 y14 w410 h350 vExplorerHotkeysTab, 
	AddTab(1, "","SysTabControl322") 
	yIt:=yBase
	
	x1:=xHelp+10
	x2:=xBase+280
	x:=xBase+247
	y:=yIt+TextBoxCheckBoxOffset
	Gui, 1:Add, CheckBox, x%x1% y%y% gEditor, F3: Open selected files in text/image editor
	Gui, 1:Add, Text, y%y% x%xhelp% cBlue ghOpenEditor vURL_OpenEditor, ?
	y:=yIt+TextBoxTextOffset
	Gui, 1:Add, Text, x%x% y%y%, Editor:
	y:=yIt
	Gui, 1:Add, Edit, x%x2% y%y% w%wTBMedium% vTextEditor R1 
	x:=x2+wTBMedium+10
	y:=yIt+TextBoxButtonOffset
	Gui, 1:Add, Button, x%x% y%y% w%wButton% gTextBrowse, ...
	yIt+=textboxstep
	x:=xBase+215
	y:=yIt+TextBoxTextOffset
	Gui, 1:Add, Text, x%x% y%y%, Image editor:
	y:=yIt
	Gui, 1:Add, Edit, x%x2% y%y% w%wTBMedium% vImageEditor R1 
	x:=x2+wTBMedium+10
	y:=yIt+TextBoxButtonOffset
	Gui, 1:Add, Button, x%x% y%y% w%wButton% gImageBrowse, ...
	yIt+=textboxstep
	
	x2:=x2-60
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghCreateNew vURL_CreateNew, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKCreateNewFile, F7: Create new file
	yIt+=checkboxstep
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghCreateNew vURL_CreateNew1, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKCreateNewFolder, F8: Create new folder
	yIt+=checkboxstep	
	
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghCopyFilenames vURL_CopyFilenames, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKCopyFilenames, ALT + C: Copy Filenames	
	yIt+=checkboxstep	
	
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghCopyFilenames vURL_CopyFilenames1, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKCopyPaths, CTRL + ALT + C: Copy paths + filenames
	yIt+=checkboxstep	
	
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghNavigation vURL_Navigation, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKProperBackspace, Backspace (Vista/7): Go upwards
	x:=x2+80
	yIt+=checkboxstep	
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghNavigation vURL_Navigation1, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKMouseGestures, Hold right mouse and click left: Go back, Hold left mouse and click right: Go forward
	yIt+=checkboxstep	
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghNavigation vURL_Navigation2, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKDoubleClickUpwards, Double click on empty space in filelist: Go upwards
	yIt+=checkboxstep	
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghAppendClipboard vURL_AppendClipboard, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKAppendClipboard, Shift + X / Shift + C: Append files to clipboard instead of replacing (cut/copy)
	yIt+=checkboxstep	
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghExplorer1dot1 vURL_Explorer1dot1, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKInvertSelection, CTRL + I: Invert selection

	yIt+=checkboxstep
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghExplorer1dot1 vURL_Explorer1dot12, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKFlattenDirectory, SHIFT + Enter: Show selected directories in flat view (Vista/7 only)
}
Settings_CreateBehavior() {
	global
	local yIt,x1,x,y
	yIt:=yBase
	x1:=xHelp+10
	x2:=xBase+280
	
	Gui, 1:Add, Tab2, x156 y14 w410 h350 vExplorerBehaviorTab, 
	AddTab(0, "","SysTabControl323")

	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghSelectFirstFile vURL_SelectFirstFile, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKSelectFirstFile, Explorer automatically selects the first file when you enter a directory
	yIt+=checkboxstep	
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghSelectFirstFile vURL_SelectFirstFile1, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKImproveEnter, Files which are only focussed but not selected can be executed by pressing enter
	yIt+=checkboxstep		
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghScrollUnderMouse vURL_ScrollUnderMouse, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vScrollUnderMouse, Scroll explorer scrollbars with mouse over them
	yIt+=checkboxstep
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghShowSpaceAndSize vURL_ShowSpaceAndSize, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKShowSpaceAndSize, Show free space and size of selected files in status bar like in XP (7 only)
	yIt+=checkboxstep	
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghApplyOperation vURL_ApplyOperation, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKAutoCheck, Automatically check "Apply to all further operations" checkboxes in file operations (Vista/7 only)
	yIt+=checkboxstep
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vRecallExplorerPath, Win+E: Open explorer in last active directory
	yIt+=checkboxstep
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vAlignExplorer, Win+E + explorer window active: Open new explorer and align them left and right
	yIt+=checkboxstep*2
	
	Gui, 1:Add, Text, x%x1% y%yIt%, Text and images from clipboard can be pasted as file in explorer with these settings
	yIt+=checkboxstep
	
	y:=yIt+TextBoxCheckBoxOffset
	Gui, 1:Add, CheckBox, x%x1% y%y% gtxt, Paste text as file
	Gui, 1:Add, Text, y%y% x%xhelp% cBlue ghPasteAsFile vURL_PasteAsFile, ?
	
	x:=xBase+232
	Gui, 1:Add, Text, x%x% y%y%, Filename:
	y:=yIt
	Gui, 1:Add, Edit, x%x2% y%y% w%wTBMedium% vTxtName R1
	yIt+=textboxstep
	
	y:=yIt+TextBoxCheckBoxOffset
	Gui, 1:Add, CheckBox, x%x1% y%y% gimg, Paste image as file
	Gui, 1:Add, Text, y%y% x%xhelp% cBlue ghPasteAsFile vURL_PasteAsFile1, ?
	y:=yIt+TextBoxTextOffset
	Gui, 1:Add, Text, x%x% y%y%, Filename:
	y:=yIt
	Gui, 1:Add, Edit, x%x2% y%y% w%wTBMedium% vImgName R1	
	yIt+=textboxstep	
	
}
Settings_CreateFastFolders() {
	global
	local yIt,x1,x,y
	yIt:=yBase
	xHelp:=xBase
	x1:=xHelp+10
	Gui, 1:Add, Tab2, x156 y14 w410 h350 vFastFoldersTab
	AddTab(0, "","SysTabControl324")
	
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghFastFolders1 vURL_FastFolders1, ?		
	Gui, 1:Add, Checkbox, x%x1% y%yIt% gFastFolders,Use Fast Folders
	yIt+=checkboxstep	
	x:=x1+xCheckboxTextOffset
	xhelp+=xCheckboxTextOffset
	y:=yIt+yCheckboxTextOffset
	Gui, 1:Add, Text, x%x% y%y% R2, In all kinds of file views you can store a path in one of ten slots by pressing CTRL`nand a numpad number key, and restore it by pressing the numpad number key again
	yIt+=checkboxstep*1.5
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghFastFolders1 vURL_FastFolders11, ?
	Gui, 1:Add, Checkbox, x%x% y%yIt% vHKFolderBand, Integrate Fast Folders into explorer folder band bar (Vista/7 only)	
	yIt+=checkboxstep
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghFastFolders2 vURL_FastFolders2, ?
	Gui, 1:Add, Checkbox, x%x% y%yIt% vHKCleanFolderBand, Remove windows folder band buttons (Vista/7 only)
	yIt+=checkboxstep
	x+=xCheckboxTextOffset
	y:=yIt+yCheckboxTextOffset
	Gui, 1:Add, Text, x%x% y%y% R2 vFolderBandDescription, If you use the folder band as a favorites bar like in browsers, it is recommended that you get rid`nof the buttons predefined by windows whereever possible (such as Slideshow, Add to Library,...)
	x-=xCheckboxTextOffset
	yIt+=checkboxstep*1.5
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghFastFolders2 vURL_FastFolders21, ?
	Gui, 1:Add, Checkbox, x%x% y%yIt% vHKPlacesBar, Integrate Fast Folders into open/save dialog places bar (First 5 Entries)
	yIt+=checkboxstep
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghFastFolders2 vURL_FastFolders22, ?
	Gui, 1:Add, Checkbox, x%x% y%yIt% vHKFFMenu, Middle mouse button: Show Fast Folders move/copy menu
	yIt+=checkboxstep
	y:=yIt+yCheckboxTextOffset
	x+=xCheckboxTextOffset
	Gui, 1:Add, Text, x%x% y%y% R3, When clicking with middle mouse button in a supported file view, a menu`nwith the stored Fast Folders will show up. Clicking an entry will move all`nselected files into that directory, holding CTRL while clicking will copy the files.
}
Settings_CreateTabs() {
	global
	local yIt,x1,x,y,x2
	yIt:=yBase
	xHelp:=xBase
	x1:=xHelp+10
	Gui, 1:Add, Tab2, x156 y14 w410 h350 vExplorerTabsTab
	AddTab(0, "","SysTabControl325")
	
	Gui, 1:Add, Text, x%x1% y%yIt% R3, 7plus makes it possible to use tabs in explorer. New tabs are opened with the middle mouse button`nand with CTRL+T, Tabs are cycled by clicking the Tabs or pressing CTRL+(SHIFT)+TAB,`nand closed by middle clicking a tab and with CTRL+W
	yIt+=CheckboxStep*2.25
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghTabs vURL_Tabs, ?		
	Gui, 1:Add, Checkbox, x%x1% y%yIt% gUseTabs vUseTabs,Use Tabs in Explorer
	yIt+=checkboxstep
	x:=x1+xCheckboxTextOffset
	xhelp+=xCheckboxTextOffset
	x2:=x+240
	y:=yIt+TextBoxCheckBoxOffset
	Gui, 1:Add, Text, x%x% y%y% vTabLabel1, Create tabs:
	Gui, 1:Add, DropDownList, x%x2% y%yIt% w%wTBMedium% vNewTabPosition AltSubmit,next to current tab|at the end
	yIt+=textboxstep
	y:=yIt+TextBoxCheckBoxOffset
	Gui, 1:Add, Text, x%x% y%y% vTabLabel2, Tab startup path (empty for current dir):
	Gui, 1:Add, Edit, x%x2% y%yIt% vTabStartupPath w%wTBMedium% R1,%TabStartupPath%
	x2+=wTBMedium+10
	y:=yIt+TextBoxButtonOffset
	Gui, 1:Add, Button, x%x2% y%yIt% w%wButton% vTabStartupPathBrowse gTabStartupPathBrowse,...
	x2:=x+240
	yIt+=textboxstep
	Gui, 1:Add, Checkbox, x%x% y%yIt% vActivateTab,Activate tab on tab creation
	yIt+=checkboxstep
	Gui, 1:Add, Checkbox, x%x% y%yIt% vTabWindowClose,Close all tabs when window is closed
	yIt+=checkboxstep	
	y:=yIt+TextBoxCheckBoxOffset
	Gui, 1:Add, Text, x%x% y%y% vTabLabel3, On tab close:
	Gui, 1:Add, DropDownList, x%x2% y%yIt% w%wTBMedium% vOnTabClose AltSubmit,activate left tab|activate right tab
	yIt+=textboxstep
	y:=yIt+TextBoxCheckBoxOffset
	Gui, 1:Add, Checkbox, x%x% y%y% gOpenFolderInNew vOpenFolderInNew, Middle mouse button on folder: Open in new
	Gui, 1:Add, DropDownList, x%x2% y%yIt% w%wTBMedium% vMiddleOpenFolder AltSubmit, window|tab|tab in background
	yIt+=checkboxstep	
}
Settings_CreateWindowHandling() {
	global
	local yIt,x1,x,y
	xHelp:=xBase
	x1:=xHelp+10
	Gui, 1:Add, Tab2, x156 y14 w410 h350 vWindowHandlingTab, 
	AddTab(0, "","SysTabControl326")
	yIt:=yBase

	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghTaskbar vURL_Taskbar3, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKTitleClose, Middle click on title bar: Close program
	yIt+=checkboxstep	
	
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghWindow vURL_Window, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKToggleAlwaysOnTop, Right click on title bar: Toggle "Always on top"
	yIt+=checkboxstep			
	
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghWindow vURL_Window1, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKKillWindows, Alt+F5/Right click on close button: Force-close active window (kill process)
	yIt+=checkboxstep		
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghSlideWindow vURL_SlideWindow, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKSlideWindows gSlideWindow, WIN + SHIFT + Arrow keys: Slide Window function
	yIt+=checkboxstep	
	y:=yIt+yCheckboxTextOffset
	x:=x1+xCheckboxTextOffset
	Gui, 1:Add, Text, x%x% y%y% R4, A Slide Window is moved off screen, it will not be shown until you activate it through task bar /`nALT + TAB or move the mouse to the border where it was hidden. It will then slide into the screen,`nand slide out again when the mouse leaves the window or when another window gets activated.`nDeactivate this mode by moving the window or pressing WIN+SHIFT+Arrow key in another direction.
	yIt+=checkboxstep*2.5
	Gui, 1:Add, Checkbox, x%x% y%yIt% vSlideWinHide, Hide Slide Windows in taskbar and from ALT + TAB
	yIt+=checkboxstep
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghCapslock vURL_Capslock, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKFlashWindow, Capslock: Activate flashing window (blinking on taskbar, e.g. instant messengers, ...)
	yIt+=checkboxstep
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghCapslock vURL_Capslock1, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKToggleWindows, Capslock: Switch between current and previous window
	yIt+=checkboxstep
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghWindow1dot1 vURL_Window1dot1, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKAltDrag, ALT+Left Mouse Drag: Move windows
	yIt+=checkboxstep
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghWindow1dot1 vURL_Window1dot11, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKAltMinMax, ALT + Mouse wheel: Minimize/Maximize/Restore window under mouse
	yIt+=checkboxstep
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghWindow1dot1 vURL_Window1dot12, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKTrayMin, Right click minimize button or WIN + SHIFT + Arrow key in taskbar direction: Minimize to tray
	yIt+=checkboxstep
	y:=yIt+TextBoxCheckBoxOffset
	Gui, 1:Add, Text, y%y% x%xhelp% cBlue ghWindow vURL_Window3, ?
	Gui, 1:Add, Checkbox, x%x1% y%y% gFlip3D, Mouse in upper left corner: Toggle Aero Flip 3D (Vista/7 only)
	x:=xBase+362
	y:=yIt+TextBoxTextOffset
	Gui, 1:Add, Text, x%x% y%y%, Seconds in corner:
	x:=xBase+248+wTBLarge
	Gui, 1:Add, Edit, 		x%x% y%yIt% w%wTBShort% R1 vAeroFlipTime	
	y:=yIt+TextBoxButtonOffset
	yIt+=textboxstep
}
Settings_CreateDesktopTaskBar() {
	global
	local yIt,x1,x,y
	xHelp:=xBase
	x1:=xHelp+10
	yIt:=yBase
	y:=yIt+TextBoxCheckBoxOffset
	Gui, 1:Add, Tab2, x156 y14 w410 h350 vDesktopTaskbarTab, 
	AddTab(0, "","SysTabControl327")
	y:=yIt+TextBoxCheckBoxOffset
	Gui, 1:Add, Text, y%y% x%xhelp% cBlue ghTaskbar vURL_Taskbar, ?
	Gui, 1:Add, Checkbox, x%x1% y%y% gTaskbarLaunch, Double click on empty taskbar: Run
	x:=xBase+258
	Gui, 1:Add, Edit, x%x% y%yIt% w%wTBLarge% R1 vTaskbarLaunchPath
	y:=yIt+TextBoxButtonOffset
	x:=x+wTBLarge+10
	Gui, 1:Add, Button, x%x% y%y% w%wButton% gTaskbarLaunchBrowse vTaskbarLaunchPathBrowse, ...
	yIt+=textboxstep
	
	;Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghWindow vURL_Window2, ?
	y:=yIt+TextBoxCheckBoxOffset
	Gui, 1:Add, CheckBox, x%x1% y%y% gDoubleClickDesktop vDoubleClickDesktop, Double click on desktop: Run	
	x:=xBase+258
	Gui, 1:Add, Edit, x%x% y%yIt% w%wTBLarge% vDoubleClickDesktopPath R1
	y:=yIt+TextBoxButtonOffset
	x+=wTBLarge+10
	Gui, 1:Add, Button, x%x% y%y% w%wButton% gDoubleClickDesktopBrowse vDoubleClickDesktopBrowse, ...
	yIt+=textboxstep
	
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghTaskbar vURL_Taskbar1, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKMiddleClose, Middle click on taskbuttons: close task
	yIt+=checkboxstep
	
	x:=x1+xCheckboxTextOffset
	y:=yIt+yCheckBoxTextOffset
	Gui, 1:Add, Text, x%x% y%y%, Middle click on empty taskbar: Taskbar properties
	yIt+=checkboxstep	
	
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghTaskbar vURL_Taskbar2, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKActivateBehavior, Left click on task group button (7 only): cycle through windows	
	yIt+=checkboxstep	
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghWindow vURL_Window2, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKToggleWallpaper, Middle mouse click on desktop: Toggle wallpaper (7 only)
	yIt+=checkboxstep
}
Settings_CreateCustomHotkeys() {
	global
	local yIt,x1,x2,x,y
	xHelp:=xBase
	x1:=xHelp+10
	x2 := x1 + 410
	yIt:=yBase
	Gui, 1:Add, Tab2, x156 y14 w410 h350 vCustomHotkeysTab, 
	AddTab(0, "","SysTabControl328")
	Gui, 1:Add, Text, x%x1% y%yIt% R2, You can add custom hotkeys to launch programs here. You should not use hotkeys that are used `nby this program elsewhere, also you should make sure not to overwrite hotkeys used by other programs.
	yIt+=35
	Gui, 1:Add, Radio, x%x1% y%yIt% vCustomHotkeysGlobal gCustomHotkeysGlobal, Global hotkeys
	yIt+=checkboxstep
	y := yIt + TextBoxCheckBoxOffset
	Gui, 1:Add, Radio, x%x1% y%y% vCustomHotkeysSpecific gCustomHotkeysSpecific, program-specific hotkeys
	x := x1 + 150
	Gui, 1:Add, DropDownList, x%x% y%yIt% w250 vCustomHotkeysFilter gCustomHotkeysFilter
	y := yIt + TextBoxButtonOffset
	Gui, 1:Add, Button, x%x2% y%yIt% w80 vCustomHotkeysFilterBrowse gCustomHotkeysFilterBrowse, Browse
	yIt += textboxstep
	Gui, 1:Add, ListView, x%x1% y%yIt% w400 vCustomHotkeysList gCustomHotkeysList_SelectionChange Grid -LV0x10 -Multi R10 AltSubmit, Hotkey|Command
	OnMessage(0x100, "WM_KEYDOWN")
	Gui, 1:Add, Button, x%x2% y%yIt% w80 vCustomHotkeysAdd gAddHotkey, Add Hotkey
	yIt += textboxstep
	Gui, 1:Add, Button, x%x2% y%yIt% w80 vCustomHotkeysRemove gRemoveHotkey, Delete Hotkey
	yIt += textboxstep
	Gui, 1:Add, Button, x%x2% y%yIt% w80 vCustomHotkeysEditKey gEditHotkey, Edit Hotkey	
	yIt += 150 - textboxstep -4
	Gui, 1:Add, Button, x%x2% y%yIt% w80 gCustomHotkeyHelp, Help
	yIt += textboxstep + 4
	y := yIt + TextBoxTextOffset
	Gui, 1:Add, Text, x%x1% y%y%, Command:
	x:=x1+54
	Gui, 1:Add, Edit, x%x% y%yIt% w348 vCustomHotkeysCommand gCustomHotkeysCommand_Change
	y := yIt + TextBoxButtonOffset
	Gui, 1:Add, Button, x%x2% y%yIt% w80 vCustomHotkeysEditCommand gEditCommand, Browse
	yIt += textboxstep
	;Gui, 1:Add, Text, x%x1% y%yIt%, You can use placeholders to create context-sensitive hotkeys. Supported placeholders:`n${P}: Current path in explorer`n${1}...${N}: Selected file(s)`nExample usages are hotkeys to open files with specific programs (diff tools, editors,...)
}
Settings_CreateFTP() {
	global
	local yIt,x1,x,y
	yIt:=yBase
	xHelp:=xBase
	x1:=xHelp+10
	Gui, 1:Add, Tab2, x156 y14 w410 h350 vFTPTab, 
	AddTab(0, "","SysTabControl329")
	Gui, 1:Add, Text, x%x1% y%yIt% R4, You can upload selected files from explorer to an FTP server by`npressing CTRL + U. You can also take screenshots (ALT + Insert = fullscreen`,`nWIN + Insert = active window) and directly upload them. WIN + Delete will upload`nimage or text data from clipboard. URL(s) will be copied to the clipboard.
	yIt:=100
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghFTP vURL_FTP, ?
	Gui, 1:Add, CheckBox, x%x1% y%yIt% gFTP, Use FTP
	yIt+=checkboxstep	
	x1:=xHelp+xCheckBoxTextOffset+10
	x2:=xHelp+122
	y:=yIt+TextBoxTextOffset
	Gui, 1:Add, Text, x%x1% y%y%, Hostname
	Gui, 1:Add, Edit, x%x2% y%yIt% w%wTBMedium% R1 vFTP_Host
	yIt+=TextBoxStep	
	
	y:=yIt+TextBoxTextOffset
	Gui, 1:Add, Text, x%x1% y%y%, Port
	Gui, 1:Add, Edit, x%x2% y%yIt% w%wTBShort% R1 vFTP_PORT Number
	yIt+=TextBoxStep
	
	y:=yIt+TextBoxTextOffset
	Gui, 1:Add, Text, x%x1% y%y%, Username
	Gui, 1:Add, Edit, x%x2% y%yIt% w%wTBMedium% R1 vFTP_Username
	yIt+=TextBoxStep	
	
	y:=yIt+TextBoxTextOffset
	Gui, 1:Add, Text, x%x1% y%y%, Password
	Gui, 1:Add, Edit, x%x2% y%yIt% w%wTBMedium% R1 vFTP_Password Password
	yIt+=TextBoxStep	
	
	y:=yIt+TextBoxTextOffset
	Gui, 1:Add, Text, x%x1% y%y%, Remote Folder
	Gui, 1:Add, Edit, x%x2% y%yIt% w%wTBMedium% R1 vFTP_Path
	yIt+=TextBoxStep
	
	Gui, 1:Add, Text, x%x1% y%yIt%, URL under which the files can be accessed through HTTP
	yIt+=checkboxstep
	
	y:=yIt+TextBoxTextOffset
	Gui, 1:Add, Text, x%x1% y%y%, URL
	Gui, 1:Add, Edit, x%x2% y%yIt% w%wTBMedium% R1 vFTP_URL
}
Settings_CreateMisc() {
	global
	local yIt,x1
	Gui, 1:Add, Tab2, x156 y14 w410 h350 vMiscTab, 
	AddTab(0, "","SysTabControl3210")
	x1:=xBase+10
	xhelp:=xBase
	yIt:=yBase
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghImproveConsole vURL_ImproveConsole, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKImproveConsole, Open current folder in CMD by pressing WIN + C and enable CTRL + V and Alt + F4 in CMD
	yIt+=checkboxstep
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHKPhotoViewer, Windows picture viewer: Rotate image with R and L
	yIt+=checkboxstep
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghJoyControl vURL_JoyControl, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vJoyControl, Use joystick/gamepad as remote control when not in fullscreen (optimized for XBOX360 gamepad)
	yIt+=checkboxstep
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghClipboardManager vURL_ClipboardManager, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vClipboardManager, WIN + V: Clipboard manager (stores last 10 entries)	
	yIt+=checkboxstep
	Gui, 1:Add, Text, y%yIt% x%xhelp% cBlue ghWordDelete vURL_WordDelete, ?
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vWordDelete, Make CTRL+Backspace and CTRL+Delete work in all textboxes
	
	yIt+=2*checkboxstep
	y:=yIt+TextBoxTextOffset
	x2:=x1+180
	Gui, 1:Add, Text, x%x1% y%y% Number, Image compression quality:
	Gui, 1:Add, Edit, x%x2% y%yIt% w%wTBShort% R1 vImageQuality
	yIt+=TextBoxStep
	y:=yIt+TextBoxTextOffset
	Gui, 1:Add, Text, x%x1% y%y%, Default image extension:
	Gui, 1:Add, Edit, x%x2% y%yIt% w%wTBShort% R1 vImageExtension
	yIt+=TextBoxStep
	y:=yIt+TextBoxTextOffset
	Gui, 1:Add, Text, x%x1% y%y%, Fullscreen detection include list
	Gui, 1:Add, Edit, x%x2% y%yIt% w%wTBHuge% R1 vFullscreenInclude
	yIt+=TextBoxStep
	y:=yIt+TextBoxTextOffset
	Gui, 1:Add, Text, x%x1% y%y%, Fullscreen detection exclude list
	Gui, 1:Add, Edit, x%x2% y%yIt% w%wTBHuge% R1 vFullscreenExclude
	yIt+=TextBoxStep
	
	yIt+=checkboxstep
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vAutorun, Autorun 7plus on windows startup
	yIt+=checkboxstep
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vHideTrayIcon, Hide Tray Icon (press WIN + H to show settings!)
	yIt+=checkboxstep
	Gui, 1:Add, Checkbox, x%x1% y%yIt% vAutoUpdate, Automatically look for updates on startup
}
Settings_CreateAbout() {
	global
	local yIt,x1,x2,x,y,version
	Gui, 1:Add, Tab2, x156 y14 w410 h350 vAboutTab, 
	AddTab(0, "","SysTabControl3211")
	yIt:=YBase
	x1:=XBase+10
	x2:=xBase+350
	if(A_IsCompiled)			
		Gui, 1:Add, Picture, w128 h128 y%yIt% x%x2% Icon3 vLogo, %A_ScriptFullPath%
	else
		Gui, 1:Add, Picture, w128 h128 y%yIt% x%x2% vLogo, %A_ScriptDir%\128.png
	
	Gui, 1:font, s20
	version := MajorVersion "." MinorVersion "." BugfixVersion
	Gui, 1:Add, Text, y%yIt% x%x1%, 7plus Version %version%
	Gui, 1:font
	yIt+=hText*3
	x2:=x1+100
	Gui, 1:Add, Text, y%yIt% x%x1% , Project page:
	Gui, 1:Add, Text, y%yIt% x%x2% cBlue gProjectpage vURL_Projectpage, http://code.google.com/p/7plus/
	yIt+=hText
	Gui, 1:Add, Text, y%yIt% x%x1% , Report bugs:
	Gui, 1:Add, Text, y%yIt% x%x2% cBlue gBugtracker vURL_Bugtracker, http://code.google.com/p/7plus/issues/list
	yIt+=hText
	Gui, 1:Add, Text, y%yIt% x%x1% , Author:
	Gui, 1:Add, Text, y%yIt% x%x2% , Christian Sander
	yIt+=hText
	Gui, 1:Add, Text, y%yIt% x%x1% , E-Mail:
	Gui, 1:Add, Text, y%yIt% x%x2% cBlue gMail vURL_Mail, fragman@gmail.com
	yIt+=hText*2
	Gui, 1:Add, Text, y%yIt% x%x1%, To support the development of this project, please donate:
	yIt+=hText*1.5
	if(A_IsCompiled)			
		Gui, 1:Add, Picture, y%yIt% x%x1% cBlue gDonate Icon4 vURL_Donate, %A_ScriptFullPath%
	else
		Gui, 1:Add, Picture, y%yIt% x%x1% cBlue gDonate vURL_Donate, %A_ScriptDir%\Donate.png		
	yIt+=hText*2
	x2:=x1+200
	Gui, 1:Add, Text, y%yIt% x%x1%, Proudly written in Autohotkey
	Gui, 1:Add, Text, y%yIt% x%x2%, Updater uses
	x2+=66
	Gui, 1:Add, Text, y%yIt% x%x2% vURL_7zip g7zip cBlue, 7-Zip
	x2+=24
	Gui, 1:Add, Text, y%yIt% x%x2%, , which is licensed under the 
	x2+=136
	Gui, 1:Add, Text, y%yIt% x%x2% vURL_LGPL gLGPL cBlue, LGPL
	yIt+=hText
	Gui, 1:Add, Text, y%yIt% x%x1% cBlue gAhk vURL_AHK, www.autohotkey.com		
	yIt+=hText*2
	Gui, 1:Add, Text, y%yIt% x%x1% , Licensed under  	
	x2:=x1+100
	Gui, 1:Add, Text, y%yIt% x%x2% cBlue gGPL vURL_GPL, GNU General Public License v3
	yIt+=hText*2
	Gui, 1:Add, Text, y%yIt% x%x1% , Credits for lots of code samples and help go out to:`nSean, HotKeyIt, majkinetor, Titan, Lexikos, TheGood, PhiLho, Temp01, Laszlo, jballi, Shrinker`nand the other guys and gals on #ahk and the forums.	
}

;---------------------------------------------------------------------------------------------------------------
; The following functions set the GUI values and are called each time the GUI is shown
;---------------------------------------------------------------------------------------------------------------
Settings_SetupEvents() {
	global
	Settings_Events := Events.DeepCopy()
	outputdebug("Old Count: " Events.len() "New count: " Settings_Events.len())
	;Settings_Events.base.base := ArrBase ; This crashes
	
enum := Settings_Events._newenum()
outputdebug new object
while enum[key,value]
{
	outputdebug %key% %value%
}
	Gui, ListView, GUI_EventsList
	LV_Delete()
	Loop % Settings_Events.len()
	{
		LV_Add(A_Index = 1 ? "Select" : "",Settings_Events[A_Index].ID,Settings_Events[A_Index].Trigger.DisplayString(), Settings_Events[A_Index].Name)
	}
	GuiControl, 1:enable, GUI_EventsList_Add
	GuiControl, 1:enable, GUI_EventsList_Remove
	GuiControl, 1:enable, GUI_EventsList_Edit
}
Settings_SetupHotkeys() {
	global
	local temp
	;Setup text editor
	GuiControl, 1:, TextEditor, %TextEditor%
	GuiControl, 1:, ImageEditor, %ImageEditor%	
	temp:=(TextEditor!="" || ImageEditor!="")
	GuiControl, 1:,F3: Open selected files in text/image editor,%temp%
	GoSub Editor
	
	if(!Vista7)
		GuiControl, 1:disable, HKProperBackspace
		
	GuiControl, 1:,HKCreateNewFile,%HKCreateNewFile%
	GuiControl, 1:,HKCreateNewFolder,%HKCreateNewFolder%
	GuiControl, 1:,HKCopyFilenames,%HKCopyFilenames%
	GuiControl, 1:,HKCopyPaths,%HKCopyPaths%
	GuiControl, 1:,HKDoubleClickUpwards,%HKDoubleClickUpwards%
	GuiControl, 1:,HKAppendClipboard,%HKAppendClipboard%
	GuiControl, 1:,HKProperBackspace,%HKProperBackspace%
	GuiControl, 1:,HKMouseGestures,%HKMouseGestures%
	GuiControl, 1:,HKInvertSelection,%HKInvertSelection%
	GuiControl, 1:,HKFlattenDirectory,%HKFlattenDirectory%
}
Settings_SetupBehavior() {
	global	
	local temp
	if(A_OSVersion!="WIN_7")
		GuiControl, 1:disable, HKShowSpaceAndSize
	
	if(!Vista7)
		GuiControl, 1:disable, HKAutoCheck
	GuiControl, 1:, ImgName, %ImgName%
	GuiControl, 1:, TxtName, %TxtName%
	
	;Setup paste text as file
	temp:=(txtName!="")
	GuiControl, 1:,Paste text as file,%temp%
	GoSub txt
	
	;Setup paste image as file	
	temp:=(imgName!="")
	GuiControl, 1:,Paste image as file,%temp%
	GoSub img
		
	GuiControl, 1:, HKSelectFirstFile, %HKSelectFirstFile%
	GuiControl, 1:, HKImproveEnter, %HKImproveEnter%
	GuiControl, 1:, ScrollUnderMouse, %ScrollUnderMouse%
	GuiControl, 1:, HKShowSpaceAndSize, %HKShowSpaceAndSize%	
	GuiControl, 1:, HKAutoCheck, %HKAutoCheck%
	GuiControl, 1:, RecallExplorerPath, %RecallExplorerPath%
	GuiControl, 1:, AlignExplorer, %AlignExplorer%
}
Settings_SetupFastFolders() {
	global			
	if(!Vista7)
	{
		GuiControl, 1:disable, HKFolderBand
		GuiControl, 1:disable, HKCleanFolderBand
		GuiControl, 1:disable, FolderBandDescription
	}
	GuiControl, 1:,HKFolderBand,%HKFolderBand%
	GuiControl, 1:,HKCleanFolderBand,%HKCleanFolderBand%
	GuiControl, 1:,HKPlacesBar,%HKPlacesBar%
	GuiControl, 1:,HKFFMenu,%HKFFMenu%
	GuiControl, 1:,Use Fast Folders,%HKFastFolders%
	GoSub FastFolders
}
Settings_SetupTabs() {
	global
	GuiControl, 1:Choose, NewTabPosition, %NewTabPosition%
	GuiControl, 1:Choose, OnTabClose, %OnTabClose%
	GuiControl, 1:,UseTabs,%UseTabs%
	GoSub UseTabs
	GuiControl, 1:,ActivateTab,%ActivateTab%
	GuiControl, 1:,TabWindowClose,%TabWindowClose%
	if(MiddleOpenFolder>0)
		GuiControl, 1:,OpenFolderInNew,1
	else
		GuiControl, 1:,OpenFolderInNew,0
	GoSub OpenFolderInNew
	local x:=max(MiddleOpenFolder,1)	
	GuiControl, 1:Choose, MiddleOpenFolder, %x%
}
Settings_SetupWindowHandling() {
	global
	GuiControl, 1:,HKTitleClose,%HKTitleClose%
	GuiControl, 1:,HKToggleAlwaysOnTop,%HKToggleAlwaysOnTop%
	GuiControl, 1:,HKKillWindows,%HKKillWindows%
	GuiControl, 1:,HKSlideWindows,%HKSlideWindows%
	GuiControl, 1:,SlideWinHide,%SlideWinHide%	
	GuiControl, 1:,HKFlashWindow,%HKFlashWindow%
	GuiControl, 1:,HKToggleWindows,%HKToggleWindows%
	GuiControl, 1:,HKAltDrag,%HKAltDrag%	
	GuiControl, 1:,HKAltMinMax,%HKAltMinMax%	
	GuiControl, 1:,HKTrayMin,%HKTrayMin%	
	GuiControl, 1:, AeroFlipTime, %AeroFlipTime%
	;Setup Aero Flip 3D
	temp:=(AeroFlipTime>=0)
	GuiControl, 1:,Mouse in upper left corner: Toggle Aero Flip 3D,%temp%
	if(!temp)
		GuiControl, 1:, AeroFlipTime, 0
	GoSub Flip3D
}
Settings_SetupDesktopTaskBar() {
	global
	local temp
	;Setup taskbar launch
	temp:=(TaskbarLaunchPath!="")
	GuiControl, 1:,Double click on empty taskbar: Run,%temp%
	GuiControl, 1:, TaskbarLaunchPath, %TaskbarLaunchPath%
	GoSub TaskbarLaunch
	
		
	if(A_OsVersion!="WIN_7")
	{
		GuiControl, 1:disable, HKActivateBehavior
		GuiControl, 1:disable, HKToggleWallpaper
	}
	/*
	if(!Vista7)
	{
		GuiControl, 1:disable, AeroFlipTime
		GuiControl, 1:disable, Mouse in upper left corner: Toggle Aero Flip 3D (Vista/7 only)
		GuiControl, 1:disable, Seconds in corner:
	}
	*/
	GuiControl, 1:,HKTaskbarLaunch,%HKTaskbarLaunch%
	GuiControl, 1:,HKMiddleClose,%HKMiddleClose%
	RegRead, HKActivateBehavior, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, LastActiveClick
	GuiControl, 1:,HKActivateBehavior,%HKActivateBehavior%
	GuiControl, 1:,HKToggleWallpaper,%HKToggleWallpaper%
	temp:=(DoubleClickDesktop !=0 && DoubleClickDesktop != "")
	GuiControl, 1:, DoubleClickDesktop, %temp%
	if(temp)
		GuiControl, 1:, DoubleClickDesktopPath, %DoubleClickDesktop%
	else
		GuiControl, 1:, DoubleClickDesktopPath,
	GoSub DoubleClickDesktop
}
Settings_SetupCustomHotkeys() {
	global
	local filter
	Settings_CustomHotkeys := Array()
	Settings_CustomHotkeys_Filters := Array()
	GuiControl, 1:, CustomHotkeysFilter,|
	Loop % CustomHotkeys.len()
	{
		Settings_CustomHotkeys.Append(Object("key", CustomHotkeys[A_Index].key, "command", CustomHotkeys[A_Index].command, "filter", CustomHotkeys[A_Index].filter))
		outputdebug("hotkeys: " CustomHotkeys[A_Index].key " " CustomHotkeys[A_Index].command " " CustomHotkeys[A_Index].filter " settings: " Settings_CustomHotkeys.key " " Settings_CustomHotkeys.command " " Settings_CustomHotkeys.filter)
		filter := CustomHotkeys[A_Index].filter
		if(filter && !Settings_CustomHotkeys_Filters.Contains(filter))
		{
			outputdebug new filter %filter%
			if(Settings_CustomHotkeys_Filters.len() = 0)
			{
				GuiControl, 1:, CustomHotkeysFilter, %filter%||
				SelectedHotkeyFilter := filter
			}
			else
				GuiControl, 1:, CustomHotkeysFilter, %filter%
			Settings_CustomHotkeys_Filters.Append(filter)
		}
	}
	GuiControl, 1:, CustomHotkeysFilter
	GuiControl, 1:, CustomHotkeysGlobal, 1
	;GoSub CustomHotkeysGlobal
	
	GuiControl, 1:disable, CustomHotkeysFilter
	GuiControl, 1:disable, CustomHotkeysFilterBrowse
	GuiControl, 1:enable, CustomHotkeysList
	GuiControl, 1:enable, CustomHotkeysAdd
	GuiControl, 1:enable, CustomHotkeysRemove
	GuiControl, 1:enable, CustomHotkeysEditKey
	GuiControl, 1:enable, CustomHotkeysCommand
	GuiControl, 1:enable, CustomHotkeysEditCommand
	CustomHotkeysGlobal:=1
	CustomHotkeys_ApplyFilter("")
}
Settings_SetupFTP() {
	global
	;Setup FTP
	GuiControl, 1:, FTP_Host, %FTP_Host%
	GuiControl, 1:, FTP_PORT, %FTP_PORT%
	GuiControl, 1:, FTP_Username, %FTP_Username%
	GuiControl, 1:, FTP_Password, %FTP_Password%
	GuiControl, 1:, FTP_Path, %FTP_Path%
	GuiControl, 1:, FTP_URL, %FTP_URL%
	GuiControl, 1:,Use FTP,%FTP_Enabled%
	GoSub FTP
}
Settings_SetupMisc() {
	global
	local temp, Autorun
	GuiControl, 1:, ImageQuality, %ImageQuality%
	GuiControl, 1:, ImageExtension, %ImageExtension%
	GuiControl, 1:, FullscreenInclude, %FullscreenInclude%
	GuiControl, 1:, FullscreenExclude, %FullscreenExclude%
	GuiControl, 1:,HKImproveConsole,%HKImproveConsole%		
	GuiControl, 1:,HKPhotoViewer,%HKPhotoViewer%	
	GuiControl, 1:,JoyControl,%JoyControl%
	GuiControl, 1:,ClipboardManager,%ClipboardManager%
	GuiControl, 1:,WordDelete,%WordDelete%
	GuiControl, 1:,HideTrayIcon,%HideTrayIcon%
	GuiControl, 1:,AutoUpdate,%AutoUpdate%
	;Figure out if Autorun is enabled
	RegRead, Autorun, HKCU, Software\Microsoft\Windows\CurrentVersion\Run , 7plus
	temp:=Autorun != ""
	GuiControl, 1:, Autorun,%temp%
}
Settings_SetupAbout() {
	global
	
}

AddTab(IconNumber, TabName, TabControl) {
   Gui 1: +LastFound
   VarSetCapacity(TCITEM, 100, 0)
	 NumPut(3, TCITEM ,0) ; Mask (3) comes from TCIF_TEXT(1) + TCIF_IMAGE(2).
	 NumPut(&TabName, TCITEM ,12) ; pszText
	 NumPut(IconNumber - 1, TCITEM ,20) ; iImage: -1 to convert to zero-based.
   SendMessage, 0x1307, 999, &TCITEM, %TabControl%  ; 0x1307 is TCM_INSERTITEM
}
listbox:
GuiControlGet,selected,1:,MyListBox
outputdebug listbox %selected%
Loop, Parse, TabList, |
{
	StringReplace, stripped, A_LoopField, %A_Space% , , 1
	StringReplace, stripped, stripped, / , , 1
	stripped .= "Tab"
	If (selected = A_LoopField)
	{
		outputdebug show %stripped%
		GuiControl, 1:Show, %stripped%
		GuiControl, 1:Text, GGroupBox, %A_LoopField%
		test:=stripped
	}
	else 
	{
		outputdebug hide %stripped%
		GuiControl, 1:Hide, %stripped%
	}
}
GuiControl, 1:MoveDraw, MyListBox
GuiControl, 1:Movedraw, GGroupbox
GuiControl, 1:Movedraw, %test%
GuiControl, 1:MoveDraw, BtnOK
GuiControl, 1:MoveDraw, BtnCancel
GuiControl, 1:MoveDraw, TutLabel
GuiControl, 1:MoveDraw, Wait
return

ShowSettings()
{
	global
	local x,y,yIt,x1,x2
	Critical, Off
	if(!SettingsActive)
	{
		SettingsActive:=True
		;---------------------------------------------------------------------------------------------------------------
		; Create GUI
		;---------------------------------------------------------------------------------------------------------------
		Gui, 1:Default
		Gui, 1:+OwnDialogs
		if(!SettingsInitialized)
		{
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
			TabList = Events|Explorer Hotkeys|Explorer Behavior|Fast Folders|Explorer Tabs|Window Handling|Desktop / Taskbar|Custom Hotkeys|FTP|Misc|About 
			Gui, 1:Add, ListBox, x16 y20 w120 h350 gListbox vMyListBox, %TabList%
			Gui, 1:Add, GroupBox, x156 y14 w530 h350 vGGroupBox , Explorer Hotkeys  
			/*
			Gui, 1:Add, Treeview, x0 y0 w120 h540 vTree gTree -Lines -Buttons -HScroll
			
			TV_Explorer:=TV_Add("Explorer","","Expand")
			TV_ExplorerHotkeys:=TV_Add("Hotkeys",TV_Explorer,"Select")
			TV_ExplorerBehavior:=TV_Add("Behavior",TV_Explorer)
			TV_ExplorerFastFolders:=TV_Add("Fast Folders",TV_Explorer)
			TV_WindowHandling:=TV_Add("Window handling","","Expand")
			TV_WindowHandling1:=TV_Add("Window handling 1",TV_WindowHandling)
			TV_WindowHandling1:=TV_Add("Window handling 2",TV_WindowHandling)
			TV_FTP:=TV_Add("FTP","","Expand")
			TV_Misc:=TV_Add("Misc","","Expand")
			TV_About:=TV_Add("About","","Expand")
			*/
			Gui, 1:Add, Button, x606 y370 w80 h23 vBtnOK gCancel, Cancel
			Gui, 1:Add, Button, x526 y370 w70 h23 vBtnCancel gOK, OK
			Gui, 1:Add, Text, x16 y375 vTutLabel, Click on ? to see video tutorial help!
			Gui, 1:Add, Text, y375 x370 vWait, Applying settings, please wait!
			Settings_CreateEvents()
			Settings_CreateHotkeys()
			Settings_CreateBehavior()
			Settings_CreateFastFolders()
			Settings_CreateTabs()
			Settings_CreateWindowHandling()
			Settings_CreateDesktopTaskBar()
			Settings_CreateCustomHotkeys()
			Settings_CreateFTP()
			Settings_CreateMisc()
			Settings_CreateAbout()			
			SettingsInitialized := true
		}
		GuiControl, 1:Hide, Wait
		GuiControl, 1:Choose,MyListBox,Events
		GoSub ListBox
		Gui, 1:Show, x338 y159 h404 w700, 7plus Settings
		Winwaitactive 7plus Settings		
				
		;---------------------------------------------------------------------------------------------------------------
		; Setup Control Status
		;---------------------------------------------------------------------------------------------------------------
		Settings_SetupEvents()
		Settings_SetupHotkeys()
		Settings_SetupBehavior()
		Settings_SetupFastFolders()
		Settings_SetupTabs()
		Settings_SetupWindowHandling()
		Settings_SetupDesktopTaskBar()
		Settings_SetupCustomHotkeys()
		Settings_SetupFTP()
		Settings_SetupMisc()
		Settings_SetupAbout()
			
		;Code for URL hand cursor, don't touch :D
		;Hand cursor over controls where the assigned variable starts with URL_
		; Retrieve scripts PID 
		Process, Exist 
		pid_this := ErrorLevel 

		; Retrieve unique ID number (HWND/handle) 
		WinGet, hw_Gui, ID, ahk_class AutoHotkeyGUI ahk_pid %pid_this% 

		; Call "HandleMessage" when script receives WM_SETCURSOR message 
		WM_SETCURSOR = 0x20 
		OnMessage(WM_SETCURSOR, "HandleMessage") 

		; Call "HandleMessage" when script receives WM_MOUSEMOVE message 
		WM_MOUSEMOVE = 0x200 
		OnMessage(WM_MOUSEMOVE, "HandleMessage")
	  
	}
	Return
}

;---------------------------------------------------------------------------------------------------------------
; Control Handlers
;---------------------------------------------------------------------------------------------------------------
GUI_EventsList_SelectionChange:
Return
GUI_EventsList_Add:
GUI_AddEvent()
Return
GUI_AddEvent()
{
	global Settings_Events, GUI_EventsList
	Gui, ListView, GUI_EventsList
	Event := EventSystem_CreateEvent(Settings_Events)
	LV_Add("", Event.ID, Event.Trigger.DisplayString(), Event.Name)
}
GUI_EventsList_Remove:
GUI_RemoveEvent()
Return
GUI_RemoveEvent()
{
	i:=LV_GetNext("")
	
}

GUI_EventsList_Edit:
Return
GUI_EventsLisit_Help:
Return

txt:
GuiControlGet, enabled ,1: , Paste text as file
GuiControl, 1:enable%enabled%,TxtName
Return

img:
GuiControlGet, enabled ,1: , Paste image as file
GuiControl, 1:enable%enabled%,ImgName
Return

Editor:
GuiControlGet, enabled ,1: , F3: Open selected files in text/image editor
GuiControl, 1:enable%enabled%,TextEditor
GuiControl, 1:enable%enabled%,ImageEditor
GuiControl, 1:enable%enabled%,Button5
GuiControl, 1:enable%enabled%,Button6
Return

TextBrowse:
Gui 1:+OwnDialogs
FileSelectFile, editorpath , 3, , Select text editor executable, *.exe
if !ErrorLevel
	GuiControl, 1:,TextEditor,%editorpath%
Return

ImageBrowse:
Gui 1:+OwnDialogs
FileSelectFile, imagepath , 3, , Select image editor executable, *.exe
if !ErrorLevel
	GuiControl, 1:,ImageEditor,%imagepath%
Return

FastFolders:
GuiControlGet, enabled ,1: , Use Fast Folders
GuiControl, 1:enable%enabled%, HKPlacesBar
GuiControl, 1:enable%enabled%, HKFFMenu
if(enabled)
{
	GuiControl, 1:enable%Vista7%, HKFolderBand
	GuiControl, 1:enable%Vista7%, HKCleanFolderBand
}
else
{
	GuiControl, 1:disable, HKFolderBand
	GuiControl, 1:disable, HKCleanFolderBand
}
Return

UseTabs:
GuiControlGet, enabled ,1: , UseTabs
GuiControl, 1:enable%enabled%, NewTabPosition
GuiControl, 1:enable%enabled%, TabStartupPath
GuiControl, 1:enable%enabled%, ActivateTab
GuiControl, 1:enable%enabled%, TabWindowClose
GuiControl, 1:enable%enabled%, OnTabClose
GuiControl, 1:enable%enabled%, ShowSingleTab
GuiControl, 1:enable%enabled%, TabStartupPathBrowse
GuiControl, 1:enable%enabled%, TabLabel1
GuiControl, 1:enable%enabled%, TabLabel2
GuiControl, 1:enable%enabled%, TabLabel3
GuiControl, 1:enable%enabled%, MiddleOpenFolder
GuiControl, 1:enable%enabled%, OpenFolderInNew
Return

OpenFolderInNew:
GuiControlGet, enabled ,1: , OpenFolderInNew
GuiControl, 1:enable%enabled%, MiddleOpenFolder
return

TabStartupPathBrowse:
Gui 1:+OwnDialogs
path:=COM_CreateObject("Shell.Application").BrowseForFolder(0, "Enter Path to add as button", 0).Self.Path
if(path!="")
	GuiControl, , 1:TabStartupPath,%path%
return

TaskbarLaunch:
GuiControlGet, enabled ,1: , Double click on empty taskbar: Run
GuiControl, 1:enable%enabled%,TaskbarLaunchPath
GuiControl, 1:enable%enabled%,TaskbarLaunchPathBrowse
Return

TaskbarLaunchBrowse:
Gui 1:+OwnDialogs
FileSelectFile, TaskbarPath , 3, , Select taskbar executable, *.exe
if !ErrorLevel
{
	if(InStr(TaskbarPath," "))
		TaskbarPath:=Quote(TaskbarPath)
	GuiControl, 1:,TaskbarLaunchPath,%TaskbarPath%
}
Return

Flip3D:
GuiControlGet, enabled ,1: ,Mouse in upper left corner: Toggle Aero Flip 3D
GuiControl, 1:enable%enabled%, AeroFlipTime
if(enabled)
{
	GuiControlGet, flip ,1: ,AeroFlipTime
	if(flip<0||flip="")
		flip=0
	GuiControl, 1:,AeroFlipTime,%flip%
}
return

SlideWindow:
GuiControlGet, enabled,1: , HKSlideWindows
GuiControl, 1:enable%enabled%, SlideWinHide
return

DoubleClickDesktop:
GuiControlGet, enabled ,1: ,DoubleClickDesktop
GuiControl, 1:enable%enabled%, DoubleClickDesktopPath
GuiControl, 1:enable%enabled%, DoubleClickDesktopBrowse
return

DoubleClickDesktopBrowse:
Gui 1:+OwnDialogs
FileSelectFile, path , 3, , Select file to execute, *.exe
if(path!="")
	GuiControl, 1:,DoubleClickDesktop,%path%
Return

AddHotkey:
Gui, ListView, CustomHotkeysList
LV_Add("Select","","")
GoSub EditHotkey
if(key)
	GoSub EditCommand
if(key="" || path="")
{
	i:=LV_GetNext("")
	LV_Delete(i)
}
return

RemoveHotkey:
Gui, ListView, CustomHotkeysList
i:=LV_GetNext("")
LV_Delete(i)
return

EditHotkey:
Gui, ListView, CustomHotkeysList
Critical, Off
i:=LV_GetNext("")
key:=HotKeyGui(10,1, "Select Hotkey", 1,"","","",key)
if(key)
	LV_Modify(i,"Col1",key)	
return

EditCommand:
Gui 1:+OwnDialogs
FileSelectFile, path , 3, , Select hotkey command, *.exe
if(path!="")
{
	path:=Quote(path)
	GuiControl, 1:,CustomHotkeysCommand, %path%
}
return

CustomHotkeysList_SelectionChange:
Gui, ListView, CustomHotkeysList
if(A_GuiEvent="I" && InStr(ErrorLevel, "S", true))
{
	LV_GetText(CustomHotkeysCommand, A_EventInfo , 2)
	GuiControl, 1:,CustomHotkeysCommand, %CustomHotkeysCommand%
	GuiControl, 1:enable, CustomHotkeysCommand
	GuiControl, 1:enable, CustomHotkeysEditCommand
	GuiControl, 1:enable, CustomHotkeysRemove
	GuiControl, 1:enable, CustomHotkeysEditKey
}
else if(A_GuiEvent="I" && InStr(ErrorLevel, "s", true))
{
	GuiControl, 1:disable, CustomHotkeysCommand
	GuiControl, 1:disable, CustomHotkeysEditCommand
	GuiControl, 1:disable, CustomHotkeysRemove
	GuiControl, 1:disable, CustomHotkeysEditKey
	outputdebug pre clearing
	GuiControl, 1:,CustomHotkeysCommand, %A_Space%
	outputdebug post clearing
}
else if(A_GuiEvent="DoubleClick")
	GoSub EditHotkey
Return

WM_KEYDOWN(wParam, lParam)
{
	if(A_GUI = 1 && A_GuiControl = "CustomHotkeysList" && wParam = 0x2E) ;Delete key pressed on CustomHotkeysList
	{
		Gui, ListView, CustomHotkeysList
		i:=LV_GetNext("")
		LV_Delete(i)
	}
}

CustomHotkeysCommand_Change:
Gui, ListView, CustomHotkeysList
i:=LV_GetNext("")
if(i!=0)
{
	GuiControlGet, CustomHotkeysCommand ,1: , %CustomHotkeysCommand%
	LV_Modify(i,"Col2",CustomHotkeysCommand)
}
Return

CustomHotkeysGlobal:
outputdebug custom hotkeys global clicked
;save to settings hotkey list, then apply filter in listview
GuiControl, 1:disable, CustomHotkeysFilter
GuiControl, 1:disable, CustomHotkeysFilterBrowse
GuiControl, 1:enable, CustomHotkeysList
GuiControl, 1:enable, CustomHotkeysAdd
GuiControl, 1:enable, CustomHotkeysRemove
GuiControl, 1:enable, CustomHotkeysEditKey
GuiControl, 1:enable, CustomHotkeysCommand
GuiControl, 1:enable, CustomHotkeysEditCommand
GuiControlGet, SelectedHotkeyFilter, 1:, CustomHotkeysFilter
if(SelectedHotkeyFilter!="")
	CustomHotkeys_SaveCurrentView()
CustomHotkeys_ApplyFilter("")
CustomHotkeysGlobal:=1
return

CustomHotkeysSpecific:
Gui, ListView, CustomHotkeysList
GuiControl, 1:enable, CustomHotkeysFilter
GuiControl, 1:enable, CustomHotkeysFilterBrowse
CustomHotkeys_SaveCurrentView()
GuiControlGet, SelectedHotkeyFilter, 1:, CustomHotkeysFilter
outputdebug specific filter: %SelectedHotkeyFilter%
LV_Delete()
if(SelectedHotkeyFilter)
{
	CustomHotkeys_ApplyFilter(SelectedHotkeyFilter)
}
Else
{
	GuiControl, 1:disable, CustomHotkeysList
	GuiControl, 1:disable, CustomHotkeysAdd
	GuiControl, 1:disable, CustomHotkeysRemove
	GuiControl, 1:disable, CustomHotkeysEditKey
	GuiControl, 1:disable, CustomHotkeysCommand
	GuiControl, 1:disable, CustomHotkeysEditCommand
}
CustomHotkeysGlobal:=0
return

CustomHotkeysFilterBrowse:
Gui 1:+OwnDialogs
FileSelectFile, path , 3, , Select program for program-specific hotkeys, *.exe
SplitPath,path,path
if(!Settings_CustomHotkeys_Filters.Contains(path))
{
	Settings_CustomHotkeys_Filters.Append(path)
	CustomHotkeys_SaveCurrentView()
	GuiControl, 1:, CustomHotkeysFilter, %path%||
	SelectedHotkeyFilter := path
	CustomHotkeys_ApplyFilter(path)
	GuiControl, 1:enable, CustomHotkeysList
	GuiControl, 1:enable, CustomHotkeysAdd
	GuiControl, 1:enable, CustomHotkeysRemove
	GuiControl, 1:enable, CustomHotkeysEditKey
	GuiControl, 1:enable, CustomHotkeysCommand
	GuiControl, 1:enable, CustomHotkeysEditCommand
}
Return

CustomHotkeysFilter:
CustomHotkeys_SaveCurrentView()
PrintHotkeys()
outputdebug change from %SelectedHotkeyFilter%
GuiControlGet, SelectedHotkeyFilter, 1:, CustomHotkeysFilter
outputdebug to %SelectedHotkeyFilter%
CustomHotkeys_ApplyFilter(SelectedHotkeyFilter)
PrintHotkeys()
return

CustomHotkeyHelp:
MsgBox,0x2000, Custom Hotkeys Help, You can define global hotkeys, aswell as hotkeys that are application-specific. Those are only triggered when the selected program is active. You can also use placeholders in command arguments. Supported placeholders:`n`nAny window:`n${T} : Filepath+Filename extracted from current window title`n`nExplorer:`n${P} : Current path of the active explorer window`n${1}...${n} : n-th selected file, enclosed in " "`n${N} : All selected files, separated by spaces`n`nHint: If you have Autohotkey (or any other scripting language) installed, you can also launch your own scripts from here!
return
CustomHotkeys_ApplyFilter(filter) {
	global
	Gui, ListView, CustomHotkeysList
	LV_Delete()
	Loop % Settings_CustomHotkeys.len()
	{
		if(Settings_CustomHotkeys[A_Index].filter = filter)
			LV_Add("",Settings_CustomHotkeys[A_Index].key,Settings_CustomHotkeys[A_Index].command)
	}
	LV_Modify(1, "Select")
}

CustomHotkeys_SaveCurrentView() {
	global
	local count, key, i
	Gui, ListView, CustomHotkeysList
	;GuiControlGet, filter, 1:, CustomHotkeysFilter
	if(SelectedHotkeyFilter = "" && !CustomHotkeysGlobal) ;Don't save on unfilled dropdownlist
		return
	if(CustomHotkeysGlobal)
		SelectedHotkeyFilter:=""
	outputdebug save current view filter %filter%
	i:=1
	;Delete all previous entries from this filter
	Loop % Settings_CustomHotkeys.len()
	{
		if(Settings_CustomHotkeys[i].filter = SelectedHotkeyFilter)
		{
			outputdebug("remove: " Settings_CustomHotkeys[A_Index].key " " Settings_CustomHotkeys[A_Index].command " " Settings_CustomHotkeys[A_Index].filter)
			key := Settings_CustomHotkeys[i].key
			outputdebug delete key %key%
			Settings_CustomHotkeys.Delete(i)
			continue
		}
		i++
	}
	;Now add all hotkeys from listview
	count := LV_GetCount()
	outputdebug #hotkeys in listview: %count%
	Loop % count
	{
		LV_GetText(key,A_Index,1)
		LV_GetText(command,A_Index,2)
		outputdebug add key %key% command %command% filter %filter%
		if(key!="" && command != "")
			Settings_CustomHotkeys.Append(Object("key",key,"command",command,"filter",SelectedHotkeyFilter))
	}
}

FTP:
GuiControlGet, enabled ,1: ,Use FTP
GuiControl, 1:enable%enabled%, FTP_Host
GuiControl, 1:enable%enabled%, FTP_Username
GuiControl, 1:enable%enabled%, FTP_Password
GuiControl, 1:enable%enabled%, FTP_Port
GuiControl, 1:enable%enabled%, FTP_Path
GuiControl, 1:enable%enabled%, FTP_URL
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
hExplorer1dot1:
run http://www.youtube.com/watch?v=xKmWOEbMI1Q
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
hTabs:
msgbox not recorded yet
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
hWindow1dot1:
run http://www.youtube.com/watch?v=1vutsoA3j7Y
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
hWordDelete:
msgbox not recorded yet
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
GuiControlGet, active ,1: , Use Fast Folders
HKFastFolders:=active
GuiControl, 1:Show, Wait
GuiControl, 1:MoveDraw, Wait
changed:=false
GuiControlGet, active ,1: , HKFolderBand
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

GuiControlGet, active ,1: , HKCleanFolderBand
if(active && HKFastFolders && (!HKCleanFolderBand || !wasactive))
{
	BackupAndRemoveFolderBandButtons()
}
else if(HKCleanFolderBand && ((wasActive && !HKFastFolders) || !active))
{
	RestoreFolderBandButtons()
}
		
GuiControlGet, active ,1: , HKPlacesBar
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
Gui 1:Submit

if(JoyControl)
	JoystickStart()
else
	JoystickStop()
	
;Store paste text as file filename
GuiControlGet, txtenabled ,1: , Paste text as file
GuiControlGet, pastename ,1: , TxtName
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

;Store paste image as file filename
GuiControlGet, imgenabled ,1: , Paste image as file
GuiControlGet, pastename ,1: , ImgName
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
GuiControlGet, editorenabled ,1: , F3: Open selected files in text/image editor
GuiControlGet, editorpath ,1: , TextEditor
if editorenabled
{
	TextEditor:=editorpath
}
else
{
	TextEditor:=""
}

;Store image editor filename
GuiControlGet, imageeditorpath ,1: , ImageEditor
if editorenabled
{
	ImageEditor:=imageeditorpath
}
else
{
	ImageEditor:=""
}

;Store MiddleOpenFolder
GuiControlGet, enabled, 1: , OpenFolderInNew
if(!enabled)
	MiddleOpenFolder:=0

;Store taskbar launch filename
GuiControlGet, enabled ,1: , Double click on empty taskbar: Run
GuiControlGet, path ,1: , TaskbarLaunchPath
if enabled
{
	TaskbarLaunchPath:=path
}
else
{
	TaskbarLaunchPath:=""
}

;Store Aero Flip time
GuiControlGet, flip,1:,Mouse in upper left corner: Toggle Aero Flip 3D
if(flip&&Vista7)
	SetTimer, hovercheck, 10
else
{
	AeroFlipTime:=-1
	SetTimer, hovercheck, Off
}

;Store double click desktop
GuiControlGet, enabled, 1:, DoubleClickDesktop
if(!enabled)
	DoubleClickDesktop:=0
else
	GuiControlGet, DoubleClickDesktop, 1:, DoubleClickDesktopPath
;Store custom hotkeys
CustomHotkeys_SaveCurrentView()
RemoveAllHotkeys()
Loop % Settings_CustomHotkeys.len()
{
	AddHotkey(Settings_CustomHotkeys[A_Index].key, Settings_CustomHotkeys[A_Index].command, Settings_CustomHotkeys[A_Index].filter)
}
Settings_CustomHotkeys := Array()

;UnSlide hidden windows
if(!HKSlideWindows)
	SlideWindows_Exit()

;Store FTP Settings
GuiControlGet, FTP_Enabled,1: ,Use FTP
if(FTP_Password!=temp)
{
	outputdebug ftp password changed from %temp% to %FTP_Password%, encrypt it
	FTP_Password:=Encrypt(FTP_Password)
	outputdebug after encryption: %ftp_password%
}
ValidateFTPVars()

;Store Autorun setting
if(Autorun)
{
	if(A_IsCompiled)
		RegWrite, REG_SZ, HKCU, Software\Microsoft\Windows\CurrentVersion\Run , 7plus, "%A_ScriptDir%\UACAutorun.exe"
	else
		RegWrite, REG_SZ, HKCU, Software\Microsoft\Windows\CurrentVersion\Run , 7plus, "%A_ScriptDir%\UACAutorun.ahk"
}
else
	RegDelete, HKCU, Software\Microsoft\Windows\CurrentVersion\Run, 7plus

RegRead, temp, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, LastActiveClick
RegWrite, REG_SZ, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, LastActiveClick, %HKActivateBehavior%
if(temp!=HKActivateBehavior)
{
	MsgBox, 4, Restart Explorer, You need to restart explorer to apply a setting. Do you want to do this now?
	IfMsgBox Yes
	{
		Runwait, taskkill /im explorer.exe /f, , Hide
		Run, %a_windir%\explorer.exe
		;Process, close,explorer.exe
		/*
		Send {CTRL down}{ESC}{CTRL up}
		WinWaitActive ahk_class DV2ControlHost
		Send {Right}
		Send {CTRL down}{SHIFT down}{AppsKey}
		while(!IsContextMenuActive())
		{
			Sleep 10
		}
		Send {CTRL up}{Shift up}{Up}
		Send {Enter}
		Sleep 500
		Run %a_windir%\explorer.exe
		*/
	}
}
if(HideTrayIcon)
{
	MsgBox You have chosen to hide the tray icon. This means that you will only be able to access the settings dialog by pressing WIN + H. Also, the program can only be ended by using the task manager then.
	Menu, Tray, NoIcon
}
else
	Menu, Tray, Icon
WriteIni()
SettingsActive:=False
Gui 1:Cancel
Return

GuiEscape:
Cancel:
GuiClose:
SettingsActive:=False
Settings_CustomHotkeys := ""
Gui 1:Cancel
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
              Gui, 1:Font, cBlue underline 
              GuiControl, 1:Font, %A_GuiControl% 
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
              Gui, 1:Font, norm cBlue 
              GuiControl, 1:Font, %LastCtrl% 
              
              DllCall("SetCursor", "uint", h_old_cursor) 
              
              URL_hover= 
            } 
        } 
    } 
}

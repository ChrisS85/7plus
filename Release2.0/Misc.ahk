/*
;CMD Improvements
#if HKImproveConsole
#c::
dir:=GetCurrentFolder()
outputdebug dir %dir%
if(dir)
	Run "cmd.exe", %dir%
else
	Run "cmd.exe", C:\
return
#if

;windows picture viewer image rotation r and l hotkeys
#if HKPhotoViewer && WinActive("ahk_class Photo_Lightweight_Viewer")
r::^.
l::^,
#if
*/
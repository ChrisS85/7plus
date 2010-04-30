;Some first run intro
wizardry:
MsgBox, 4,,Welcome to the ultimate windows tweaking experience!`nBefore we begin, would you like to see a list of features?	
IfMsgBox Yes
	run http://code.google.com/p/7plus/wiki/Features
MsgBox, 4,,At the beginning, you should configure the settings and activate/deactivate the features to your liking. You can access the settings menu later through the tray icon or by pressing CTRL+H. Do you want to open the settings window now?
IfMsgBox Yes
	ShowSettings()
while(WinExist("7plus Settings"))
	Sleep 100
return

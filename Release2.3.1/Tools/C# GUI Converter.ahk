#include <CGUI>
Class ConverterGUI extends CGUI
{
	__New()
	{
		global CFileDialog
		this.Add("Edit", "EditPath", "x10", "")
		this.Add("Button", "BtnBrowse", "x+10", "Browse")
		this.Add("Edit", "EditSavePath", "x10 y+10", "")
		this.Add("Button", "BtnSaveBrowse", "x+10", "Browse")
		this.Add("Button", "BtnConvert", "x10 y+10", "Convert")
		this.FileDialog := new CFileDialog()
	}
	BtnBrowse_ButtonClicked()
	{
		this.FileDialog.Mode := "Open"
		if(this.FileDialog.Show())
			this.EditPath.Text := this.FileDialog.Filename
	}
	BtnSaveBrowse_ButtonClicked()
	{
		this.FileDialog.Mode := "Save"
		if(this.FileDialog.Show())
			this.EditSavePath.Text := this.FileDialog.Filename
	}
	BtnConvert_ButtonClicked()
	{
		
	}
}
ConverterGUI_BtnBrowse:
ConverterGUI_BtnSaveBrowse:
ConverterGUI_BtnConvert:
CGUI.HandleEvent()
return
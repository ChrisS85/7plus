gui := new CSharpGuiConverter()
#include <CGUI>
Class CSharpGuiConverter Extends CGUI
{
	__New()
	{
		this.Add("Text", "label1", "x12 y15 w53 h13", "Input File:")
		Base.__New()
		
		this.Add("Edit", "txtInput", "x71 y14 w274 h20", "")
		
		this.Add("Button", "btnInput", "x351 y12 w36 h23", "...")
		
		this.Add("Text", "label2", "x12 y41 w61 h13", "Output File:")
		
		this.Add("Edit", "txtOutput", "x71 y40 w274 h20", "")
		
		this.Add("Button", "btnOutput", "x351 y38 w36 h23", "...")
		
		this.Add("Button", "btnConvert", "x15 y66 w120 h23", "Convert")
		this.btnConvert.Enabled := 0
		
		this.Add("Button", "btnRun", "x141 y66 w120 h23", "Run Converted File")
		this.btnRun.Enabled := 0
		
		this.Add("Button", "btnEdit", "x267 y66 w120 h23", "Edit Converted File")
		this.btnEdit.Enabled := 0
		
		this.height := 99
		this.Title := "C# GUI Converter"
		this.Width := 401
		this.Show()
	}
	btnInput_Click()
	{
		
	}
	btnOutput_Click()
	{
		
	}
	btnConvert_Click()
	{
		
	}
	btnRun_Click()
	{
		
	}
	btnEdit_Click()
	{
		
	}
}
CSharpGuiConverter_btnInput:
CSharpGuiConverter_btnOutput:
CSharpGuiConverter_btnConvert:
CSharpGuiConverter_btnRun:
CSharpGuiConverter_btnEdit:
CGUI.HandleEvent()
return
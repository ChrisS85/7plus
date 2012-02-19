Class CSendMailAction Extends CAction
{
	static Type := RegisterType(CSendMailAction, "Send an email")
	static Category := RegisterCategory(CSendMailAction, "System")
	
	static From     := "...@gmail.com"
	static To       := "anybody@somewhere.com"
	static Subject  := "Message Subject"
	static Body     := "Message Body"
	static Attach   := "Path_Of_Attachment" ; can add multiple attachments, the delimiter is |
	static Server   := "smtp.gmail.com" ; specify your SMTP server
	static Port     := 465 ; 25
	static TLS      := True ; False
	static Username := "...@gmail.com"
	static Password := ""
	static Timeout := 10
	
	Execute(Event)
	{
		Critical
		From     := Event.ExpandPlaceholders(this.From)
		To       := Event.ExpandPlaceholders(this.To)
		Subject  := Event.ExpandPlaceholders(this.Subject)
		Body     := Event.ExpandPlaceholders(this.Body)
		Attach   := Event.ExpandPlaceholders(this.Attach) ; can add multiple attachments, the delimiter is |

		Server   := Event.ExpandPlaceholders(this.Server) ; specify your SMTP server
		Port     := Event.ExpandPlaceholders(this.Port) ; 25
		TLS      := Event.ExpandPlaceholders(this.TLS) ; False
		Send     := 2   ; cdoSendUsingPort
		Auth     := 1   ; cdoBasic
		Username := Event.ExpandPlaceholders(this.Username)
		Password := Event.ExpandPlaceholders(Decrypt(this.Password))

		pmsg :=   ComObjCreate("CDO.Message")
		pcfg :=   pmsg.Configuration
		pfld :=   pcfg.Fields

		pfld.Item("http://schemas.microsoft.com/cdo/configuration/sendusing") := Send
		pfld.Item("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout") := this.Timeout
		pfld.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") := Server
		pfld.Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") := Port
		pfld.Item("http://schemas.microsoft.com/cdo/configuration/smtpusessl") := TLS
		pfld.Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") := Auth
		pfld.Item("http://schemas.microsoft.com/cdo/configuration/sendusername") := Username
		pfld.Item("http://schemas.microsoft.com/cdo/configuration/sendpassword") := Password
		pfld.Update()
		
		pmsg.From := From
		pmsg.To := To
		pmsg.Subject := Subject
		pmsg.TextBody := Body
		Loop, Parse, Attach, |, %A_Space%%A_Tab%
			pmsg.AddAttachment(A_LoopField)
		pmsg.Send()
		if(A_LastError)
			Msgbox % "Send mail error: " FormatMessageFromSystem(A_LastError)
		Critical, Off
		return 1
	} 

	DisplayString()
	{
		return "Send mail to " this.To
	}

	GuiShow(GUI, GoToLabel = "")
	{
		static sGUI
		if(GoToLabel = "")
		{
			sGUI := GUI
			this.Password := Decrypt(this.Password)
			this.AddControl(GUI, "Edit", "From", "", "", "From:", "Placeholders", "Action_SendMail_Placeholders_From")
			this.AddControl(GUI, "Edit", "To", "", "", "To:", "Placeholders", "Action_SendMail_Placeholders_To")
			this.AddControl(GUI, "Edit", "Subject", "", "", "Subject:", "Placeholders", "Action_SendMail_Placeholders_Subject")
			this.AddControl(GUI, "Edit", "Body", "", "", "Body:", "Placeholders", "Action_SendMail_Placeholders_Body")
			this.AddControl(GUI, "Edit", "Attach", "", "", "Attach:", "Browse", "Action_SendMail_Browse", "Placeholders", "Action_SendMail_Placeholders_Attach")
			this.AddControl(GUI, "Edit", "Server", "", "", "Server:", "Placeholders", "Action_SendMail_Placeholders_Server")
			this.AddControl(GUI, "Edit", "Port", "", "", "Port:", "Placeholders", "Action_SendMail_Placeholders_Port")
			this.AddControl(GUI, "Checkbox", "TLS", "TLS")
			this.AddControl(GUI, "Edit", "Username", "", "", "Username:", "Placeholders", "Action_SendMail_Placeholders_Username")
			this.AddControl(GUI, "Edit", "Password", "", "", "Password:", "Placeholders", "Action_SendMail_Placeholders_Password")
			this.AddControl(GUI, "Edit", "Timeout", "", "", "Timeout:")
		}
		else if(GoToLabel = "Browse")
			this.SelectFile(sGUI, "Attach")
		else if(InStr(GoToLabel, "Action_SendMail_Placeholders_") = 1)
			ShowPlaceholderMenu(sGUI, SubStr(GoToLabel, 30))
	}
	GuiSubmit(GUI)
	{
		Base.GuiSubmit(GUI)
		this.Password := Encrypt(this.Password)
	}
}
Action_SendMail_Browse:
GetCurrentSubEvent().GuiShow("", "Browse")
return

Action_SendMail_Placeholders_From:
Action_SendMail_Placeholders_To:
Action_SendMail_Placeholders_Subject:
Action_SendMail_Placeholders_Body:
Action_SendMail_Placeholders_Attach:
Action_SendMail_Placeholders_Server:
Action_SendMail_Placeholders_Port:
Action_SendMail_Placeholders_Username:
Action_SendMail_Placeholders_Password:
GetCurrentSubEvent().GuiShow("", A_ThisLabel)
return
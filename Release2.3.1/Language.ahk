LoadLanguage()
{
	global Language, IniPath, CLanguage
	IniRead, Language, %IniPath%, General, Language, En
	Languages := Array()
	Languages.append(new CLanguage("en", "English", ""))
	Languages.append(new CLanguage("fr", "Francais", "fr_"))
	Language := Object("CurrentLanguage", Languages.SubItem("ShortName", Language), "Languages", Languages)
	Language.CurrentLanguage.LoadLocalizedStrings()
}

class CLanguage
{
	__New(ShortName, FullName, WikiPrefix)
	{
		this.ShortName := ShortName
		this.FullName := FullName
		this.WikiPrefix := WikiPrefix
		this.Strings := Object()
	}
	LoadLocalizedStrings()
	{
	
	}	
	OpenWikiPage(Page, SkipTranslation=false)
	{
		run % "http://code.google.com/p/7plus/wiki/" (SkipTranslation ? "" : this.WikiPrefix) Page, UseErrorLevel
	}
}
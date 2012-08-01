/*
Class: CEnumerator
Generic enumerator object that can be used for dynamically generated array members. It requires that the object defines a MaxIndex() function.
To make an object iterable, make sure to define the MaxIndex() function and insert this function in the class definition:
|_NewEnum()
|{
|	return new CEnumerator(this)
|}
*/
Class CEnumerator
{
	__New(Object)
	{
		this.Object := Object
	}
	Next(byref key, byref value)
	{
		global debug
		if(debug)
			msgbox % "Next(" key ", " value ")`nClass: " this.Object.__Class "`nstart`nCallstack:`n" Callstack(20, 1)
		if(key = "")
		{
			key := this.Object.MinIndex()
			if(key = "")
				key := 1
		}
		else
			key++

		if(debug)
			msgbox % "Next(" key ", " value ") middle`nCallstack:`n" Callstack(20, 1)
		if(key <= this.Object.MaxIndex())
			value := this.Object[key]
		else
			key := ""

		if(debug)
			msgbox % "Next(" key ", " value ") end`nCallstack:`n" Callstack(20, 1)
		return key != ""
	}
}
/*
Class: CEnumerator
Generic enumerator object that can be used for dynamically generated array members.
It's possible to define custom MinIndex() and MaxIndex() functions for array boundaries.
If there are missing array members between min and max index, they will be iterated but will have a value of 0.
This means that real sparse arrays are not supported by this enumerator by design.
To make an object use this iterator, insert this function in the class definition:
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
		this.first := true
	}
	Next(byref key, byref value)
	{
		if(this.first)
		{
			this.Remove("first")
			key := this.Object.MinIndex()
			if(!ObjHasKey(this.Object, key))
				key := ""
		}
		else
			key++
		if(key <= this.Object.MaxIndex())
			value := ObjHasKey(this.Object, key) ? this.Object[key] : 0
		else
			key := ""
		return key != ""
	}
}
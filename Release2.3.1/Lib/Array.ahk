; Array Lib - temp01 - http://www.autohotkey.com/forum/viewtopic.php?t=49736 
; Modified by Fragman
; Array is 1-based!!!
#include <CEnumerator>
Array(Params*){ 
	return new CArray(Params*)
}
IsArray(obj)
{
	return IsObject(obj) && obj.Is(CArray)
}
Array_CompareFunc(a, b, c){ 
   return a > b ? 1 : a = b ? 0 : -1 
} 

Class CArray extends CRichObject
{
	__New(Params*)
	{
		for index, Param in Params
			this.Insert(Param)
	}
	_NewEnum()
	{
		return new CEnumerator(this)
	}
	InsertUnique(Params*)
	{
		if(Params.MaxIndex() && !this.IndexOf(Params[1]))
			this.Insert(Params*)
	}
	IndexOf(val, opts="", startpos=1)
	{
		if(IsObject(val))
		{
			for k, v in this
			  If ( k >= startpos && v = val )
				 Return, k
		}
		P := !!InStr(opts, "P"), C := !!InStr(opts, "C")
		If A := !!InStr(opts, "A")
			matches := Array()
		Loop % this.MaxIndex()
			If(A_Index>=startpos)
				If(match := InStr(this[A_Index], val, C)) and (P or StrLen(this[A_Index])=StrLen(val))
				{
					If A
						matches.Insert(A_Index)
					Else
						Return A_Index
				}
		If A
		  Return matches
		Else
		  Return 0
	}
	IndexOfEqual(val, startpos = 0, key = "")
	{
		if(IsObject(val))
			Loop % this.MaxIndex()
				if(A_Index >= startpos && ((key && this[A_Index][key] = val[key]) || this[A_Index].Equals(val)))
					return A_Index
		else
			Loop % this.MaxIndex()
				if(A_Index >= startpos && this[A_Index] = val)
					return A_Index
	}
	ToString(Separator = "`n")
	{
		string := ""
		Loop % this.MaxIndex()
			string .= (A_Index = 1 ? "" : Separator) this[A_Index]
		return string
	}
	Contains(val)
	{
		return this.indexOf(val) > 0
	}
	Join(sep="`n"){ 
	   Loop, % this.MaxIndex() 
		  str .= this[A_Index] sep 
	   StringTrimRight, str, str, % StrLen(sep) 
	   return str 
	} 
	Copy(){ 
	   Return Array().extend(this) 
	} 

	;~ Insert(index, Params*)
	;~ {
		;~ if(!Params.MaxIndex())
			;~ this._Insert(index)
		;~ else
			;~ for offset, param in Params
				;~ this._Insert(index + (offset-1), param) 
		;~ Return this 
	;~ }
	Reverse(){ 
	   arr2 := Array() 
	   Loop, % len:=this.MaxIndex() 
		  arr2[len-(A_Index-1)] := this[A_Index] 
	   Return arr2 
	} 
	Sort(func="Array_CompareFunc"){ 
	   n := this.MaxIndex(), swapped := true 
	   while swapped { 
		  swapped := false 
		  Loop, % n-1 { 
			 i := A_Index 
			 if %func%(this[i], this[i+1], 1) > 0 ; standard ahk syntax for sort callout functions 
				this.insert(i, this[i+1]).delete(i+2), swapped := true 
		  } 
		  n-- 
	   } 
	   Return this 
	} 
	Unique(func="Array_CompareFunc"){   ; by infogulch 
	   i := 0 
	   while ++i < this.MaxIndex(), j := i + 1 
		  while j <= this.MaxIndex() 
			 if !%func%(this[i], this[j], i-j) 
				this.delete(j) ; j comes after 
			 else 
				j++ ; only increment to next element if not removing the current one 
	   Return this 
	} 

	Extend(Params*){ 
		for index, Param in Params
		  If IsObject(Param) 
			 Loop, % Param.MaxIndex() 
				this.Insert(Param[A_Index])
	   Return this 
	} 
	Pop(){ 
	   Return this.delete(this.MaxIndex()) 
	} 
	Delete(Params*){ 
		for index, Param in Params
		{
			if(IsObject(Param)) ;Arrays have no object keys
				this._Remove(this.IndexOf(Param))
			else
				this._Remove(Param)
		}
	   Return this 
	} 

	MaxIndex(){ 
	   len := this._MaxIndex() 
	   Return len="" ? 0 : len 
	}

	Swap(i,j){
		if(this.MaxIndex()<i||this.MaxIndex()<j||i<1||j<1)
			return 0
		x:=this[i]
		this[i]:=this[j]
		this[j]:=x
		return 1
	}

	Move(i,j)
	{
		if(i > this.MaxIndex() || j > this.MaxIndex())
			return 0
		if(i = j)
			return 1
		x := this[i]
		this.Remove(i)
		; I believe the following if is wrong, possibly revert if there are any array problems with the move function
		; if(i<j)
			this.Insert(j,x)
		; else
			; this.Insert(j-1,x)
		; }
		return 1
	}
}
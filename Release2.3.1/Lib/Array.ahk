; Array Lib - temp01 - http://www.autohotkey.com/forum/viewtopic.php?t=49736 
; Array is 1-based!!!
Array(Params*){ 
	global ArrBase 
	If !ArrBase
	{
	  ArrBase := RichObject()
	  ArrBase.len := "Array_Length"
	  ArrBase.indexOf := "Array_indexOf"
	  ArrBase.indexOfSubItem := "Array_indexOfSubItem"
	  ArrBase.indexOfSubItemBetween := "Array_indexOfSubItemBetween"
	  ArrBase.SubItem := "Array_SubItem"
	  ArrBase.contains := "Array_Contains"
	  ArrBase.join := "Array_Join" 
	  ArrBase.append := "Array_Append"
	  ArrBase.insert := "Array_Insert"
	  ArrBase.delete := "Array_Delete" 
	  ArrBase.sort := "Array_sort"
	  ArrBase.reverse := "Array_Reverse"
	  ArrBase.unique := "Array_Unique" 
	  ArrBase.extend := "Array_Extend"
	  ;ArrBase.copy := "Array_Copy"
	  ArrBase.pop := "Array_Pop"
	  ArrBase.swap := "Array_Swap"
	  ArrBase.move := "Array_Move"
	  ArrBase.ToString := "Array_ToString"
	}
	arr := Object("base", ArrBase) 
	for Index, Param in Params
	  arr._Insert(Param)
	Return arr
} 

IsArray(arr)
{
	global ArrBase
	return IsFunc(arr.len)
	object := arr.base
	while(object && object != ArrBase)
	{
		object := object.base
	}
	return object = ArrBase
}
Array_ToString(arr, Separator = "`n")
{
	string := ""
	Loop % arr.len()
		string .= (A_Index = 1 ? "" : Separator) arr[A_Index]
	return string
}
Array_indexOf(arr, val, opts="", startpos=1){
	if(IsObject(val))
	{
		enum := arr._newEnum()
		while enum[ k, v ]
		  If ( k >= startpos && v = val )
			 Return, k
	}
	P := !!InStr(opts, "P"), C := !!InStr(opts, "C")
	If A := !!InStr(opts, "A")
		matches := Array()
	Loop % arr.len()
		If(A_Index>=startpos)
			If(match := InStr(arr[A_Index], val, C)) and (P or StrLen(arr[A_Index])=StrLen(val))
			{
				If A
					matches.append(A_Index)
				Else
					Return A_Index
			}
	If A
	  Return matches
	Else
	  Return 0
}
Array_indexOfSubItem(arr, subitem, val){
	if(IsObject(val))
	{
		enum := arr._newEnum()
		while enum[ k, v ]
		  If (IsObject(v) && v[subitem] = val )
			 Return, k
	}
	Loop % arr.len()
		If(IsObject(arr[A_Index]) && arr[A_Index][subitem] = val)
			Return A_Index
	Return 0
}
Array_indexOfSubItemBetween(arr, subitem, val, val2){
	if(IsObject(val))
	{
		enum := arr._newEnum()
		while enum[ k, v ]
		  If (IsObject(v) && v[subitem] = val )
			 Return, k
		return 0
	}
	if(val2 = "")
		val2 := val
	Loop % arr.len()
		If(IsObject(arr[A_Index]) && arr[A_Index][subitem] >= val && arr[A_Index][subitem] <= val2)
			Return A_Index
	Return 0
}
Array_SubItem(arr, subitem, val)
{
	if(IsObject(val))
	{
		enum := arr._newEnum()
		while enum[ k, v ]
		  If (IsObject(v) && v[subitem] = val )
			 Return, arr[k]
	}
	Loop % arr.len()
		If(IsObject(arr[A_Index]) && arr[A_Index][subitem] = val)
			Return arr[A_Index]
	 Return ""
}
Array_Contains(arr, val)
{
	return arr.indexOf(val) > 0
}
Array_Join(arr, sep="`n"){ 
   Loop, % arr.len() 
      str .= arr[A_Index] sep 
   StringTrimRight, str, str, % StrLen(sep) 
   return str 
} 
Array_Copy(arr){ 
   Return Array().extend(arr) 
} 

Array_Append(arr, Params*){ 
   Return arr.insert(arr.len()+1, Params*) 
} 
Array_Insert(arr, index, Params*)
{
	if(!Params.MaxIndex())
		arr._Insert(index)
	else
		for offset, param in Params
			arr._Insert(index + (offset-1), param) 
	Return arr 
}
Array_Reverse(arr){ 
   arr2 := Array() 
   Loop, % len:=arr.len() 
      arr2[len-(A_Index-1)] := arr[A_Index] 
   Return arr2 
} 
Array_Sort(arr, func="Array_CompareFunc"){ 
   n := arr.len(), swapped := true 
   while swapped { 
      swapped := false 
      Loop, % n-1 { 
         i := A_Index 
         if %func%(arr[i], arr[i+1], 1) > 0 ; standard ahk syntax for sort callout functions 
            arr.insert(i, arr[i+1]).delete(i+2), swapped := true 
      } 
      n-- 
   } 
   Return arr 
} 
Array_Unique(arr, func="Array_CompareFunc"){   ; by infogulch 
   i := 0 
   while ++i < arr.len(), j := i + 1 
      while j <= arr.len() 
         if !%func%(arr[i], arr[j], i-j) 
            arr.delete(j) ; j comes after 
         else 
            j++ ; only increment to next element if not removing the current one 
   Return arr 
} 
Array_CompareFunc(a, b, c){ 
   return a > b ? 1 : a = b ? 0 : -1 
} 

Array_Extend(arr, Params*){ 
	for index, Param in Params
      If IsObject(Param) 
         Loop, % Param.len() 
            arr.append(Param[A_Index])
   Return arr 
} 
Array_Pop(arr){ 
   Return arr.delete(arr.len()) 
} 
Array_Delete(arr, Params*){ 
	for index, Param in Params
	{
		if(IsObject(Param)) ;Arrays have no object keys
			arr._Remove(arr.IndexOf(Param))
		else
			arr._Remove(Param)
	}
   Return arr 
} 

Array_Length(arr){ 
   len := arr._MaxIndex() 
   Return len="" ? 0 : len 
}

Array_Swap(arr,i,j){
	if(arr.len()<i||arr.len()<j||i<1||j<1)
		return 0
	x:=arr[i]
	arr[i]:=arr[j]
	arr[j]:=x
	return 1
}

Array_Move(arr,i,j)
{
	if(arr.len()<i||arr.len()<j)
		return 0
	if(i=j)
		return 1
	x:=arr[i]
	arr.Delete(i)
	; I believe the following if is wrong, possibly revert if there are any array problems with the move function
	; if(i<j)
		arr.Insert(j,x)
	; else
		; arr.Insert(j-1,x)
	; }
	return 1
}

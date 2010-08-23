/*
<Node1>value</Node1>
<Node2>
<key>value</key>
<key2>value</key2>
</Node2>

<Node1>value</Node1> <Node2> <key>value</key> <key2>value</key2> </Node2>
<key>value</key> <key2>value</key2>
*/
xml := XML_Write("", "Node1", "value")
node2:= XML_Write("", "key", "value")
node2:=XML_Write(node2, "key2", "value")
xml:=XML_Write(xml,"Node2", "`n" node2)
msgbox % xml
obj := XML_Read(xml)
exitapp

XML_Write(xml, name, value)
{
	return xml "<" name ">" value "</" name ">`n"
}

XML_Save(xmlObject, path, xml = "", level = 0)
{
	enum := xmlObject._newEnum()
	while enum[k,v]
	{
		if(IsFunc(v.len)) ;If current value is an array
		{
			Loop % v.len()
			{
				if(IsObject(v[A_Index]))
				{
					xml .= "<" k ">`n" 
					xml := XML_Save(v[A_Index], "", xml, level + 1)
					xml .= "</" k ">"
				}
				else
				{
					value := StringReplace(v,"<","&lt;",1)
					value := StringReplace(value,">","&gt;",1)
					xml .= "<" k ">" value "</" k ">`n"
				}
			}
			continue
		}
		else if(IsObject(v))
		{
			xml .= "<" k ">`n"
			xml := XML_Save(v, "", xml, level + 1) 
			xml .= "</" k ">"
		}
		else
		{
			value := StringReplace(v,"<","&lt;",1)
			value := StringReplace(value,">","&gt;",1)
			xml .= "<" k ">" value "</" k ">"
		}
		xml .= "`n"
		
	}
	if(path)
	{
		FileDelete, %path%
		FileAppend, %xml%, %path%
	}
	return xml
}
XML_Read(xml,node = 0)
{
	if(node = 0)
		node := Object()
	xml := strTrimLeft(xml,"`n")
	xml := strTrimLeft(xml,"`r`n")
	if(!strstartswith(xml,"<"))
	{
		; outputdebug % "string starts with " substr(xml,1,1)
		return ""
	}
	start := 1
	while(start != 0) ;loop until no more keys, all keys from this level read
	{
		len := InStr(xml,">", 0, start + 1) - start - 1
		key := SubStr(xml,start + 1,InStr(xml,">", 0, start + 1) - start - 1)
		; outputdebug read key %key%
		if(strEndsWith(key,"/"))
		{
			; outputdebug single key without value
			start += strlen(key) + 3
			continue
		}
		start += StrLen(key) + 2
		depth := 1
		end := start
		while(depth > 0)
		{
			open := InStr(xml, "<" key ">",0,end)
			close := InStr(xml, "</" key ">",0,end)
			
			if(!close) ;No closing key, ERROR
				return ""
			if(open && open < close)
			{
				depth++
				end := open + StrLen("<" key ">")
				continue
			}
			else
			{
				depth--
				end := close + StrLen("</" key ">")
				continue
			}
		}
		value := SubStr(xml,start,end - start - 2 - strlen(key) - 1)
		value := strTrimLeft(value,"`n")
		value := strTrimLeft(value,"`r`n")
		; outputdebug value: %value%
		if(value = "")
		{
			; outputdebug empty value
			start := InStr(xml, "<",0,end)
			continue
		}
		
		if(InStr(value, "<"))
		{
			; outputdebug xml value %key%
			subnode := Object()
			value := XML_Read(value, subnode)
		}
		else
		{
			; outputdebug normal value %key%
			value := StringReplace(value, "&gt;",">",1)
			value := StringReplace(value, "&lt;","<",1)
		}
		if(node.HasKey(key) && node[key].len() < 0) ;Key already exists and is not an array, make it one and append things
		{
			; outputdebug turn %key% into array
			array := Array()
			array.append(node[key])
			array.append(value)
			node[key] := array
		}
		else if(node.HasKey(key) && node[key].len() > 0) ;Key already exists and is an array, just append the new key
		{
			node[key].append(value)
			; outputdebug % "append " key " to array, new len " node[key].len()
		}
		else
		{
			; outputdebug set key %key%
			node[key] := value
		}	
		start := InStr(xml, "<",0,end)
	}
	; outputdebug % "key " key " len " node.len()
	return node
}

XML_Get(XMLObject, path)
{
	StringSplit, node, path, /
	if(node0 = 0)
		return ""
	obj := XMLObject
	Loop %node0%
	{
		node := node%A_Index%
		if(strEndsWith(node,"]"))
		{
			pos := strTrimRight(SubStr(node, InStr(node,"[",0,0) + 1),"]")
			node := SubStr(node, 1, InStr(node,"[",0,0) - 1)
		}
		else
			pos := 0
		if(pos = 0)
			obj := obj[node]
		else
			obj := obj[node][pos]		
	}
	return obj
}


#include 7plus.ahk
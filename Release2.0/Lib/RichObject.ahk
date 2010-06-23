objDeepCopy(ast, reserved=0) 
{ 
  if !reserved 
   reserved := object("copied" . &ast, 1)  ; to keep track of unique objects within top object 
  if !isobject(ast) 
	copy := richObject() 

   outputdebug("len" ast.len())
  enum := ast._newenum() 
  while enum[key, value] 
{ 
	outputdebug loop %key% %value%
  if reserved["copied" . &value] 
    continue  ; don't copy repeat objects (circular references) 
  copy._Insert(key, objDeepCopy(value, reserved)) 
} 
  return copy 
} 

objPrint(ast, reserved=0) 
{ 
  if !isobject(ast) 
    return " " ast " " 
  
  if !reserved 
    reserved := object("seen" . &ast, 1)  ; to keep track of unique objects within top object 
  
  enum := ast._newenum() 
  while enum[key, value] 
  { 
    if reserved["seen" . &value] 
      string .= key . ": WARNING: CIRCULAR OBJECT SKIPPED !!!`n "  
    else 
      string .= key . ": " . objPrint(value, reserved) 
  } 
  return "(" string ") " 
} 

objEqual(x, y, reserved=0) 
{ 
  if !reserved 
   reserved := object("seen" . &x, 1)  ; to keep track of unique objects within top object 


  if !(x != y) ; equal non-object values or exact same object 
    return 1 ; note != obeys StringCaseSense, unlike = and == 
  if !isobject(x) 
    return 0 ; unequal non-object value 
  ; recursively compare contents of both objects: 
  enumx := x._newenum() 
  enumy := y._newenum() 
  while enumx[xkey, xvalue] && enumy[ykey, yvalue] 
     { 
     if (xkey != ykey) 
       return 0 
    
    if reserved["seen" . &value] 
       continue  ; don't compare repeat objects (circular references) 

     if !objEqual(xvalue, yvalue) 
       return 0 
    } 
  ; finally, check that there are no excess key-value pairs in y: 
  return ! enumy[ykey] 
} 

objCopy(ast) 
{ 
  if !isobject(ast) 
   return ast 

  copy := richObject() 
  enum := ast._newenum() 
  while enum[key, value] 
     copy._Insert(key, value) 
  return copy 
} 

richObject(){ 
   static richObject 
   If !richObject 
      richObject := Object("base", Object("print", "objPrint", "copy", "objCopy" 
                             , "deepCopy", "objDeepCopy", "equal", "objEqual" 
             , "flatten", "objFlatten"  )) 
    
   return  Object("base", richObject) 
} 

objIsCircular(ast, reserved=0) 
{ 
  if !reserved 
    reserved := object("seen" . &ast, 1)  ; to keep track of unique objects within top object 
  
  if !isobject(ast) 
    return " " ast " " 
  enum := ast._newenum() 
  while enum[key, value] 
  {    
    if reserved["seen" . &value] 
    { 
      msgbox error: circular references not supported 
      return 1 
    } 
    objIsCircular(value, reserved) 
  } 
  return 0 
} 

objFlatten(ast, reserved=0) 
{ 
  if !isobject(ast) 
    return ast 
  if !reserved 
    reserved := object("seen" . &ast, 1)  ; to keep track of unique objects within top object 

  flat := richObject() ; flat object 
  
  enum := ast._newenum() 
  while enum[key, value] 
  { 
    if !isobject(value) 
      flat._Insert(value) 
    else 
    { 
    if reserved["seen" . &value] 
      continue 
      next := objFlatten(value, reserved) 
      loop % next._MaxIndex() 
      flat._Insert(next[A_Index]) 
      
    } 
  } 
  return flat 
} 
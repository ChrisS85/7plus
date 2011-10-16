#include *i <LV> 
#include <_Struct> 
ObjTree(obj,Title="ObjTree",Options="+AlwaysOnTop +Resize,GuiShow=w440 h240",ishwnd=-1){ 
   global _Struct 
   static ObjTreeListView,ObjTreeTreeView,TREEHWND,LISTHWND,parents,LV_SortArrow:="LV_SortArrow",ToolTipText 
   static HDR:=new _Struct("HWND hwndFrom,UINT_PTR idFrom,UINT code,LPTSTR pszText,int cchTextMax,HANDLE hItem,LPARAM lParam") 
   static TVN_FIRST := 0xfffffe70,TVN_GETINFOTIP := TVN_FIRST - 14 - (A_IsUnicode?0:1) 
   static temp:=OnMessage(0x4e,"ObjTree"),hwnd 
   If ishwnd!=-1 
   { 
      HDR[]:=Title 
      If ((HDR.hwndFrom-TREEHWND)!=0 || HDR.code!=TVN_GETINFOTIP) 
         Return 
      TV_GetText(TV_Text,HDR.hItem) 
      object:=parents["",HDR.hItem] 
      If !(Parents[object]=HDR.hItem){ 
         for k,v in object 
         { 
            If ((IsObject(k)?(Chr(177) " " (&k)):k)=TV_Text){ 
                  HDR.pszText:=v 
                  HDR.cchTextMax:=StrLen(v) 
               Return 
            } 
         } 
      } else { 
         ToolTipText= 
         for k,v in object 
         { 
            ToolTipText.=(ToolTipText?"`n":"") (IsObject(v)?"[Obj] ":"") SubStr(k,1,50) (StrLen(k)>50?"...":"") " = " SubStr(v,1,100) (StrLen(v)>100?"...":"") 
            If (A_Index>20){ 
               ToolTipText.="`n...s" 
               break 
            } 
         } 
         HDR.pszText:=ToolTipText 
         HDR.cchTextMax:=StrLen(ToolTipText) 
      } 
      Return 
   } 
   Loop % (G := 50) { ;find free gui after 50 
    Gui %G%:+LastFoundExist 
    IfWinNotExist ;gui is free 
      break 
    G++ 
   } 

   ;--- Apply user defined options 
   Loop, Parse, Options, `,, % A_Space 
   { 
    opt := Trim(SubStr(A_LoopField,1,InStr(A_LoopField,"=")-1)) 
    If (InStr("Font,GuiShow,NoWait",opt)) 
      %opt% := SubStr(A_LoopField,InStr(A_LoopField,"=") + 1,StrLen(A_LoopField))  
    else GuiOptions:=A_LoopField 
   } 
   if Font 
    Gui, %G%:Font, % SubStr(Font,1,Pos := InStr(Font,":") - 1), % SubStr(Font,Pos + 2,StrLen(Font))  
   RegExMatch(GuiShow,"\bw\K[0-9]+\b",width) 
   RegExMatch(GuiShow,"\bh\K[0-9]+\b",height) 

   Gui,%G%:Default 
   Gui,%G%:%GuiOptions% +LastFound 
   hwnd:=WinExist() 
   Gui,%G%:Add,Button, x0 y0 NoTab Hidden Default gObjTree_ButtonOK,Show/Expand Object 
   Gui,%G%:Add,Button,xs ys NoTab gObjTree_ExpandSelection,&Expand 
   Gui,%G%:Add,Button,x+1 NoTab gObjTree_ExpandAll,Expand &All 
   Gui,%G%:Add,Button, x+1 NoTab gObjTree_CollapseSelection,&Collapse 
   Gui,%G%:Add,Button, x+1 NoTab gObjTree_CollapseAll,Collap&se All 
   Gui,%G%:Add,Text,% "x+10 w" width*0.5 " h30",{Enter}`t`tshow selected object`n{BackSpace}`tshow parent object 
   GuiControlGet,pos,Pos 
   Gui,%G%:Add,TreeView,% "xs w" ((Width)/2) " h" (Height-40) " gObjTree_ObjTreeClick +0x800 hwndTREEHWND vObjTreeTreeView" 
   Gui,%G%:Add,ListView,% "x+1 w" ((Width)/2) " h" ((Height-40)*0.5) " AltSubmit Checked ReadOnly gObjTree_ListClick hwndLISTHWND vObjTreeListView",[IsObj] Key/Address|Value/Address 
   Gui,%G%:Add,Edit,% "y+1 w" ((Width)/2) " h" ((Height-40)*0.5) " HWNDEDITHWND ReadOnly" 
   ;Attach(TREEHWND,"w1/2 h") 
   ;Attach(LISTHWND,"w1/2 h1/2 x1/2 y0") 
   ;Attach(EDITHWND,"w1/2 h1/2 x1/2 y1/2") 
   parents:=ObjTree_Add(obj) 
   Gui,%G%:Show,%GuiShow%,%Title% 
   WinWaitClose,ahk_id %hwnd% 
   Gui,%G%:Destroy 
   TV_Delete() 
   hwnd= 
   Return 
   ObjTree_ObjTreeClick: 
      LV_CurrRow:="",LV_Delete(),TV_GetText(TV_Text,A_EventInfo) 
      GuiControl,,Edit1 
      for k,v in parents[""] 
         If (k=A_EventInfo) 
            object:=v 
      for k,v in object 
      { 
         LV_Add(((IsObject(v)||IsObject(k))?"Check":"") (TV_Text=(IsObject(k)?(Chr(177) " " (&k)):k)?(" Select",LV_CurrRow:=A_Index):"") 
                  ,IsObject(k)?(Chr(177) " " (&k)):k,IsObject(v)?(Chr(177) " " (&v)):v) 
         If (LV_CurrRow=A_Index) 
            GuiControl,,Edit1,%v% 
      } 
      If LV_CurrRow 
         LV_Modify(LV_CurrRow,"Vis") ;make sure selcted row it is visible 
      Loop 2 
         LV_ModifyCol(A_Index,"AutoHdr") ;autofit contents 
   Return 
    
   ObjTree_ListClick: 
      If (A_GuiEvent = "ColClick") 
         Return ,IsFunc(LV_SortArrow)?LV_SortArrow.(LISTHWND, A_EventInfo): 
      else if (A_GuiEvent="k" && A_EventInfo=8){ 
         If TV_GetParent(TV_GetSelection()) 
            TV_Modify(TV_GetParent(TV_GetSelection())) 
         return 
      } else if (A_GuiEvent="Normal"){ 
         GuiControl,,Edit1 
         TV_Item:=TV_GetSelection() 
         If !(TV_Child:=TV_GetChild(TV_Item)) 
            TV_Item:=TV_GetParent(TV_Item),TV_Child:=TV_GetChild(TV_Item) 
         If (!TV_GetNext(TV_Child) && TV_GetChild(TV_Child) && TV_GetText(TVP,TV_Child) && TV_GetText(TVC,TV_GetParent(TV_Child)) && TVC=TVP) 
            If TV_GetParent(TV_Child) 
               TV_Child:=TV_GetParent(0) 
            else 
               TV_Child:=TV_GetNext() 
         If !TV_Child 
            TV_Child:=TV_GetSelection() 
         LV_GetText(LV_Item,A_EventInfo,1) 
         While (TV_GetText(TV_Item,TV_Child) && TV_Item!=LV_Item) 
            TV_Child:=TV_GetNext(TV_Child) 
         for k,v in parents["",TV_Child] 
            If (k=LV_Item || (Chr(177) " " (&k))=LV_Item){ 
               GuiControl,,Edit1,% parents["",TV_Child][k] 
               Break 
            } 
         Return 
      } else if (A_GuiEvent!="DoubleClick" && !(A_GuiEvent="I" && ErrorLevel="C")) 
         Return 
   ObjTree_ButtonOK: 
      If (A_ThisLabel="ObjTree_ButtonOK"){ 
         GuiControlGet, FocusedControl, FocusV 
         if (FocusedControl = "ObjTreeListView"){ 
            Item:=LV_GetNext(0) 
         } else if (FocusedControl = "ObjTreeTreeView") 
            Return TV_Modify(TV_GetSelection(),"Expand") 
         If !Item 
            Return 
      } else Item:=A_EventInfo 
      TV_Item:=TV_GetSelection() 
      If !(TV_Child:=TV_GetChild(TV_Item)) 
         TV_Item:=TV_GetParent(TV_Item),TV_Child:=TV_GetChild(TV_Item) 
      If (!TV_GetNext(TV_Child) && TV_GetChild(TV_Child) && TV_GetText(TVP,TV_Child) && TV_GetText(TVC,TV_GetParent(TV_Child)) && TVC=TVP) 
         If TV_GetParent(TV_Child) 
            TV_Child:=TV_GetParent(0) 
         else 
            TV_Child:=TV_GetNext() 
      If !TV_Child 
         TV_Child:=TV_GetSelection() 
      LV_GetText(LV_Item,Item,1) 
      While (TV_GetText(TV_Item,TV_Child) && TV_Item!=LV_Item) 
         TV_Child:=TV_GetNext(TV_Child) 
      If (A_GuiEvent="I" && ErrorLevel="C"){ 
         If (parents[parents["",TV_Child]]=TV_Child || TV_GetChild(TV_Child)){ 
            If (ErrorLevel=="c") 
               LV_Modify(Item,"Check") 
         } else If (Errorlevel=="C") 
            LV_Modify(Item,"-Check") 
      } else if (TV_Child) 
         TV_Modify(TV_Child) 
   Return 
    
   ObjTree_ExpandAll: 
      ObjTree_Expand(TV_GetNext()) 
   Return 
   ObjTree_ExpandSelection: 
      ObjTree_Expand(TV_GetSelection(),1) 
   Return 
   ObjTree_CollapseAll: 
      ObjTree_Expand(TV_GetNext(),0,1) 
      TV_Modify(""),TV_Modify(TV_GetNext()) 
   Return 
   ObjTree_CollapseSelection: 
      ObjTree_Expand(TV_GetSelection(),1,1) 
   Return 
} 
ObjTree_Expand(TV_Item,OnlyOneItem=0,Collapse=0){ 
   Loop { 
      If !TV_GetChild(TV_Item) 
         TV_Modify(TV_GetParent(TV_Item),(Collapse?"-":"")"Expand") 
      else TV_Modify(TV_Item,(Collapse?"-":"")"Expand") 
      If (TV_Child:=TV_GetChild(TV_Item)) 
         ObjTree_Expand(TV_Child,0,Collapse) 
   } Until (OnlyOneItem || (!TV_Item:=TV_GetNext(TV_Item))) 
} 
ObjTree_Add(obj,parent=0){ 
   static parents:=Object() 
   for k,v in obj 
   { 
      If (IsObject(v)) 
         parents[v]:=TV_Add(IsObject(k)?Chr(177) " " (&k):k,parent),parents["",parents[v]]:=v 
         , ObjTree_Add(v,parents[v]) 
      else 
         parents["",lastParent:=TV_Add(IsObject(k)?Chr(177) " " (&k):k,parent)]:=obj 
      If IsObject(k) 
         parents[k]:=TV_Add(Chr(177) " " (&k),IsObject(v)?parents[v]:lastParent),parents["",parents[k]]:=k 
         ,ObjTree_Add(k,parents[k]) 
   } 
   If (parent=0 && parent:=parents) 
      Return parent,parents:=Object() 
}
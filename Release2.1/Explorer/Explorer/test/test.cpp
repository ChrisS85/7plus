// test.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <windows.h>

int _tmain(int argc, _TCHAR* argv[])
{
	SetErrorMode(1);
	WCHAR sThisDir[MAX_PATH]; // in atlstr.h
 
 
::GetModuleFileName( // In WinBase.h.
   0, // retrieve path of .exe file for the current process.
   sThisDir, 
   MAX_PATH);
 
	LPCWSTR strPath = L"C:\\Users\\Chris\\Desktop\\7plus\\Explorer.dll";
	/* get handle to dll */ 
	HINSTANCE hGetProcIDDLL = LoadLibrary(strPath);
	if(!hGetProcIDDLL)
		system("pause");
	/* get pointer to the function in the dll*/ 
	const char* c = "SetPath";
	//FARPROC lpfnGetProcessID = GetProcAddress(HMODULE (hGetProcIDDLL),reinterpret_cast<const char*>(1)); 
	FARPROC lpfnGetProcessID = GetProcAddress(HMODULE (hGetProcIDDLL),c); 
	printf("Error: %d", GetLastError());
	if(!lpfnGetProcessID)
		system("pause");
	/* 
		Define the Function in the DLL for reuse. This is just prototyping the dll's function. 
		A mock of it. Use "stdcall" for maximum compatibility. 
	*/ 
	typedef int (__stdcall * pICFUNC)(HWND,LPCWSTR); 
	pICFUNC SetPath; 
	SetPath = pICFUNC(lpfnGetProcessID); 

	LPCWSTR strExplorerPath = L"C:\\Program Files";
	/* The actual call to the function contained in the dll */ 
	int intMyReturnVal = SetPath(0,strExplorerPath); 

	/* Release the Dll */ 
	FreeLibrary(hGetProcIDDLL);
	return 0;
}


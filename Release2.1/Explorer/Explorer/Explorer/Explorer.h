// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the EXPLORER_EXPORTS
// symbol defined on the command line. This symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// EXPLORER_API functions as being imported from a DLL, whereas this DLL sees symbols
// defined with this macro as being exported.
//#ifdef EXPLORER_EXPORTS
//#define EXPLORER_API __declspec(dllexport)
//#else
//#define EXPLORER_API __declspec(dllimport)
//#endif

// This class is exported from the Explorer.dll
/*
class EXPLORER_API CExplorer {
public:
	CExplorer(void);
	// TODO: add your methods here.
};

extern EXPLORER_API int nExplorer;

EXPLORER_API int fnExplorer(void);
*/
int _stdcall SetPath(HWND hWnd, LPCWSTR Path);
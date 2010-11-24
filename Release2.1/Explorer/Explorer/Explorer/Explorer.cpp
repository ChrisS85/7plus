// Explorer.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"
#include "Explorer.h"


#include <windows.h>
#include <shobjidl.h>
#include <shlobj.h>
#include <shlwapi.h>
#include <strsafe.h>
#include <propvarutil.h>

//#define _WIN32_WINNT 0x0600
//#define _WIN32_IE 0x0700
//#define _UNICODE

#pragma comment(lib, "shlwapi.lib")
#pragma comment(lib, "ole32.lib")
#pragma comment(lib, "shell32.lib")
#pragma comment(lib, "propsys.lib")

#define INITGUID
#include <initguid.h>
#include <exdisp.h>
#include <shlguid.h>
#include <memory.h>

// macros for walking PIDLs
#define _ILSkip(pidl, cb)       ((LPITEMIDLIST)(((BYTE*)(pidl))+cb))
#define _ILNext(pidl)           _ILSkip(pidl, (pidl)->mkid.cb)

HRESULT FreeResources(LPVOID pData);
HRESULT TestPidl(LPITEMIDLIST pidl);
LPITEMIDLIST PidlFromVARIANT(VARIANT* pvarLoc);
LPSAFEARRAY MakeSafeArrayFromData(LPBYTE pData,DWORD cbData);
HRESULT InitVARIANTFromPidl(LPVARIANT pVar, LPITEMIDLIST pidl);
UINT ILGetSize(LPITEMIDLIST pidl);


/*
// This is an example of an exported variable
EXPLORER_API int nExplorer=0;

// This is an example of an exported function.
EXPLORER_API int fnExplorer(void)
{
	return 42;
}

// This is the constructor of a class that has been exported.
// see Explorer.h for the class definition
CExplorer::CExplorer()
{
	return;
}
*/
int _stdcall SetPath(HWND hWnd, LPCWSTR Path)
{
    IShellWindows* psw;
	HRESULT hr;
	LPITEMIDLIST pidl, pidl2 = NULL;
	VARIANT vPIDL = {0}, vDummy = {0};	
	IWebBrowser2 *pwb;
    IDispatch *pdisp;
	if (FAILED(OleInitialize(NULL)))
	{
		return 1;
	}
    if (SUCCEEDED(CoCreateInstance(CLSID_ShellWindows, NULL,  
        CLSCTX_LOCAL_SERVER, IID_PPV_ARGS(&psw))))
    {
        VARIANT v = { VT_I4 };
        if (SUCCEEDED(psw->get_Count(&v.lVal)))
        {
            // walk backwards to make sure the windows that close
            // don't cause the array to be re-ordered
            while (--v.lVal >= 0)
            {
                if (S_OK == psw->Item(v, &pdisp))
                {
                    if (SUCCEEDED(pdisp->QueryInterface(IID_PPV_ARGS(&pwb))))
                    {
						HWND _hWnd;
						if(SUCCEEDED(pwb->get_HWND(reinterpret_cast<SHANDLE_PTR*>(&_hWnd))) )
						{
							if(_hWnd==hWnd)
							{
								// Get the pidl for your favorite special folder,
								// in this case literally, the Favorites folder
								if(FAILED(hr = SHParseDisplayName(Path, NULL, &pidl, 0, NULL)))
								{
									goto Error;
								}

								// Pack the pidl into a VARIANT
								if (FAILED(hr = InitVARIANTFromPidl(&vPIDL, pidl)))
								{
									goto Error;
								}

								// Verify for testing purposes only that the pidl was packed
								// properly. Don't clean up pidl2 because it's a copy of the
								// pointer, not a clone of the id list itself
								pidl2 = PidlFromVARIANT(&vPIDL);
								if (FAILED(hr = TestPidl(pidl2)))
								{
									OutputDebugString(LPCWSTR("PIDL test failed"));
									goto Error;
								}
						
								// Show the browser, and navigate to the special location
								// represented by the pidl
								hr = pwb->Navigate2(&vPIDL, &vDummy, &vDummy,&vDummy, &vDummy);
								goto Error;
							}
						}
                        pwb->Release();
                    }
                    pdisp->Release();
                }
            }
        }
        psw->Release();
    }
	Error:
	// Clean up
	VariantClear(&vPIDL);

	if (pwb)
	{
		pwb->Release();
	}

	if (pidl)
	{
		FreeResources((LPVOID)pidl);
	}

	if(pdisp)
		pdisp->Release();

	if(psw)
		psw->Release();
	OleUninitialize();
	return hr;
}
 
// convert an IShellItem or IDataObject into a VARIANT that holds an IDList
// suitable for calling IWebBrowser2::Navigate2() with
 
HRESULT InitVariantFromObject(IUnknown *punk, VARIANT *pvar)
{
    VariantInit(pvar);
 
    PIDLIST_ABSOLUTE pidl;
    HRESULT hr = SHGetIDListFromObject(punk, &pidl);
    if (SUCCEEDED(hr))
    {
        hr = InitVariantFromBuffer(pidl, ILGetSize(pidl), pvar);
        CoTaskMemFree(pidl);
    }
    return hr;
}

// Exercise the PIDL by performing common operations upon it.
// 
HRESULT TestPidl(LPITEMIDLIST pidl)
{
   HRESULT hr;
   LPSHELLFOLDER pshfDesktop = NULL, pshf = NULL;
   DWORD uFlags = SHGDN_NORMAL;
   STRRET strret;

   if (!pidl)
   {
      return E_INVALIDARG;
   }

   hr = SHGetDesktopFolder(&pshfDesktop);
   if (!pshfDesktop)
   {
      return hr;
   }

   hr = pshfDesktop->BindToObject(pidl,
                NULL,
                IID_IShellFolder,
                (LPVOID*)&pshf);
   if (!pshf)
   {
      goto Error;
   }

   hr = pshfDesktop->GetDisplayNameOf(pidl, uFlags, &strret);
   if (STRRET_WSTR == strret.uType)
   {
      FreeResources((LPVOID)strret.pOleStr);
   }

   Error:
   if (pshf) pshf->Release();
   if (pshf) pshfDesktop->Release();
   return hr;
}

// Use the shell's IMalloc implementation to free resources
HRESULT FreeResources(LPVOID pData)
{
   HRESULT hr;
   LPMALLOC pMalloc = NULL;

   if (SUCCEEDED(hr = SHGetMalloc(&pMalloc)))
   {
      pMalloc->Free((LPVOID)pData);
      pMalloc->Release();
   }

   return hr;
}

// Given a VARIANT, pull out the PIDL using brute force
LPITEMIDLIST PidlFromVARIANT(LPVARIANT pvarLoc)
{
   if (pvarLoc)
   {
      if (V_VT(pvarLoc) == (VT_ARRAY|VT_UI1))
      {
         LPITEMIDLIST pidl = (LPITEMIDLIST)pvarLoc->parray->pvData;
         return pidl;
      }
   }
   return NULL;
}

// Pack a PIDL into a VARIANT
HRESULT InitVARIANTFromPidl(LPVARIANT pvar, LPITEMIDLIST pidl)
{
   if (!pidl || !pvar)
   {
      return E_POINTER;
   }

   // Get the size of the pidl and allocate a SAFEARRAY of
   // equivalent size
   UINT cb = ILGetSize(pidl);
   LPSAFEARRAY psa = MakeSafeArrayFromData((LPBYTE)pidl, cb);
   if (!psa)
   {
      VariantInit(pvar);
      return E_OUTOFMEMORY;
   }

   V_VT(pvar) = VT_ARRAY|VT_UI1;
   V_ARRAY(pvar) = psa;
   return NOERROR;
}

// Allocate a SAFEARRAY of cbData size and pack pData into it
LPSAFEARRAY MakeSafeArrayFromData(LPBYTE pData, DWORD cbData)
{
   LPSAFEARRAY psa;

   if (!pData || 0 == cbData)
   {
      return NULL;  // nothing to do
   }

   // create a one-dimensional safe array of BYTEs
   psa = SafeArrayCreateVector(VT_UI1, 0, cbData);

   if (psa)
   {
      // copy data into the area in safe array reserved for data
      // Note we party directly on the pointer instead of using locking/ 
      // unlocking functions.  Since we just created this and no one
      // else could possibly know about it or be using it, this is okay.
      memcpy(psa->pvData,pData,cbData);
   }

   return psa;
}

// Get the size of the PIDL by walking the item id list
UINT ILGetSize(LPITEMIDLIST pidl)
{
   UINT cbTotal = 0;
   if (pidl)
   {
      cbTotal += sizeof(pidl->mkid.cb);       // Null terminator
      while (pidl->mkid.cb)
      {
         cbTotal += pidl->mkid.cb;
         pidl = _ILNext(pidl);
      }
   }

   return cbTotal;
}
				
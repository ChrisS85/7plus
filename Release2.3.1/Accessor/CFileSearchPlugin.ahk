Class CFileSearchPlugin extends CAccessorPlugin
{
	;Register this plugin with the Accessor main object
	static Type := CAccessor.RegisterPlugin("File Search", CFileSearchPlugin)
	
	Description := "Quickly find files on the computer or the current directory."
	
	Cleared := false
	List := Array()
	Icons := Array()
	AllowDelayedExecution := true
	SearchIcon := Gdip_CreateHBITMAPFromBitmap(Gdip_CreateBitmapFromFile("%WINDIR%\System32\shell32.dll", 23))

	Class CSettings extends CAccessorPlugin.CSettings
	{
		Keyword := "find"
		KeywordOnly := true
		MinChars := 2
		UseIcons := true
		ShowResultsInAccessor := true
	}
	Class CSearchInAccessorResult extends CAccessorPlugin.CResult
	{
		Actions := {DefaultAction : new CAccessor.CAction("Search", "SearchInAccessor", "", false, false, false)}
		Type := "File Search"
		Priority := CFileSearchPlugin.Instance.Priority
		MatchQuality := 1 ;Only direct matches are used by this plugin
		Title := "Show search results in Accessor for:"
		Detail1 := "File search"
	}
	Class CSearchResult extends CAccessorPlugin.CResult
	{
		Class CFileActions extends CArray
		{
			DefaultAction := new CAccessor.CAction("Open file", "Run")
			__new()
			{
				this.Insert(CAccessorPlugin.CActions.OpenWith)
				this.Insert(CAccessorPlugin.CActions.OpenPathWithAccessor)
				this.Insert(CAccessorPlugin.CActions.OpenExplorer)
				this.Insert(CAccessorPlugin.CActions.OpenCMD)
				this.Insert(CAccessorPlugin.CActions.Copy)
				this.Insert(CAccessorPlugin.CActions.ExplorerContextMenu)
			}
		}
		Class CExecutableActions extends CArray
		{
			DefaultAction := CAccessorPlugin.CActions.Run
			__new()
			{
				this.Insert(CAccessorPlugin.CActions.OpenWith)
				this.Insert(CAccessorPlugin.CActions.OpenPathWithAccessor)
				this.Insert(CAccessorPlugin.CActions.RunWithArgs)
				this.Insert(CAccessorPlugin.CActions.RunAsAdmin)
				this.Insert(CAccessorPlugin.CActions.OpenExplorer)
				this.Insert(CAccessorPlugin.CActions.OpenCMD)
				this.Insert(CAccessorPlugin.CActions.Copy)
				this.Insert(CAccessorPlugin.CActions.ExplorerContextMenu)
			}
		}
		Class CFolderActions extends CArray
		{
			DefaultAction := CAccessorPlugin.CActions.OpenExplorer
			__new()
			{
				this.Insert(CAccessorPlugin.CActions.OpenPathWithAccessor)
				this.Insert(CAccessorPlugin.CActions.OpenCMD)
				this.Insert(CAccessorPlugin.CActions.Copy)
				this.Insert(CAccessorPlugin.CActions.ExplorerContextMenu)
			}
		}
		__new(Type)
		{
			if(Type = "Folder")
				this.Actions := new this.CFolderActions()
			else if(Type = "Executable")
				this.Actions := new this.CExecutableActions()
			else
				this.Actions := new this.CFileActions()
		}
		Type := "File Search"
		Priority := CFileSearchPlugin.Instance.Priority
		MatchQuality := 1 ;Only direct matches are used by this plugin 
		Detail1 := "Search result"
	}

	;IsInSinglePluginContext(Filter, LastFilter)
	;{
	;	if(InStr(Filter, this.Settings.Keyword " ") = 1)
	;	{
	;		if(!this.Cleared)
	;		{
	;			this.Cleared := true
	;			CAccessor.Instance.RefreshList()
	;		}
	;		return true
	;	}
	;	this.Cleared := false
	;	return false
	;}

	OnOpen(Accessor)
	{
		this.List := Array()
	}
	Init(Settings)
	{
		;Perform a random MFT search to speed up searches by the user
		wt := new CWorkerThread("AccessorMFTSearch", 0, 1, 1).Start({Query : "xyz", SearchPath : "C:"})
	}
	RefreshList(Accessor, Filter, LastFilter, KeywordSet, Parameters)
	{
		if(!KeywordSet)
			return

		Results := Array()
		if(this.HasKey("List"))
		{
			;Show results from worker thread
			for index, ListEntry in this.List
			{
				SplitPath, Name, , , ext
				IsExecutable := !ListEntry.IsDir && ext && InStr("exe,cmd,bat,ahk", ext)
				Result := new this.CSearchResult(ListEntry.IsDir ? "Folder" : (IsExecutable ? "Executable" : "File"))
				Result.Title := Name := ListEntry.Name
				Result.Path := ListEntry.Path "\" ListEntry.Name
				Result.DisplayPath := ListEntry.Path
				Result.MatchQuality := ListEntry.MatchQuality
				if(this.Settings.UseIcons)
				{
					hIcon := ExtractAssociatedIcon(0, ListEntry.Path "\" ListEntry.Name, iIndex)
					this.Icons.Insert(hIcon)
					Result.Icon := hIcon
				}
				else
					Result.Icon := ListEntry.IsDir ? Accessor.GenericIcons.Folder : (IsExecutable ? Accessor.GenericIcons.Application : Accessor.GenericIcons.File)
				Results.Insert(Result)
			}
		}
		;Not searched yet, show selection to start a new search
		else if(((pos := InStr(Filter, " in ")) && InStr(FileExist(SearchPath := SubStr(Filter, pos + 4)), "D")) || SearchPath := Accessor.CurrentDirectory)
		{
			Result := new this.CSearchInAccessorResult()
			Result.Query := pos ? SubStr(Filter, 1, pos - 1) : Filter
			Result.Title .= " " Result.Query
			Result.SearchPath := SearchPath
			Result.Icon := Accessor.GenericIcons.7plus
			Results.Insert(Result)
		}
		return Results
	}
	GetDisplayStrings(ListEntry, ByRef Title, ByRef Path, ByRef Detail1, ByRef Detail2)
	{
		Path := ListEntry.SearchPath
	}
	OnClose(Accessor)
	{
		this.CancelSearch()
	
		;Get rid of old icons from last query
		if(this.Settings.UseIcons)
			for index, Icon in this.Icons
				DestroyIcon(Icon)
	}

	SearchInAccessor(Accessor, ListEntry)
	{
		this.StartWorkerThread(Accessor, ListEntry)
	}

	StartWorkerThread(Accessor, ListEntry)
	{
		this.CancelSearch()
		WorkerThread := new CWorkerThread("AccessorMFTSearch", 0, 1, 1)
		WorkerThread.OnProgress.Handler := new Delegate(this, "ProgressHandler")
		WorkerThread.OnStop.Handler := new Delegate(this, "OnStop")
		WorkerThread.OnFinish.Handler := new Delegate(this, "OnFinish")
		WorkerThread.Start({Query : ListEntry.Query, SearchPath : ListEntry.SearchPath})
		if(WorkerThread.WaitForStart(5))
		{
			WorkerThread.NotificationWindow := Notify("Searching for " WorkerThread.Task.Parameters.1.Query " in " WorkerThread.Task.Parameters.1.SearchPath, "", "", this.SearchIcon, new Delegate(this, "CancelSearch"), {min : 0, max : 100, value : 0})
			this.tmpWorkerThread := WorkerThread
		}
		else
			Notify("File search error!", "Couldn't start the search!", 5, NotifyIcons.Error)
	}

	ProgressHandler(WorkerThread, Progress)
	{
		WorkerThread.NotificationWindow.Progress := Progress
	}

	;Called when user cancels the search
	CancelSearch()
	{
		;Clear temporary data, stop worker thread
		if(this.HasKey("tmpWorkerThread") && this.tmpWorkerThread.State = "Running")
			this.tmpWorkerThread.Stop()
		if(this.tmpWorkerThread.HasKey("NotificationWindow"))
			this.tmpWorkerThread.NotificationWindow.Close()
		this.Remove("tmpWorkerThread")
		this.Remove("List")
	}

	OnStop(WorkerThread, Reason)
	{
		;Shouldn't happen
	}

	OnFinish(WorkerThread, Result)
	{
		this.tmpWorkerThread.NotificationWindow.Close()
		this.Remove("tmpWorkerThread")
		this.List := Result
		CAccessor.Instance.RefreshList()
	}

	OnFilterChanged(ListEntry, Filter, LastFilter)
	{
		this.CancelSearch()
		return true
	}
}

;Worker thread for searching
AccessorMFTSearch(WorkerThread, Task)
{
	SearchPath := Task.SearchPath
	Query := Task.Query
	SplitPath, SearchPath,,,,, Drive
	;=== get root folder ("\") refnumber
	SHARE_RW := 3 ;FILE_SHARE_READ | FILE_SHARE_WRITE
	if((hRoot := DllCall("CreateFileW", wstr, "\\.\" drive "\", uint, 0, uint, SHARE_RW, PTR, 0, uint, OPEN_EXISTING := 3, uint, FILE_FLAG_BACKUP_SEMANTICS := 0x2000000, PTR, 0, PTR)) = -1)
		return
	;BY_HANDLE_FILE_INFORMATION
	;   0   DWORD dwFileAttributes;
	;   4   FILETIME ftCreationTime;
	;   12   FILETIME ftLastAccessTime;
	;   20   FILETIME ftLastWriteTime;
	;   28   DWORD dwVolumeSerialNumber;
	;   32   DWORD nFileSizeHigh;
	;   36   DWORD nFileSizeLow;
	;   40   DWORD nNumberOfLinks;
	;   44   DWORD nFileIndexHigh;
	;   48   DWORD nFileIndexLow;
	VarSetCapacity(fi, 52, 0)
	result := DllCall("GetFileInformationByHandle", PTR, hRoot, PTR, &fi, "UINT")
	DllCall("CloseHandle", PTR, hRoot, "UINT")
	if(!result)
		return
	dirdict := {}
	rootDirKey := "" ((NumGet(fi, 44) << 32) + NumGet(fi, 48))
	dirdict[rootDirKey] := {name : drive, parent : "0"}

	;=== open USN journal
	GENERIC_RW := 0xC0000000 ;GENERIC_READ | GENERIC_WRITE
	if((hJRoot := DllCall("CreateFileW", wstr, "\\.\" drive, uint, GENERIC_RW, uint, SHARE_RW, PTR, 0, uint, OPEN_EXISTING := 3, uint, 0, uint, 0, PTR)) = -1)
		return
	cb := 0
	VarSetCapacity(cujd, 16) ;CREATE_USN_JOURNAL_DATA
	NumPut(0x800000, cujd, 0, "uint64")
	NumPut(0x100000, cujd, 8, "uint64")
	if(DllCall("DeviceIoControl", PTR, hJRoot, uint, FSCTL_CREATE_USN_JOURNAL := 0x000900e7, PTR, &cujd, uint, 16, PTR, 0, uint, 0, UINTP, cb, PTR, 0, "UINT") = 0)
	{
		DllCall("CloseHandle", PTR, hJRoot, "UINT")
		return
	}
	;=== prepare data to query USN journal
	;USN_JOURNAL_DATA
	;   0   DWORDLONG UsnJournalID;
	;   8   USN FirstUsn;
	;   16   USN NextUsn;
	;   24   USN LowestValidUsn;
	;   32   USN MaxUsn;
	;   40   DWORDLONG MaximumSize;
	;   48   DWORDLONG AllocationDelta;
	VarSetCapacity(ujd, 56, 0)
	if(DllCall("DeviceIoControl", PTR, hJRoot, uint, FSCTL_QUERY_USN_JOURNAL := 0x000900f4, PTR, 0, uint, 0, PTR, &ujd, uint, 56, UINTP, cb, PTR, 0, "UINT") = 0)
	{
		DllCall("CloseHandle", PTR, hJRoot, "UINT")
		return
	}
	JournalMaxSize := NumGet(ujd, 40, "uint64")

	;=== enumerate USN journal
	cb := 0
	filedict := {}
	filedict.SetCapacity(JournalMaxSize // (128 * 10))
	dirdict.SetCapacity(JournalMaxSize // (128 * 10))
	JournalChunkSize := 0x100000
	VarSetCapacity(pData, 8 + JournalChunkSize, 0)
	;MFT_ENUM_DATA
	;   0   DWORDLONG StartFileReferenceNumber;
	;   8   USN LowUsn;
	;   16   USN HighUsn;
	VarSetCapacity(med, 24, 0)
	NumPut(NumGet(ujd, 16, "uint64"), med, 16, "uint64") ;med.HighUsn=ujd.NextUsn
	num := 0
	WorkerThread.Progress := 0
	while(DllCall("DeviceIoControl", PTR, hJRoot, uint, FSCTL_ENUM_USN_DATA := 0x000900b3, PTR, &med, uint, 24, PTR, &pData, uint, 8 + JournalChunkSize, uintp, cb, PTR, "UINT"))
	{
		pUSN := &pData + 8
		;USN_RECORD
		;   0   DWORD RecordLength;
		;   4   WORD   MajorVersion;
		;   6   WORD   MinorVersion;
		;   8   DWORDLONG FileReferenceNumber;
		;   16   DWORDLONG ParentFileReferenceNumber;
		;   24   USN Usn;
		;   32   LARGE_INTEGER TimeStamp;
		;   40   DWORD Reason;
		;   44   DWORD SourceInfo;
		;   48   DWORD SecurityId;
		;   52   DWORD FileAttributes;
		;   56   WORD   FileNameLength;
		;   58   WORD   FileNameOffset;
		;   60   WCHAR FileName[1];
		while(cb > 60)
		{
			ref := "" NumGet(pUSN + 8, "uint64") ;USN.FileReferenceNumber
			refparent := "" NumGet(pUSN + 16, "uint64") ;USN.ParentFileReferenceNumber
			fn := StrGet(pUSN + 60, NumGet(pUSN + 56, "ushort") // 2, "UTF-16") ;USN.FileName
			if(IsDir := NumGet(pUSN + 52) & 0x10) ;USN.FileAttributes & FILE_ATTRIBUTE_DIRECTORY
				dirdict[ref] := {name : fn, parent : refparent}
			if(Query = "" || (MatchQuality := FuzzySearch(fn, Query, false)) > 0.6)
			{
				filedict[ref] := {name : fn, parent : refparent, IsDir : IsDir, MatchQuality : MatchQuality}
				num++
			}
			i := NumGet(pUSN + 0) ;USN.RecordLength
			pUSN += i
			cb -= i
		}
		NumPut(NumGet(pData, "uint64"), med, "uint64")
		WorkerThread.Progress := Round(A_index * JournalChunkSize / JournalMaxSize * 90)
	}
	DllCall("CloseHandle", PTR, hJRoot, "UINT")

	;=== connect files to parent folders
	filelist := {}
	if(!SearchPath)
		filelist.SetCapacity(filedict.getCapacity() * 128) ;This is probably not a good idea when a SearchPath is specified
	for k, v in filedict
	{
		v2 := v
		fn := v.name
		SubFolderDict := {}
		while(v2.parent)
		{
			p := dirdict[v2.parent]
			fn := p.name "\" fn
			v2 := p
		}
		if(Instr(fn, SearchPath) = 1)
		{
			SplitPath, fn, Name, Path
			filelist.Insert({Name : Name, Path : Path, IsDir : v.IsDir, MatchQuality : v.MatchQuality})
		}
		WorkerThread.Progress := 90 + (A_index / num * 10)
	}
	filelist := ArraySort(filelist, "Name", "Up")
	return filelist
}

;FTPUploadThread(WorkerThread, EventScheduleID, ActionIndex, files, Hostname, Port, User, decrypted, URL, NumberOfFTPSubDirs, TargetFolder)
;{
;	global FTP
;	cliptext := ""
;	result := 1
;	; connect to FTP server 
;	FTP := FTP_Init()
;	FTP.WorkerThread := WorkerThread
;	FTP.Port := Port
;	FTP.Hostname := Hostname
;	if(!FTP.Open(Hostname, User, decrypted))
;	{
;		WorkerThread.Stop({Title : "Connection Error", Text : "Couldn't connect to " Hostname ". Correct host/username/password?"})
;		result := 0
;	}
;	else
;	{
;		;go into target directory, optionally creating directories along the way.
;		if(TargetFolder != "" && FTP.SetCurrentDirectory(TargetFolder) != true)
;		{
;			Loop, Parse, TargetFolder, /\
;			{
;				;Skip current level if it exists
;				if(ftp.SetCurrentDirectory(A_LoopField))
;					continue
;				;Try to create current level
;				if(ftp.CreateDirectory(A_LoopField) != true)
;				{
;					WorkerThread.Stop({Title : "FTP Error", Text : "Couldn't create target directory " A_LoopField ". Check permissions!"})
;					result := 0
;					break
;				}
;				;Try to go into newly created directory
;				if(ftp.SetCurrentDirectory(A_LoopField) != true)
;				{
;					WorkerThread.Stop({Title : "FTP Error", Text : "Couldn't switch to created target directory" A_LoopField ". Check permissions!"})
;					result := 0
;					break
;				}
;			}
;		}
;		if(result != 0)
;		{
;			FTPBaseDir := FTP.GetCurrentDirectory()
;			for index, File in files
;			{
;				if(WorkerThread.State != "Running")
;					return
;				;Report the progress of the worker thread.
;				WorkerThread.SendData({Type : "File", File : File.File, RemoteName : File.TargetFile})

;				;Upload the file
;				result := FTPUploadThread_UploadSingleFile(File, TargetFolder, FTPBaseDir, URL)
;				if(!result.status)
;					WorkerThread.Stop({Title : "FTP Error", Text : (result.error ? result.error : "Couldn't upload " File.File " properly.`nMake sure you have write rights and the path exists")})
;				if(result.URL)
;					cliptext .= (index = 1 ? "" : "`r`n") result.URL
;			}
;			FTP.Close()
			
;			;Send URLs to main thread
;			return {Type : "URLs", URLs : cliptext}
;		}
;	}
;	return result
;}

#x::
time := 0
Loop 1
{
	start := A_TickCount
	ListMFTfiles("C:", ".ahk", "C:\Projekte\AutoHotkey")
	time += A_TickCount - start
}
msgbox % time
return
ListMFTfiles(drive, filter = "", subfolder = "")
{
	;=== get root folder ("\") refnumber
	SHARE_RW := 3 ;FILE_SHARE_READ | FILE_SHARE_WRITE
	if((hRoot := DllCall("CreateFileW", wstr, "\\.\" drive "\", uint, 0, uint, SHARE_RW, PTR, 0, uint, OPEN_EXISTING := 3, uint, FILE_FLAG_BACKUP_SEMANTICS := 0x2000000, PTR, 0, PTR)) = -1)
		return
	;BY_HANDLE_FILE_INFORMATION
	;   0   DWORD dwFileAttributes;
	;   4   FILETIME ftCreationTime;
	;   12   FILETIME ftLastAccessTime;
	;   20   FILETIME ftLastWriteTime;
	;   28   DWORD dwVolumeSerialNumber;
	;   32   DWORD nFileSizeHigh;
	;   36   DWORD nFileSizeLow;
	;   40   DWORD nNumberOfLinks;
	;   44   DWORD nFileIndexHigh;
	;   48   DWORD nFileIndexLow;
	VarSetCapacity(fi, 52, 0)
	result := DllCall("GetFileInformationByHandle", PTR, hRoot, PTR, &fi, "UINT")
	DllCall("CloseHandle", PTR, hRoot, "UINT")
	if(!result)
		return
	dirdict := {}
	rootDirKey := "" ((NumGet(fi, 44) << 32) + NumGet(fi, 48))
	dirdict[rootDirKey] := {name : drive, parent : "0"}

	;=== open USN journal
	GENERIC_RW := 0xC0000000 ;GENERIC_READ | GENERIC_WRITE
	if((hJRoot := DllCall("CreateFileW", wstr, "\\.\" drive, uint, GENERIC_RW, uint, SHARE_RW, PTR, 0, uint, OPEN_EXISTING := 3, uint, 0, uint, 0, PTR)) = -1)
		return
	cb := 0
	VarSetCapacity(cujd, 16) ;CREATE_USN_JOURNAL_DATA
	NumPut(0x800000, cujd, 0, "uint64")
	NumPut(0x100000, cujd, 8, "uint64")
	if(DllCall("DeviceIoControl", PTR, hJRoot, uint, FSCTL_CREATE_USN_JOURNAL := 0x000900e7, PTR, &cujd, uint, 16, PTR, 0, uint, 0, UINTP, cb, PTR, 0, "UINT") = 0)
	{
		DllCall("CloseHandle", PTR, hJRoot, "UINT")
		return
	}

	;=== prepare data to query USN journal
	;USN_JOURNAL_DATA
	;   0   DWORDLONG UsnJournalID;
	;   8   USN FirstUsn;
	;   16   USN NextUsn;
	;   24   USN LowestValidUsn;
	;   32   USN MaxUsn;
	;   40   DWORDLONG MaximumSize;
	;   48   DWORDLONG AllocationDelta;
	VarSetCapacity(ujd, 56, 0)
	if(DllCall("DeviceIoControl", PTR, hJRoot, uint, FSCTL_QUERY_USN_JOURNAL := 0x000900f4, PTR, 0, uint, 0, PTR, &ujd, uint, 56, UINTP, cb, PTR, 0, "UINT") = 0)
	{
		DllCall("CloseHandle", PTR, hJRoot, "UINT")
		return
	}
	JournalMaxSize := NumGet(ujd, 40, "uint64")

	;=== enumerate USN journal
	cb := 0
	filedict := {}
	filedict.SetCapacity(JournalMaxSize // (128 * 10))
	dirdict.SetCapacity(JournalMaxSize // (128 * 10))
	JournalChunkSize := 0x100000
	VarSetCapacity(pData, 8 + JournalChunkSize, 0)
	;MFT_ENUM_DATA
	;   0   DWORDLONG StartFileReferenceNumber;
	;   8   USN LowUsn;
	;   16   USN HighUsn;
	VarSetCapacity(med, 24, 0)
	NumPut(NumGet(ujd, 16, "uint64"), med, 16, "uint64") ;med.HighUsn=ujd.NextUsn

	if(showprogress)
		Progress, b p0
	while(DllCall("DeviceIoControl", PTR, hJRoot, uint, FSCTL_ENUM_USN_DATA := 0x000900b3, PTR, &med, uint, 24, PTR, &pData, uint, 8 + JournalChunkSize, uintp, cb, PTR, "UINT"))
	{
		pUSN := &pData + 8
		;USN_RECORD
		;   0   DWORD RecordLength;
		;   4   WORD   MajorVersion;
		;   6   WORD   MinorVersion;
		;   8   DWORDLONG FileReferenceNumber;
		;   16   DWORDLONG ParentFileReferenceNumber;
		;   24   USN Usn;
		;   32   LARGE_INTEGER TimeStamp;
		;   40   DWORD Reason;
		;   44   DWORD SourceInfo;
		;   48   DWORD SecurityId;
		;   52   DWORD FileAttributes;
		;   56   WORD   FileNameLength;
		;   58   WORD   FileNameOffset;
		;   60   WCHAR FileName[1];
		while(cb > 0)
		{
			ref := "" NumGet(pUSN + 8, "uint64") ;USN.FileReferenceNumber
			refparent := "" NumGet(pUSN + 16, "uint64") ;USN.ParentFileReferenceNumber
			fn := StrGet(pUSN + 60, NumGet(pUSN + 56, "ushort") // 2, "UTF-16") ;USN.FileName
			if(NumGet(pUSN + 52) & 0x10) ;USN.FileAttributes & FILE_ATTRIBUTE_DIRECTORY
				dirdict[ref] := {name : fn, parent : refparent}
			else
				if(filter = "" || InStr(fn, filter))
					filedict[ref] := {name : fn, parent : refparent}
			i := NumGet(pUSN + 0) ;USN.RecordLength
			pUSN += i
			cb -= i
		}
		NumPut(NumGet(pData, "uint64"), med, "uint64")
		if(showprogress)
			Progress, % Round(A_index * JournalChunkSize / JournalMaxSize * 100)
	}
	DllCall("CloseHandle", PTR, hJRoot, "UINT")

	;=== connect files to parent folders
	filelist := {}
	if(!subfolder)
		filelist.SetCapacity(filedict.getCapacity() * 128) ;This is probably not a good idea when a subfolder is specified
	for k, v in filedict
	{
		v2 := v
		fn := v.name
		SubFolderDict := {}
		while(v2.parent)
		{
			p := dirdict[v2.parent]
			fn := p.name "\" fn
			v2 := p
		}
		if(Instr(fn, subfolder) = 1)
			filelist.Insert(fn)
	}
	if(showprogress)
		Progress, 99
	if(showprogress)
		Progress, OFF
	return filelist
}
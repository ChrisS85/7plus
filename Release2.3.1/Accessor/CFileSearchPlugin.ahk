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
		ResultIndexingKey := "Path"
		Type := "File Search"
		Priority := CFileSearchPlugin.Instance.Priority
		MatchQuality := 1 ;Only direct matches are used by this plugin 
		Detail1 := "Search result"
	}

	OnOpen(Accessor)
	{
	}

	Init(PluginSettings)
	{
	}

	ShowSettings(PluginSettings, GUI, PluginGUI)
	{
		AddControl(PluginSettings, PluginGUI, "Checkbox", "UseIcons", "Use proper icons (not recommended)", "", "", "", "", "", "", "If checked, 7plus will use the correct icon for each file. This can cause instabilities for large results.")
	}
	
	RefreshList(Accessor, Filter, LastFilter, KeywordSet, Parameters)
	{
		if(!KeywordSet)
			return

		Results := {}
		;this if always returns true, it simply inits the search path
		if((!this.HasKey("tmpWorkerThread") && !this.HasKey("List")) && (((pos := InStr(Filter, " in ")) && InStr(FileExist(SearchPath := SubStr(Filter, pos + 4)), "D")) || (SearchPath := this.SearchPath) || (SearchPath := Accessor.CurrentDirectory) || ((SearchPath := "") || true)))
		{
			Result := new this.CSearchInAccessorResult()
			Result.Query := pos ? SubStr(Filter, 1, pos - 1) : Filter
			Result.Title .= " " Result.Query
			Result.SearchPath := SearchPath
			Result.Icon := Accessor.GenericIcons.7plus
			Results.Insert(Result)
		}
		else if(IsObject(this.List))
		{
			;Show results from query
			for index, Match in this.List
			{
				;Search process returns a string that looks like this: Path|MatchQuality
				StringSplit, Path, Match, |
				SplitPath, Path1, Name, Dir, ext
				IsDir := InStr(FileExist(Path1), "D")
				IsExecutable := !IsDir && ext && InStr("exe,cmd,bat,ahk", ext)
				Result := new this.CSearchResult(IsDir ? "Folder" : (IsExecutable ? "Executable" : "File"))
				Result.Title := Name
				Result.Path := Path1
				Result.DisplayPath := Dir
				Result.MatchQuality := Path2
				if(this.Settings.UseIcons)
				{
					hIcon := ExtractAssociatedIcon(0, Path1, iIndex)
					this.Icons.Insert(hIcon)
					Result.Icon := hIcon
				}
				else
					Result.Icon := IsDir ? Accessor.GenericIcons.Folder : (IsExecutable ? Accessor.GenericIcons.Application : Accessor.GenericIcons.File)
				Results[Result.Path] := Result ;Avoid duplicates which can appear somehow with different case in path
			}
		}
		return Results
	}
	;Code for db search
	;RefreshList(Accessor, Filter, LastFilter, KeywordSet, Parameters)
	;{
	;	if(!KeywordSet)
	;		return

	;	Results := Array()
	;	if(this.HasKey("db"))
	;	{
	;		outputdebug db
	;		;this if always returns true, it simply inits the search path
	;		if(((pos := InStr(Filter, " in ")) && InStr(FileExist(SearchPath := SubStr(Filter, pos + 4)), "D")) || (SearchPath := this.SearchPath) || (SearchPath := Accessor.CurrentDirectory) || (SearchPath := "" || true))
	;		{
	;			outputdebug % "search for " (pos ? SubStr(Filter, 1, pos - 1) : Filter) " in " SearchPath
	;			;Result := new this.CSearchInAccessorResult()
	;			;Result.Query := pos ? SubStr(Filter, 1, pos - 1) : Filter
	;			;Result.Title .= " " Result.Query
	;			;Result.SearchPath := SearchPath
	;			;Result.Icon := Accessor.GenericIcons.7plus
	;			;Results.Insert(Result)
	;			results := this.db.Query(pos ? SubStr(Filter, 1, pos - 1) : Filter, SearchPath)
	;			;Show results from query
	;			for index, ListEntry in results
	;			{
	;				Name := ListEntry.Name
	;				outputdebug % name
	;				SplitPath, Name, , , ext
	;				IsExecutable := !ListEntry.IsDir && ext && InStr("exe,cmd,bat,ahk", ext)
	;				Result := new this.CSearchResult(ListEntry.IsDir ? "Folder" : (IsExecutable ? "Executable" : "File"))
	;				Result.Title := Name
	;				Result.Path := ListEntry.Path "\" ListEntry.Name
	;				Result.DisplayPath := ListEntry.Path
	;				;Result.MatchQuality := ListEntry.MatchQuality
	;				if(this.Settings.UseIcons)
	;				{
	;					hIcon := ExtractAssociatedIcon(0, ListEntry.Path "\" ListEntry.Name, iIndex)
	;					this.Icons.Insert(hIcon)
	;					Result.Icon := hIcon
	;				}
	;				else
	;					Result.Icon := ListEntry.IsDir ? Accessor.GenericIcons.Folder : (IsExecutable ? Accessor.GenericIcons.Application : Accessor.GenericIcons.File)
	;				Results.Insert(Result)
	;			}
	;		}
	;	}
		
	;	return Results
	;}
	GetDisplayStrings(ListEntry, ByRef Title, ByRef Path, ByRef Detail1, ByRef Detail2)
	{
		Path := ListEntry.SearchPath ? ListEntry.SearchPath : ListEntry.DisplayPath
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
		this.StartWorkerThread(ListEntry)
		Accessor.RefreshList()
	}

	StartWorkerThread(ListEntry)
	{
		WorkerThread := new CWorkerThread("AccessorMFTSearch", 0, 1, 1)
		WorkerThread.OnProgress.Handler := new Delegate(this, "ProgressHandler")
		WorkerThread.OnStop.Handler := new Delegate(this, "OnStop")
		WorkerThread.OnData.Handler := new Delegate(this, "OnData")
		WorkerThread.OnFinish.Handler := new Delegate(this, "OnFinish")
		WorkerThread.Start({SearchPath : ListEntry.SearchPath, Query : ListEntry.Query, PlainSearchTimeout : 2000})
		if(WorkerThread.WaitForStart(5))
		{
			WorkerThread.NotificationWindow := Notify("Searching for " ListEntry.Query (ListEntry.Searchpath ? " in " ListEntry.SearchPath : ""), "", "", this.SearchIcon, "", {min : 0, max : 100, value : 0})
			this.tmpWorkerThread := WorkerThread
		}
		else
			Notify("File search error!", "Couldn't start the searching process!", 5, NotifyIcons.Error)
	}
	;Code for db-based search
	;StartWorkerThread()
	;{
	;	WorkerThread := new CWorkerThread("BuildFileDatabase", 0, 1, 1)
	;	;WorkerThread := new CWorkerThread("AccessorMFTSearch", 0, 1, 1)
	;	WorkerThread.OnProgress.Handler := new Delegate(this, "ProgressHandler")
	;	WorkerThread.OnStop.Handler := new Delegate(this, "OnStop")
	;	WorkerThread.OnFinish.Handler := new Delegate(this, "OnFinish")
	;	WorkerThread.Start(Settings.ConfigPath "\DriveIndex.sqlite")
	;	if(WorkerThread.WaitForStart(5))
	;	{
	;		WorkerThread.NotificationWindow := Notify("Indexing files", "", "", this.SearchIcon, "", {min : 0, max : 100, value : 0})
	;		this.tmpWorkerThread := WorkerThread
	;	}
	;	else
	;		Notify("File indexing error!", "Couldn't start the indexing process!", 5, NotifyIcons.Error)
	;}

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

	OnData(WorkerThread, Data)
	{

	}
	OnFinish(WorkerThread, Result)
	{
		outputdebug finished!
		outputdebug % "result: " strlen(result)
		this.tmpWorkerThread.NotificationWindow.Close()
		this.Remove("tmpWorkerThread")
		outputdebug to array
		this.List := ToArray(Result)
		outputdebug % "array created " this.list.MaxIndex()
		CAccessor.Instance.RefreshList()
	}
	;Code for db-based search
	;OnFinish(WorkerThread, Result)
	;{
	;	this.db := new DatabaseFileList(Settings.ConfigPath "\DriveIndex.sqlite")
	;	this.tmpWorkerThread.NotificationWindow.Close()
	;	this.Remove("tmpWorkerThread")
	;	;this.List := Result
	;	;CAccessor.Instance.RefreshList()
	;}

	OnFilterChanged(ListEntry, Filter, LastFilter)
	{
		this.CancelSearch()
		if(this.HasKey("SearchPath") && InStr(LastFilter, this.Settings.Keyword " ") = 1 && InStr(Filter, this.Settings.Keyword " ") != 1)
			this.Remove("SearchPath")
		return true
	}
}

;Worker thread for searching
AccessorMFTSearch(WorkerThread, Task)
{
	OPEN_EXISTING := 3
	FILE_FLAG_BACKUP_SEMANTICS := 0x2000000
	SHARE_RW := 3 ;FILE_SHARE_READ | FILE_SHARE_WRITE
	GENERIC_RW := 0xC0000000 ;GENERIC_READ | GENERIC_WRITE

	Path := Task.SearchPath ? ((SubStr(Task.SearchPath, 0) = "\") ? Task.SearchPath : Task.SearchPath "\") : ""
	Query := Task.Query
	if(Path)
	{
		SplitPath, Path,,,,, Drive
		Drives := SubStr(Drive, 1, 1)
	}
	else
		DriveGet, Drives, List, FIXED
	DriveCount := StrLen(Drives)


	VarSetCapacity(filelist, 1000 * 200) ; 1000 filepaths of ~100 widechars
	delim := "`n"

	num := 0

	Loop, Parse, Drives
	{
		DriveIndex := A_Index - 1 ;For progress
		Drive := A_LoopField ":"
		DriveGet, FS, FS, %A_LoopField%: ;USN journal can only be used on NTFS drives, other need to use standard folder iteration
		NTFS := FS = "NTFS"
		;=== if path can be enumerated within specified time, return filelist at once
		if(!NTFS || Task.PlainSearchTimeout > 0)
		{
			t0 := A_TickCount
			bUsePath := true
			loop, %path%*, 1, 1 ;folders too, with recursion
				if((NTFS && A_TickCount - t0 > Task.PlainSearchTimeout) || WorkerThread.State = "Stopped")
				{
					bUsePath := false
					break
				}
				else if(Query = "" || (MatchQuality := FuzzySearch(A_LoopFileName, Query, false)) > 0.6)
				{
					filelist .= A_LoopFileLongPath "|" MatchQuality delim
					num++
				}
			if(bUsePath)
				continue
		}

		if(WorkerThread.State = "Stopped")
			return

		if(FS = "NTFS")
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
			ref := "" ((NumGet(fi, 44) << 32) + NumGet(fi, 48))
			dirdict[ref] := {name : drive, parent : "0", files : {}}

			;=== open volume
			GENERIC_RW := 0xC0000000 ;GENERIC_READ | GENERIC_WRITE
			if((hJRoot := DllCall("CreateFileW", wstr, "\\.\" drive, uint, GENERIC_RW, uint, SHARE_RW, PTR, 0, uint, OPEN_EXISTING := 3, uint, 0, uint, 0, PTR)) = -1)
				return

			;=== open USN journal
			VarSetCapacity(cujd, 16) ;CREATE_USN_JOURNAL_DATA
			NumPut(0x800000, cujd, 0, "uint64")
			NumPut(0x100000, cujd, 8, "uint64")
			if(DllCall("DeviceIoControl", PTR, hJRoot, uint, FSCTL_CREATE_USN_JOURNAL := 0x000900e7, PTR, &cujd, uint, 16, PTR, 0, uint, 0, UINTP, cb, PTR, 0, "UINT") = 0)
			{
				DllCall("CloseHandle", PTR, hJRoot, "UINT")
				return
			}

			;=== estimate overall number of files

			;NTFS_VOLUME_DATA_BUFFER
			;   0   LARGE_INTEGER VolumeSerialNumber;
			;   8   LARGE_INTEGER NumberSectors;
			;   16   LARGE_INTEGER TotalClusters;
			;   24   LARGE_INTEGER FreeClusters;
			;   32   LARGE_INTEGER TotalReserved;
			;   40   DWORD         BytesPerSector;
			;   44   DWORD         BytesPerCluster;
			;   48   DWORD         BytesPerFileRecordSegment;
			;   52   DWORD         ClustersPerFileRecordSegment;
			;   56   LARGE_INTEGER MftValidDataLength;
			;   64   LARGE_INTEGER MftStartLcn;
			;   72   LARGE_INTEGER Mft2StartLcn;
			;   80   LARGE_INTEGER MftZoneStart;
			;   88   LARGE_INTEGER MftZoneEnd;
			VarSetCapacity(voldata, 96, 0)
			mftFiles := 0
			mftFilesMax := 0
			if(DllCall("DeviceIoControl", "PTR", hJRoot, "uint", FSCTL_GET_NTFS_VOLUME_DATA := 0x00090064, "PTR", 0, "uint", 0, "PTR", &voldata, "uint", 96, "uintp", cb, "uint", 0) && cb = 96)
				if(i := NumGet(voldata, 48))
					mftFilesMax := NumGet(voldata, 56, "uint64") // i ;MftValidDataLength/BytesPerFileRecordSegment

			;=== query USN journal

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
			JournalMaxSize := NumGet(ujd, 40, "uint64") + NumGet(ujd, 48, "uint64") ;MaximumSize + AllocationDelta
			JournalChunkSize := 0x10000 ;1MB chunk, ~10-20 read ops for 150k files
			if(mftFilesMax = 0)
	     		mftFilesMax := JournalMaxSize / JournalChunkSize
	   		
			;=== enumerate USN journal

			cb := 0
			numAll := 0 ;matching files from all dirs
			VarSetCapacity(pData, 8 + JournalChunkSize, 0)
			dirdict.SetCapacity(JournalMaxSize // (128 * 50)) ;average file name ~64 widechars, dircount is ~1/50 of filecount

			;MFT_ENUM_DATA
			;   0   DWORDLONG StartFileReferenceNumber;
			;   8   USN LowUsn;
			;   16   USN HighUsn;
			VarSetCapacity(med, 24, 0)
			NumPut(NumGet(ujd, 16, "uint64"), med, 16, "uint64") ;med.HighUsn=ujd.NextUsn

			while(DllCall("DeviceIoControl", PTR, hJRoot, uint, FSCTL_ENUM_USN_DATA := 0x000900b3, PTR, &med, uint, 24, PTR, &pData, uint, 8 + JournalChunkSize, uintp, cb, PTR, 0, "UINT"))
			{
				if(WorkerThread.State = "Stopped")
					return
				WorkerThread.Progress := DriveIndex / DriveCount * 85 + (mftFiles * 80) / mftFilesMax / DriveCount
				pUSN := &pData + 8
				while(cb > 8)
				{
					mftFiles++
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
					fnsize 	  :=	NumGet(pUSN + 56, "ushort")
					fname 	  :=	StrGet(pUSN + 60, fnsize // 2, "UTF-16") ;USN.FileName
					IsDir 	  :=	NumGet(pUSN + 52) & 0x10 ;USN.FileAttributes & FILE_ATTRIBUTE_DIRECTORY
					ref 	  := ""	NumGet(pUSN + 8, "uint64") ;USN.FileReferenceNumber
					refparent := "" NumGet(pUSN + 16, "uint64") ;USN.ParentFileReferenceNumber
					
					if(IsDir)
					{
			            v := dirdict[ref]
			            if(v = "")
			            {
			            	v := {}
			            	v.files := {}
			            }
			            v.setCapacity(4) ;4th value 'dir' is created later in resolveFolder()
			            v.setCapacity("name", fnsize)
			            v.name := fname
			            v.setCapacity("parent", strlen(refparent) << 1)
			            v.parent := refparent
			            if(Query = "" || (MatchQuality := FuzzySearch(fname, Query, false)) > 0.6)
			            {
			            	v.files.SetCapacity(ref, fnsize)
							v.files[ref] := fname "|" MatchQuality
							numAll++
			            }
			            dirdict[ref] := v
			        }
			        else if(Query = "" || (MatchQuality := FuzzySearch(fname, Query, false)) > 0.6)
					{
						v := dirdict[refparent]
						if(v)
							v := v.files
						else
						{
							v := {}
							dirdict[refparent] := {files : v}
						}
						v.SetCapacity(ref, fnsize)
						v[ref] := fname "|" MatchQuality
						numAll++
					}
					i := NumGet(pUSN + 0) ;USN.RecordLength
					pUSN += i
					cb -= i
				}
				NumPut(NumGet(pData, "uint64"), med, "uint64")
			}
			DllCall("CloseHandle", PTR, hJRoot, "UINT")
			WorkerThread.Progress := DriveIndex / DriveCount * 85 + 80 / DriveCount
			;=== connect files to parent folders & build new cache
			;VarSetCapacity(filelist, numAll * 200) ;average full filepath ~100 widechars
			bPathFilter := StrLen(Path) > 3 && InStr(FileExist(Path), "D")
			for dk, dv in dirdict
			{
				if(dv.files.getCapacity())
				{
					dir := AccessorMFTSearch_resolveFolder(dirdict, dk)
					if(!bPathFilter || InStr(dir, Path) = 1)
						for k, v in dv.files
						{
							filelist .= dir v delim
							num++
						}
				}
			}
			WorkerThread.Progress := (DriveIndex + 1) / DriveCount * 85
			dirdict := ""
		}
	}
	Sort, filelist, D%delim%
	return filelist
}

AccessorMFTSearch_resolveFolder(byref dirdict, byref ddref)
{
   p := dirdict[ddref]
   pd := p.dir
   if(!pd)
   {
      pd := (p.parent ? AccessorMFTSearch_resolveFolder(dirdict, p.parent) : "") p.name "\"
      p.setCapacity("dir", StrLen(pd) * 2)
      p.dir := pd
   }
   return pd
}




; REQUIRES NEWER sqlite3.dll,DataBaseSQLLite.ahk and SQLite_L.ahk THAN IS PROVIDED IN DBA
#Include <DBA>

class DatabaseFileList {
	Path := ""
    __new(file = ":memory:")
    {
    	this.Path := file
        this.db := DBA.DatabaseFactory.OpenDatabase("SqLite", this.Path)
        this.db.Query("CREATE TABLE files (id INTEGER PRIMARY KEY, parent_id INTEGER, name TEXT)")
        this.db.Query("CREATE TABLE dirs (id INTEGER PRIMARY KEY, path TEXT, name TEXT)")
        this.db.Query("CREATE INDEX ix_parent_id ON files (parent_id)") ; index the file parent ids
        this.db.Query("CREATE INDEX ix_path ON dirs (path)") ; index the dir paths
        ;this.db.Query("CREATE INDEX index_parent ON files (parent_id)") ; index the dir paths
        this.FileCache := new Collection()
        this.DirCache := new Collection()
    }
    addDir(ref, path, name)
    {
        this.DirCache.Insert({id : ref, path : path, name : name})
    }
    
    addFile(ref, name, parent)
    {
        this.FileCache.Insert({id : ref, parent_id : parent, name : name})
    }
    flush()
    {
        if(this.FileCache.Count() > 0)
        {
            this.db.InsertMany(this.FileCache, "files")
            this.FileCache := new Collection()
        }
        if(this.DirCache.Count() > 0)
        {
            this.db.InsertMany(this.DirCache, "dirs")
            this.DirCache := new Collection()
        }
    }
    allocate(length)
    {
    }
    SaveToDisk(Path)
    {
    	if(this.Path = ":memory:" && Path != ":memory:")
    	{
    		this.flush()
    		this.db.Query("ATTACH '" Path "' AS diskdb")
			this.db.Query("CREATE TABLE diskdb.files AS SELECT * FROM files")
			this.db.Query("CREATE TABLE diskdb.dirs AS SELECT * FROM dirs")
    	}
    }
    Query(name, path)
    {
        ret := []
        ;Get files
        q := "Select dirs.path,files.name from dirs JOIN files WHERE dirs.id = files.parent_id AND dirs.path LIKE '" path "%' AND files.name LIKE '%" name "%'"
        ;q := "SELECT * FROM dirs WHERE path='" path "' OR path LIKE '" path "'%"
        
        for i, row in this.db.Query(q).Rows
            ret.Insert({Path : row.path, Name : row.name, IsDir : false})

       	;Get dirs
        q := "Select * from dirs WHERE name LIKE '%" name "%'"
        for i, row in this.db.Query(q).Rows
        {
        	Path := row.path
        	SplitPath, Path,,Path
            ret.Insert({Path : Path, Name : row.name, IsDir : true})
        }
        return ret
    }
}

;Builds a database of all files on fixed drives
BuildFileDatabase(WorkerThread, SavePath)
{
	FileList := new DatabaseFileList()
	DriveGet, Drives, List, FIXED
	NTFSDrives := ""
	Loop, Parse, Drives
	{
		DriveGet, FS, FS, %A_LoopField%:
		if(FS = "NTFS")
			NTFSDrives .= A_LoopField
	}
	DriveCount := StrLen(NTFSDrives)
	Loop, Parse, NTFSDrives
	{
		tooltip, %A_LoopField%:,,,2
		DriveIndex := A_Index - 1
		Drive := A_LoopField ":"
		;=== get root folder ("\") refnumber
		SHARE_RW := 3 ;FILE_SHARE_READ | FILE_SHARE_WRITE
		if((hRoot := DllCall("CreateFileW", wstr, "\\.\" drive "\", uint, 0, uint, SHARE_RW, PTR, 0, uint, OPEN_EXISTING := 3, uint, FILE_FLAG_BACKUP_SEMANTICS := 0x2000000, PTR, 0, PTR)) = -1)
			continue
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
			continue
		dirdict := {}
		rootDirKey := "" ((NumGet(fi, 44) << 32) + NumGet(fi, 48))
		dirdict[rootDirKey] := {name : drive, parent : "0"}

		;=== open USN journal
		GENERIC_RW := 0xC0000000 ;GENERIC_READ | GENERIC_WRITE
		if((hJRoot := DllCall("CreateFileW", wstr, "\\.\" drive, uint, GENERIC_RW, uint, SHARE_RW, PTR, 0, uint, OPEN_EXISTING := 3, uint, 0, uint, 0, PTR)) = -1)
			continue
		cb := 0
		VarSetCapacity(cujd, 16) ;CREATE_USN_JOURNAL_DATA
		NumPut(0x800000, cujd, 0, "uint64")
		NumPut(0x100000, cujd, 8, "uint64")
		if(DllCall("DeviceIoControl", PTR, hJRoot, uint, FSCTL_CREATE_USN_JOURNAL := 0x000900e7, PTR, &cujd, uint, 16, PTR, 0, uint, 0, UINTP, cb, PTR, 0, "UINT") = 0)
		{
			DllCall("CloseHandle", PTR, hJRoot, "UINT")
			continue
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
			continue
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
		        if(fn)
		        {
			        if(IsDir := NumGet(pUSN + 52) & 0x10) ;USN.FileAttributes & FILE_ATTRIBUTE_DIRECTORY
			    		dirdict[ref] := {name : fn, parent : refparent}
					else
						FileList.addFile(ref, fn, refparent)
				}
		        i := NumGet(pUSN + 0) ;USN.RecordLength
		        pUSN += i
		        cb -= i
			}
	    	FileList.Flush()
	        NumPut(NumGet(pData, "uint64"), med, "uint64")
	        WorkerThread.Progress := Round(DriveIndex/DriveCount * 100 + A_index * JournalChunkSize / JournalMaxSize * 50 / DriveCount)
	    }
	    DllCall("CloseHandle", PTR, hJRoot, "UINT")
	    tooltip, File iteration completed
	    ;=== connect files to parent folders

		start := A_TickCount
	    items := dirdict.getCapacity()
	    dirdict2 := []
	    dirdict2.SetCapacity(dirdict.getCapacity())
		for k, v in dirdict
		{
			;Skip most reports for performance
			if(Mod(A_Index, 1000))
				WorkerThread.Progress := Round(DriveIndex/DriveCount * 100 + 50 / DriveCount + A_index / items * 50 / DriveCount)
			v2 := v
			path := v.name
			;msgbox directory %path%
			while(v2.parent)
			{
				;if(p := dirdict2[v2.parent])
				;{
				;	msgbox % "parents: " p.Path
				;	path := p.Path "\" path
				;	;tooltip, %path%,,,2
				;	break
				;}
				;msgbox % "parent: " v2.name
				p := dirdict[v2.parent]
				path := p.name "\" path
				v2 := p
			}
			;Path := Path = Drive ? Path : Drive "\" Path
			FileList.addDir(k, Path, v.name)
			;dirdict2[k] := {Path : path, Name : v.name}
		}
		;for reference, v in dirdict2
		;{
		;	FileList.addDir(reference, v.Path, v.name)
		;}
		tooltip directory creation completed
		FileList.Flush()

		;msgbox, % ((A_TickCount - start) / 60000) " minutes"
		tooltip flushed
	}
	tooltip indexing completed
	FileList.SaveToDisk(SavePath)
    return FileList
}






;Worker thread for searching
;BuildFileDatabase(WorkerThread, Drive)
;{
;	;=== get root folder ("\") refnumber
;	SHARE_RW := 3 ;FILE_SHARE_READ | FILE_SHARE_WRITE
;	if((hRoot := DllCall("CreateFileW", wstr, "\\.\" drive "\", uint, 0, uint, SHARE_RW, PTR, 0, uint, OPEN_EXISTING := 3, uint, FILE_FLAG_BACKUP_SEMANTICS := 0x2000000, PTR, 0, PTR)) = -1)
;		return
;	;BY_HANDLE_FILE_INFORMATION
;	;   0   DWORD dwFileAttributes;
;	;   4   FILETIME ftCreationTime;
;	;   12   FILETIME ftLastAccessTime;
;	;   20   FILETIME ftLastWriteTime;
;	;   28   DWORD dwVolumeSerialNumber;
;	;   32   DWORD nFileSizeHigh;
;	;   36   DWORD nFileSizeLow;
;	;   40   DWORD nNumberOfLinks;
;	;   44   DWORD nFileIndexHigh;
;	;   48   DWORD nFileIndexLow;
;	VarSetCapacity(fi, 52, 0)
;	result := DllCall("GetFileInformationByHandle", PTR, hRoot, PTR, &fi, "UINT")
;	DllCall("CloseHandle", PTR, hRoot, "UINT")
;	if(!result)
;		return
;	dirdict := {}
;	rootDirKey := "" ((NumGet(fi, 44) << 32) + NumGet(fi, 48))
;	dirdict[rootDirKey] := {name : drive, parent : "0"}

;	;=== open USN journal
;	GENERIC_RW := 0xC0000000 ;GENERIC_READ | GENERIC_WRITE
;	if((hJRoot := DllCall("CreateFileW", wstr, "\\.\" drive, uint, GENERIC_RW, uint, SHARE_RW, PTR, 0, uint, OPEN_EXISTING := 3, uint, 0, uint, 0, PTR)) = -1)
;		return
;	cb := 0
;	VarSetCapacity(cujd, 16) ;CREATE_USN_JOURNAL_DATA
;	NumPut(0x800000, cujd, 0, "uint64")
;	NumPut(0x100000, cujd, 8, "uint64")
;	if(DllCall("DeviceIoControl", PTR, hJRoot, uint, FSCTL_CREATE_USN_JOURNAL := 0x000900e7, PTR, &cujd, uint, 16, PTR, 0, uint, 0, UINTP, cb, PTR, 0, "UINT") = 0)
;	{
;		DllCall("CloseHandle", PTR, hJRoot, "UINT")
;		return
;	}
;	;=== prepare data to query USN journal
;	;USN_JOURNAL_DATA
;	;   0   DWORDLONG UsnJournalID;
;	;   8   USN FirstUsn;
;	;   16   USN NextUsn;
;	;   24   USN LowestValidUsn;
;	;   32   USN MaxUsn;
;	;   40   DWORDLONG MaximumSize;
;	;   48   DWORDLONG AllocationDelta;
;	VarSetCapacity(ujd, 56, 0)
;	if(DllCall("DeviceIoControl", PTR, hJRoot, uint, FSCTL_QUERY_USN_JOURNAL := 0x000900f4, PTR, 0, uint, 0, PTR, &ujd, uint, 56, UINTP, cb, PTR, 0, "UINT") = 0)
;	{
;		DllCall("CloseHandle", PTR, hJRoot, "UINT")
;		return
;	}
;	JournalMaxSize := NumGet(ujd, 40, "uint64")

;	;=== enumerate USN journal
;	cb := 0
;	filedict := {}
;	filedict.SetCapacity(JournalMaxSize // (128 * 10))
;	dirdict.SetCapacity(JournalMaxSize // (128 * 10))
;	JournalChunkSize := 0x100000
;	VarSetCapacity(pData, 8 + JournalChunkSize, 0)
;	;MFT_ENUM_DATA
;	;   0   DWORDLONG StartFileReferenceNumber;
;	;   8   USN LowUsn;
;	;   16   USN HighUsn;
;	VarSetCapacity(med, 24, 0)
;	NumPut(NumGet(ujd, 16, "uint64"), med, 16, "uint64") ;med.HighUsn=ujd.NextUsn
;	num := 0
;	WorkerThread.Progress := 0
;	while(DllCall("DeviceIoControl", PTR, hJRoot, uint, FSCTL_ENUM_USN_DATA := 0x000900b3, PTR, &med, uint, 24, PTR, &pData, uint, 8 + JournalChunkSize, uintp, cb, PTR, "UINT"))
;	{
;		pUSN := &pData + 8
;		;USN_RECORD
;		;   0   DWORD RecordLength;
;		;   4   WORD   MajorVersion;
;		;   6   WORD   MinorVersion;
;		;   8   DWORDLONG FileReferenceNumber;
;		;   16   DWORDLONG ParentFileReferenceNumber;
;		;   24   USN Usn;
;		;   32   LARGE_INTEGER TimeStamp;
;		;   40   DWORD Reason;
;		;   44   DWORD SourceInfo;
;		;   48   DWORD SecurityId;
;		;   52   DWORD FileAttributes;
;		;   56   WORD   FileNameLength;
;		;   58   WORD   FileNameOffset;
;		;   60   WCHAR FileName[1];
;		while(cb > 60)
;		{
;			ref := "" NumGet(pUSN + 8, "uint64") ;USN.FileReferenceNumber
;			refparent := "" NumGet(pUSN + 16, "uint64") ;USN.ParentFileReferenceNumber
;			fn := StrGet(pUSN + 60, NumGet(pUSN + 56, "ushort") // 2, "UTF-16") ;USN.FileName
;			if(IsDir := NumGet(pUSN + 52) & 0x10) ;USN.FileAttributes & FILE_ATTRIBUTE_DIRECTORY
;				dirdict[ref] := {name : fn, parent : refparent, num : 0}
;			else
;			{
;				filedict[ref] := {name : fn, parent : refparent}
;				num++
;			}
;			i := NumGet(pUSN + 0) ;USN.RecordLength
;			pUSN += i
;			cb -= i
;		}
;		NumPut(NumGet(pData, "uint64"), med, "uint64")
;		WorkerThread.Progress := Round(A_index * JournalChunkSize / JournalMaxSize * 90)
;	}
;	DllCall("CloseHandle", PTR, hJRoot, "UINT")
;	;=== connect files to parent folders
;	;Tree := {}
;	for k, v in filedict
;	{
;		;WorkerThread.Progress := 90 + (A_index / num * 10)
;		v2 := v
;		fn := v.name
;		SubFolderDict := [v.name]
;		while(v2.parent)
;		{
;			p := dirdict[v2.parent]
;			dirdict[v2.parent].num++
;			SubFolderDict.Insert(v2.name)
;			fn := v2.name "\" fn
;			v2 := p
;		}
;		;Create tree structure
;		node := Tree
;		Loop % len := SubFolderDict.MaxIndex()
;		{
;			if(!node.HasKey(SubFolderDict[len - A_index + 1]))
;			{
;				node[SubFolderDict[len - A_index + 1]] := {}
;				node[SubFolderDict[len - A_index + 1]].SetCapacity(0)
;			}
;			node := node[SubFolderDict[len - A_index + 1]]
;		}
;	}
;	filedict := ""
;	dirdict := ""
;	tree := ""
;	msgbox finished
;	return Tree
;}
;OnFinish(WorkerThread, Result)
;{
;	msgbox OnFinish
;	for index, v in result
;		msgbox % index
;}
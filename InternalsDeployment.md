# Startup, update deployment and installation #
Currently there are 3 scenarios how an installation/update of 7plus can happen:
  * By extraction of the released archive without previous existinng data
  * By using the AutoUpdate function
  * By extracting a released archive over an existing 7plus installation

The first case equals that of a fresh installation. In this case the steps in "Additional First run procedure" are performed upon the first program start.

When using the AutoUpdater, an executable file gets downloaded that extracts and overwrites the old files.

If a newer version is extracted over an older version, 7plus can detect this by the version information of the Events.xml file and apply the needed update steps on the first run.

# Startup procedure #
  * Evaluating command line parameters: This is done relatively close to the beginning of the program. 7plus determines if it runs in portable mode and checks if it's meant to run regularly or act as a worker process for a running instance of 7plus. If it is, it will call the worker function and exit afterwards. It can also be run to signal an existing instance to execute a certain event in which case it will also exit here.
  * Check if on the current platform, possibly exit on non-Unicode builds of AHK and show warnings on system with wrong bitness
  * Finding the settings directory: If portable, use application directory, otherwise %AppData%\7plus\.
  * Load settings from Settings.ini
  * Create %Temp%\7plus
  * Check if config files can be written. If UAC is enabled and 7plus is run in portable mode in Program Files directory this will not be possible and 7plus will exit.
  * Detect Fresh installation through missing Settings.ini -> Go to Additional First run procedure
  * Initialize various subsystems and Event system
  * Check for updates, -> go to Updating
  * Post updating steps, -> go to PostUpdate
  * Write %Temp%\7plus\hwnd.txt to allow other components to find the running 7plus instance easily
  * Initialize various other components, callbacks and Accessor
  * Show tray icon
  * Start the Event scheduler
  * If First run, -> Go to Additional First run procedure Part 2

# Additional First run procedure #
Part 1:
  * Create config path directory
  * Copy Events\All Events.xml to ConfigPath\
  * Register shell extension silently
  * Add uninstall information if not portable
  * Apply version specific tasks
Part 2:
  * Show a message box asking if Features page should be opened
  * Show notification message that asks the user to open the settings

# Updating #
  * If connected, download http://7plus.googlecode.com/files/NewVersion.ini and check if there is a new version
  * If yes, show the update message and download the Autoupdate to %TEMP%\7plus\Updater.exe
  * On success, write Config path and program directory in %A\_Temp%\7plus\Update.ini, run the updater and exit

# PostUpdate #
  * If %TEMP%\7plus\Updater.exe exists:
    * If the events.xml version is lower than the program version (indicating that an update has been installed), try to patch "\Events\ReleasePatch\" MajorVersion "." MinorVersion "." BugfixVersion ".0.xml"
    * Register shell extension silently
    * Add uninstall information if not portable
    * Apply version specific tasks
    * Show Dialog with option to show changelog
    * Delete %TEMP%\7plus\Updater.exe

# Update creation script #
The UpdateCreator.ahk script in the main directory of the repository is used to compile and zip distributions and create the Autoupdater binaries for all platforms. It works completely by itself and just needs to be started, but it relies on AHK being installed in %A\_ProgramFiles%\Autohotkey and Compile\_AHK in %A\_ProgramFiles%\Autohotkey\Compiler\Compile\_AHK.exe.
It uses lists for excluding files, filetypes and directories from the distribution, copies all needed files to a temp directory, compiles 7plus.ahk for the current platform and writes the Updating script which is explained below. The updating script is compiled and includes the zipped distribution file.

# Autoupdating script #
These files are downloaded for the matching platform and update the curently installed version of 7plus to the new one.
The script reads config path and installation directory from %A\_Temp%\7plus\Update.ini, extracts 7za.exe and the archive
Release patch is copied to %Temp%\7plus\ReleasePatch
Other files are copied to Install directory
Afterwards, 7plus is started again and the updater exits
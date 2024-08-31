@echo off
setlocal enabledelayedexpansion

:start

cls

::SERVER AUTOSTART SETTINGS: autostart loads the headless client with the latest autosave. these settings only apply to autostart
set "autosettings=--port 11753 --verbose --headless" 

:: DEFAULT SETTINGS:  DO NOT USE --headless HERE! These will be applied unless using AUTOSTART or CUSTOM SETTINGS
set "settings=--port 11753 --verbose"

:: ALTERNATIVE .EXE LOCATION: if this .bat is not in the same folder as openrct2.exe enter your openrct2.exe location below. 
set "OpenRCT2Dir=C:\Users\admin\Desktop\Roller_Coaster_Tycoon\openrct2.exe"

:: REPLACE autosaveFolder and savesFolder with your folder locations if needed
:: this WILL NOT change where openrct2 saves files, only where this .bat looks for save files to load
:: EXAMPLE: set "savesFolder=C:\Users\admin\Desktop\Roller_Coaster_Tycoon\"
set "autosaveFolder=%userprofile%\Documents\OpenRCT2\save\autosave" 
set "savesFolder=%userprofile%\Documents\OpenRCT2\save"
 


:: ENTER CUSTOM SETTINGS BELOW 

::You can name and define up to 3 custom settings profiles below

set "customname=NameTheseSettings"
set "customsettings=PutSettingsHere"

set "customname1=NameTheseSettings"
set "customsettings1=PutSettingsHere"

set "customname2=ExampleNameHere"
set "customsettings2=--example --settings"


::::::::::::::::::::DONT CHANGE ANYTHING BELOW UNLESS YOU KNOW WHAT YOU'RE DOING:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "latestFile="
set "filePath="
set "fileFound=false"  
set "headlessMode=false"
set "custom=false"
set "dmenu=Start Openrct2 with default settings"
set "dmenu1=Start Openrct2 and load save with default settings"
set "dmenu2=Start headless and load save with default settings"
set "gui="
set "defaultsettings=%settings%"

echo Welcome Back

call :checkOpenRCT2

call :searchforlatest

call :foundFile

call :autostart

call :listoptions

call :listautosaves

call :listmanualsaves

call :dirprompt

call :retry

call :loadfile


::Check for openrct executable

:checkOpenRCT2

if exist "%~DP0openrct2.exe" (
    echo "OpenRCT2.exe found in %~DP0"
    Timeout /t 5
    exit /b
    
)
if not exist "%~DP0openrct2.exe" (
    echo OpenRCT2.exe not found in %~DP0.  
    echo:
    echo Checking %OpenRCT2Dir%
    Timeout /T 5
    cls

)
if exist "%OpenRCT2Dir%" (
    echo: OpenRCT2.exe found in %OpenRCT2Dir%
Timeout /T 5

exit /b

)
    

if not exist "%OpenRCT2Dir%\*.exe" (
    echo Openrct2.exe not found. Script will exit. 
    echo:
    echo Place this .bat in the same folder as openrct2.exe OR define OpenRCT2Dir in the .bat
    pause
    exit /b
    Timeout /T 5
 ) else ( 
        exit /b 
)
    


:: Find the latest .park file
:searchforlatest

for /f "delims=" %%i in ('dir /b /a-d /o-d "%autosaveFolder%\*.park" 2^>nul') do (
    set "latestFile=%%i"
)

exit /b

:foundFile

:: Check if a file was found

if "%latestFile%"=="" (
    echo No save files found in %autosaveFolder%. autostart will not function properly.
    pause
    cls
    exit /b 
 
 ) else (
 exit /b
)
  


:autostart

choice /c:CY /n /m "Server will start in 10 seconds. Press Y to run now, or C to Cancel" /t:10 /d:Y
    if errorlevel 2 (
    call :autoload
    exit /b
    
    ) else if errorlevel 1 (
    
    exit /b
    )

 :autoload
  
  cls
  
  echo Server starting with save file %latestFile%
  if exist "%~DP0openrct2.exe" (
  
  start "" "%~DP0openrct2.exe" host "%autosaveFolder%\!latestFile!" %autosettings%

  ) else (
if exist "%OpenRCT2Dir%" (
 start "" "%OpenRCT2Dir%" host "%autosaveFolder%\!latestFile!" %autosettings% )

 )
 
goto :quit


:listoptions

cls
echo The current settings are:%settings% 
echo:
echo:
echo 1. %dmenu%
echo:
echo 2. %dmenu1%
echo:
echo 3. %dmenu2%
echo:
echo 4. Settings Menu
echo:
echo 5. Exit without starting 
echo:
echo 6. Restart
echo:
choice /C 123456 /m "Choose an option to continue:"

::DEBUG
::set "currenterrorlevel=%errorlevel%"

::echo: errorlevel is : %currenterrorlevel%
pause

if errorlevel 6 (
    goto :start
)

if errorlevel 5 (
    goto :quit
)

if errorlevel 4 (
    set "custom=true"
    goto :dsettingsmenu
)

if errorlevel 3 ( 
    set "headlessMode=true"
    set "custom=false"
    set "gui=false"
    set "settings=%defaultsettings%"
    exit /b
)

if errorlevel 2 (
    if "%custom%" == "true" (
        set "headlessMode=false"
    ) else (
        set "gui=true"
    )
    exit /b
        
    )
    

if errorlevel 1 (
    
    if "%custom%" == "true" (
        echo "custom=true" 
        pause
    ) else ( 
        if exist "%~DP0openrct2.exe" (
            start "" "%~DP0openrct2.exe" host "" %settings%
            echo: Starting OpenRCT2 with these settings:
            echo: %settings%
            goto :quit
        ) else if exist "%OpenRCT2Dir%" (
            start "" "%OpenRCT2Dir%" host "" %settings% 
            echo: Starting OpenRCT2 with these settings:
            echo: %settings%
            goto :quit 
            )
        )
    )
       

::DEBUG
::echo: end of listoptions      
 pause
goto :loadfile 








 

:listautosaves

cls
::DEBUG
::echo: %custom%
echo Listing autosave files in %autosaveFolder%
set "count=0"
    for /f "delims=" %%i in ('dir /b /a-d /o-d "%autosaveFolder%\*.park" 2^>nul') do (
    set /a count+=1
    echo !count!: %%i
    set "file[!count!]=%%i"
    
)
    if %count% == 0 (
    echo No autosave files found. Checking for manual saves
    pause
    cls
    exit /b
    
)

set /p userChoice=Enter the # of the file you want to load or ('0' to skip to Saves folder): 
    if "%userChoice%" == "0" (
    exit /b
)  

::validate choice and set latestfile

    if not defined file[%userChoice%] (
    echo Invalid Selection
    goto :listautosaves
)
set "latestFile=!file[%userchoice%]!"
set "filePath=%autosaveFolder%\%latestFile%"
    goto :loadfile



:listmanualsaves

cls

echo Listing save files in %savesFolder%
set "count=0"
for /f "delims=" %%i in ('dir /b /a-d /o-d "%savesFolder%\*.park" 2^>nul') do (
    set /a count+=1
    echo !count!: %%i
    set "file[!count!]=%%i"

)


    if %count% == 0 ((
    echo No save files found in %savesFolder%!
    pause
    )
    
echo Would you like to try another location or restart?    
echo:
echo 1. Try another location
echo:
echo 2. Restart Script
echo:

choice /C 12 /m "Choose an option to continue:"

if errorlevel 2 (
    goto :start
)

if errorlevel 1 (
    goto :dirprompt)

)



set /p userChoice=Enter the # of the file you want to load or '0' to input another directory: 
    
    if "%userChoice%" equ "0" (
    exit /b
) 

::validate choice and set latestfile

    if not defined file[%userChoice%] (
    echo Invalid Selection
    exit /b
)

set "latestFile=!file[%userchoice%]!"
set "filePath=%savesFolder%\%latestFile%"
    goto :loadfile



:dirprompt

cls

set /p "otherlocation=Enter another save location: "
set "count=0"

    if "%otherlocation%" == "PinchCactus" (
        cls
        echo: Computers dont make errors
        echo: What they do they do on purpose.
        pause
        goto :retry
           
)

cls

    if not exist %otherlocation% ((
        echo %otherlocation% NOT FOUND!)
        pause
        goto :retry 
    

    ) else (
    
    echo Listing save files in %otherlocation%
    set "count=0"
        for /f "delims=" %%i in ('dir /b /a-d /o-d "%otherlocation%\*.park" 2^>nul') do (
            set /a count+=1
            echo !count!: %%i
            set "file[!count!]=%%i")

)

    if %count% == 0 ((
        echo No save files found in %otherlocation%!
        pause
        )
        cls

        goto :retry
)

    set /p userChoice=Enter the # of the file you want to load or '0' to exit: 
        if "%userChoice%" equ "0" (
        
        exit /b 
    )

:retry

cls

echo Would you like to try another location or restart?    
echo:
echo 1. Try another location
echo:
echo 2. Restart Script
echo:
choice /C 12 /m "Choose an option to continue:"

    if errorlevel 2 (
    goto :start
)

    if errorlevel 1 (
    goto :dirprompt
)


if %count% equ 0 (
    echo No save files found in %otherlocation%.
    
    pause
    
    goto :dirprompt
)
::validate choice and set latestfile

if not defined file[%userChoice%] (
    echo Invalid Selection
    exit /b
)
set "latestFile=!file[%userchoice%]!"
set "filePath=%otherlocation%\%latestFile%"
    goto :loadfile




::CUSTOM SETTINGS


:dsettingsmenu

cls

if "%custom%" == "true" (
    

    set dmenu=Start openrct2 with custom settings
    
    set dmenu1=Start openrct2 with custom settings and load save
)
echo The current settings are %settings% 
echo:
echo:
echo Select settings to load.     
echo:
echo 1. "%customname%"
echo    "%customsettings%"
echo:
echo 2. "%customname1%"
echo    "%customsettings1%"
echo:
echo 3. "%customname2%"
echo    "%customsettings2%"
echo:
echo 4. Enter custom settings(these will NOT persist between restarts)
echo:


    
choice /C 1234 /m "Choose an option:" 

if errorlevel 4 ( 
            goto :level4

 ) else if errorlevel 3 (
            cls
            set "settings=%customsettings2%"
            echo You have selected "%customname2%"
            echo:
            echo "!settings!"
            echo:
            pause
            goto :listoptions
  

   ) else if errorlevel 2 (
            cls
            set settings=%customsettings1%
            echo You have selected "%customname1%"
            echo:
            echo "!settings!"
            echo:
            pause
            goto :listoptions

 
 
  ) else if errorlevel 1 (
            cls
            set settings=%customsettings%
            echo You have selected "%customname%"
            echo:
            echo "!settings!"
            echo:
            pause
            goto :listoptions
)

:level4

cls
set /p userChoice=Enter your desired settings or type restart to return to main menu: 
    
        
if "%userChoice%"=="restart" (
    goto :start 
        
    ) else (
     set "settings=%userChoice%"
     cls
    echo You have chosen and applied the settings below:
    echo:
     echo !settings!
    echo:
     pause
    goto :listoptions
        
        )


:loadfile
:: Launch OpenRCT2 with the selected file
::DEBUG
::echo: gui value %gui%
::pause


if "%headlessMode%" == "true" (
    echo Launching OpenRCT2 in headless mode with file: %filePath%
    if exist "%~DP0openrct2.exe" (
        start "" "%~DP0openrct2.exe" host "%filePath%" --headless %settings%
    ) else (
        if exist "%OpenRCT2Dir%" (
        start "" "%OpenRCT2Dir%" host "%filePath%" --headless %settings% 
        )    
    
    )  

)



if "%custom%" == "true" (
    echo Launching OpenRCT2 and loading : %filepath%
    echo:
    echo: With these settings: %settings% 
    
    if exist "%~DP0openrct2.exe" (
        start "" "%~DP0openrct2.exe" host "%filePath%" %settings%
    ) else ( 
        if exist "%OpenRCT2Dir%" (
            start "" "%OpenRCT2Dir%" host "%filePath%" %settings%

        )
    )
)
 
 if "%gui%" == "true" (
    echo Launching OpenRCT2 server with GUI and loading : %filePath%
    
    if exist "%~DP0openrct2.exe" (
        start "" "%~DP0openrct2.exe" host "%filePath%" %settings%
    ) else (
        if exist "%OpenRCT2Dir%" (
        start "" "%OpenRCT2Dir%" host "%filePath%" %settings% 
        )    
    
    )  

)

:quit

Timeout /T 10 
    exit







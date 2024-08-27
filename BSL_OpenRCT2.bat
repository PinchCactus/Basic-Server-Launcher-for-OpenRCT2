@echo off
setlocal enabledelayedexpansion


:: replace autosaveFolder and savesFolder with your folder locations
set "autosaveFolder=C:\Users\admin\Documents\OpenRCT2\save\autosave" 
set "savesFolder=C:\Users\admin\Desktop\Roller_Coaster_Tycoon\Saves"
:: replace OpenRCT2Dir with your openrct.exe location
set "OpenRCT2Dir=C:\Users\admin\Desktop\Roller_Coaster_Tycoon"
set "latestFile="
set "filePath="
set "fileFound=false"
set "headlessMode=false"
::server autostart settings. autostart loads the headless client with the latest autosave 
set "autosettings=--port 11754 --verbose --headless" 
:: Settings for manual loading. DO NOT USE --headless HERE
set "settings=--port 11753 --verbose"

:: CUSTOM SETTINGS BELOW NOT IMPLEMENTED AT THIS TIME
::you can name and set custom settings below

set "CustomSettingsName=NameTheseSettings"
set "Csettings=PutSettingsHere"

set "CustomSettingsName1=NameTheseSettings"
set "Csettings1=PutSettingsHere"




:start

echo Welcome Back

call :checkOpenRCT2

call :searchforlatest

call :foundFile

call :autostart

call :listoptions

call :listautosaves

call :listmanualsaves

call :dirprompt

call :loadfile


::Check for openrct executable

:checkOpenRCT2

if not exist "%OpenRCT2Dir%\*.exe" (
    echo openrct2.exe not found. Script will exit. Check OpenRCT2Dir in the bat!
    pause
    exit /b1
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
  Timeout /T 10
  start "" "%OpenRCT2Dir%\OpenRCT2.exe" host "%autosaveFolder%\!latestFile!" %autosettings%
  exit


:listoptions

cls

echo 1. Start GUI without loading save
echo 2. Start GUI and load save
echo 3. Start headless and load save
echo 4. Restart
echo 5. Exit without starting 
choice /C 12345 /m "Choose an option to continue:"

if errorlevel 5 (
    exit
)

if errorlevel 4 (
    call "%~f0"
)

if errorlevel 3 ( 
    set "headlessMode=true"
    exit /b
)

if errorlevel 2 (
    set "headlessMode=false"
    exit /b
)

if errorlevel 1 (
    start "" "%OpenRCT2Dir%\OpenRCT2.exe"

    echo Starting OpenRCT2.exe
    
    pause

    exit
)






:listautosaves

cls

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
    cls
echo Would you like to try another location or restart?    
echo
echo 1. Try another location
echo
echo 2. Restart Script
echo

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

echo.
set /p "otherlocation=Enter another save location: "
set "count=0"

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
if "%userChoice%" equ "0" ((

:retry

echo Would you like to try another location or restart? )   
echo.
echo 1. Try another location
echo 2. Restart Script
echo
choice /C 12 /m "Choose an option to continue:"

if errorlevel 2 (
    goto :start
)

if errorlevel 1 (
    goto :dirprompt
)
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




::customsettings to be implemented





:loadfile
:: Launch OpenRCT2 with the selected file
if "%headlessMode%" equ "true" (
    echo Launching OpenRCT2 in headless mode with file: %filePath%
    start "" "%OpenRCT2Dir%\OpenRCT2.exe" host "%filePath%" --headless %settings%
    
    pause
    
    exit
) else (
    echo Launching OpenRCT2 server with GUI and loading : %filePath%
    
    start "" "%OpenRCT2Dir%\OpenRCT2.exe" host "%filePath%" %settings%
    
    Timeout /T 5
)
   
    exit







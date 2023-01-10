@echo off
TITLE Delirio's DayZ Server Manager

set "CONFIG=DDSM.cfg"
set LAST_VERSION=2.1
set DZDS_APP_ID=223350
set MOD_CPP=meta.cpp
set DDSM_PATH=%CD%
:intro
echo [32mWelcome
echo    to
echo. 
echo      ___      _ _     _     _        
echo     ^|   \ ___^| (_)_ _(_)___( )___    
echo     ^| ^|) / -_) ^| ^| '_^| / _ \/(_-^<    
echo     ^|___/\___^|_^|_^|_^| ^|_\___/ /__/    
echo.
echo          ___           _____         
echo         ^|   \ __ _ _  _^|_  /         	
echo         ^| ^|) / _` ^| ^|^| ^|/ /          
echo        _^|___/\__,_^|\_, /___^|         
echo       / __^| ___ _ _^|__/____ _ _      
echo       \__ \/ -_) '_\ V / -_) '_^|     
echo   __  ^|___/\___^|_^|  \_/\___^|_^|       
echo  ^|  \/  ^|__ _ _ _  __ _ __ _ ___ _ _ 
echo  ^| ^|\/^| / _` ^| ' \/ _` / _` / -_) '_^|
echo  ^|_^|  ^|_\__,_^|_^|^|_\__,_\__, \___^|_^|  
echo                        ^|___/         
echo                              VERSION:%LAST_VERSION%
echo.
Goto :configLoader

:configLoader
:start
if not exist %CONFIG% (
	Goto :firstTimeSetup
) else (
	echo LOADING CONFIG
	Goto :loadConfig
)

exit /b 4

:loadConfig
for /f "delims=" %%x in ('findstr /n .* "%CONFIG%"') do (
	for /F "tokens=1,2,3 delims=: " %%a in ("%%x") do (
		if "%%b"=="" Goto :finishLoading
		if "%%c"=="" (
			set "%%b"
		) else (
			set "%%b:%%c"
		)
	)
)
Goto :finishLoading
exit /b 5

:finishLoading
if "%LAST_VERSION%"=="%VERSION%" (
	echo CONFIG FILE %CONFIG% IS UP TO DATE
	echo CHECKING CONFIGURATION SETTINGS
	Goto :checkConfig
) else (
	echo VERSION MISMATCH.
	echo UPDATING %CONFIG%
	Goto :generateConfig
)
exit /b 6

:checkConfig
echo CHECKING LOADED CONFIG
if "%STEAMCMD_PATH%"=="" (
	Goto :setConfig
) else ( 
	cd /d %STEAMCMD_PATH%
	if not exist "steamcmd.exe" (
		if not exist "steamcmd.zip" (
			bitsadmin.exe /transfer "DOWNLOAD-STEAMCMD" /priority FOREGROUND "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" "%STEAMCMD_PATH%\steamcmd.zip"
			Goto :checkConfig
		) else (
			tar -xf steamcmd.zip
			del steamcmd.zip
			Goto :checkConfig
		) 
	) else (
		set "STEAMAPPS_MODS_PATH=%STEAMCMD_PATH%\steamapps\workshop\content\221100"
		set "SERVER_MODS_PATH=%SERVER_PATH%\mods"
		echo FINISHED LOADING
		pause
		Goto :mainMenu
	)
)

exit /b 7

:generateConfig
if not exist %CONFIG% (
	echo FIRST TIME SETUP?
	pause
	Goto :firstTimeSetup
) else (
	echo Updating
	Goto :setConfig
)
exit /b 8

:firstTimeSetup
echo Thank you for downloading Delirio's DayZ Server Manager
echo.
echo Press any key to start setup...
pause > nul 
echo.

cls
ECHO GENERATING A NEW CONFIG FILE
ECHO.
Goto :writeConfig

exit /b 9

:setConfig
for /F "tokens=1,1 delims==" %%A in (%CONFIG%) do (
	if "%%A"=="VERSION" (
		echo CONFIG LOADED
		echo CURRENT %LAST_VERSION%
		Goto :writeConfig
	) else (
		if "%%A"=="STEAMCMD_PATH" (
			cls
			echo SELECT STEAMCMD INSTALLATION FOLDER
			echo !!NO SPACES ALLOWED IN THE FOLDER PATH!!
			CALL :selectFolder STEAMCMD_PATH
		) else (
			if "%%A"=="SERVER_PATH" (
				cls
				echo SELECT SERVER INSTALATION FOLDER
				CALL :selectFolder SERVER_PATH
			) else (
				if "%%A"=="STEAM_USER" (
					cls
					echo ENTER YOUR STEAM USERNAME - LEAVE BLANK TO ENTER THE USERNAME WHEN STARTING STEAMCMD
					echo (STEAMCMD HAS THE OPTION TO REMEMBER YOUR CREDENTIALS^)
					echo.
					set /p STEAM_USER=Steam username:
				)
			)
		)
	)
)
Goto :writeConfig
exit /b 10

:showConfig
echo Show Config
echo.
echo Steamcmd installation folder:	%STEAMCMD_PATH%
echo Server instnaces folder: 	%SERVER_PATH%
echo Steam username: 		%STEAM_USER%
echo DDSM Version: 			%VERSION%
echo.
echo Addiontal variables
echo.
echo Configuration file name:	%CONFIG%
echo DayZ App ID: 			%DZDS_APP_ID%
echo Mod CPP filename: 		%MOD_CPP%
echo DDSM Folder location 		%DDSM_PATH%
echo.
pause > nul
Goto :configLoaderMenu


:resetConfig
cls
echo Resetting Configuration
echo.
echo SELECT SERVER INSTALATION FOLDER
CALL :selectFolder SERVER_PATH
cls
echo Resetting Configuration
echo.
echo SELECT STEAMCMD INSTALLATION FOLDER
echo ^!^!NO SPACES ALLOWED IN THE FOLDER PATH^!^!
CALL :selectFolder STEAMCMD_PATH
cls
echo Resetting Configuration
echo.
echo ENTER YOUR STEAM USERNAME LEAVE BLANK TO ENTER THE USERNAME WHEN STARTING STEAMCMD
echo (STEAMCMD HAS THE OPTION TO REMEMBER YOUR CREDENTIALS^)
echo.
set /p STEAM_USER=Steam username:
cls
echo NEW CONFIG
echo.
echo STEAMCMD_PATH=%STEAMCMD_PATH%
echo SERVER_PATH=%SERVER_PATH%
echo STEAM_USER=%STEAM_USER%
echo VERSION=%VERSION%
pause
cls
Goto :writeConfig

:writeConfig
cd /d %DDSM_PATH%
(
echo STEAMCMD_PATH=%STEAMCMD_PATH%
echo SERVER_PATH=%SERVER_PATH%
echo STEAM_USER=%STEAM_USER%
echo VERSION=%LAST_VERSION%
)>%CONFIG%
if "%STEAMCMD_PATH%"=="" Goto :setConfig
if "%SERVER_PATH%"=="" Goto :setConfig
echo %CONFIG% STORED AND LOADED
Goto :configLoader
exit /b 11

:configLoaderMenu
cls
echo Choose an option
ECHO 	1. Show config
ECHO 	2. Reset config

ECHO 	0. Return to Main Menu
echo.
set choice=
set /p choice=Option (0-9):
echo.
if not '%choice%'=='' set choice=%choice:~0,1%
cls
if '%choice%'=='1' goto showConfig
if '%choice%'=='2' goto resetConfig
if '%choice%'=='3' goto selectConfigPath
if '%choice%'=='0' goto mainMenu

ECHO %choice% is not valid! Try again.. PRESS ANY KEY TO CONTINUE
pause >nul
Goto configLoaderMenu

exit /b 12

:mainMenu
cls
echo DayZ Server Manager Main Menu
echo.
echo Choose an option
ECHO 	1. Update DayZ Dedicated Server Instance(s)
ECHO 	2. Update DayZ Workshop Mod(s)
ECHO 	3. Download DayZ Workshop Mod(s)
ECHO 	4. Install DayZ Dedicated Server
ECHO 	5. Install/Update Dedicated Server Workshop Mod
ECHO 	6. Delete Workshop Mod *
ECHO 	7. Delete Dedicated Server Instance Workshop Mod *
ECHO 	8. Create server script
ECHO 	9. Edit configuration
ECHO 	0. Exit Delirio's DayZ Mod Manager
:: ADD UPDATE ALL SERVER UPDATE ALL MODS AS #1 and #2
echo.
echo 		* = Feature is missing or incomplete
set choice=
set /p choice=Option (0-9):
echo.
if not '%choice%'=='' set choice=%choice:~0,1%
cls
if '%choice%'=='1' goto updateServer
if '%choice%'=='2' goto updateMod
if '%choice%'=='3' goto installMod
if '%choice%'=='4' goto installServer
if '%choice%'=='5' goto installServerMod
if '%choice%'=='6' goto deleteMod
if '%choice%'=='7' goto deleteServerMod
if '%choice%'=='8' goto createScript
if '%choice%'=='9' goto configLoaderMenu
if '%choice%'=='0' goto shutDown

ECHO %choice% is not valid! Try again.. PRESS ANY KEY TO CONTINUE
pause >nul
Goto mainMenu
exit /b 13

:installServer
cls
echo Installing DayZ Dedicated Server
echo.
echo.
echo Type "X" to return to the main menu.
set /p serverFolder=Sever name (eg. dayzserver):
if "%serverFolder%"=="X" Goto :mainMenu
if "%serverFolder%"=="" Goto :installServer
set serverDestination=%SERVER_PATH%\%serverFolder%
if exist "%serverDestination%\" (
	echo.
	echo This server already exists.
	echo Would you like to update it instead?
	CHOICE /C YNC /M "Press Y for Yes, N for No or C for Cancel."
	if not errorlevel 1 goto installServer
	if errorlevel 3 Goto :mainMenu
	if errorlevel 2 Goto :installServer
	Goto :updateServer
	exit /b 14
)
echo Installing DayZ Dedicated Server to: %serverDestination%
echo Is this correct?
CHOICE /C YNC /M "Press Y for Yes, N for No or C for Cancel."
if not errorlevel 1 goto installServer
if errorlevel 3 Goto :mainMenu
if errorlevel 2 Goto :installServer
cls
echo Connecting to steam to download DayZ Dedicated Server.
echo Have your Steam Guard ready!
echo.
pause
echo LAST WARNING! Starting in 10 seconds
%STEAMCMD_PATH%\steamcmd +force_install_dir "%serverDestination%" +login "%STEAM_USER%" +app_update 223350 validate +quit
if %ERRORLEVEL% EQU 0 (
	cls
	echo DayZ Dedicated Server successfully installed to: %serverDestination%
	echo Press any key to continue to the main menu...
	pause >nul
	Goto :mainMenu
	exit /b 15
) else (
	cls
	echo Steamcmd exited with an error.
	echo Please check %serverDestination% to see server installation results.
	pause
	Goto :mainMenu
)
exit /b 16

:installMod
cls
Echo Installing/Updating mod
echo.
echo Please provide the following information:
set /p workshopid=Workshop id:
ECHO workshopid = %workshopid%
ECHO.
SET /A validateWorkshopid=workshopid
if %validateWorkshopid% EQU %workshopid% (
	IF %workshopid% GTR 0 (
	FOR /F "delims=" %%A IN ('powershell -NoLogo -NoProfile -Command "'%workshopid%'.PadLeft(10,'0')"') DO (SET "validateWorkshopid=%%~A")
	Goto :steamappsFolderCheck
	)
	IF %workshopid% LSS 0 ( Goto :invalidWorkshopID )
	IF %workshopid% EQU 0 ( Goto :invalidWorkshopID )
) ELSE (
	:invalidWorkshopID
	ECHO WorkshopID:%workshopid% is not valid
	pause >nul
	Goto :installMod
)
exit /b 17

:steamappsFolderCheck
set currentSteamappsFolder=%STEAMAPPS_MODS_PATH%\%workshopid%
IF NOT EXIST "%STEAMAPPS_MODS_PATH%\%workshopid%" (
	echo Mod not installed. Downloading now
	Goto :downloadMod
) ELSE (
	echo Mod already installed in %STEAMAPPS_MODS_PATH%
	echo Would you like to update the Mod: 
	CHOICE /C YN /M "Press Y for Yes, N for No."
	if not errorlevel 1 (
		echo Whoopsie! not error 1
		pause
		Goto :mainMenu
	)
	if errorlevel 3 (
		echo Whoopsie! error level 3
		pause
		Goto :mainMenu
	)
	if errorlevel 2 (
		::This is No N option.
		Goto :mainMenu
	)
	
	echo this feature is not made yet
	echo Press any key to continue...
	pause >nul
	Goto :updateMod
)



:downloadMod
echo Connecting to steam to download Mod.
echo WorkshopID:%workshopid%
echo.
echo Have your Steam Guard ready!
pause
echo LAST WARNING! Starting in 10 seconds
timeout 10
cls
%STEAMCMD_PATH%\steamcmd +login %STEAM_USER% +workshop_download_item 221100 %workshopid% validate +quit
if %ERRORLEVEL% EQU 0 (
	cls
	echo Mod:%workshopid% was successfully installed to: %serverDestination%
	echo Press any key to continue to the main menu...
	pause >nul
	Goto :mainMenu
	exit /b 18
) else (
	cls
	echo Steamcmd exited with an error.
	echo Please check %currentSteamappsFolder% to see server installation results.
	pause
	Goto :mainMenu
)
exit /b 19


:updateServer
echo Server Update
cd /d %SERVER_PATH%
setlocal enableextensions enabledelayedexpansion
set /a i = 0
for /D %%a in (*) do (
	set /a i += 1
	set instanceList[!i!]=%%a
	
) 
set instanceAmount=%i%
ECHO YOU CURRENTLY HAVE %instanceAmount% DayZ SERVERS INSTALLED.
echo.
echo NR	SERVER NAME
if "%instanceAmount%" LEQ "1" (
	echo dir /d
	Goto :selectInstance
)  else (
rem show all instances
	for /L %%i in (1,1,%instanceAmount%-1) do (
		echo %%i	!instanceList[%%i]!
	)
	Goto :selectInstance
)

:selectInstance
echo.
echo Which server would you like to update?

echo Type the number of the server or * for all.
echo.
echo Example: 1, 2, 5
set /p instanceSelection=Number(s):
if "%instanceSelection%"=="*" ( Goto :updateAllInstances )
::1, 5, 6
cls
echo UPDATING SELECTION
FOR /L %%c IN (1,1,%instanceAmount%) DO (
	echo.%instanceSelection% | findstr /C:"%%c" 1>nul
	if errorlevel 1 (
		break
	) ELSE (
		echo %%c	!instanceList[%%c]!
	)
)
echo.
echo.
echo These servers will now be updated
cd /d %STEAMCMD_PATH%

FOR /L %%c IN (1,1,%instanceAmount%) DO (
	echo.%instanceSelection% | findstr /C:"%%c" 1>nul
	if errorlevel 1 (
		break
	) ELSE (
		echo UPDATING SERVER !instanceList[%%c]!
		echo.
		set "updateCommand=steamcmd +force_install_dir "%SERVER_PATH%\!instanceList[%%c]!" +login "%STEAM_USER%" +app_update 223350 validate +quit"
		!updateCommand!
		if %ERRORLEVEL% EQU 0 (
			cls
			echo Server:!instanceList[%%c]! was successfully updated
		) else (
			cls
			echo Steamcmd exited with an error.
			echo Please check %SERVER_PATH%\!instanceList[%%c]! to see server files.
			pause
			
		)
	)
)
Echo Finished updating servers
echo Press any key to return to the Main Menu.
pause > nul
endlocal
Goto :mainMenu
exit /b 40

:updateAllInstances
cd /d %SERVER_PATH%
echo.
echo Updating the following servers
for /D %%a in (*) do (
	echo %%a	
) 
echo.
pause
cls
for /D %%a in (*) do (
	echo.
	echo Updating server: %%a
	echo.
	set "updateCommand=steamcmd +force_install_dir "%SERVER_PATH%\%%a" +login "%STEAM_USER%" +app_update 223350 validate +quit"
	cd /d %STEAMCMD_PATH%
	!updateCommand!
	if %ERRORLEVEL% EQU 0 (
		cls
		echo Server: %%a was successfully updated
	) else (
		cls
		echo Steamcmd exited with an error.
		echo Please check %SERVER_PATH%\%%a\ to see server files.
		pause
		
	)
) 

echo Finished updating servers
echo Press any key to return to the Main Menu
pause > nul
endlocal
Goto :mainMenu
exit /b 50


:updateMod
if not exist %STEAMAPPS_MODS_PATH% (
	echo There are no mods installed
	pause
	Goto :mainMenu
) else (
	Goto :getWorkshopIDs
)
exit /b 20

:getWorkshopIDs
if not exist %STEAMAPPS_MODS_PATH% echo There are no mods installed & pause & Goto :mainMenu
cd /d %STEAMAPPS_MODS_PATH%
setlocal enableextensions enabledelayedexpansion
set /a i = 0
for /D %%a in (*) do (
	set /a i += 1
	set modList[!i!]=%%a
) 
set modAmount=%i%
ECHO YOU CURRENTLY HAVE %modAmount% MODS INSTALLED.
echo.
echo NR	WorkshopID	Name
if "%modAmount%" LEQ "1" (
	cd /d %STEAMAPPS_MODS_PATH%\!modList[1]!
	FOR /F "tokens=* USEBACKQ" %%F IN (`findstr name %MOD_CPP%`) DO (
		SET extModName=%%F
	)
	for /f tokens^=2delims^=^" %%a in ("!extModName!") do set "modName=%%a"
	echo	1	!modList[1]!	!modName!
	Goto :selectMod
)
for /L %%i in (1,1,%modAmount%-1) do (
	cd /d %STEAMAPPS_MODS_PATH%\!modList[%%i]!
	FOR /F "tokens=* USEBACKQ" %%F IN (`findstr name %MOD_CPP%`) DO (
		SET extModName=%%F
		for /f tokens^=2delims^=^" %%a in ("!extModName!") do set "modName[%%i]=%%a"
		echo	%%i	!modList[%%i]!	!modName[%%i]!
	)
)
Goto :selectMod

:selectMod
echo.
echo Which mods would you like to update?
echo Type the number of the mod or * for all.
echo.
echo Example: 1, 4, 13
set /p modSelection=Number(s):
if "%modSelection%"=="*" echo UPDATE ALL
::1, 5, 6
cls
echo UPDATING SELECTION
echo.
echo NR	WorkshopID	Name
FOR /L %%c IN (1,1,%modAmount%) DO (
	echo.%modSelection% | findstr /C:"%%c" 1>nul
	if errorlevel 1 (
		break
	) ELSE (
		echo %%c	!modList[%%c]!	!modName[%%c]!
	)
)
echo.
echo These mods will now be updated
SET "updateCommand=%STEAMCMD_PATH%\steamcmd +login %STEAM_USER%"
FOR /L %%c IN (1,1,%modAmount%) DO (
	echo.%modSelection% | findstr /C:"%%c" 1>nul
	if errorlevel 1 (
		break
	) ELSE (
		set "updateCommand=!updateCommand! +workshop_download_item 221100 !modList[%%c]! validate"
	)
)
set "updateCommand=%updateCommand% +quit"
pause
%updateCommand%
if %ERRORLEVEL% EQU 0 (
	cls
	echo Mods were successfully updated
	echo Press any key to continue to the main menu...
	echo.
	echo THIS DID NOT UPDATE THE KEYS TO YOUR SERVER INSTANCE!
	pause >nul
	endlocal
	Goto :mainMenu
	exit /b 18
) else (
	cls
	echo Steamcmd exited with an error.
	echo Please check something to see some results.
	pause
	endlocal
	Goto :mainMenu
)
exit /b 30
pause
endlocal
Goto :mainMenu

:installServerMod
if not exist %STEAMAPPS_MODS_PATH% echo There are no mods installed & pause & Goto :mainMenu
cd /d %STEAMAPPS_MODS_PATH%

setlocal enableextensions enabledelayedexpansion
set /a i = 0
for /D %%a in (*) do (
	set /a i += 1
	set modList[!i!]=%%a
) 
set modAmount=%i%
Echo INSTALLED MODS
echo.
echo NR	WorkshopID	Name
if "%modAmount%" LEQ "1" (
	cd /d %STEAMAPPS_MODS_PATH%\!modList[1]!
	FOR /F "tokens=* USEBACKQ" %%F IN (`findstr name %MOD_CPP%`) DO (
		SET extModName=%%F
	)
	for /f tokens^=2delims^=^" %%a in ("!extModName!") do set "modName=%%a"
	echo	1	!modList[1]!	!modName!
) else (
	for /L %%i in (1,1,%modAmount%-1) do (
		cd /d %STEAMAPPS_MODS_PATH%\!modList[%%i]!
		FOR /F "tokens=* USEBACKQ" %%F IN (`findstr name %MOD_CPP%`) DO (
			SET extModName=%%F
			for /f tokens^=2delims^=^" %%a in ("!extModName!") do set "modName[%%i]=%%a"
			echo	%%i	!modList[%%i]!	!modName[%%i]!
		)
	)
)
echo.
echo Which mods would you like to install?
echo.
echo Type the number of the mod or * for all.
echo.
echo Example: 1, 4, 13
set /p modSelection=Number(s):
if "%modSelection%"=="*" echo UPDATE ALL

cls
echo SELECTED MODS
echo.
echo NR	WorkshopID	Name
FOR /L %%c IN (1,1,%modAmount%) DO (
	echo.%modSelection% | findstr /C:"%%c" 1>nul
	if errorlevel 1 (
		break
	) ELSE (
		rem do all instance selection and copy files here
		rem :selectModInstance
		echo %%c	!modList[%%c]!	!modName[%%c]!
	)
)
echo.

cd /d %SERVER_PATH%
set /a i = 0
for /D %%a in (*) do (
	set /a i += 1
	set instanceList[!i!]=%%a
) 
set instanceAmount=%i%
echo.
echo Select the server you want these mods installed to
echo.
echo NR	SERVER NAME
if "%i%" LEQ "1" (
	echo dir /d
)  else (
	for /L %%b in (1,1,%instanceAmount%-1) do (
		echo %%b	!instanceList[%%b]!
	)
)
echo 		Total Instances:%i%
echo.
echo Type the number of the server or * for all.
echo.
echo Example: 1, 2, 5
set /p instanceSelection=Number(s):
cls
echo SELECTED MODS AND SERVER INSTANCES
echo.
FOR /L %%d IN (1,1,%instanceAmount%) DO (
	echo #########################################################
	echo.%instanceSelection% | findstr /C:"%%d" 1>nul
	if errorlevel 1 (
		break
	) ELSE (
		echo #	SERVER:!instanceList[%%d]!				#
		echo #							#
		echo #	SELECTED MODS:					#
		FOR /L %%c IN (1,1,%modAmount%) DO (
			echo.%modSelection% | findstr /C:"%%c" 1>nul
			if errorlevel 1 (
				break
			) ELSE (
				rem SHOUULD REPLACE SOME # with TAB=		 " and fill till end
				rem do all instance selection and copy files here
				rem :selectModInstance
				echo #	 %%c	!modList[%%c]!	!modName[%%c]!		#
			)
		)
	)
	echo #########################################################
	echo.
)
pause
echo.
cls
FOR /L %%d IN (1,1,%instanceAmount%) DO (
	echo.%instanceSelection% | findstr /C:"%%d" 1>nul
	if errorlevel 1 (
		break
	) ELSE (
		cls
		echo WORKING ON SERVER:	!instanceList[%%d]!
		echo.
		echo INSTALLING MOD:	!modName[%%c]!
		echo.
		FOR /L %%c IN (1,1,%modAmount%) DO (
			echo.%modSelection% | findstr /C:"%%c" 1>nul
			if errorlevel 1 (
				break
			) ELSE (
				cd /d %SERVER_PATH%\!instanceList[%%d]!\
				rem mkdir "@!modName[%%c]!"
				if not exist "@!modName[%%c]!" (
					mklink /J "@!modName[%%c]!" "%STEAMAPPS_MODS_PATH%\!modList[%%c]!" > nul
					pause
				) else ( 
					echo @!modName[%%c]!" already exists - Updating keys
				)
				xcopy /y "%STEAMAPPS_MODS_PATH%\!modList[%%c]!\keys\*.bikey" "keys\" > nul
				echo.
				echo INSTALLED !modName[%%c]! IN !instanceList[%%d]!
				echo.
				echo ^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!
				echo Make sure you possibly still need to fix the types.xml and other config files depending on the installed mod.
				echo see https://steamcommunity.com/sharedfiles/filedetails/?id=^^!modList[%%c]^^! to find more details.
				echo ^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!					
				pause
				cls
			)
		)
	)
)
echo Finished installing mods to server instances
echo Press any key to return to the main menu
pause > nul
endlocal
Goto :mainMenu
exit /b 60

:deleteMod
cls
echo This is a future feature.
echo Please be patient.
echo.
echo To delete a mod, goto %STEAMAPPS_MODS_PATH%\ and delete the workshopID folder.
echo.
echo Please keep in mind, that if this mod is being used by a server and you dont change the condig files. It will stop working.
echo.
echo returning to main menu.
pause >nul
Goto :mainMenu

:deleteServerMod
cls
echo This is a future feature.
echo Please be patient.
echo.
echo To delete a server mod, follow the following steps.
echo Check which key is in the mods keys folder. Goto the server instance's keys folder and delete the file with the same name, found in the mods keys folder.
echo goto %SERVER_PATH%\dayzserver\ and delete the Mod folder starting with "@".
echo.
echo Please keep in mind, that if the key of this mod is being used by another mod on this server, Deleting the key will stop all mods using that key, to stop working.
echo.
echo returning to main menu.
pause >nul
Goto :mainMenu

rem TESTING
:createScript
setlocal enabledelayedexpansion
cd /d %SERVER_PATH%
echo For which server would you like to create a script?
set /a i = 0
for /D %%a in (*) do (
	set /a i += 1
	set instanceList[!i!]=%%a
) 
set instanceAmount=%i%
echo.
echo Select the server you want to create a script for
echo.
echo NR	SERVER NAME
if "%i%" LEQ "1" (
	echo dir /d
)  else (
	for /L %%b in (1,1,%instanceAmount%-1) do (
		echo %%b	!instanceList[%%b]!
	)
)
echo 		Total Instances:%i%
echo.
echo Type the number of the server or * for all.
echo.
echo Example: 1, 2, 5
set /p instanceSelection=Number(s):
cd /d %SERVER_PATH%\!instanceList[%instanceSelection%]!\
cls
echo Which mods would you like to start your server with?
echo.
echo NR	Mod
rem select which mods you would like in your script
set /a i = 0
for /D %%a in (*) do (
	set currentMod=%%a
	if "!currentMod:~0,1!"=="@" (
		set /a i += 1
		set modList[!i!]=%%a
		echo !i!	%%a
	)
) 
echo.
echo SELECTED MODS AND SERVER INSTANCES
echo.
FOR /L %%d IN (1,1,%instanceAmount%) DO (
	echo.%instanceSelection% | findstr /C:"%%d" 1>nul
	if errorlevel 1 (
		break
	) ELSE (
		echo	SELECTED SERVER:!instanceList[%%d]!		
		)
	)
)
pause

exit /b 80

















echo Type the number of the server or * for all.
echo.
echo Example: 1, 2, 5
set /p instanceSelection=Number(s):
cls
echo SELECTED MODS AND SERVER INSTANCES
echo.
FOR /L %%d IN (1,1,%instanceAmount%) DO (
	echo #########################################################
	echo.%instanceSelection% | findstr /C:"%%d" 1>nul
	if errorlevel 1 (
		break
	) ELSE (
		echo #	SERVER:!instanceList[%%d]!				#
		echo #							#
		echo #	SELECTED MODS:					#
		FOR /L %%c IN (1,1,%modAmount%) DO (
			echo.%modSelection% | findstr /C:"%%c" 1>nul
			if errorlevel 1 (
				break
			) ELSE (
				rem SHOUULD REPLACE SOME # with TAB=		 " and fill till end
				rem do all instance selection and copy files here
				rem :selectModInstance
				echo #	 %%c	!modList[%%c]!	!modName[%%c]!		#
			)
		)
	)
	echo #########################################################
	echo.
)

















rem END TESTING!



:selectFolder
set "psCommand="(new-object -COM 'Shell.Application').BrowseForFolder(0,'Please choose a folder.', 0).self.path""
for /f "usebackq delims=" %%I in (`powershell %psCommand%`) do (
	set "%~1=%%I"
)
exit /b 50

:shutDown
echo.
echo.
echo Thank you for using
echo      ___      _ _     _     _        
echo     ^|   \ ___^| (_)_ _(_)___( )___    
echo     ^| ^|) / -_) ^| ^| '_^| / _ \/(_-^<    
echo     ^|___/\___^|_^|_^|_^| ^|_\___/ /__/    
echo.
echo          ___           _____         
echo         ^|   \ __ _ _  _^|_  /         	
echo         ^| ^|) / _` ^| ^|^| ^|/ /          
echo        _^|___/\__,_^|\_, /___^|         
echo       / __^| ___ _ _^|__/____ _ _      
echo       \__ \/ -_) '_\ V / -_) '_^|     
echo   __  ^|___/\___^|_^|  \_/\___^|_^|       
echo  ^|  \/  ^|__ _ _ _  __ _ __ _ ___ _ _ 
echo  ^| ^|\/^| / _` ^| ' \/ _` / _` / -_) '_^|
echo  ^|_^|  ^|_\__,_^|_^|^|_\__,_\__, \___^|_^|  
echo                        ^|___/         
echo    Written by: Delirio       VERSION:%LAST_VERSION%
echo		04/12/2022
echo.
echo                                  Goodbye!
pause >nul
exit 0
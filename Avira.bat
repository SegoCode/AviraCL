@echo off

:: ----------------------------------------------------------
:: ---------------------ADMIN PRIVILEGES---------------------
:: ----------------------------------------------------------

set powershell=%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe

fltmc >nul 2>&1 || (
    echo Administrator privileges are required.
    %powershell% Start -Verb RunAs '%0' 2> nul || (
        echo Right-click on the script and select "Run as administrator".
        pause & exit 1
    )
    exit 0
)

:: ----------------------------------------------------------

mode 88,35
title github.com/SegoCode 
cd %~dp0

:: Check internet connection
ping -n 2 8.8.8.8 > nul
if not %errorlevel% == 1 (
    set internet=[1;32mOnline [m
) else (
	set internet=[1;31mOffline [m
)

cls
echo.
echo    Avira ScanCL tool, Network status %internet%
echo    [1;36mDownloading Avira dependencies... [m 
echo    -----------------------------------------------
echo. 

if not exist *.key (
    echo    [1;31mYou need a Avira license[m, put .key file in "%~dp0" 
    pause > nul
    exit
)

if exist "scancl.exe" (
   if exist "fusebundle.exe" (
       goto MENU
   )
)

:: ----------------------------------------------------------
:: -------------------------FIRST RUN------------------------
:: ----------------------------------------------------------  
if %errorlevel% == 1 (
    echo    [1;31mYou need an internet connection[m, to download Avira dependencies. 
    pause > nul
    exit
)

echo    Loading, Please wait...       = [[1;31m 1/5 [m]
powershell -Command "$progressPreference = 'silentlyContinue';Invoke-WebRequest http://professional.avira-update.com/package/scancl/win32/en/scancl-win32.zip -OutFile scancl-win32.zip" > nul 2>&1

echo    Loading, Please wait...       = [[1;31m 2/5 [m]
powershell -Command "$progressPreference = 'silentlyContinue';Invoke-WebRequest http://install.avira-update.com/package/fusebundlegen/win32/en/avira_fusebundlegen-win32-en.zip -OutFile avira_fusebundlegen-win32-en.zip" > nul 2>&1

echo    Loading, Please wait...       = [[1;31m 3/5 [m]
powershell -Command "$progressPreference = 'silentlyContinue'; expand-archive -path 'avira_fusebundlegen-win32-en.zip'" > nul 2>&1
powershell -Command "$progressPreference = 'silentlyContinue'; expand-archive -path 'scancl-win32.zip'" > nul 2>&1

echo    Loading, Please wait...       = [[1;31m 4/5 [m]
xcopy /Q /Y "scancl-win32\scancl-1.9.161.2" "%~dp0" > nul 2>&1
xcopy /Q /Y "avira_fusebundlegen-win32-en" "%~dp0" > nul 2>&1

echo    Loading, Please wait...       = [[1;31m 5/5 [m]
rmdir /s /q scancl-win32 > nul 2>&1
rmdir /s /q avira_fusebundlegen-win32-en > nul 2>&1

echo.
echo    Avira dependencies download   = [[1;32m DONE [m]
timeout /t 4 /nobreak > NUL

goto UPDATE
:: ----------------------------------------------------------


:MENU
cls
echo.
echo    Avira ScanCL tool, Network status %internet%
echo    [1;36mWaiting for user input... [m 
echo    -----------------------------------------------
echo.  
echo    [1]  Avira canner
echo    [2]  Avira Updater  
echo    [3]  Config Scanner
echo    [4]  Github
echo.  
Set /P optm=^>^> 
If "%optm%"=="1" (Goto :SCANMENU)
If "%optm%"=="2" (Goto :UPDATE)
If "%optm%"=="3" (start notepad "scancl.conf")
If "%optm%"=="4" (start "" https://github.com/SegoCode)
goto MENU


:UPDATE
cls
echo.
echo    Avira ScanCL tool, Network status %internet%
echo    [1;36mDownloading and updating database... [m 
echo    -----------------------------------------------
echo.  
del *.zip > nul 2>&1
del *.vdf > nul 2>&1
del *.gz > nul 2>&1
del *.crt > nul 2>&1
del *.yml > nul 2>&1
del *.idx > nul 2>&1
del *.rdf > nul 2>&1
del *.dat > nul 2>&1
for %%i in (*.dll) do if not "%%i"=="msvcr90.dll" del "%%i" > nul 2>&1

fusebundle.exe

powershell -Command "$progressPreference = 'silentlyContinue'; expand-archive -path 'install\vdf_fusebundle.zip'" > nul 2>&1
xcopy /q /y "vdf_fusebundle" "%~dp0" > nul 2>&1
rmdir /s /q install > nul 2>&1
rmdir /s /q temp > nul 2>&1 
rmdir /s /q vdf_fusebundle > nul 2>&1 
goto MENU

:SCANMENU
cls
echo.
echo    Avira ScanCL tool, Network status %internet%
echo    [1;36mWaiting for user input... [m 
echo    -----------------------------------------------
echo.  
echo    [1]  Fast Scan (C:)
echo    [2]  Full Drive Scan (All Drives)
echo    [3]  On demand Scan        
echo    [4]  Back 
echo.  
Set /P optscan=^>^>
cls
if %optscan%==1 (scancl.exe C: --smartextensions --defaultaction=delete --suspiciousaction=delete --heurlevel=3 --colors)
if %optscan%==2 (scancl.exe --allboot --allhard --allremote --withtype=all --defaultaction=delete --suspiciousaction=delete --heurlevel=3 --colors --stats)
if %optscan%==3 (goto ondem)
if %optscan%==4 (goto menu)
pause > nul
goto SCANMENU

:ondem
Echo: 
Echo     Enter directory to scan: 
Echo: 
set /p scandir=^>^>
cls
echo Apply file restrictions scancl.conf
echo Scanning directory: %scandir%
scancl.exe %scandir% --config=scancl.conf --colors
pause > nul
goto menu



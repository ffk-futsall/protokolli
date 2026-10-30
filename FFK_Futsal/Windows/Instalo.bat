@echo off
setlocal EnableExtensions
title Instalimi i Procesverbaleve te Futsallit - FFK
set "SRC=%~dp0"
set "DEST=%LOCALAPPDATA%\FFK_Futsal"
set "HTML=FFK_Futsal_Protokolli.html"
set "ICO=FFK_ikona.ico"
set "LNKNAME=Procesverbalet e Futsallit"
set "PF86=%ProgramFiles(x86)%"

echo.
echo  Duke instaluar Procesverbalet e Futsallit (FFK)...
echo.

REM --- 1. Kontrollo qe ZIP-i eshte shpaketuar ---
echo %SRC% | find /i "\Temp\" >nul
if not errorlevel 1 goto :zipgabim
if not exist "%SRC%%HTML%" goto :zipgabim
goto :kopjo

:zipgabim
echo  GABIM: skedari %HTML% nuk u gjet pergjat Instalo.bat.
echo  Duhet ta shpaketoni ZIP-in PARA se ta hapni Instalo.bat:
echo    klik me te djathten mbi ZIP ^> Extract All ^> Extract
echo  Pastaj hapeni dosjen e re dhe klikoni dy here Instalo.bat.
echo.
pause
exit /b 1

REM --- 2. Kopjo skedaret ---
:kopjo
if not exist "%DEST%" mkdir "%DEST%"
copy /Y "%SRC%%HTML%" "%DEST%\" >nul
copy /Y "%SRC%%ICO%" "%DEST%\" >nul
if not exist "%DEST%\%HTML%" goto :kopjegabim
goto :browser

:kopjegabim
echo  GABIM: nuk u kopjua skedari ne %DEST%
echo  Provoni te hapni Instalo.bat si Administrator (klik me te djathten ^> Run as administrator).
echo.
pause
exit /b 1

REM --- 3. Gjej Edge ose Chrome per hapje ne ekran te plote ---
:browser
set "BROWSER="
if exist "%PF86%\Microsoft\Edge\Application\msedge.exe" set "BROWSER=%PF86%\Microsoft\Edge\Application\msedge.exe"
if not defined BROWSER if exist "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" set "BROWSER=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
if not defined BROWSER if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" set "BROWSER=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not defined BROWSER if exist "%PF86%\Google\Chrome\Application\chrome.exe" set "BROWSER=%PF86%\Google\Chrome\Application\chrome.exe"
if not defined BROWSER if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" set "BROWSER=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"

set "URLPATH=%DEST:\=/%"

set "TP=%DEST%\%HTML%"
set "ARGS="
if defined BROWSER set "TP=%BROWSER%"
if defined BROWSER set "ARGS=--app=""file:///%URLPATH%/%HTML%"" --start-fullscreen"

REM --- 4. Krijo shkurtoret me VBScript (nuk varet nga PowerShell) ---
set "VBS=%TEMP%\ffk_shkurtore.vbs"
> "%VBS%"  echo Set w = CreateObject("WScript.Shell")
>> "%VBS%" echo For Each f In Array("Desktop", "Programs")
>> "%VBS%" echo   On Error Resume Next
>> "%VBS%" echo   Set s = w.CreateShortcut(w.SpecialFolders(f) ^& "\%LNKNAME%.lnk")
>> "%VBS%" echo   s.TargetPath = "%TP%"
>> "%VBS%" echo   s.Arguments = "%ARGS%"
>> "%VBS%" echo   s.IconLocation = "%DEST%\%ICO%"
>> "%VBS%" echo   s.WorkingDirectory = "%DEST%"
>> "%VBS%" echo   s.Description = "FFK - Procesverbalet e Futsallit"
>> "%VBS%" echo   s.Save
>> "%VBS%" echo Next
cscript //nologo "%VBS%" >nul 2>&1
del "%VBS%" >nul 2>&1

REM --- 5. Kontrollo qe shkurtorja u krijua (desktop normal ose OneDrive) ---
set "OK="
if exist "%USERPROFILE%\Desktop\%LNKNAME%.lnk" set "OK=1"
if exist "%USERPROFILE%\OneDrive\Desktop\%LNKNAME%.lnk" set "OK=1"
if exist "%OneDrive%\Desktop\%LNKNAME%.lnk" set "OK=1"
if defined OK goto :sukses

REM --- 6. Rezerva: shkurtore .url (hapet me shfletuesin standard, ekran i plote me klikimin e pare) ---
set "TARGETDESK=%USERPROFILE%\Desktop"
if exist "%OneDrive%\Desktop" set "TARGETDESK=%OneDrive%\Desktop"
> "%TARGETDESK%\%LNKNAME%.url"  echo [InternetShortcut]
>> "%TARGETDESK%\%LNKNAME%.url" echo URL=file:///%URLPATH%/%HTML%?full=1
>> "%TARGETDESK%\%LNKNAME%.url" echo IconFile=%DEST%\%ICO%
>> "%TARGETDESK%\%LNKNAME%.url" echo IconIndex=0
if exist "%TARGETDESK%\%LNKNAME%.url" goto :sukses

echo.
echo  Aplikacioni u kopjua ne: %DEST%
echo  por shkurtorja nuk u krijua. Hapeni manualisht skedarin:
echo    %DEST%\%HTML%
echo.
start "" explorer "%DEST%"
pause
exit /b 0

:sukses
echo.
echo  U krye! Ne desktop u krijua shkurtorja "%LNKNAME%" me logon e FFK.
if defined BROWSER (
  echo  Aplikacioni hapet automatikisht ne ekran te plote ^(si me F11^).
) else (
  echo  Nuk u gjet Edge/Chrome; shtypni F11 per ekran te plote pas hapjes.
)
echo  Per te dalur nga ekrani i plote: F11 ^(ose mbani shtypur Esc^).
echo  Mund ta fshini kete dosje ZIP; aplikacioni funksionon edhe pa internet.
echo.
pause
exit /b 0

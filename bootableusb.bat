@ECHO OFF &setlocal enabledelayedexpansion
mode 80,25
color f1
title BootableUSB
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Requesting Administrative Privileges...
    goto uacprompt
) else ( goto gotadmin )
:uacprompt
    echo set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "%~s0", "%params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    exit /B

:gotadmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
	:start
	cls
	set disk=
	(
	echo list disk
	echo exit
	)>script.tmp
	echo Please wait getting disk list...
diskpart /s "%cd%\script.tmp" >"%temp%\list.txt"
del script.tmp
cls
echo.
echo ----Make sure to select the right disk----
echo            *Enter [c] to cancel*
echo ==========================================
type "%temp%\list.txt" | findstr "Online"
echo ------------------------------------------
echo.
set /p "disk=Enter the disk number: "
if not defined disk cls &echo Error: No Entry &timeout 5 >nul &goto start
if %disk%==c cls &echo Goodbye %username% &timeout 5 >nul &exit
cls
echo.
echo  +========================================================+
echo  + Warning: This process will Reformat your disk %disk% drive!  +
echo  +========================================================+
echo  +             CONTINUE CREATE BOOTABLE USB?              +
echo  ==========================================================
echo.
echo                   Enter [y] for yes
echo                   Enter [n] for no
echo.
CHOICE /C yn /N /M  "Continue Create Bootable USB? ?: "
if %errorlevel%==1 goto yes
if %errorlevel%==2 cls &echo Goodbye %username% &timeout 3 >nul &exit

:yes
cls
echo.
echo Please wait formating disk %disk% into ntfs...
  (
  echo select disk %disk%
  echo clean
  echo create partition primary
  echo select partition 1
  echo active
  echo format fs=ntfs quick
  echo exit
  )>%temp%\script.txt
  diskpart /s "%temp%\script.txt" 
  cls
  echo.
echo Formating disk %disk% into ntfs...ok &timeout 3 >nul
wmic logicaldisk get caption,description | findstr "Removable" >tmp
set _drive=
set /p _drive=<tmp &del tmp
set drive=%_drive:~0,1%
:proceed
cls
echo.
echo Please wait for pop-up folder...and browse your iso file
set iso=
call :browse_file
echo Please wait extracting "%iso%" to drive %drive%:
echo %ProgramFiles(x86)% | find "x86" > NUL && set extract=bin\7z64\7z.exe || set extract=bin\7z.exe
%extract% x -y -o%drive%:\ "%iso%"
echo F | xcopy /S /Q /Y /F %drive%:\boot\bootsect.exe bin\bootsect.exe >nul
bin\bootsect.exe /nt60 %drive%:
if %errorlevel% NEQ 0 cls &echo Sorry process failed! please wait trying method 2...&timeout 3 >nul &bin\win_bootsect.exe /nt60 %drive%:
echo Finished!
del /f bin\bootsect.exe
pause >nul
echo Goodbye %username% thank you for using this tool
timeout 5  >nul
exit

:browse_file
set ps_cmd=powershell "Add-Type -AssemblyName System.windows.forms|Out-Null;$f=New-Object System.Windows.Forms.OpenFileDialog;$f.Filter='All files (.)|*.*';$f.showHelp=$true;$f.ShowDialog()|Out-Null;$f.FileName"
for /f "delims=" %%I in ('%ps_cmd%') do set "iso=%%I"
if "%iso%"=="" echo  & echo Error: Please browse your iso file &timeout 5 >nul &goto :proceed
exit /b

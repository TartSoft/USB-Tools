@echo off
:: EnableExtensions and EnableDelayedExpansion
setlocal EnableExtensions EnableDelayedExpansion
cd /d %~dp0 & set "drive=D:" & set "mount=0" & echo/
set "file=%USERPROFILE%\Downloads\plc-stick_8.3.zip"
REM Check if exist USB Flash 
if exist %drive%\nul (format %drive% /q /fs:FAT32 /Y /v:USBFlash
REM Else echo "Flash drive is not mounted to the computer"
) else (set "mount=1" & echo Flash drive is not mounted to the computer)
timeout 3
if not %mount% equ 1 (echo/
    cscript //nologo "%~f0?.wsf" "%file%" "%drive%\"
    echo Unpack completed. Running setup... & echo/
    call %drive%\setup.bat
    timeout 3 & echo Install completed & echo/
    removedrive %drive% -L
    echo All tasks done. Remove Flash Drive.
) else (echo/ & echo Reinsert the drive or open Disk Management)
timeout /t 3 /nobreak >nul
exit /b
::End Batch Code

----- Begin WSF Script --->
<job><script language="VBScript">
Set objShell = CreateObject("Shell.Application")
Set Ag=Wscript.Arguments
set WshShell = WScript.CreateObject("WScript.Shell")

Set DestFldr=objShell.NameSpace(Ag(1))
Set SrcFldr=objShell.NameSpace(Ag(0))
Set FldrItems=SrcFldr.Items
DestFldr.CopyHere FldrItems, &H214
</script></job>
----- End WSF Script --->

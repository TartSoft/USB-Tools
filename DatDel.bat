@Echo Off
SetLocal EnableExtensions DisableDelayedExpansion
Set "_I=%~1"
If Not Defined _I (Echo= No input parameter provided.
    Echo= Exiting . . . & Timeout 3 /NoBreak>Nul & Exit /B)
Mountvol|Find /I "%_I:~,1%:\">Nul && (Set "_I=%_I:~,1%") || (
    Echo= Invalid parameter provided.
    Echo= Exiting . . . & Timeout 3 /NoBreak>Nul & Exit /B)
For /F "Skip=2 Tokens=*" %%A In ('WMIC DiskDrive Where InterfaceType^="USB"^
 Assoc /AssocClass:Win32_DiskDriveToDiskPartition 2^>Nul') Do (
    For /F UseBackQ^ Delims^=^"^ Tokens^=2 %%B In ('%%A') Do (
        For /F Delims^=^":^ Tokens^=6 %%C In (
            'WMIC Path Win32_LogicalDiskToPartition^|Find "%%B"') Do (
                If /I "%%C"=="%_I%" GoTo :Task)))
Echo= %_I%: is not a connected USB drive.
>Nul Timeout 5
Exit/B
:Task
Choice /C YN /T 15 /D N /M "Do you want to delete all files from %_I%:?"
If ErrorLevel 2 Exit /B
CD /D %_I%:
(   Del /A/F/Q *
    RD /S /Q *)>Nul 2>&1

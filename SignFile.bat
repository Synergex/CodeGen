@echo off
setlocal

set SignTarget=%~1
set CertFile=%~2
set Secret=%~3
set Description=%~4
set AzureAppId=%~5
set AzureDirId=%~6

if NOT DEFINED SignTarget goto usage
if NOT DEFINED CertFile goto usage
if NOT DEFINED Secret goto usage

powershell -NoLogo -NoProfile -Command "Import-Module .\signfile.ps1; Azure-Signfile -CertFile \"%CertFile%\" -SignSecret \"%Secret%\" -Description \"%Description%\" -TargetFile \"%SignTarget%\" -ApplicationId \"%AzureAppId%\" -DirectoryId \"%AzureDirId%\""
endlocal
goto exit

:usage
echo *** usage: signfile filename certificate_name password description
echo *** example: signfile dbr.exe SomeCert MySecret "Synergy/DE Runtime"
endlocal

:exit


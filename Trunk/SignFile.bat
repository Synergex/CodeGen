@echo off

rem p1 = Path to file to be signed
rem p2 = Drive letter containing certificate in root folder
rem p3 = Password
rem p4 = Description
rem p5 = URL for more information

if "%1x" == "x" goto usage
if "%2x" == "x" goto usage
if "%3x" == "x" goto usage
if "%4x" == "x" goto usage
if "%5x" == "x" goto usage

setlocal
set DEVROOT=%~dp0
pushd "%DEVROOT%"

set CERTIFICATE="%2\certificate.cer"
set PRIVATEKEY="%2\privatekey.pfx"
set PASSWORD=%3
set DESCRIPTION="%4"
set INFOURL=%5
set TIMESTAMPURL=http://timestamp.verisign.com/scripts/timstamp.dll

signtool sign /v /ac %CERTIFICATE% /f %PRIVATEKEY% /p %PASSWORD% /d %DESCRIPTION% /du %INFOURL%/t %TIMESTAMPURL% %1

goto done

:done

popd
endlocal
exit

:usage

echo Usage: SignFile "fileToSign" keyFileDrive password "description" infoUrl

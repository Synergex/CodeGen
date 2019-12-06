rem @echo off
setlocal
pushd %~dp0

if "%1"=="" goto usage

set FILE_TO_SIGN=%1

if not exist "%FILE_TO_SIGN%" (
  echo ERROR: File %FILE_TO_SIGN% was not found!
  goto done
)

set TIMESTAMP_URL=http://timestamp.entrust.net/TSS/RFC3161sha2TS

echo.
for %%F in ("%FILE_TO_SIGN%") do echo Signing %%~nxF

rem Should be able to use %WindowsSdkDir% but it looks like Visual Studio clears it for some reason!

rem This is the command used with the certificate on the physical USB device.
"C:\Program Files (x86)\Windows Kits\10\bin\10.0.16299.0\x86\signtool.exe" sign /fd SHA256 /a /tr "%TIMESTAMP_URL%" "%FILE_TO_SIGN%"

if "%ERRORLEVEL%"=="0" (
  echo SUCCESS!
)

goto done

:usage
echo.
echo Usage: SignFile <fileSpec>
echo.

:done
popd
endlocal
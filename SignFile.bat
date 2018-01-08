rem @echo off
setlocal
pushd %~dp0

if "%1"=="" goto usage

set FILE_TO_SIGN=%1

if not exist "%FILE_TO_SIGN%" (
  echo ERROR: File %FILE_TO_SIGN% was not found!
  goto done
)

if not defined CODE_SIGN_CERT (
  echo ERROR: No code signing certificate is defined. Set environment varaible CODE_SIGN_CERT.
  goto done
)

if not exist "%CODE_SIGN_CERT%" (
  echo ERROR: Code signing certificate %CODE_SIGN_CERT% was not found!
  goto done
)

set PASSWORD=%2
if not "%PASSWORD%"=="" goto gotPassword

set PASSWORD=%CODE_SIGN_PWD%
if "%PASSWORD%"=="" (
  echo ERROR: Code signing password is not defined. Set environment variable CODE_SIGN_PWD.
  goto done  
)

:gotPassword

set TIMESTAMP_URL=http://timestamp.entrust.net/TSS/AuthenticodeTS

echo.
for %%F in ("%FILE_TO_SIGN%") do echo Signing %%~nxF

rem Should be able to use %WindowsSdkDir% but it looks like Visual Studio clears it for some reason!

rem This is the command used with the certificate on the physical USB device.
"C:\Program Files (x86)\Windows Kits\10\bin\10.0.16299.0\x86\signtool.exe" sign /fd SHA256 /t http://timestamp.entrust.net/TSS/AuthenticodeTS /q "%FILE_TO_SIGN%"

if "%ERRORLEVEL%"=="0" (
  echo SUCCESS!
)

goto done

:usage
echo.
echo Usage: SignFile file [password]
echo.

:done
popd
endlocal
@echo off
setlocal
pushd %~dp0

if "%1"=="" goto usage

set FILE_TO_SIGN=%1

if not exist "%FILE_TO_SIGN%" (
  echo ERROR: File %FILE_TO_SIGN% was not found!
  goto done
)

echo.
for %%F in ("%FILE_TO_SIGN%") do echo Signing %%~nxF

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

set PASSWORD=%CODE_SIGN_PSWD%
if "%PASSWORD%"=="" (
  echo ERROR: Code signing password is not defined. Set environment variable CODE_SIGN_PWD.
  goto done  
)

:gotPassword

set TIMESTAMP_URL=http://timestamp.entrust.net/TSS/AuthenticodeTS

signtool sign /f "%CODE_SIGN_CERT%" /p %PASSWORD% /t %TIMESTAMP_URL% /fd SHA256 /q  "%FILE_TO_SIGN%"

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
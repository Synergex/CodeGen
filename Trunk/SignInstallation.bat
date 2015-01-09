@echo off
setlocal

cls
echo.
echo ------------------------------
echo CodeGen Code Signing Procedure
echo ------------------------------
echo.

set FILE_TO_SIGN=%~dp0Bin\Release\CodeGen.msi

if not exist "%FILE_TO_SIGN%" (
  echo.
  echo ERROR: File %FILE_TO_SIGN% was not found!
  goto done
)

if not defined CODE_SIGN_CERT (
  echo.
  echo ERROR: No code signing certificate is defined. Set environment varaible CODE_SIGN_CERT!
  goto done
)

if not exist "%CODE_SIGN_CERT%" (
  echo.
  echo ERROR: Code signing certificate %CODE_SIGN_CERT% was not found!
  goto done
)

for %%F in ("%FILE_TO_SIGN%")   do echo Signing file         : %%~nxF
for %%F in ("%CODE_SIGN_CERT%") do echo With certificate     : %%~nxF

set /p PASSWORD="                       Certificate password : "
echo [%PASSWORD%]
if "%PASSWORD%" == "" (
  echo.
  echo ERROR: Certificate password is required!
  goto done
)

echo.

set TIMESTAMP_URL=http://timestamp.entrust.net/TSS/AuthenticodeTS

signtool sign /f "%CODE_SIGN_CERT%" /p %PASSWORD% /t %TIMESTAMP_URL% /v "%FILE_TO_SIGN%"

if "%ERRORLEVEL%"=="0" (
  echo.
  echo SUCCESS!
)

:done
echo.
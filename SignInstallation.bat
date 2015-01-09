@echo off
setlocal

if "%1"=="" goto usage

set DEVROOT=%~dp0
pushd "%DEVROOT%"

set FILETOSIGN="Bin\Release\CodeGen.msi"
set CERTIFICATE="C:\Users\Steve\Documents\PSG_Code_Signing_Certificate_And_Private_Key_2015_01_08.pfx"
set TIMESTAMPURL=http://timestamp.entrust.net/TSS/AuthenticodeTS
set DESCRITPION="CodeGen Installation"

signtool sign /f %CERTIFICATE% /p %1 /t %TIMESTAMPURL% /v %FILETOSIGN%
popd
goto done

:usage
echo Usage: SignInstallation <password>

:done
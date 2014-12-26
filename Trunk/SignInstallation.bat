rem @echo off

if "%1x" == "x" goto usage

setlocal
set DEVROOT=%~dp0
pushd "%DEVROOT%"

if not exist SignFile.bat goto missing_script

call SignFile Bin\Release\CodeGen.msi K: %1 "CodeGen Installation" "http://codegen.codeplex.com"

:missing_script
echo Script SignFile.bat is missing!

:done

popd
endlocal
exit

:usage
usage: SignInstallation <password>

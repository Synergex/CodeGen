@echo off
setlocal

set PATH=C:\Program Files\7-Zip;%PATH%

pushd %~dp0

if not exist distribution\linux\. mkdir distribution\linux

pushd CodeGen
echo Building Linux distribution
dotnet publish -c Release -r linux-x64 -o ..\distribution\linux
popd

pushd distribution
if exist codegen_linux64.zip del codegen_linux64.zip
pushd linux
7z a -r ..\codegen_linux64.zip *
popd
popd

popd
endlocal
pause

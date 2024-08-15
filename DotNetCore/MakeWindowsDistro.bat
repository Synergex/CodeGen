@echo off
setlocal

set PATH=C:\Program Files\7-Zip;%PATH%

pushd %~dp0

if not exist distribution\windows\.   mkdir distribution\windows
del /s /q distribution\windows\* > nul 2>&1

pushd CodeGen
echo Building Windows distribution
dotnet publish --nologo -c Release -r win-x64 --self-contained -p:PublishTrimmed=false --verbosity minimal -o ..\distribution\windows
popd

if exist ..\Documentation\CodeGen.chm copy ..\Documentation\CodeGen.chm distribution\windows > nul 2>&1

pushd distribution
if exist codegen_windows64.zip del codegen_windows64.zip
pushd windows
7z a -r ..\codegen_windows64.zip *
popd
popd

popd
endlocal

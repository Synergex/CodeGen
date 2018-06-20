@echo off
pushd %~dp0Documentation

"C:\Program Files (x86)\HelpSmith\helpsmith.exe" CodeGen.hsm /hh=CodeGen.chm /nc
"C:\Program Files (x86)\HelpSmith\helpsmith.exe" CodeGen.hsm /wh="Web Help" /nc

popd
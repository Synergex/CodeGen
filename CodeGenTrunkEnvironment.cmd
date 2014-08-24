@echo off
call "C:\Program Files\Synergex\SynergyDE\dbl\dblvars64.bat" > nul
call "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\vsvars32.bat" > nul

set TRUNKROOT=%~dp0
set CODEGEN_TPLDIR=%TRUNKROOT%Templates
set CODEGEN_OUTDIR=%TEMP%
set RPSMFIL=%TRUNKROOT%UnitTests\TestRepository\rpsmain.ism
set RPSTFIL=%TRUNKROOT%UnitTests\TestRepository\rpstext.ism
set DAT=%TRUNKROOT%UnitTests\TestData

path=%trunkroot%CodeGen\Bin\Debug;%path%;%xfnlnet%;C:\Program Files (x86)\Synergex\SynergyDE\workbench\win

prompt 64 CodeGen Trunk $p$g

cd /d "%CODEGEN_OUTDIR%"
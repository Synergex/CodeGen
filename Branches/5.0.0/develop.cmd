@echo off
set DEVROOT=%~dp0
cd /d "%DEVROOT%"
call "C:\Program Files\Synergex\SynergyDE\dbl\dblvars64.bat" > nul
call "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\vsvars32.bat" > nul
path=C:\Program Files (x86)\MSBuild\Synergex\dbl;%path%
prompt CodeGen Trunk $p$g

set RPSDAT=%DEVROOT%SampleRepository
set RPSMFIL=%RPSDAT%\rpsmain.ism
set RPSTFIL=%RPSDAT%\rpstext.ism
set CODEGEN_SRC=%DEVROOT%CodeGenEngine
set CODEGEN_TPLDIR=%DEVROOT%SampleTemplates
set CODEGEN_OUTDIR=%DEVROOT%OutputFiles
set CODEGEN_AUTHOR=Steve Ives
set CODEGEN_COMPANY=Synergex Professional Services Group

devenv "CodeGen 5.0.0.sln"

exit
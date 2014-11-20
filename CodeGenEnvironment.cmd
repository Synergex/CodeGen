@echo off

call "C:\Program Files\Synergex\SynergyDE\dbl\dblvars64.bat" > nul
call "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\vsvars32.bat" > nul

PATH=%~dp0Bin\Release;C:\Program Files (x86)\MSBuild\Synergex\dbl;C:\Program Files (x86)\WiX Toolset v3.9\bin;%PATH%

set CODEGEN_TPLDIR=%~dp0SampleTemplates
set CODEGEN_OUTDIR=%~dp0OutputFiles
set RPSMFIL=%~dp0SampleRepository\rpsmain.ism
set RPSTFIL=%~dp0SampleRepository\rpstext.ism

prompt CodeGen Trunk (Release) $p$g

cd /d %~dp0OutputFiles

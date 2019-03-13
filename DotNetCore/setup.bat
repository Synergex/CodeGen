@echo off
cd /d "%~dp0"
set CODEGEN_SRC=%~dp0..\CodeGenEngine
set CODEGEN_TPLDIR=%~dp0..\SampleTemplates
set CODEGEN_OUTDIR=%~dp0..\OutputFiles
set RPSDAT=%~dp0..\CodeGen\SampleRepository
set RPSMFIL=%~dp0..\CodeGen\SampleRepository\rpsmain.ism
set RPSTFIL=%~dp0..\CodeGen\SampleRepository\rpstext.ism

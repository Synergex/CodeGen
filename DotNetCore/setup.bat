@echo off
cd /d "%~dp0"
set CODEGEN_SRC=%~dp0CodeGenEngine
rem set CODEGEN_TPLDIR=%~dp0..\CodeGen\SampleTemplates
set CODEGEN_TPLDIR=C:\DEV\PUBLIC\CodeGen\SampleTemplates
set CODEGEN_OUTDIR=%~dp0OutputFiles\
set RPSDAT=%~dp0..\CodeGen\SampleRepository
set RPSMFIL=%~dp0..\CodeGen\SampleRepository\rpsmain.ism
set RPSTFIL=%~dp0..\CodeGen\SampleRepository\rpstext.ism

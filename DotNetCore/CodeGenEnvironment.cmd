@echo off

rem
rem This script configures a command-line environment to run the version of CodeGeCore that
rem is currently in the bin\release\netcoreapp2.0 folder. Running this script will override
rem any version that might be installed on the system.
rem

call "%VS150COMNTOOLS%VsDevCmd.bat"
call "%SYNERGYDE64%dbl\dblvars64.bat" > nul

set CODEGEN_ROOT=%~dp0..
set CODEGEN_TPLDIR=%CODEGEN_ROOT%\SampleTemplates
set CODEGEN_OUTDIR=%CODEGEN_ROOT%\OutputFiles
set RPSDAT=%CODEGEN_ROOT%\SampleRepository
set RPSMFIL=%CODEGEN_ROOT%\SampleRepository\rpsmain.ism
set RPSTFIL=%CODEGEN_ROOT%\SampleRepository\rpstext.ism

PATH=%CODEGEN_ROOT%\DotNetCore\CodeGen\bin\release\netcoreapp2.0;%PATH%

cd /d %CODEGEN_OUTDIR%

cls
echo.
codegen -version
echo.
echo CodeGen Executable : %CODEGEN_ROOT%\DotNetCore\CodeGen\bin\release\netcoreapp2.0\CodeGen.exe
echo Repository         : %RPSMFIL%
echo Template folder    : %CODEGEN_TPLDIR%
echo Output folder      : %CODEGEN_OUTDIR%
echo.

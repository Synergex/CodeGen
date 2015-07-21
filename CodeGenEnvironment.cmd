@echo off

rem
rem This script configures a command-line environment to run the version of CodeGen that
rem is currently in the Bin\Release folder. Running this script will override any version
rem that might be installed on the system.
rem

call "%VS140COMNTOOLS%vsvars32.bat"
call "%SYNERGYDE64%dbl\dblvars64.bat" > nul

set CODEGEN_ROOT=%~dp0
set CODEGEN_TPLDIR=%CODEGEN_ROOT%SampleTemplates
set CODEGEN_OUTDIR=%CODEGEN_ROOT%OutputFiles
set CODEGEN_EXTDIR=%CODEGEN_ROOT%Bin\Release
set RPSDAT=%CODEGEN_ROOT%SampleRepository
set RPSMFIL=%CODEGEN_ROOT%SampleRepository\rpsmain.ism
set RPSTFIL=%CODEGEN_ROOT%SampleRepository\rpstext.ism

PATH=%CODEGEN_ROOT%Bin\Release;%ProgramFiles(x86)%\MSBuild\Synergex\dbl;%ProgramFiles(x86)%\WiX Toolset v3.9\bin;%PATH%

cd /d %CODEGEN_OUTDIR%

cls
echo.
codegen -version
echo.
echo CodeGen Executable : %CODEGEN_ROOT%Bin\Release\codegen.exe
echo Repository         : %RPSMFIL%
echo Template folder    : %CODEGEN_TPLDIR%
echo Output folder      : %CODEGEN_OUTDIR%
echo.

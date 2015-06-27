@echo off

rem
rem This script configures a command-line environment to run the version of CodeGen that
rem is currently in the Bin\Release folder. Running this script will override any version
rem that might be installed on the system.
rem

call "%VS120COMNTOOLS%vsvars32.bat"
call "%SYNERGYDE64%dbl\dblvars64.bat" > nul

set CODEGEN_ROOT=%~dp0
set CODEGEN_EXTDIR=%CODEGEN_ROOT%Bin\Release
set CODEGEN_TPLDIR=.
set CODEGEN_OUTDIR=.
set RPSMFIL=.\rpsmain.ism
set RPSTFIL=.\rpstext.ism

PATH=%CODEGEN_ROOT%Bin\Release;%ProgramFiles(x86)%\MSBuild\Synergex\dbl;%PATH%

cls
echo.
codegen -version
echo.
echo CodeGen Executable : %CODEGEN_ROOT%Bin\Release\codegen.exe
echo Repository         : %RPSMFIL% and %RPSTFIL%
echo Template folder    : %CODEGEN_TPLDIR%
echo Output folder      : %CODEGEN_OUTDIR%
echo.

cd /d C:\
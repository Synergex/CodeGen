@echo off
rem ***************************************************************************
rem
rem Title:       CodeGen.dbl
rem
rem Type:        Program
rem
rem Description: Template based code generator
rem
rem Date:        19th March 2007
rem
rem Author:      Steve Ives, Synergex Professional Services Group
rem              http://www.synergex.com
rem
rem ***************************************************************************
rem
rem Copyright (c) 2012, Synergex International, Inc.
rem All rights reserved.
rem
rem Redistribution and use in source and binary forms, with or without
rem modification, are permitted provided that the following conditions are met:
rem
rem * Redistributions of source code must retain the above copyright notice,
rem   this list of conditions and the following disclaimer.
rem
rem * Redistributions in binary form must reproduce the above copyright notice,
rem   this list of conditions and the following disclaimer in the documentation
rem   and/or other materials provided with the distribution.
rem
rem THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
rem AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
rem IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
rem ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
rem LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
rem CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
rem SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
rem INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
rem CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
rem ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
rem POSSIBILITY OF SUCH DAMAGE.
rem
rem ***************************************************************************

setlocal

echo CodeGen Traditional Synergy build
echo =================================

set ROOT=%~dp0
pushd "%ROOT%"

if "%1"=="-h" goto USAGE
if "%1"=="-?" goto USAGE

echo Configuring environment ...

set REPOSITORY_SRC=%ROOT%..\..\RepositoryAPI
set CODEGEN_SRC=%ROOT%..\..\CodeGenEngine
set MAINLINE_SRC=%ROOT%..\..\CodeGen
set MAPPREP_SRC=%ROOT%..\..\MapPrep
set RPSINFO_SRC=%ROOT%..\..\RpsInfo
set CODEGEN_OBJ=%ROOT%obj
set CODEGEN_EXE=%ROOT%exe
set SYNEXPDIR=%ROOT%hdr
set SYNIMPDIR=%ROOT%hdr

if not exist "%SYNEXPDIR%\."   mkdir "%SYNEXPDIR%"
if not exist "%CODEGEN_OBJ%\." mkdir "%CODEGEN_OBJ%"
if not exist "%CODEGEN_EXE%\." mkdir "%CODEGEN_EXE%"

if "%1"=="32" goto X86
if "%1"=="64" goto X64
if "%1"=="" goto X86_DEFAULT
goto USAGE

:X86_DEFAULT
echo Architecture defaulting to 32-bit release mode

:X86
if not defined SYNERGYDE32 goto NO_SYNERGY_32
call "%SYNERGYDE32%\dbl\dblvars32.bat" > nul
goto DEBUG

:X64
if not defined SYNERGYDE64 goto NO_SYNERGY_64
call "%SYNERGYDE64%\dbl\dblvars64.bat" > nul
goto DEBUG

:DEBUG

if "%2"=="DEBUG" set DBG=-d
if "%2"=="debug" set DBG=-d
if "%DBG%"=="-d" echo Debug mode enabled

:PROTOTYPE

echo Deleting old prototypes ...
if exist "%SYNEXPDIR%\codegen-repositoryapi-*.dbp" del /q "%SYNEXPDIR%\codegen-repositoryapi-*.dbp"
if exist "%SYNEXPDIR%\codegen-engine-*.dbp" del /q "%SYNEXPDIR%\codegen-engine-*.dbp"

echo Prototyping Repository API ...
dblproto %REPOSITORY_SRC%\*.dbl
if ERRORLEVEL 1 goto RPS_PROTO_ERROR

echo Prototyping CodeGen Engine ...
dblproto %CODEGEN_SRC%\*.dbl
if ERRORLEVEL 1 goto ENGINE_PROTO_ERROR

echo Building Repository API ...

echo %DBG% -XTo CODEGEN_OBJ:RepositoryAPI.dbo \ > RepositoryAPI.in
for /F %%f in ('dir /b %REPOSITORY_SRC%\*.dbl') do echo %REPOSITORY_SRC%\%%f \ >> RepositoryAPI.in
echo ;Temporary file > null.dbl
echo null.dbl >> RepositoryAPI.in

dbl < RepositoryAPI.in
if ERRORLEVEL 1 goto RPS_COMPILE_ERROR

dblink %DBG% -l CODEGEN_EXE:RepositoryAPI.elb CODEGEN_OBJ:RepositoryAPI.dbo RPSLIB:ddlib.elb
if ERRORLEVEL 1 goto RPS_LINK_ERROR

del /q null.dbl
del /q RepositoryAPI.in

echo Building CodeGen Engine ...

echo %DBG% -XTo CODEGEN_OBJ:CodeGenEngine.dbo \ > CodeGenEngine.in
for /F %%f in ('dir /b %CODEGEN_SRC%\*.dbl') do echo %CODEGEN_SRC%\%%f \ >> CodeGenEngine.in
echo ;Temporary file > null.dbl
echo null.dbl >> CodeGenEngine.in

dbl < CodeGenEngine.in
if ERRORLEVEL 1 goto ENGINE_COMPILE_ERROR

dblink %DBG% -l CODEGEN_EXE:CodeGenEngine.elb CODEGEN_OBJ:CodeGenEngine.dbo CODEGEN_EXE:RepositoryAPI.elb
if ERRORLEVEL 1 goto ENGINE_LINK_ERROR

del /q null.dbl
del /q CodeGenEngine.in

echo Building CodeGen ...

dbl %DBG% -XTo CODEGEN_OBJ:CodeGen.dbo MAINLINE_SRC:CodeGen.dbl
if ERRORLEVEL 1 goto CODEGEN_COMPILE_ERROR

dblink %DBG% -o CODEGEN_EXE:CodeGen.dbr CODEGEN_OBJ:CodeGen.dbo
if ERRORLEVEL 1 goto CODEGEN_LINK_ERROR

echo Building MapPrep ...

dbl %DBG% -XTo CODEGEN_OBJ:MapPrep.dbo MAPPREP_SRC:MapPrep.dbl
if ERRORLEVEL 1 goto MAPPREP_COMPILE_ERROR

dblink %DBG% -o CODEGEN_EXE:MapPrep.dbr CODEGEN_OBJ:MapPrep.dbo CODEGEN_EXE:CodeGenEngine.elb
if ERRORLEVEL 1 goto MAPPREP_LINK_ERROR

echo Building RpsInfo ...

dbl %DBG% -XTo CODEGEN_OBJ:RpsInfo.dbo RPSINFO_SRC:RpsInfo.dbl
if ERRORLEVEL 1 goto RPSINFO_COMPILE_ERROR

dblink %DBG% -o CODEGEN_EXE:RpsInfo.dbr CODEGEN_OBJ:RpsInfo.dbo CODEGEN_EXE:CodeGenEngine.elb
if ERRORLEVEL 1 goto RPSINFO_LINK_ERROR

echo Done!

popd
goto EXIT

:NO_SYNERGY_32
echo ERROR: No 32-bit Synergy/DE installation was detected!
goto EXIT

:NO_SYNERGY_64
echo ERROR: No 64-bit Synergy/DE installation was detected!
goto EXIT

:RPS_PROTO_ERROR
echo ERROR: Repository API prototyping failed!
goto EXIT

:RPS_COMPILE_ERROR
echo ERROR: Repository API compile failed!
goto EXIT

:RPS_LINK_ERROR
echo ERROR: Repository API link failed!
goto EXIT

:ENGINE_PROTO_ERROR
echo ERROR: CodeGen Engine prototyping failed!
goto EXIT

:ENGINE_COMPILE_ERROR
echo ERROR: CodeGen Engine compile failed!
goto EXIT

:ENGINE_LINK_ERROR
echo ERROR: CodeGen Engine link failed!
goto EXIT

:CODEGEN_COMPILE_ERROR
echo ERROR: CodeGen compile failed!
goto EXIT

:CODEGEN_LINK_ERROR
echo ERROR: CodeGen link failed!
goto EXIT

:MAPPREP_COMPILE_ERROR
echo ERROR: MapPrep compile failed!
goto EXIT

:MAPPREP_LINK_ERROR
echo ERROR: MapPrep link failed!
goto EXIT

:RPSINFO_COMPILE_ERROR
echo ERROR: RpsInfo compile failed!
goto EXIT

:RPSINFO_LINK_ERROR
echo ERROR: RpsInfo link failed!
goto EXIT

:USAGE
echo CodeGen Traditional Synergy build script usage:
echo     BUILD              32-bit release mode
echo     BUILD 32           32-bit release mode
echo     BUILD 32 DEBUG     32-bit debug mode
echo     BUILD 64           64-bit release mode
echo     BUILD 64 DEBUG     64-bit debug mode
goto exit

:EXIT

endlocal

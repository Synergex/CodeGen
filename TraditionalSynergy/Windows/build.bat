@echo off
rem ***************************************************************************
rem
rem Title:       build.bat
rem
rem Type:        Windows batch file
rem
rem Description: Builds CodeGen and utilities under Traditional Synergy
rem
rem Date:        10th May 2012
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
set SMC_SRC=%ROOT%..\..\MethodCatalogAPI
set CODEGEN_SRC=%ROOT%..\..\CodeGenEngine
set CUSTOM_SRC=%ROOT%..\..\CustomTokenExample
set MAINLINE_SRC=%ROOT%..\..\CodeGen
set CREATEFILE_SRC=%ROOT%..\..\CreateFile
set MAPPREP_SRC=%ROOT%..\..\MapPrep
set RPSINFO_SRC=%ROOT%..\..\RpsInfo
set SMCINFO_SRC=%ROOT%..\..\SmcInfo
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
set BUILDMODE=32
if not defined SYNERGYDE32 goto NO_SYNERGY_32
call "%SYNERGYDE32%\dbl\dblvars32.bat" > nul
goto DEBUG

:X64
set BUILDMODE=64
if not defined SYNERGYDE64 goto NO_SYNERGY_64
call "%SYNERGYDE64%\dbl\dblvars64.bat" > nul
goto DEBUG

rem ---------------------------------------------------------------------------
:DEBUG

if "%2"=="DEBUG" set DBG=d
if "%2"=="debug" set DBG=d
if "%DBG%"=="-d" echo Debug mode enabled

rem ---------------------------------------------------------------------------
:PROTOTYPE

echo Deleting old prototypes ...
if exist "%SYNEXPDIR%\codegen-repositoryapi-*.dbp" del /q "%SYNEXPDIR%\codegen-repositoryapi-*.dbp"
if exist "%SYNEXPDIR%\codegen-engine-*.dbp" del /q "%SYNEXPDIR%\codegen-engine-*.dbp"

echo Prototyping Repository API ...
dblproto %REPOSITORY_SRC%\*.dbl
if ERRORLEVEL 1 goto RPS_PROTO_ERROR

echo Prototyping Method Catalog API ...
dblproto %SMC_SRC%\*.dbl
if ERRORLEVEL 1 goto SMC_PROTO_ERROR

echo Prototyping CodeGen Engine ...
dblproto %CODEGEN_SRC%\*.dbl
if ERRORLEVEL 1 goto ENGINE_PROTO_ERROR

rem echo Prototyping CustomTokenExample ...
rem dblproto %CUSTOM_SRC%\*.dbl
rem if ERRORLEVEL 1 goto CUSTOM_PROTO_ERROR

rem ---------------------------------------------------------------------------
echo Building Repository API ...

set SOURCEFILES=
for /f %%f in ('dir /b %REPOSITORY_SRC%\*.dbl') do call :ADDSOURCEFILE %REPOSITORY_SRC% %%f
dbl -%DBG%XTo CODEGEN_OBJ:repositoryapi.dbo %SOURCEFILES%
if ERRORLEVEL 1 goto RPS_COMPILE_ERROR
dblink -l%DBG% CODEGEN_EXE:repositoryapi.elb CODEGEN_OBJ:repositoryapi.dbo RPSLIB:ddlib.elb
if ERRORLEVEL 1 goto RPS_LINK_ERROR

rem ---------------------------------------------------------------------------
echo Building Method Catalog API ...

set SOURCEFILES=
for /f %%f in ('dir /b %SMC_SRC%\*.dbl') do call :ADDSOURCEFILE %SMC_SRC% %%f
dbl -%DBG%XTo CODEGEN_OBJ:methodcatalog.dbo %SOURCEFILES%
if ERRORLEVEL 1 goto SMC_COMPILE_ERROR
dblink -l%DBG% CODEGEN_EXE:methodcatalog.elb CODEGEN_OBJ:methodcatalog.dbo CODEGEN_EXE:repositoryapi.elb DBLDIR:synxml.elb
if ERRORLEVEL 1 goto SMC_LINK_ERROR

rem ---------------------------------------------------------------------------
echo Building CodeGen Engine ...

set SOURCEFILES=
for /f %%f in ('dir /b %CODEGEN_SRC%\*.dbl') do call :ADDSOURCEFILE %CODEGEN_SRC% %%f
dbl -%DBG%XTo CODEGEN_OBJ:codegenengine.dbo %SOURCEFILES%
if ERRORLEVEL 1 goto RPS_COMPILE_ERROR
dblink -l%DBG% CODEGEN_EXE:codegenengine.elb CODEGEN_OBJ:codegenengine.dbo CODEGEN_EXE:methodcatalog.elb CODEGEN_EXE:repositoryapi.elb DBLDIR:synxml.elb
if ERRORLEVEL 1 goto ENGINE_LINK_ERROR

rem ---------------------------------------------------------------------------
rem echo Building CustomTokenExample ...

rem set SOURCEFILES=
rem for /f %%f in ('dir /b %CUSTOM_SRC%\*.dbl') do call :ADDSOURCEFILE %CUSTOM_SRC% %%f
rem dbl -%DBG%XTo CODEGEN_OBJ:customtokens.dbo %SOURCEFILES%
rem if ERRORLEVEL 1 goto CUSTOM_COMPILE_ERROR
rem dblink -l%DBG% CODEGEN_EXE:customtokens.elb CODEGEN_OBJ:customtokens.dbo CODEGEN_EXE:codegenengine.elb
rem if ERRORLEVEL 1 goto CUSTOM_LINK_ERROR

rem ---------------------------------------------------------------------------
echo Building CodeGen ...

dbl -%DBG%XTo CODEGEN_OBJ:codegen.dbo MAINLINE_SRC:CodeGen.dbl MAINLINE_SRC:CodeGenLauncher.dbl MAINLINE_SRC:Usage.dbl
if ERRORLEVEL 1 goto CODEGEN_COMPILE_ERROR
dblink -%DBG%o CODEGEN_EXE:codegen.dbr CODEGEN_OBJ:codegen.dbo CODEGEN_EXE:codegenengine.elb CODEGEN_EXE:repositoryapi.elb
if ERRORLEVEL 1 goto CODEGEN_LINK_ERROR
cd exe
rem ---------------------------------------------------------------------------
echo Building CreateFile ...

dbl -%DBG%XTo CODEGEN_OBJ:createfile.dbo CREATEFILE_SRC:CreateFile.dbl CREATEFILE_SRC:CreateFileFromRpsFile.dbl CREATEFILE_SRC:CreateFileFromRpsStruct.dbl CREATEFILE_SRC:DoCreateFile.dbl
if ERRORLEVEL 1 goto CREATEFILE_COMPILE_ERROR
dblink -%DBG%o CODEGEN_EXE:createfile.dbr CODEGEN_OBJ:createfile.dbo CODEGEN_EXE:codegenengine.elb
if ERRORLEVEL 1 goto CREATEFILE_LINK_ERROR

rem ---------------------------------------------------------------------------
echo Building MapPrep ...

dbl -%DBG%XTo CODEGEN_OBJ:mapprep.dbo MAPPREP_SRC:MapPrep.dbl
if ERRORLEVEL 1 goto MAPPREP_COMPILE_ERROR
dblink -%DBG%o CODEGEN_EXE:mapprep.dbr CODEGEN_OBJ:mapprep.dbo CODEGEN_EXE:codegenengine.elb
if ERRORLEVEL 1 goto MAPPREP_LINK_ERROR

rem ---------------------------------------------------------------------------
echo Building RpsInfo ...

dbl -%DBG%XTo CODEGEN_OBJ:rpsinfo.dbo RPSINFO_SRC:RpsInfo.dbl
if ERRORLEVEL 1 goto RPSINFO_COMPILE_ERROR
dblink -%DBG%o CODEGEN_EXE:rpsinfo.dbr CODEGEN_OBJ:rpsinfo.dbo CODEGEN_EXE:codegenengine.elb
if ERRORLEVEL 1 goto RPSINFO_LINK_ERROR

rem ---------------------------------------------------------------------------
echo Building SmcInfo ...

dbl -%DBG%XTo CODEGEN_OBJ:smcinfo.dbo SMCINFO_SRC:SmcInfo.dbl
if ERRORLEVEL 1 goto SMCINFO_COMPILE_ERROR
dblink -%DBG%o CODEGEN_EXE:smcinfo.dbr CODEGEN_OBJ:smcinfo.dbo CODEGEN_EXE:methodcatalog.elb CODEGEN_EXE:codegenengine.elb
if ERRORLEVEL 1 goto SMCINFO_LINK_ERROR

rem ---------------------------------------------------------------------------
echo Checking batch files ...

if exist "%CODEGEN_EXE%\setenv.bat"   del /q "%CODEGEN_EXE%\setenv.bat"
if exist "%CODEGEN_EXE%\codegen.bat"  del /q "%CODEGEN_EXE%\codegen.bat"
if exist "%CODEGEN_EXE%\codegend.bat" del /q "%CODEGEN_EXE%\codegend.bat"
if exist "%CODEGEN_EXE%\mapprep.bat"  del /q "%CODEGEN_EXE%\mapprep.bat"
if exist "%CODEGEN_EXE%\rpsinfo.bat"  del /q "%CODEGEN_EXE%\rpsinfo.bat"

call :CREATE_SETENV_BAT
call :CREATE_CODEGEN_BAT
call :CREATE_CODEGEND_BAT
call :CREATE_CREATEFILE_BAT
call :CREATE_MAPPREP_BAT
call :CREATE_RPSINFO_BAT
call :CREATE_SMCINFO_BAT

rem ---------------------------------------------------------------------------
echo Verifying documentation is present ...

if not exist "%CODEGEN_EXE%\CodeGen.chm" copy "%ROOT%..\..\Documentation\CodeGen.chm" "%CODEGEN_EXE%">nul

rem ---------------------------------------------------------------------------
echo Verifying DefaultButtons.xml is present ...

if not exist "%CODEGEN_EXE%\DefaultButtons.xml" copy "%CODEGEN_SRC%\DefaultButtons.xml" "%CODEGEN_EXE%">nul
attrib -r "%CODEGEN_EXE%\DefaultButtons.xml"

rem ---------------------------------------------------------------------------
echo Verifying DataMappingsExample.xml is present ...

if not exist "%CODEGEN_EXE%\DataMappingsExample.xml" copy "%REPOSITORY_SRC%\DataMappingsExample.xml" "%CODEGEN_EXE%\DataMappingsExample.xml">nul
attrib -r "%CODEGEN_EXE%\DataMappingsExample.xml"

rem ---------------------------------------------------------------------------
echo .
echo BUILD COMPLETE!
echo .
echo To use CodeGen from any command prompt, add this folder to PATH:
echo %CODEGEN_EXE%
popd
goto EXIT

rem ---------------------------------------------------------------------------
:ADDSOURCEFILE
set SOURCEFILES=%SOURCEFILES% %1\%2
goto :eof

rem ---------------------------------------------------------------------------
:CREATE_SETENV_BAT
echo @echo off>"%CODEGEN_EXE%\setenv.bat"
if "%BUILDMODE%"=="32" echo call "%SYNERGYDE32%dbl\dblvars32.bat" ^> nul>>"%CODEGEN_EXE%\setenv.bat"
if "%BUILDMODE%"=="64" call "%SYNERGYDE64%dbl\dblvars64.bat" ^> nul>>"%CODEGEN_EXE%\setenv.bat"
echo if not defined CODEGEN_EXE    set CODEGEN_EXE=%CODEGEN_EXE%>>"%CODEGEN_EXE%\setenv.bat"
echo if not defined CODEGEN_TPLDIR set CODEGEN_TPLDIR=%~dp0..\..\Templates>>"%CODEGEN_EXE%\setenv.bat"
echo if not defined CODEGEN_OUTDIR set CODEGEN_OUTDIR=.>>"%CODEGEN_EXE%\setenv.bat"
goto :eof

rem ---------------------------------------------------------------------------
:CREATE_CODEGEN_BAT
echo Creating codegen.bat ...
echo @echo off>"%CODEGEN_EXE%\codegen.bat"
echo setlocal>>"%CODEGEN_EXE%\codegen.bat"
echo call "%CODEGEN_EXE%\setenv.bat">>"%CODEGEN_EXE%\codegen.bat"
echo dbs CODEGEN_EXE:CodeGen %%*>>"%CODEGEN_EXE%\codegen.bat"
echo endlocal>>"%CODEGEN_EXE%\codegen.bat"
goto :eof

rem ---------------------------------------------------------------------------
:CREATE_CODEGEND_BAT
echo Creating codegend.bat ...
echo @echo off>"%CODEGEN_EXE%\codegend.bat"
echo setlocal>>"%CODEGEN_EXE%\codegend.bat"
echo call "%CODEGEN_EXE%\setenv.bat">>"%CODEGEN_EXE%\codegend.bat"
echo dbr -d CODEGEN_EXE:CodeGen %%*>>"%CODEGEN_EXE%\codegend.bat"
echo endlocal>>"%CODEGEN_EXE%\codegend.bat"
goto :eof

rem ---------------------------------------------------------------------------
:CREATE_CREATEFILE_BAT
echo Creating createfile.bat

echo @echo off>"%CODEGEN_EXE%\createfile.bat"
echo setlocal>>"%CODEGEN_EXE%\createfile.bat"
echo call "%CODEGEN_EXE%\setenv.bat">>"%CODEGEN_EXE%\createfile.bat"
echo dbs CODEGEN_EXE:createfile.dbr %%*>>"%CODEGEN_EXE%\createfile.bat"
echo endlocal>>"%CODEGEN_EXE%\createfile.bat"
goto:eof

rem ---------------------------------------------------------------------------
:CREATE_MAPPREP_BAT
echo Creating mapprep.bat

echo @echo off>"%CODEGEN_EXE%\mapprep.bat"
echo setlocal>>"%CODEGEN_EXE%\mapprep.bat"
echo call "%CODEGEN_EXE%\setenv.bat">>"%CODEGEN_EXE%\mapprep.bat"
echo dbs CODEGEN_EXE:mapprep.dbr %%*>>"%CODEGEN_EXE%\mapprep.bat"
echo endlocal>>"%CODEGEN_EXE%\mapprep.bat"
goto:eof

rem ---------------------------------------------------------------------------
:CREATE_RPSINFO_BAT
echo Creating rpsinfo.bat

echo @echo off>"%CODEGEN_EXE%\rpsinfo.bat"
echo setlocal>>"%CODEGEN_EXE%\rpsinfo.bat"
echo call "%CODEGEN_EXE%\setenv.bat">>"%CODEGEN_EXE%\rpsinfo.bat"
echo dbs CODEGEN_EXE:rpsinfo.dbr %%*>>"%CODEGEN_EXE%\rpsinfo.bat"
echo endlocal>>"%CODEGEN_EXE%\rpsinfo.bat"
goto:eof

rem ---------------------------------------------------------------------------
:CREATE_SMCINFO_BAT
echo Creating smcinfo.bat

echo @echo off>"%CODEGEN_EXE%\smcinfo.bat"
echo setlocal>>"%CODEGEN_EXE%\smcinfo.bat"
echo call "%CODEGEN_EXE%\setenv.bat">>"%CODEGEN_EXE%\smcinfo.bat"
echo dbs CODEGEN_EXE:smcinfo.dbr %%*>>"%CODEGEN_EXE%\smcinfo.bat"
echo endlocal>>"%CODEGEN_EXE%\smcinfo.bat"
goto:eof

rem ---------------------------------------------------------------------------
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
:SMC_PROTO_ERROR
echo ERROR: Method Catalog API prototyping failed!
goto EXIT
:SMC_COMPILE_ERROR
echo ERROR: Method Catalog API compile failed!
goto EXIT
:SMC_LINK_ERROR
echo ERROR: Method Catalog API link failed!
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
:CUSTOM_PROTO_ERROR
echo ERROR: CustomTokenExample prototyping failed!
goto EXIT
:CUSTOM_COMPILE_ERROR
echo ERROR: CustomTokenExample compile failed!
goto EXIT
:CUSTOM_LINK_ERROR
echo ERROR: CustomTokenExample link failed!
goto EXIT
:CODEGEN_COMPILE_ERROR
echo ERROR: CodeGen compile failed!
goto EXIT
:CODEGEN_LINK_ERROR
echo ERROR: CodeGen link failed!
goto EXIT
:CREATEFILE_COMPILE_ERROR
echo ERROR: CreateFile compile failed!
goto EXIT
:CREATEFILE_LINK_ERROR
echo ERROR: CreateFile link failed!
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
:SMCINFO_COMPILE_ERROR
echo ERROR: SmcInfo compile failed!
goto EXIT
:SMCINFO_LINK_ERROR
echo ERROR: SmcInfo link failed!
goto EXIT

rem ---------------------------------------------------------------------------
:USAGE
echo CodeGen Traditional Synergy build script usage:
echo     BUILD              32-bit release mode
echo     BUILD 32           32-bit release mode
echo     BUILD 32 DEBUG     32-bit debug mode
echo     BUILD 64           64-bit release mode
echo     BUILD 64 DEBUG     64-bit debug mode
goto exit

rem ---------------------------------------------------------------------------
:EXIT
endlocal

@echo off
rem ***************************************************************************
rem
rem Title:       clean.bat
rem
rem Type:        Windows batch file
rem
rem Description: Deletes all files created by build.bat
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

set ROOT=%~dp0
pushd "%ROOT%"

if exist hdr\*.* del /q hdr\*.*
if exist obj\*.* del /q obj\*.*
if exist exe\*.dbr del /q exe\*.dbr
if exist exe\*.elb del /q exe\*.elb
if exist exe\*.chm del /q exe\*.chm
if exist exe\codegen.bat del /q exe\codegen.bat
if exist exe\codegend.bat del /q exe\codegend.bat
if exist exe\mapprep.bat del /q exe\mapprep.bat
if exist exe\rpsinfo.bat del /q exe\rpsinfo.bat
if exist exe\createfile.bat del /q exe\createfile.bat
if exist exe\setenv.bat del /q exe\setenv.bat
if exist exe\DefaultButtons.xml del /q exe\DefaultButtons.xml
if exist exe\DataMappingsExample.xml del /q exe\DataMappingsExample.xml

if exist hdr\. rmdir /q hdr
if exist obj\. rmdir /q obj

popd
endlocal
@echo off
setlocal
call "%SYNERGYDE32%dbl\dblvars32.bat"
pushd %~dp0
set RPSMFIL=SampleRepository\rpsmain.ism
set RPSTFIL=SampleRepository\rpstext.ism
if not exist SampleRepository\CodeGen.sch goto no_delete
echo Deleting existing repository schema...
del /q SampleRepository\CodeGen.sch
:no_delete
echo Exporting new repository schema...
dbs RPS:rpsutl -e SampleRepository\CodeGen.sch
if "%ERRORLEVEL%"=="1" goto export_fail
goto done
:export_fail
echo *ERROR* Schema export failed
goto done
:done
popd
endlocal
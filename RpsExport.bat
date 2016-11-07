@echo off
pushd %~dp0..
if not exist rps\vdsc.sch goto no_delete
echo Deleting existing repository schema...
del /q rps\vdsc.sch
:no_delete
echo Exporting new repository schema...
dbs RPS:rpsutl -e rps\vdsc.sch
if "%ERRORLEVEL%"=="1" goto export_fail
goto done
:export_fail
echo *ERROR* Schema export failed
goto done
:done
popd
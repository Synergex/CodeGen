@echo off
pushd %~dp0..
rem Make sure we have a schema
echo Locating schema file...
if not exist rps\vdsc.sch goto no_schema
rem Test to see if the schema will load
echo Testing schema load...
dbs RPS:rpsutl -i rps\vdsc.sch -ia -ir -s -n rps\rpsmain.new rps\rpstext.new
if "%ERRORLEVEL%"=="1" goto parse_fail
if exist rps\rpsmain.new del /q rps\rpsmain.new
if exist rps\rpsmain.ne1 del /q rps\rpsmain.ne1
if exist rps\rpstext.new del /q rps\rpstext.new
if exist rps\rpstext.ne1 del /q rps\rpstext.ne1
echo Test OK
rem Load the schema
echo Performing schema load...
dbs RPS:rpsutl -i rps\vdsc.sch -ia -ir
if "%ERRORLEVEL%"=="1" goto load_fail
echo Schema loaded OK
goto done
:no_schema
echo *ERROR* Schema file not found!
goto done
:parse_fail
echo *ERROR* Schema parse failed - repository not changed
goto done
:load_fail
echo *ERROR* Schema load failed - repository not changed
:done

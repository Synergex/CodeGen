@echo off
setlocal
call "%SYNERGYDE32%dbl\dblvars32.bat"
pushd %~dp0
set RPSMFIL=SampleRepository\rpsmain.ism
set RPSTFIL=SampleRepository\rpstext.ism
rem Make sure we have a schema
echo Locating schema file...
if not exist SampleRepository\CodeGen.sch goto no_schema
rem Test to see if the schema will load
echo Testing schema load...
dbs RPS:rpsutl -i SampleRepository\CodeGen.sch -ia -ir -s -n SampleRepository\rpsmain.new SampleRepository\rpstext.new
if "%ERRORLEVEL%"=="1" goto parse_fail
if exist SampleRepository\rpsmain.new del /q SampleRepository\rpsmain.new
if exist SampleRepository\rpsmain.ne1 del /q SampleRepository\rpsmain.ne1
if exist SampleRepository\rpstext.new del /q SampleRepository\rpstext.new
if exist SampleRepository\rpstext.ne1 del /q SampleRepository\rpstext.ne1
echo Test OK
rem Load the schema
echo Performing schema load...
dbs RPS:rpsutl -i SampleRepository\CodeGen.sch -ia -ir
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
endlocal
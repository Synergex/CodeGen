@echo off
cd "%SOLUTIONDIR%Output"
if exist EMPLOYEE_NEW.SCH del EMPLOYEE_NEW.SCH
call "%SYNERGYDE32%dbl\dblvars32.bat"
"%SOLUTIONDIR%MapPrep\bin\debug\mapprep" -s EMPLOYEE -p -r
if exist EMPLOYEE_NEW.SCH (
  echo Created %SOLUTIONDIR%Output\EMPLOYEE_NEW.SCH
) else (
  echo ERROR: New schema file not found!
)
cd "%SOLUTIONDIR%MapPrep"
pause
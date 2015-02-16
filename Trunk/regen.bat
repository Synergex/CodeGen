@echo off

if not defined CODEPLEX_UID (
  echo ERROR: CodePlex user ID is not defined. Set environment varaible CODEPLEX_UID.
  goto done
)

if not defined CODEPLEX_PWD (
  echo ERROR: CodePlex password is not defined. Set environment varaible CODEPLEX_PWD.
  goto done
)

setlocal

rem These commands were lifted from the Orchestrator project file SymphonyOrchestrator.symproj

set ROOT=%~dp0
pushd "%ROOT%SymphonyOrchestratorLibrary"

set OPT=-e -r -lf
set CODEGEN_TPLDIR=%SYMPHONYTPL%

set STR_DATA=CODEGEN_STRUCTURES CODEGEN_COMMAND CODEGEN_USER_TOKEN EXECUTION_RESULTS ORCHESTRATOR_DEFAULTS
set STR_STYLE=CODEGEN_STRUCTURES CODEGEN_COMMAND ORCHESTRATOR_DEFAULTS ORCHESTRATOR_PROJECT
set STR_CONTENT=CODEGEN_STRUCTURES CODEGEN_COMMAND ORCHESTRATOR_DEFAULTS ORCHESTRATOR_PROJECT
set STR_COLLECTION=CODEGEN_COMMAND ORCHESTRATOR_PROJECT
set STR_ASXML=CODEGEN_COMMAND ORCHESTRATOR_DEFAULTS

echo.
echo Checking out generated files...

tf checkout /recursive *.CodeGen.* /login:%CODEPLEX_UID%,%CODEPLEX_PWD% > nul

echo.
echo Regenerating code...

codegen %OPT% -s %STR_DATA%       -t Symphony_DataNoExcel -o .\Model     -n Symphony.Orchestrator.Library.Model -prefix m
codegen %OPT% -s %STR_STYLE%      -t Symphony_Style       -o .\Resources -cw 16 -ut ASSEMBLYNAME=SymphonyOrchestratorLibrary ANCESTORCONTROL=Window
codegen %OPT% -s %STR_CONTENT%    -t Symphony_Content     -o .\Resources -n Symphony.Orchestrator.Library.Content -ut ASSEMBLYNAME=SymphonyOrchestratorLibrary
codegen %OPT% -s %STR_COLLECTION% -t Symphony_Collection  -o .\Content   -n Symphony.Orchestrator.Library.Content
codegen %OPT% -s %STR_ASXML%      -t Symphony_AsXML       -o .\Model     -n Symphony.Orchestrator.Library.Model

echo.
echo Code generation complete

popd
endlocal

:done


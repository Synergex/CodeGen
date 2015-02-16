@echo off

if "%CODEPLEX_UID%" == "" goto codeplex_setup
if "%CODEPLEX_PWD%" == "" goto codeplex_setup

setlocal

rem These commands were lifted from the Orchestrator project file SymphonyOrchestrator.symproj

set ROOT=%~dp0

pushd "%ROOT%"

set OPT=-e -r -lf
set CODEGEN_TPLDIR=%SYMPHONYTPL%
set OUTDIR=%ROOT%SymphonyOrchestratorLibrary

set STR_DATA=CODEGEN_STRUCTURES CODEGEN_COMMAND CODEGEN_USER_TOKEN EXECUTION_RESULTS ORCHESTRATOR_DEFAULTS
set STR_STYLE=CODEGEN_STRUCTURES CODEGEN_COMMAND ORCHESTRATOR_DEFAULTS ORCHESTRATOR_PROJECT
set STR_CONTENT=CODEGEN_STRUCTURES CODEGEN_COMMAND ORCHESTRATOR_DEFAULTS ORCHESTRATOR_PROJECT
set STR_COLLECTION=CODEGEN_COMMAND ORCHESTRATOR_PROJECT
set STR_ASXML=CODEGEN_COMMAND ORCHESTRATOR_DEFAULTS

echo.
echo Checking out generated files...

tf checkout /recursive SymphonyOrchestratorLibrary\*.CodeGen.* /login:%CODEPLEX_UID%,%CODEPLEX_PWD% > nul

echo.
echo Regenerating code...

codegen %OPT% -s %STR_DATA%       -t Symphony_DataNoExcel -o %OUTDIR%\Model     -n Symphony.Orchestrator.Library.Model -prefix m
codegen %OPT% -s %STR_STYLE%      -t Symphony_Style       -o %OUTDIR%\Resources -cw 16 -ut ASSEMBLYNAME=SymphonyOrchestratorLibrary ANCESTORCONTROL=Window
codegen %OPT% -s %STR_CONTENT%    -t Symphony_Content     -o %OUTDIR%\Resources -n Symphony.Orchestrator.Library.Content -ut ASSEMBLYNAME=SymphonyOrchestratorLibrary
codegen %OPT% -s %STR_COLLECTION% -t Symphony_Collection  -o %OUTDIR%\Content   -n Symphony.Orchestrator.Library.Content
codegen %OPT% -s %STR_ASXML%      -t Symphony_AsXML       -o %OUTDIR%\Model     -n Symphony.Orchestrator.Library.Model

popd
endlocal
goto done

:codeplex_setup
echo.
echo ERROR: Please define your CODEPLEX login details in CODEPLEX_UID and CODEPLEX_PWD
echo.
:done


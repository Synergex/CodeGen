@echo off
setlocal

rem These commands were lifted from the Orchestrator project file SymphonyOrchestrator.symproj

set ROOT=%~dp0
set CODEGEN_TPLDIR=%SYMPHONYTPL%
set OUTDIR=%ROOT%SymphonyOrchestratorLibrary

set STR_DATA=CODEGEN_STRUCTURES CODEGEN_COMMAND CODEGEN_USER_TOKEN EXECUTION_RESULTS ORCHESTRATOR_DEFAULTS
set STR_STYLE=CODEGEN_STRUCTURES CODEGEN_COMMAND ORCHESTRATOR_DEFAULTS ORCHESTRATOR_PROJECT
set STR_CONTENT=CODEGEN_STRUCTURES CODEGEN_COMMAND ORCHESTRATOR_DEFAULTS ORCHESTRATOR_PROJECT
set STR_COLLECTION=CODEGEN_COMMAND ORCHESTRATOR_PROJECT
set STR_ASXML=CODEGEN_COMMAND ORCHESTRATOR_DEFAULTS

codegen -s %STR_DATA%       -t Symphony_DataNoExcel -o %OUTDIR%\Model     -r -prefix m -n Symphony.Orchestrator.Library.Model
codegen -s %STR_STYLE%      -t Symphony_Style       -o %OUTDIR%\Resources -r -prefix m -cw 16 -ut ASSEMBLYNAME=SymphonyOrchestratorLibrary ANCESTORCONTROL=Window
codegen -s %STR_CONTENT%    -t Symphony_Content     -o %OUTDIR%\Resources -r -prefix m -n Symphony.Orchestrator.Library.Content -ut ASSEMBLYNAME=SymphonyOrchestratorLibrary
codegen -s %STR_COLLECTION% -t Symphony_Collection  -o %OUTDIR%\Content   -r -prefix m -n Symphony.Orchestrator.Library.Content
codegen -s %STR_ASXML%      -t Symphony_AsXML       -o %OUTDIR%\Model     -r -prefix m -n Symphony.Orchestrator.Library.Model

endlocal
$ ! ***************************************************************************
$ !
$ ! Title:       BUILD.COM
$ !
$ ! Type:        OpenVMS DCL Command Procedure
$ !
$ ! Description: Builds CodeGen and utilities under OpenVMS
$ !
$ ! Date:        11th May 2012
$ !
$ ! Author:      Steve Ives, Synergex Professional Services Group
$ !              http://www.synergex.com
$ !
$ ! ***************************************************************************
$ !
$ ! Copyright (c) 2012, Synergex International, Inc.
$ ! All rights reserved.
$ !
$ ! Redistribution and use in source and binary forms, with or without
$ ! modification, are permitted provided that the following conditions are met:
$ !
$ ! * Redistributions of source code must retain the above copyright notice,
$ !   this list of conditions and the following disclaimer.
$ !
$ ! * Redistributions in binary form must reproduce the above copyright notice,
$ !   this list of conditions and the following disclaimer in the documentation
$ !   and/or other materials provided with the distribution.
$ !
$ ! THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
$ ! AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
$ ! IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
$ ! ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
$ ! LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
$ ! CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
$ ! SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
$ ! INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
$ ! CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
$ ! ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
$ ! POSSIBILITY OF SUCH DAMAGE.
$ !
$ ! ***************************************************************************
$ !
$ ! Check that we have logicals for SYNRTL and DBLTLIB
$ !
$ IF F$TRNLNM("SYNRTL").EQS."" .OR. F$TRNLNM("DBLTLIB").EQS.""
$ THEN
$   WRITE SYS$OUTPUT ""
$   WRITE SYS$OUTPUT "To build and run CodeGen you must define system wide logical names for SYNRTL"
$   WRITE SYS$OUTPUT "and DBLTLIB to point to the appropriate files in SYS$SHARE, like this:"
$   WRITE SYS$OUTPUT ""
$   WRITE SYS$OUTPUT "	$ DEFINE/SYSTEM SYNRTL  SYS$SHARE:SYNRTL.EXE"
$   WRITE SYS$OUTPUT "	$ DEFINE/SYSTEM DBLTLIB SYS$SHARE:DBLTLIB.OLB"
$   WRITE SYS$OUTPUT ""
$   WRITE SYS$OUTPUT "These logical names should be defined in your system startup command procedure"
$   WRITE SYS$OUTPUT "(SYS$MANAGER:SYSTARTUP_VMS.COM) immediately after you call the Synergy/DE"
$   WRITE SYS$OUTPUT "startup command procedure (SYS$MANAGER:SYNERGY_STARTUP.COM). Please define"
$   WRITE SYS$OUTPUT "these logical names and run this procedure again."
$   WRITE SYS$OUTPUT ""
$   GOTO DONE
$ ENDIF
$ ! 
$ BUILDLOC = F$PARSE(F$ENVIRONMENT("PROCEDURE"),,,"DEVICE") + F$PARSE(F$ENVIRONMENT("PROCEDURE"),,,"DIRECTORY")
$ SET DEF 'BUILDLOC
$ !
$ ROOT = F$EXTRACT(0,F$LOCATE("TRADITIONALSYNERGY.OPENVMS]",BUILDLOC),BUILDLOC)
$ !
$ RPSPATH        = ROOT + "REPOSITORYAPI]"
$ SMCPATH        = ROOT + "METHODCATALOGAPI]"
$ ENGINEPATH     = ROOT + "CODEGENENGINE]"
$ MAINPATH       = ROOT + "CODEGEN]"
$ CREATEFILEPATH = ROOT + "CREATEFILE]"
$ MAPPREPPATH    = ROOT + "MAPPREP]"
$ RPSINFOPATH    = ROOT + "RPSINFO]"
$ SMCINFOPATH    = ROOT + "SMCINFO]"
$ HDRPATH        = ROOT + "TRADITIONALSYNERGY.OPENVMS.HDR]
$ OBJPATH        = ROOT + "TRADITIONALSYNERGY.OPENVMS.OBJ]
$ EXEPATH        = ROOT + "TRADITIONALSYNERGY.OPENVMS.EXE]
$ !
$ DEFINE/NOLOG VMS_ROOT         'BUILDLOC
$ DEFINE/NOLOG REPOSITORY_SRC   'RPSPATH
$ DEFINE/NOLOG SMC_SRC          'SMCPATH
$ DEFINE/NOLOG CODEGEN_SRC      'ENGINEPATH
$ DEFINE/NOLOG MAINLINE_SRC     'MAINPATH
$ DEFINE/NOLOG CREATEFILE_SRC   'CREATEFILEPATH
$ DEFINE/NOLOG MAPPREP_SRC      'MAPPREPPATH
$ DEFINE/NOLOG RPSINFO_SRC      'RPSINFOPATH
$ DEFINE/NOLOG SMCINFO_SRC      'SMCINFOPATH
$ DEFINE/NOLOG CODEGEN_LIB      'OBJPATH
$ DEFINE/NOLOG CODEGEN_OBJ      'OBJPATH
$ DEFINE/NOLOG CODEGEN_EXE      'EXEPATH
$ DEFINE/NOLOG SYNEXPDIR        'HDRPATH
$ DEFINE/NOLOG SYNIMPDIR        'HDRPATH
$ DEFINE/NOLOG SYNXML_SH        DBLDIR:SYNXML.EXE
$ !
$ !Check that the directories that are not created by the CodePlex download
$ !exist on the system
$ !
$ SET MESSAGE/NOFAC/NOSEV/NOID/NOTEXT
$ SET NOON
$ CREATE/DIR CODEGEN_OBJ:
$ CREATE/DIR CODEGEN_EXE:
$ CREATE/DIR SYNEXPDIR:
$ ON ERROR THEN EXIT
$ SET MESSAGE/FAC/SEV/ID/TEXT
$ !
$ IF "''P1'".EQS."ALL"       THEN GOTO RPSAPI
$ IF "''P1'".EQS."RPSAPI"    THEN GOTO RPSAPI
$ IF "''P1'".EQS."SMCAPI"    THEN GOTO SMCAPI
$ IF "''P1'".EQS."ENGINE"    THEN GOTO ENGINE
$ IF "''P1'".EQS."CODEGEN"   THEN GOTO CODEGEN
$ IF "''P1'".EQS."UTILITIES" THEN GOTO UTILITIES
$ !
$ WRITE SYS$OUTPUT "Specify ALL, RPSAPI, SMCAPI, ENGINE, CODEGEN or UTILITIES"
$ EXIT
$ !
$ !----------------------------------------------------------------------------
$ RPSAPI:
$ !
$ WRITE SYS$OUTPUT "Prototyping Repository API ..."
$ IF F$SEARCH("SYNEXPDIR:CODEGEN-REPOSITORYAPI-*.DBP").NES."" THEN DELETE/NOLOG/NOCONF SYNEXPDIR:CODEGEN-REPOSITORYAPI-*.DBP;*
$ DBLPROTO REPOSITORY_SRC:*.DBL
$ !
$ WRITE SYS$OUTPUT "Creating library CODEGEN_LIB:REPOSITORYAPI.OLB ..."
$ LIB/CREATE CODEGEN_LIB:REPOSITORYAPI.OLB
$ !
$ WRITE SYS$OUTPUT "Compiling Repository API ..."
$ RPS_LOOP:
$     FILE = F$SEARCH("REPOSITORY_SRC:*.DBL")
$     IF FILE .EQS. "" THEN GOTO RPSAPI_DONE
$     NAME = F$PARSE(FILE,,,"NAME")
$     CALL REPOSITORY_BUILD 'NAME
$     GOTO RPS_LOOP
$ !
$ RPSAPI_DONE:
$ !
$ IF F$SEARCH("CODEGEN_EXE:DataMappingsExample.xml").EQS."" THEN COPY/NOLOG REPOSITORY_SRC:DataMappingsExample.xml CODEGEN_EXE:DataMappingsExample.xml
$ !
$ IF "''P1'".EQS."RPSAPI" THEN GOTO DONE
$ !
$ !----------------------------------------------------------------------------
$ SMCAPI:
$ !
$ WRITE SYS$OUTPUT "Prototyping Method Catalog API ..."
$ IF F$SEARCH("SYNEXPDIR:CODEGEN-METHODCATALOGAPI-*.DBP").NES."" THEN DELETE/NOLOG/NOCONF SYNEXPDIR:CODEGEN-METHODCATALOGAPI-*.DBP;*
$ DBLPROTO SMC_SRC:*.DBL
$ !
$ WRITE SYS$OUTPUT "Creating library CODEGEN_LIB:METHODCATALOGAPI.OLB ..."
$ LIB/CREATE CODEGEN_LIB:METHODCATALOGAPI.OLB
$ !
$ WRITE SYS$OUTPUT "Compiling Method Catalog API ..."
$ SMC_LOOP:
$     FILE = F$SEARCH("SMC_SRC:*.DBL")
$     IF FILE .EQS. "" THEN GOTO SMCAPI_DONE
$     NAME = F$PARSE(FILE,,,"NAME")
$     CALL SMC_BUILD 'NAME
$     GOTO SMC_LOOP
$ !
$ SMCAPI_DONE:
$ !
$ IF "''P1'".EQS."SMCAPI" THEN GOTO DONE
$ !
$ !----------------------------------------------------------------------------
$ ENGINE:
$ !
$ WRITE SYS$OUTPUT "Prototyping CodeGen Engine ..."
$ IF F$SEARCH("SYNEXPDIR:CODEGEN-ENGINE-.DBP").NES."" THEN DELETE/NOLOG/NOCONF SYNEXPDIR:CODEGEN-ENGINE-*.DBP;*
$ DBLPROTO CODEGEN_SRC:*.DBL
$ !
$ WRITE SYS$OUTPUT "Creating library LIB:CODEGENENGINE.OLB ..."
$ LIB/CREATE CODEGEN_LIB:CODEGENENGINE.OLB
$ !
$ WRITE SYS$OUTPUT "Compiling CodeGen Engine ..."
$ ENGINE_LOOP:
$     FILE = F$SEARCH("CODEGEN_SRC:*.DBL")
$     IF FILE .EQS. "" THEN GOTO ENGINE_DONE
$     NAME = F$PARSE(FILE,,,"NAME")
$     CALL ENGINE_BUILD 'NAME
$     GOTO ENGINE_LOOP
$ !
$ ENGINE_DONE:
$ !
$ IF F$SEARCH("CODEGEN_EXE:DefaultButtons.xml").EQS."" THEN COPY/NOLOG CODEGEN_SRC:DefaultButtons.xml CODEGEN_EXE:DefaultButtons.xml
$ !
$ IF "''P1'".EQS."ENGINE" THEN GOTO DONE
$ !
$ !----------------------------------------------------------------------------
$ CODEGEN:
$ !
$ WRITE SYS$OUTPUT " - Building CodeGen ..."
$ DIB/OPT/OBJ=CODEGEN_OBJ:CODEGEN.OBJ MAINLINE_SRC:CODEGEN.DBL
$ LINK/EXE=CODEGEN_EXE:CODEGEN.EXE CODEGEN_OBJ:CODEGEN.OBJ,VMS_ROOT:CODEGEN/OPT
$ !
$ IF "''P1'".EQS."CODEGEN" THEN GOTO DONE
$ !
$ !----------------------------------------------------------------------------
$ UTILITIES:
$ !
$ WRITE SYS$OUTPUT " - Building CreateFile ..."
$ DIB/OPT/OBJ=CODEGEN_OBJ:CREATEFILE.OBJ CREATEFILE_SRC:CREATEFILE.DBL
$ LINK/EXE=CODEGEN_EXE:CREATEFILE.EXE CODEGEN_OBJ:CREATEFILE.OBJ,VMS_ROOT:CODEGEN/OPT
$ !
$ WRITE SYS$OUTPUT " - Building MapPrep ..."
$ DIB/OPT/OBJ=CODEGEN_OBJ:MAPPREP.OBJ MAPPREP_SRC:MAPPREP.DBL
$ LINK/EXE=CODEGEN_EXE:MAPPREP.EXE CODEGEN_OBJ:MAPPREP.OBJ,VMS_ROOT:CODEGEN/OPT
$ !
$ WRITE SYS$OUTPUT " - Building RpsInfo ..."
$ DIB/OPT/OBJ=CODEGEN_OBJ:RPSINFO.OBJ RPSINFO_SRC:RPSINFO.DBL
$ LINK/EXE=CODEGEN_EXE:RPSINFO.EXE CODEGEN_OBJ:RPSINFO.OBJ,VMS_ROOT:CODEGEN/OPT
$ !
$ WRITE SYS$OUTPUT " - Building SmcInfo ..."
$ DIB/OPT/OBJ=CODEGEN_OBJ:SMCINFO.OBJ SMCINFO_SRC:SMCINFO.DBL
$ LINK/EXE=CODEGEN_EXE:SMCINFO.EXE CODEGEN_OBJ:SMCINFO.OBJ,VMS_ROOT:CODEGEN/OPT
$ !
$ IF "''P1'".EQS."UTILITIES" THEN GOTO DONE
$ !
$ !----------------------------------------------------------------------------
$ ! SUBROUTINES
$ !
$ REPOSITORY_BUILD: SUBROUTINE
$ !
$ WRITE SYS$OUTPUT " - Building ''P1'"
$ DIB/OPT/OBJ=CODEGEN_OBJ:'P1.OBJ REPOSITORY_SRC:'P1.DBL
$ LIB/REPLACE CODEGEN_LIB:REPOSITORYAPI.OLB CODEGEN_OBJ:'P1.OBJ
$ !
$ EXIT
$ ENDSUBROUTINE
$ !
$ SMC_BUILD: SUBROUTINE
$ !
$ WRITE SYS$OUTPUT " - Building ''P1'"
$ DIB/OPT/OBJ=CODEGEN_OBJ:'P1.OBJ SMC_SRC:'P1.DBL
$ LIB/REPLACE CODEGEN_LIB:METHODCATALOGAPI.OLB CODEGEN_OBJ:'P1.OBJ
$ !
$ EXIT
$ ENDSUBROUTINE
$ !
$ ENGINE_BUILD: SUBROUTINE
$ !
$ WRITE SYS$OUTPUT " - Building ''P1'"
$ DIB/OPT/OBJ=CODEGEN_OBJ:'P1.OBJ CODEGEN_SRC:'P1.DBL
$ LIB/REPLACE CODEGEN_LIB:CODEGENENGINE.OLB CODEGEN_OBJ:'P1.OBJ
$ !
$ EXIT
$ ENDSUBROUTINE
$ !
$ !----------------------------------------------------------------------------
$ DONE:
$ !
$ EXIT

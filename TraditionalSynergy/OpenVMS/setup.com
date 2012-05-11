$ ! ***************************************************************************
$ !
$ ! Title:       SETUP.COM
$ !
$ ! Type:        OpenVMS DCL Command Procedure
$ !
$ ! Description: Sets up a runtime environment for CodeGen on OpenVMS
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
$ ! Figure out where the files are on disk based on the location of this file
$ !
$ CODEGENLOC = F$PARSE(F$ENVIRONMENT("PROCEDURE"),,,"DEVICE") + F$PARSE(F$ENVIRONMENT("PROCEDURE"),,,"DIRECTORY")
$ ROOT = F$EXTRACT(0,F$LOCATE("TRADITIONALSYNERGY.OPENVMS]",CODEGENLOC),CODEGENLOC)
$ !
$ EXEPATH = ROOT + "TRADITIONALSYNERGY.OPENVMS.EXE]
$ TPLPATH = ROOT + "TEMPLATES]
$ OUTPATH = ROOT + "OUTPUT]"
$ !
$ ! Define any missing logical names
$ !
$ IF F$TRNLNM("CODEGEN_EXE").EQS.""
$ THEN
$   DEFINE/NOLOG CODEGEN_EXE 'EXEPATH
$ ENDIF
$ !
$ IF F$TRNLNM("CODEGEN_TPLDIR").EQS.""
$ THEN
$   DEFINE/NOLOG CODEGEN_TPLDIR 'TPLPATH
$ ENDIF
$ !
$ IF F$TRNLNM("CODEGEN_OUTDIR").EQS.""
$ THEN
$   DEFINE/NOLOG CODEGEN_OUTDIR 'OUTPATH
$ ENDIF
$ !
$ IF F$TRNLNM("CODEGEN_AUTHOR").EQS.""
$ THEN
$   DEFINE/NOLOG CODEGEN_AUTHOR "Put your name nere"
$ ENDIF
$ !
$ IF F$TRNLNM("CODEGEN_COMPANY").EQS.""
$ THEN
$   DEFINE/NOLOG CODEGEN_COMPANY "Put your company name here"
$ ENDIF
$ !
$ ! Make sure the output directory exists
$ !
$ SET MESSAGE/NOFAC/NOSEV/NOID/NOTEXT
$ SET NOON
$ CREATE/DIR CODEGEN_OUTDIR:
$ ON ERROR THEN EXIT
$ SET MESSAGE/FAC/SEV/ID/TEXT
$ !
$ ! Create global symbols to allow the user to execute the programs
$ !
$ CODEGEN :== $CODEGEN_EXE:CODEGEN.EXE
$ MAPPREP :== $CODEGEN_EXE:MAPPREP.EXE
$ RPSINFO :== $CODEGEN_EXE:RPSINFO.EXE
$ !
$ EXIT
$ ! ***************************************************************************
$ !
$ ! Title:       CREATE_INSTALL.COM
$ !
$ ! Type:        Creates a ZIP file containig a binary distribution of CodeGen
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
$ LOCATION = F$PARSE(F$ENVIRONMENT("PROCEDURE"),,,"DEVICE") + F$PARSE(F$ENVIRONMENT("PROCEDURE"),,,"DIRECTORY")
$ !
$ SET DEFAULT 'LOCATION
$ !
$ IF F$SEARCH("CODEGEN*.ZIP").NES."" THEN DELETE/NOLOG/NOCONFIRM CODEGEN*.ZIP;*
$ !
$ CREATE/DIRECTORY [.KIT.TEMPLATES]
$ !
$ ! Copy the main program files
$ !
$ COPY/NOLOG/NOCONFIRM [.EXE]CODEGEN.EXE             [.KIT]
$ COPY/NOLOG/NOCONFIRM [.EXE]CREATEFILE.EXE          [.KIT]
$ COPY/NOLOG/NOCONFIRM [.EXE]DATAMAPPINGSEXAMPLE.XML [.KIT]
$ COPY/NOLOG/NOCONFIRM [.EXE]DEFAULTBUTTONS.XML      [.KIT]
$ COPY/NOLOG/NOCONFIRM [.EXE]MAPPREP.EXE             [.KIT]
$ COPY/NOLOG/NOCONFIRM [.EXE]RPSINFO.EXE             [.KIT]
$ COPY/NOLOG/NOCONFIRM [.EXE]SMCINFO.EXE             [.KIT]
$ COPY/NOLOG/NOCONFIRM INSTALL_SETUP.COM             [.KIT]CODEGEN_SETUP.COM
$ !
$ ! Copy all the template files
$ !
$ COPY/NOLOG/NOCONFIRM [-.-.TEMPLATES]*.*; [.KIT.TEMPLATES]
$ !
$ ! Create the backup saveset and Zip it
$ !
$ SET DEFAULT [.KIT]
$ BACKUP [...]*.*; [-]CODEGEN.BCK/SAVE
$ SET DEFAULT [-]
$ !
$ IF F$GETSYI("ARCH_NAME").EQS."IA64"
$ THEN
$   ZIPFILE="CODEGEN_v_v_v_VMS_INTEGRITY_SYNERGY_v_v_v.ZIP"
$ ELSE
$   ZIPFILE="CODEGEN_v_v_v_VMS_ALPHA_SYNERGY_v_v_v.ZIP"
$ ENDIF
$ !
$ !This ZIP command assumes a blobal symbol "ZIP" pointing to
$ !Zip V2.3 from Info-Zip
$ !
$ ZIP "-V" "-D" -j -q  'ZIPFILE CODEGEN.BCK INSTALL_README.TXT
$ !
$ ! Clean up
$ !
$ DELETE/NOCONFIRM/NOLOG CODEGEN.BCK;*
$ DELETE/NOCONFIRM/NOLOG [.KIT.TEMPLATES]*.*;*
$ DELETE/NOCONFIRM/NOLOG [.KIT]TEMPLATES.DIR;*
$ DELETE/NOCONFIRM/NOLOG [.KIT]*.*;*
$ DELETE/NOCONFIRM/NOLOG KIT.DIR;*
$ !
$ EXIT

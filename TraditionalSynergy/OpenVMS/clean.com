$ ! ***************************************************************************
$ !
$ ! Title:       CLEAN.COM
$ !
$ ! Type:        OpenVMS DCL Command Procedure
$ !
$ ! Description: Cleans up files left behind by BUILD.COM and CREATE_INSTALL.COM
$ !
$ ! Date:        3rd February 2014
$ !
$ ! Author:      Steve Ives, Synergex Professional Services Group
$ !              http://www.synergex.com
$ !
$ ! ***************************************************************************
$ !
$ ! Copyright (c) 2014, Synergex International, Inc.
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
$ IF F$SEARCH("[.HDR]*.*")    .NES."" THEN DELETE/NOLOG/NOCONFIRM [.HDR]*.*;*
$ IF F$SEARCH("HDR.DIR")      .NES."" THEN DELETE/NOLOG/NOCONFIRM HDR.DIR;*
$ !
$ IF F$SEARCH("[.OBJ]*.*")    .NES."" THEN DELETE/NOLOG/NOCONFIRM [.OBJ]*.*;*
$ IF F$SEARCH("OBJ.DIR")      .NES."" THEN DELETE/NOLOG/NOCONFIRM OBJ.DIR;*
$ !
$ IF F$SEARCH("[.EXE]*.*")    .NES."" THEN DELETE/NOLOG/NOCONFIRM [.EXE]*.*;*
$ IF F$SEARCH("EXE.DIR")      .NES."" THEN DELETE/NOLOG/NOCONFIRM EXE.DIR;*
$ !
$ IF F$SEARCH("CODEGEN*.ZIP") .NES."" THEN DELETE/NOLOG/NOCONFIRM CODEGEN*.ZIP;*
$ !

<CODEGEN_FILENAME><structure_name>.htm</CODEGEN_FILENAME>
;//****************************************************************************
;//
;// Title:       html_rps_structure_docs.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: This template generates HTML documentation for a structure.
;//
;// Date:        19th March 2007
;//
;// Author:      Steve Ives, Synergex Professional Services Group
;//              http://www.synergex.com
;//
;//****************************************************************************
;//
;// Copyright (c) 2012, Synergex International, Inc.
;// All rights reserved.
;//
;// Redistribution and use in source and binary forms, with or without
;// modification, are permitted provided that the following conditions are met:
;//
;// * Redistributions of source code must retain the above copyright notice,
;//   this list of conditions and the following disclaimer.
;//
;// * Redistributions in binary form must reproduce the above copyright notice,
;//   this list of conditions and the following disclaimer in the documentation
;//   and/or other materials provided with the distribution.
;//
;// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
;// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;// POSSIBILITY OF SUCH DAMAGE.
;//
;//****************************************************************************
<HTML>
<HEAD>
<TITLE>Structure <STRUCTURE_NAME></TITLE>
</HEAD>
<BODY>
<H1>Structure <STRUCTURE_NAME></H1>
<H3><STRUCTURE_DESC></H3>
<TABLE BORDER="1" WIDTH="100%">
<TR>
<TH ALIGN="LEFT">Field</TH>
<TH ALIGN="LEFT">Description</TH>
<TH ALIGN="LEFT">Type</TH>
</TR>
<FIELD_LOOP>
<TR>
<TD><FIELD_NAME></TD>
<TD><FIELD_DESC></TD>
<TD><FIELD_TYPE><FIELD_SIZE><FIELD_PRECISION></TD>
</TR>
</FIELD_LOOP>
</TABLE>
</BODY>
</HTML>

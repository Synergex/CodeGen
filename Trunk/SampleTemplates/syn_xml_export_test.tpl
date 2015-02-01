<CODEGEN_FILENAME><structure_name>_xml_export_test.dbl</CODEGEN_FILENAME>
<PROCESS_TEMPLATE>syn_xml_export.tpl</PROCESS_TEMPLATE>
;//****************************************************************************
;//
;// Title:       syn_xml_export_test.tpl
;//
;// Type         CodeGen Template
;//
;// Description: This template generates a Synergy program which exports the
;//              contents of a data file to an XML file.
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
;;*****************************************************************************
;;
;; Routine:     <structure_name>_xml_export_test
;;
;; Author:      <AUTHOR>
;;
;; Company:     <COMPANY>
;;
;;*****************************************************************************
;;
;; WARNING:     This code was generated by CodeGen. Any changes that you make
;;              to this file will be lost if the code is regenerated.
;;
;;*****************************************************************************
;;
main <structure_name>_xml_export_test

    .include "DBLDIR:synxml.def"

    record
        tt          ,i4
        error       ,i4
        errtxt      ,a40
    endrecord

proc

    xcall flags(7004020,1)
    open(tt=%syn_freechn,i,"tt:")

    writes(tt,"Exporting <FILE_NAME> to <structure_name>_collection.xml")

    error = %<structure_name>_xml_export("<structure_name>_collection.xml",errtxt)

    if (error) then
        writes(tt,"Export failed - " + %atrim(errtxt))
    else
        writes(tt,"Export complete")

    close tt
    stop

endmain

.include "<structure_name>_xml_elem.dbl"
.include "<structure_name>_xml_export.dbl"

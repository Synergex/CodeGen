<CODEGEN_FILENAME><StructureName>ToJson.dbl</CODEGEN_FILENAME>
;//****************************************************************************
;//
;// Title:       json_from_record.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: This template generates a Synergy function routine which
;//              converts a Synergy record to JSON
;//
;// Date:        3rd February 2010
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
;; Function:    <StructureName>ToJson
;;
;; Description: Convert a <STRUCTURE_NAME> record to JSON
;;
;; Author:      <AUTHOR>
;;
;; Created:     <DATE> at <TIME>
;;
;;*****************************************************************************
;;

.include "<STRUCTURE_NOALIAS>" repository, structure="s<StructureName>", end

function <StructureName>ToJson, string

    required in  <StructureName>, s<StructureName>
    endparams

    stack record
        json, string
    endrecord

proc

    json = '{"<StructureName>":{'

    <FIELD_LOOP>
    json = json + '"<FieldName>":<IF ALPHA>"'+%atrim(<StructureName>.<field_name>)+'"</IF><IF NUMERIC>'+%string(<StructureName>.<field_name>)+'</IF><,>'
    </FIELD_LOOP>

    json = json + '}}'

    freturn json

endfunction


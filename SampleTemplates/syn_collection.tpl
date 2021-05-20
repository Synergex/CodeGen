<CODEGEN_FILENAME><Structure_Name>Collection.dbl</CODEGEN_FILENAME>
<PROCESS_TEMPLATE>syn_io.tpl</PROCESS_TEMPLATE>
;//****************************************************************************
;//
;// Title:       syn_collection.tpl
;//
;// Type         CodeGen Template
;//
;// Description: This template generates a function which returns a collection
;//              of records in a dynamic memory handle.
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
;; Method:      <Structure_Name>Collection
;;
;; Description: Returns a collection of <STRUCTURE_NAME> records
;;
;; Author:      <AUTHOR>
;;
function <Structure_Name>Collection ,^VAL

    required out a_mh   ,int    ;Collection of structures (memory handle)
    endparams

    .include "CODEGEN_INC:structure_io.def"
    .include "<STRUCTURE_NOALIAS>" repository, structure="<structure_name>"

    .define D_BUFSZ 50  ;;Memory buffer increment (records)

    .align
    stack record localData
        ch      ,int    ;;File channel
        ms      ,int    ;;Total "rows" allocated in dynamic memory
        mc      ,int    ;;Used "rows" in dynamic memory
        error   ,int    ;;Error number
    endrecord

proc

    init localData

    ;;Open the file
    if (<Structure_Name>Io(IO_OPEN_INP,ch)!=IO_OK) then
        error=1
    else
    begin
        repeat
        begin
            ;;Does memory need resizing?
            if (mc==ms)
                a_mh=%mem_proc(DM_RESIZ|DM_BLANK,(^size(<structure_name>)*(ms+=D_BUFSZ)),a_mh)
            ;;Get the next record
            if (<Structure_Name>Io(IO_READ_NEXT,ch,,,^m(<structure_name>[mc+=1],a_mh))!=IO_OK)
                exitloop
        end

        ;;Resize handle to absolute size
        a_mh=%mem_proc(DM_RESIZ,(^size(<structure_name>)*(mc-=1)),a_mh)

        ;;Close the file
        xcall <Structure_Name>Io(IO_CLOSE,ch)
    end

    freturn error

endfunction

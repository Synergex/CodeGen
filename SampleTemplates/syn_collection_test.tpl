<CODEGEN_FILENAME><Structure_Name>CollectionTest.dbl</CODEGEN_FILENAME>
;//****************************************************************************
;//
;// Title:       syn_collection_test.tpl
;//
;// Type         CodeGen Template
;//
;// Description: Generates a test program for use with the template
;//              syn_collection.tpl
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
;; Method:      <structure_name>_<template>
;;
;; Description: Returns a collection of <STRUCTURE_NAME> records
;;
;; Author:      <AUTHOR>
;;
main <Structure_Name>CollectionTest

    .include "<STRUCTURE_NOALIAS>" repository, structure="<structure_name>"

    record
        tt      ,int    ;;Terminal channel
        errnum  ,int    ;;Error number
        mh      ,int    ;;Memory handle containing <STRUCTURE_NAME> records
        mc      ,int    ;;Number of <STRUCTURE_NAME> records returned
        count   ,int    ;;Loop counter
    endrecord

proc

    xcall flags(7004020,1)
    open(tt=syn_freechn,i,"tt:")

    mh = mem_proc(DM_ALLOC,1)

    if (errnum=<structure_name>_collection(mh)) then
        writes(tt,"<Structure_Name>Collection returned error "+string(errnum))
    else
    begin
        for count from 1 thru (mc=(mem_proc(DM_GETSIZE,mh)/^size(<structure_name>)))
            writes(tt,^m(<structure_name>[count],mh))
        writes(tt,string(mc)+" records found")
    end

    mh = mem_proc(DM_FREE,mh)

    close tt
    stop

endmain

.include "<Structure_Name>Io.dbl"
.include "<Structure_Name>Collection.dbl"
.include "CODEGEN_SUB:IsNumeric.dbl"

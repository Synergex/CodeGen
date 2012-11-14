<CODEGEN_FILENAME><Structure_Name>Io.dbl</CODEGEN_FILENAME>
;//****************************************************************************
;//
;// Title:       syn_io.tpl
;//
;// Type         CodeGen Template
;//
;// Description: This template generates a Synergy function which performs
;//              file IO for a specific structure / file specification.
;//
;// Date:        19th March 2007
;//
;// Author:      Richard C. Morris, Synergex Professional Services Group
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
;; Routine:     <Structure_Name>Io
;;
;; Author:      <AUTHOR>
;;
;; Company:     <COMPANY>
;;
;; Created:     <DATE> at <TIME>
;;
;;*****************************************************************************
;;
;; WARNING:     This code was generated by <CODEGEN_VERSION>.  Any changes that
;;              you make to this file will be lost if the code is regenerated.
;;
;;*****************************************************************************
;;
.include "<STRUCTURE_NOALIAS>" repository, structure="str<Structure_Name>", end

function <Structure_Name>Io ,^val

    ;Required arguments
    required in a_mode          ,n      ;;Access type
    required inout a_channel    ,n      ;;Channel
    required in a_key           ,a      ;;Key value
    required in a_keynum        ,n      ;;Key number
    required inout <structure_name> ,str<Structure_Name>
    optional in a_lock          ,n      ;;Lock record?
    optional in a_partial       ,n      ;;Do partial key reads?
    optional out a_errtxt       ,a      ;;Returned error text
    endparams

    .include "CODEGEN_INC:structure_io.def"

    stack record localData
        err         ,int    ;;Error occurred / error number
        line        ,int    ;;Error line number
        keyno       ,int    ;;Key number
        keylen      ,int    ;;Key length
        lock        ,int    ;;Lock record?
        pos         ,int    ;;Position in a string
        errmsg      ,a45    ;;Error message
        message     ,a80    ;;User message
        keyval      ,a255   ;;Hold original key
    endrecord

    <TAG_FIELD_DEFINE>
    <TAG_VALUE_DEFINE>
    <TAG_END_DEFINE>

proc

    init localData

    onerror fatalIoError

    if ^passed(a_key)
    begin
        keyval = a_key
        if (^passed(a_partial)&&a_partial) then
            keylen = %trim(a_key)
        else
            keylen = ^size(a_key)
    end

    if ^passed(a_keynum) then
        keyno=a_keynum
    else
        keyno=D_PRIMKEY

    if (!^passed(a_key) && ^passed(<structure_name>))
    begin
        keyval = %keyval(a_channel,<structure_name>,keyno)
        if (^passed(a_partial)&&a_partial) then
            keylen = %trim(%keyval(a_channel,<structure_name>,keyno))
        else
            keylen = ^len(%keyval(a_channel,<structure_name>,keyno))
    end

    if (!^passed(a_lock)) then
        lock = Q_NO_LOCK
    else
        lock = Q_AUTO_LOCK

    if (^passed(a_errtxt))
        clear a_errtxt

    using a_mode select

    (IO_OPEN_INP),
    begin
        open(a_channel=%syn_freechn,i:i,"<FILE_NAME>")
        &   [ERR=openError]
    end

    (IO_OPEN_UPD),
    begin
        open(a_channel=%syn_freechn,u:i,"<FILE_NAME>")
        &   [ERR=openError]
    end

    (IO_FIND),
    begin
        find(a_channel,,keyval(1:keylen),KEYNUM:keyno)
        &   [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
    end

    (IO_FIND_FIRST),
    begin
        find(a_channel,,^FIRST,KEYNUM:keyno)
        &   [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
    end

    (IO_READ_FIRST),
    begin
        .ifdef TAG_FIELD
        read(a_channel,<structure_name>,TAG_VALUE,KEYNUM:keyno,LOCK:lock)
        &   [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
        .else
        read(a_channel,<structure_name>,^FIRST,KEYNUM:keyno,LOCK:lock)
        &   [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
        .endc
    end

    (IO_READ),
    begin
        read(a_channel,<structure_name>,keyval(1:keylen),KEYNUM:keyno,LOCK:lock)
        &   [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
    end

    (IO_READ_NEXT),
    begin
        reads(a_channel,<structure_name>,LOCK:lock)
        &   [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
    end

    (IO_READ_PREV),
    begin
        reads(a_channel, <structure_name>,,REVERSE,LOCK:lock)
        &   [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
    end

    (IO_READ_LAST),
    begin
        .ifdef TAG_FIELD
        begin
            read(a_channel,<structure_name>,TAG_ENDVALUE,KEYNUM:keyno,LOCK:lock)
            &   [$ERR_EOF=readLastTag,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=readLastTag]
            ;;Now read the perious one!
            if (FALSE) then
readLastTag,    read(a_channel,<structure_name>,^LAST,KEYNUM:keyno,LOCK:lock)
                &   [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
            else
                reads(a_channel,<structure_name>,,REVERSE,LOCK:lock)
                &   [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
        end
        .else
        read(a_channel,<structure_name>,^LAST, KEYNUM:keyno,LOCK:lock)
        &   [$ERR_EOF=endOfFile,$ERR_LOCKED=recordLocked,$ERR_KEYNOT=keyNotFound]
        .endc
    end

    (IO_CREATE),
    begin
        .ifdef TAG_FIELD
        <structure_name>.TAG_FIELD = TAG_VALUE
        .endc
        ;;Make sure zero decimals contain zeros not spaces
        <FIELD_LOOP>
        <IF DECIMAL>
        if (!<field_path>)
            clear <field_path>
        </IF DECIMAL>
        <IF DATE>
        if (!<field_path>)
            clear <field_path>
        </IF DATE>
        <IF TIME>
        if (!<field_path>)
            clear <field_path>
        </IF TIME>
        </FIELD_LOOP>
        store(a_channel,<structure_name>)
        &   [$ERR_NODUPS=duplicateKey]
    end

    (IO_DELETE),
    begin
        delete(a_channel)
        &   [$ERR_NOCURR=noCurrentRecord]
    end

    (IO_UPDATE),
    begin
        write(a_channel,<structure_name>)
        &   [$ERR_NOCURR=noCurrentRecord]
    end

    (IO_UNLOCK),
    begin
        unlock a_channel
    end

    (IO_CLOSE),
    begin
        if (a_channel)
        begin
            close a_channel
            clear a_channel
        end
    end

    (),
    begin
        if (^passed(a_errtxt))
            a_errtxt = "Invalid file access mode"
    end

    endusing

    offerror

    ;;If we have a tag, chek it here
    .ifdef TAG_FIELD
    if (^passed(<structure_name>))
    begin
        if (^a(<structure_name>.TAG_FIELD)!=TAG_VALUE)
        begin
            if (!^passed(a_lock) || (^passed(a_lock) && !a_lock))
                if (a_channel && %chopen(a_channel))
                    unlock a_channel
            freturn IO_EOF
        end
    end
    .endc

    if (!^passed(a_lock) || (^passed(a_lock) && !a_lock))
        if (a_channel && %chopen(a_channel))
            unlock a_channel

    freturn IO_OK

;;-----------------------------------------------------------------------------

recordLocked,

    ;;Return the locked error code
    if (^passed(a_errtxt))
        a_errtxt = "Record locked"

    freturn IO_LOCKED

;;-----------------------------------------------------------------------------

endOfFile,

    unlock a_channel

    if (^passed(a_errtxt))
        a_errtxt = "Record not found - end of file"

    freturn IO_EOF

;;-----------------------------------------------------------------------------

keyNotFound,

    unlock a_channel

    if (^passed(a_errtxt))
        a_errtxt = "Record not found"

    if (^passed(a_key))
        a_key = keyval

    freturn IO_NOT_FOUND

;;-----------------------------------------------------------------------------

duplicateKey,

    unlock a_channel

    if (^passed(a_errtxt))
        a_errtxt = "Record already exists"

    freturn IO_DUP_KEY

;;-----------------------------------------------------------------------------

noCurrentRecord,

    unlock a_channel

    if (^passed(a_errtxt))
        a_errtxt = "No record was locked"

    freturn IO_NO_CUR_REC

;;-----------------------------------------------------------------------------

fatalIoError,

    if (a_channel && %chopen(a_channel))
        unlock a_channel

    offerror


    if (^passed(a_errtxt))
    begin
        call getErrorText
        a_errtxt = message
    end

    freturn IO_FATAL

;;-----------------------------------------------------------------------------

getErrorText,

    xcall error(err,line)
    xcall ertxt(err,errmsg)

    xcall s_bld(message,,'Error : %d, %a, at line : %d',err,errmsg,line)

    return


;;-----------------------------------------------------------------------------

openError,

    if (^passed(a_errtxt))
        a_errtxt = "Failed to open file"

    freturn IO_FATAL

endfunction


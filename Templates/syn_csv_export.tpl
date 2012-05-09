<CODEGEN_FILENAME>Export<StructureName>.dbl</CODEGEN_FILENAME>
<PROVIDE_FILE>ReplaceCharacter.dbl</PROVIDE_FILE>
<PROVIDE_FILE>DecimalToMDYString.dbl</PROVIDE_FILE>
<PROVIDE_FILE>DecimalToTimeString.dbl</PROVIDE_FILE>
;//****************************************************************************
;//
;// Title:       syn_csv_export.tpl
;//
;// Type         CodeGen Template
;//
;// Description: This template generates a function reads through all of the
;//              records in a data file and exports the data to a delimited
;//              text file.
;//
;// Date:        22nd November 2011
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
;; Method:      Export<StructureName>
;;
;; Description: Export <FILE_NAME> to a delimited text file
;;
;; Author:      <AUTHOR>
;;
;; Date:        <DATE> <TIME>
;;
function Export<StructureName>          ,^val
    optional in aDelimiter              ,a1
    optional in aReplaceDelimiterWith   ,a1
    optional out aReplacedDelimiters    ,i4
    endparams

    .include "<STRUCTURE_NOALIAS>" repository, record="<StructureName>", end

    stack record localData
        chIn        ,i4
        chOut       ,i4
        ok          ,i4
        replaced    ,i4
        delimiter   ,a1
        replaceWith ,a1
        csvBuf      ,String
    endrecord

proc

    init localData
    ok = 1

    ;;Set the delimiter
    if (^passed(aDelimiter)&&(aDelimiter)) then
        delimiter = aDelimiter
    else
        delimiter = "|"

    ;;Set the character to use if the delimiter is found in a string
    if (^passed(aReplaceDelimiterWith)&&(aReplaceDelimiterWith)) then
        replaceWith = aReplaceDelimiterWith
    else
        replaceWith = "_"

    ;;Open the ISAM file
    try
    begin
        open(chIn,i:i,"<FILE_NAME>")
    end
    catch (ex)
    begin
        clear chIn, ok
    end
    endtry

    ;;Open the CSV file
    if (ok)
    begin
        try
        begin
            open(chOut,o:s,"<StructureName>.txt")
        end
        catch (ex)
        begin
            clear chOut, ok
        end
        endtry
    end

    ;;Process each record
    repeat
    begin
        ;;Get the next record
        try
        begin
            reads(chIn,<StructureName>)
        end
        catch (ex, @EndOfFileException)
        begin
            exitloop
        end
        endtry

        ;;Make sure there are no commas in alpha fields
        <FIELD_LOOP>
        <IF ALPHA>
        replaced += %ReplaceCharacter(<StructureName>.<field_name>,delimiter,replaceWith)
        </IF>
        </FIELD_LOOP>

        csvBuf = ""
        <FIELD_LOOP>
        <IF ALPHA>
        & + %atrim(<StructureName>.<field_name>)
        </IF>
        <IF DECIMAL>
        & + %string(<StructureName>.<field_name>)
        </IF>
        <IF DATE>
        & + %DecimalToMDYString(<StructureName>.<field_name>)
        </IF>
        <IF TIME>
        & + %DecimalToTimeString(<StructureName>.<field_name>)
        </IF>
        <IF INTEGER>
        & + %string(<StructureName>.<field_name>)
        </IF>
        <IF MORE>
        & + delimiter
        </IF>
        </FIELD_LOOP>

        ;;Add the record to the output file
        writes(chOut,csvBuf)

    end

    ;;Close any open files
    if (chIn&&%chopen(chIn))
    begin
        close chIn
        if (chOut&&%chopen(chOut))
            close chOut
    end

    ;;Return information
    if (^passed(aReplacedDelimiters))
        aReplacedDelimiters = replaced

    freturn ok

endfunction


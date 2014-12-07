<CODEGEN_FILENAME><StructureName>SqlLoad.dbl</CODEGEN_FILENAME>
<PROCESS_TEMPLATE>DatabaseRoutines.tpl</PROCESS_TEMPLATE>
;//*****************************************************************************
;//
;// Title:        DatabaseRoutinesBulkLoadMapped.tpl
;//
;// Description:  Template to generate a Synergy function which loads data from
;//               a data file to a database table for a mapped structure via
;//               BULK INSERT.
;//
;// Date:         28th July 2014
;//
;// Author:       Steve Ives, Synergex Professional Services Group
;//               http://www.synergex.com
;//
;//****************************************************************************
;//
;// Copyright (c) 2014, Synergex International, Inc.
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
;; Routine:     <StructureName>Load
;;
;; Author:      <AUTHOR>
;;
;; Company:     <COMPANY>
;;
;;*****************************************************************************
;;
;; WARNING:     This code was generated by CodeGen.  Any changes that you make
;;              to this file will be lost if the code is regenerated.
;;
;;*****************************************************************************
;;
;; Possible return values from this routine are:
;;
;;  true    Table loaded
;;  false   Error (see a_errtxt)
;;
function <StructureName>Load ,^val
    required in  a_dbchn    ,int            ;;Connected database channel
    optional out a_rowcount ,n              ;;Rows inserted
    optional out a_errtxt   ,a              ;;Error text
    endparams

    .include "CONNECTDIR:ssql.def"

    stack record localData
        ok              ,boolean            ;;Return status
        chIn            ,int                ;;Input file channel  (data file)
        chOut           ,int                ;;Output file channel (delimited file)
        cursor          ,int                ;;Database cursor
        dberror         ,int                ;;Database error number
        length          ,int                ;;Length of error message
        transaction     ,boolean            ;;Is there a SQL transaction in progress
        errtxt          ,a512               ;;Error message
        sqlCommand      ,string             ;;Bulk insert SQL statement
        fileSpec        ,string             ;;Bulk load data file
        errorFile       ,string             ;;Bulk insert errors file
        sqlFile         ,string             ;;Bulk load SQL statement file
    endrecord

proc

    init localData
    ok = true

    ;;Open the data file associated with the mapped structure
    try 
    begin
        open(chIn=%syn_freechn,i:i,"<MAPPED_FILE>")
    end
    catch (ex)
    begin
        ok = false
        errtxt = "Failed to open input file <MAPPED_FILE>"
        clear chIn
    end
    endtry

    ;;Open the delimited output file and build the SQL statement
    try 
    begin
        ;;Get the TEMP path
        data tempPath, a256
        xcall getlog("TEMP",tempPath,length)
        if (tempPath(length:1)!="\")
            tempPath = %atrim(tempPath) + "\"

        ;;Define the output file name and make sure there isn't an old one out there
        fileSpec = %atrim(tempPath)+"<STRUCTURE_NAME>.BULK_LOAD"
        xcall delet(fileSpec)

        ;;Open the output file
        open(chOut=%syn_freechn,o:s,fileSpec)

        ;;Define the error and SQL command file names
        errorFile = fileSpec + ".ERRORS"
        sqlFile   = fileSpec + ".SQL"

        ;;Build the SQL statement
        sqlCommand = "BULK INSERT [<STRUCTURE_NAME>] FROM '"+fileSpec+"' WITH (FIELDTERMINATOR='|',ROWTERMINATOR='\n',FIRSTROW=2,KEEPNULLS,ERRORFILE='"+errorFile+"')"
        
        ;;Save the SQL statement to a file (for debugging)
        begin
            data tmpCh, i4, 0
            xcall delet(sqlFile)
            open(tmpch,o:s,sqlFile)
            writes(tmpCh,sqlCommand)
            close tmpCh
        end

        ;;Make sure there are no previous error files hanging around
        xcall delet(errorFile)
        xcall delet(errorFile + ".Error.Txt")
    end
    catch (ex)
    begin
        ok = false
        errtxt = "Failed to open output file " + fileSpec
        clear chOut
    end
    endtry

    ;Put column headings into the delimited file
    writes(chOut,"<FIELD_LOOP><FIELD_SQLNAME>|</FIELD_LOOP>")

    if (ok)
    begin
        data fileRecord, strFileRecord
        data databaseRecord, strDatabaseRecord

        ;;Read records from the input file and write the output file
        repeat
        begin
            data row, string, ""

            ;;Get the next record from the file and map it into the database record
            reads(chIn,fileRecord,eof)
            xcall <StructureName>Map(fileRecord,databaseRecord)

            ;;Put the record in the delimited bulk load file
            <FIELD_LOOP>
            <IF ALPHA>
            row = row + %atrim(<FIELD_NAME>)
            </IF ALPHA>
            <IF DECIMAL>
            row = row + %string(<FIELD_NAME>)
            </IF DECIMAL>
            <IF DATE>
            if (<FIELD_NAME>)
                row = row + %string(<FIELD_NAME>,"XXXX-XX-XX")
            </IF DATE>
            <IF TIME_HHMM>
            row = row + %string(<FIELD_NAME>,"XX:XX")
            </IF TIME_HHMM>
            <IF TIME_HHMMSS>
            row = row + %string(<FIELD_NAME>,"XX:XX:XX")
            </IF TIME_HHMMSS>
            <IF INTEGER>
            row = row + %string(<FIELD_NAME>)
            </IF INTEGER>
            row = row +"|"
            </FIELD_LOOP>
            writes(chOut,row)
        end
    end

eof,
    close chIn
    close chOut

    ;;Start a database transaction
    if (ok)
    begin
        transaction = false
        if (%ssc_commit(a_dbchn,SSQL_TXON)==SSQL_NORMAL) then
            transaction = true
        else
        begin
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
                errtxt="Failed to start transaction"
            ok = false
        end
    end

    ;;Open a database cursor for the command
    if (ok)
    begin
        if (%ssc_open(a_dbchn,cursor,sqlCommand,SSQL_NONSEL)==SSQL_FAILURE)
        begin
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
                errtxt="Failed to open cursor"
            clear cursor
            ok = false
        end
    end

    ;;Execute the cursor
    if (ok)
    begin
        data rowsAffected, i4
        if (%ssc_execute(a_dbchn,cursor,SSQL_STANDARD,,rowsAffected)==SSQL_NORMAL) then
        begin
            if (^passed(a_rowcount))
                a_rowcount = rowsAffected
        end
        else
        begin
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
                errtxt="Failed to execute SQL statement"
            ok = false
        end
    end

    ;;Close the cursor
    if (cursor)
    begin
        if (%ssc_close(a_dbchn,cursor)==SSQL_FAILURE)
        begin
            if (ok)
            begin
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
                    errtxt="Failed to close cursor"
                ok = false
            end
        end
    end

    ;;Commit or rollback the transaction
    if (transaction)
    begin
        if (ok) then
        begin
            ;;Success, commit the transaction
            if (%ssc_commit(a_dbchn,SSQL_TXOFF)==SSQL_FAILURE)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
                    errtxt="Failed to commit transaction"
            end
        end
        else
        begin
            ;;There was an error, rollback the transaction
            xcall ssc_rollback(a_dbchn,SSQL_TXOFF)
        end
    end

    ;;Clean up
    if (ok)
    begin
        xcall delet(fileSpec)
        xcall delet(sqlFile)
        xcall delet(errorFile)
        xcall delet(errorFile + ".Error.Txt")
    end

    ;;Return the error text
    if (^passed(a_errtxt))
        a_errtxt = errtxt

    freturn ok

endfunction


;;*****************************************************************************
;;
;; Routine:     <StructureName>Map
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
subroutine <StructureName>Map

    required in  <mapped_structure>, strFileRecord
    required out <structure_name>, strDatabaseRecord
    endparams

proc

    <FIELD_LOOP>
    <field_path> = <mapped_path_conv>
    </FIELD_LOOP>

    xreturn

endsubroutine

;;*****************************************************************************
;;
;; Routine:     <StructureName>Unmap
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
subroutine <StructureName>Unmap

    required in  <structure_name>, strDatabaseRecord
    required out <mapped_structure>, strFileRecord
    endparams

proc

    <FIELD_LOOP>
    <mapped_path> = <field_path_conv>
    </FIELD_LOOP>

    xreturn

endsubroutine

.include "<MAPPED_STRUCTURE>" repository, structure="strFileRecord", end
.include "<STRUCTURE_NOALIAS>" repository, structure="strDatabaseRecord", end
<CODEGEN_FILENAME><structure_name>_delete_row.dbl</CODEGEN_FILENAME>
;//****************************************************************************
;//
;// Title:       sql_delete_row.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: Template to generate a Synergy function which deletes a row
;//              from a SQL Server database table.
;//
;// Date:        12th March 2008
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
;; Routine:     <structure_name>_delete_row
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
;; Possible return values from this routine are:
;;
;;  true    row deleted
;;  false   Error (see a_errtxt)
;;
function <structure_name>_delete_row ,^val

    required in  a_dbchn    ,int    ;;Connected database channel
    <PRIMARY_KEY>
    <SEGMENT_LOOP>
    optional in  a_<segment_name> ,a
    </SEGMENT_LOOP>
    </PRIMARY_KEY>
    optional in  a_where    ,a      ;;Where clause to determine rows deleted.
    optional out a_errtxt   ,a      ;;Error text
    endparams

    ;;Note: Primary key segments or a_where must be specified.

    .include "CONNECTDIR:ssql.def"
    .include "<STRUCTURE_NOALIAS>" repository, stack record="<structure_name>"

    stack record local_data
        ok          ,boolean    ;;Return status
        dberror     ,int        ;;Database error number
        cursor      ,int        ;;Database cursor
        length      ,int        ;;Length of a string
        transaction ,int        ;;Transaction in progress
        errtxt      ,a512       ;;Error message text
        sql         ,string     ;;SQL statement
    endrecord

proc

    init local_data
    ok = true

    ;;-------------------------------------------------------------------------
    ;;Start a database transaction
    ;;
    if (%ssc_commit(a_dbchn,SSQL_TXON)==SSQL_NORMAL) then
        transaction=1
    else
    begin
        ok = false
        if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
            errtxt="Failed to start transaction"
    end

    ;;-------------------------------------------------------------------------
    ;;Open a cursor for the DELETE statement
    ;;
    if (ok)
    begin
        if (<PRIMARY_KEY><SEGMENT_LOOP>(^passed(a_<segment_name>)&&a_<segment_name>)<&&></SEGMENT_LOOP></PRIMARY_KEY>) then
        begin
            sql = "DELETE FROM <STRUCTURE_NAME> WHERE <PRIMARY_KEY><SEGMENT_LOOP> <SEGMENT_NAME>=:<SEGMENT_NUMBER> <AND></SEGMENT_LOOP></PRIMARY_KEY>"
            if (%ssc_open(a_dbchn,cursor,(a)sql,SSQL_NONSEL,,<PRIMARY_KEY><KEY_SEGMENTS></PRIMARY_KEY>,<PRIMARY_KEY><SEGMENT_LOOP>a_<segment_name><,></SEGMENT_LOOP></PRIMARY_KEY>)==SSQL_FAILURE)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
                    errtxt="Failed to open cursor"
            end
        end
        else
        begin
            sql = "DELETE FROM <STRUCTURE_NAME> WHERE " + %atrim(a_where)
            if (%ssc_open(a_dbchn,cursor,(a)sql,SSQL_NONSEL)==SSQL_FAILURE)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
                    errtxt="Failed to open cursor"
            end
        end
    end

    ;;-------------------------------------------------------------------------
    ;;Execute the query
    ;;
    if (ok)
    begin
        if (%ssc_execute(a_dbchn,cursor,SSQL_STANDARD)==SSQL_FAILURE)
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
                errtxt="Failed to execute SQL statement"
        end
    end

    ;;-------------------------------------------------------------------------
    ;;Close the database cursor
    ;;
    if (cursor)
    begin
        if (%ssc_close(a_dbchn,cursor)==SSQL_FAILURE)
        begin
            if (ok)
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
                    errtxt="Failed to close cursor"
            end
        end
    end

    ;;-------------------------------------------------------------------------
    ;;Commit or rollback the transaction
    ;;
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

    ;;-------------------------------------------------------------------------
    ;;If there was an error message, return it to the calling routine
    ;;
    if (^passed(a_errtxt))
    begin
        if (ok) then
            clear a_errtxt
        else
            a_errtxt=errtxt
    end

    freturn ok

endfunction


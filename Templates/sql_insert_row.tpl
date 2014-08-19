<CODEGEN_FILENAME><structure_name>_insert_row.dbl</CODEGEN_FILENAME>
<PROVIDE_FILE>IsNumeric.dbl</PROVIDE_FILE>
;//****************************************************************************
;//
;// Title:       sql_insert_row.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: Template to generate a Synergy function which inserts a row
;//              into a table in a SQL Server database.
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
;; Routine:     <structure_name>_insert_row
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
;;              you make to this file will be lost if the code is regenerated
;;
;;*****************************************************************************
;;
;; Possible return values from this routine are:
;;
;;  true    Row inserted
;;  false   Error (see a_errtxt)
;;
function <structure_name>_insert_row ,^val

    required in  a_dbchn    ,int    ;;Connected database channel
    required in  a_data     ,a      ;;Record containing data to insert
    optional out a_errtxt   ,a      ;;Error text
    endparams

    .include "CONNECTDIR:ssql.def"
    .include "<STRUCTURE_NOALIAS>" repository, stack record="<structure_name>"

    external function
        IsNumeric   ,^val
    endexternal

    stack record local_data
        ok          ,boolean    ;;Return status
        dberror     ,int        ;;Database error number
        cursor      ,int        ;;Database cursor
        cnt         ,int        ;;Generic counter
        transaction ,int        ;;Transaction in progress
        length      ,int        ;;Length of a string
        errtxt      ,a512       ;;Error message text
    endrecord

    static record
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
    ;;Open a cursor for the INSERT statement
    ;;
    if (ok)
    begin
        if (!(a)sql)
        begin
            sql = "INSERT INTO <STRUCTURE_NAME> ("
            <FIELD_LOOP>
            & + "<FIELD_SQLNAME><,>"
            </FIELD_LOOP>
            & + ") VALUES(<FIELD_LOOP>:<FIELD#LOGICAL><,></FIELD_LOOP>)"
        end

        if (%ssc_open(a_dbchn,cursor,(a)sql,SSQL_NONSEL,SSQL_STANDARD)==SSQL_FAILURE)
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
                errtxt="Failed to open cursor"
        end
    end

    ;;-------------------------------------------------------------------------
    ;;Bind the host variables for data to be inserted
    ;;
    if (ok)
    begin
        if (%ssc_bind(a_dbchn,cursor,<STRUCTURE_FIELDS>,
        <FIELD_LOOP>
        <IF NOTDATE>
        &    <structure_name>.<field_name><,>
        </IF>
        <IF DATE>
        &    ^a(<structure_name>.<field_name>)<,>
        </IF>
        </FIELD_LOOP>
        &   )==SSQL_FAILURE)
        begin
            ok = false
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
                errtxt="Failed to bind variables"
        end
    end

    ;;-------------------------------------------------------------------------
    ;;Insert the row into the database
    ;;
    if (ok)
    begin
        ;;Load data into bound record
        <structure_name> = a_data

        ;;Clean up the data
        <FIELD_LOOP>
        <IF ALPHA>
        <field_path>=%atrim(<field_path>)+%char(0)
        </IF>
        <IF DECIMAL>
        if ((!<field_path>)||(!%IsNumeric(^a(<field_path>))))
            clear <field_path>
        </IF>
        <IF DATE>
        if ((!<field_path>)||(!%IsNumeric(^a(<field_path>))))
            ^a(<field_path>(1:1))=%char(0)
        </IF>
        <IF TIME>
        if ((!<field_path>)||(!%IsNumeric(^a(<field_path>))))
            ^a(<field_path>(1:1))=%char(0)
        </IF>
        </FIELD_LOOP>

        ;;Execute INSERT statement
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


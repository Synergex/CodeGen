<CODEGEN_FILENAME><structure_name>_select_rows.dbl</CODEGEN_FILENAME>
;//****************************************************************************
;//
;// Title:       sql_select_rows.tpl
;//
;// Description: Template to generate a Synergy function which retrieves
;//              multiple rows from a table in a SQL Server database.
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
;; Routine:     <structure_name>_select_rows
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
;;   true   Success, rows returned
;;   false  Error, see a_errtxt
;;
function <structure_name>_select_rows ,^val

    required in  a_dbchn    ,int    ;Connected database channel
    required in  a_where    ,a      ;Where clause to use
    required out a_data     ,int    ;Memory handle with matching rows rows
    optional in  a_estrows  ,int    ;Estimated row count
    optional out a_rows     ,int    ;Row count
    optional out a_errtxt   ,a      ;Error text
    endparams

    .include "CONNECTDIR:ssql.def"
    .include "<STRUCTURE_NOALIAS>" repository, stack record="<structure_name>"
    .include "<STRUCTURE_NOALIAS>" repository, structure="row", nofields

    stack record local_data
        ok      ,boolean    ;;OK to continue
        dberror ,int        ;;Database error number
        cursor  ,int        ;;Database cursor
        length  ,int        ;;Length of a string
        mh      ,int        ;;Memory handle
        mi      ,int        ;;Memory increment size
        ms      ,int        ;;Memory size (allocated rows)
        mc      ,int        ;;Memory content (used rows)
        errtxt  ,a512       ;;Error message text
        sql     ,string     ;;SQL statement
    endrecord

.proc

    init <structure_name>,local_data
    ok = true

    ;;-------------------------------------------------------------------------
    ;;Determine increment size for dynamic memory
    ;;
    if (^passed(a_estrows) && a_estrows) then
        mi = a_estrows * 1.2
    else
        mi = 50

    ;;-------------------------------------------------------------------------
    ;;Open a cursor for the SELECT statement
    ;;
    sql = "SELECT "
    <FIELD_LOOP>
    &   "<FIELD_SQLNAME><,>"
    </FIELD_LOOP>
    &   " FROM <STRUCTURE_NAME> "

    if (^passed(a_where) && a_where)
        sql = %atrim(sql) + " WHERE " + %atrim(a_where)

    if (%ssc_open(a_dbchn,cursor,(a)sql,SSQL_SELECT)==SSQL_FAILURE)
    begin
        ok = false
        if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
            errtxt="Failed to open cursor"
    end

    ;;-------------------------------------------------------------------------
    ;;Bind host variables to receive the data
    ;;
    if (ok)
    begin
        if (%ssc_define(a_dbchn,cursor,<STRUCTURE_FIELDS>,
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
    ;;Move data to host variables
    ;;
    if (ok)
    begin

        ;;Allocate initial dynamic memory
        mh = %mem_proc(DM_ALLOC+DM_STATIC,(^size(row)*(ms=mi)))

        repeat
        begin
            using (%ssc_move(a_dbchn,cursor,1)) select
            (SSQL_NORMAL),
            begin
                if ((mc+=1)>ms)
                    mh = %mem_proc(DM_RESIZ,(^size(row)*(ms+=mi)),mh)
                ^m(row[mc],mh) = <structure_name>
            end
            (SSQL_NOMORE),
            begin
                if (mc) then
                    mh = %mem_proc(DM_RESIZ,(^size(row)*mc),mh)
                else
                    mh = %mem_proc(DM_FREE,mh)
                exitloop
            end
            (SSQL_FAILURE),
            begin
                ok = false
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
                    errtxt="Failed to execute SQL statement"
                set mh, mc = %mem_proc(DM_FREE,mh)
                exitloop
            end
            endusing
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
    ;;Return data
    ;;
    if (mh)
        a_data = mh

    ;;-------------------------------------------------------------------------
    ;;Return row count
    ;;
    if (^passed(a_rows))
        a_rows = mc

    ;;-------------------------------------------------------------------------
    ;;If there was an error message, return it to the calling routine
    ;;
    if (^passed(a_errtxt))
        if (ok) then
            clear a_errtxt
        else
            a_errtxt=errtxt

    freturn ok

endfunction

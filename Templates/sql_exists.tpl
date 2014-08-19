<CODEGEN_FILENAME><structure_name>_exists.dbl</CODEGEN_FILENAME>
;//****************************************************************************
;//
;// Title:       sql_exists.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: Template to generate a Synergy function which determines if
;//              a table exists in a SQL Server database
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
;; Routine:     <structure_name>_exists
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
;;*******************************************************************************
;;
;; Possible return values from this routine are:
;;
;;  -1  An error occurred
;;  0   Table does not exist
;;  1   Table exists
;;
function <structure_name>_exists ,^val

    required in  a_dbchn    ,int    ;;Connected database channel
    optional out a_errtxt   ,a      ;;Error text
    endparams

    .include "CONNECTDIR:ssql.def"
    .include "<STRUCTURE_NOALIAS>" repository, stack record="<structure_name>"

    stack record local_data
        error       ,int    ;;Returned error number
        dberror     ,int    ;;Database error number
        cursor      ,int    ;;Database cursor
        length      ,int    ;;Length of a string
        table_name  ,a128   ;;Retrieved table name
        errtxt      ,a512   ;;Error message text
    endrecord

proc

    init <structure_name>,local_data

    ;;-------------------------------------------------------------------------
    ;;Open a cursor for the SELECT statement
    ;;
    if (%ssc_open(a_dbchn,cursor,"SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES "
    &   "WHERE TABLE_NAME='<STRUCTURE_NAME>'",SSQL_SELECT)==SSQL_FAILURE)
    begin
        error=-1
        if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
            errtxt="Failed to open cursor"
    end

    ;;-------------------------------------------------------------------------
    ;;Bind host variables to receive the data
    ;;
    if (!error)
    begin
        if (%ssc_define(a_dbchn,cursor,1,table_name)==SSQL_FAILURE)
        begin
            error=-1
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
                errtxt="Failed to bind variable"
        end
    end

    ;;-------------------------------------------------------------------------
    ;;Move data to host variables
    ;;
    if (!error)
    begin
        if (%ssc_move(a_dbchn,cursor,1)==SSQL_NORMAL)
                error = 1 ;; Table exists
    end

    ;;-------------------------------------------------------------------------
    ;;Close the database cursor
    ;;
    if (cursor)
    begin
        if (%ssc_close(a_dbchn,cursor)==SSQL_FAILURE)
        begin
            if (!error)
            begin
                error=-1
                if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
                    errtxt="Failed to close cursor"
            end
        end
    end

    ;;-------------------------------------------------------------------------
    ;;If there was an error message, return it to the calling routine
    ;;
    if (^passed(a_errtxt))
    begin
        if (error) then
            a_errtxt=errtxt
        else
            clear a_errtxt
    end

    freturn error

endfunction


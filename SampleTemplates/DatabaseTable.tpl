<CODEGEN_FILENAME><StructureName>Table.dbl</CODEGEN_FILENAME>
<PROCESS_TEMPLATE>DatabaseTableBase.tpl</PROCESS_TEMPLATE>
<PROCESS_TEMPLATE>DatabaseTableConnection.tpl</PROCESS_TEMPLATE>
<REQUIRES_OPTION>FL</REQUIRES_OPTION>
;//****************************************************************************
;//
;// Title:       DatabaseTable.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: This template generates a class which can be used to interact
;//              with a table in a SQL Server database. It is intended for use
;//              with UNMAPPED tables. For MAPPED tables use the template
;//              DatabaseTableMapped.tpl.
;//
;// Date:        12th May 2012
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
;; Title:       <StructureName>Table.dbl
;;
;; Type:        Class
;;
;; Description: This class provides the ability to interact with a SQL Server
;;              database table named <StructureName> using records defined
;;              by the repository structure <STRUCTURE_NOALIAS> and data
;;              stored in the file <FILE_NAME>.
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
import System.Collections
import <NAMESPACE>

namespace <NAMESPACE>

    ;;; <summary>
    ;;; Class used to interact with the database table <StructureName>
    ;;; </summary>
    public class <StructureName>Table extends DatabaseTableBase

        ;;SQL Statements
        private static mCreateTableStatement    ,string
        private static mInsertStatement         ,string
        private static mSelectByKeyStatement    ,string
        private static mSelectAllStatement      ,string
        private static mSelectWhereStatement    ,string
        private static mDeleteByKeyStatement    ,string

        ;;Defines the layout of the synergy record used to transfer data
        ;;to and from the database. Used with %ssc_strdef() and populated
        ;;by the loadRecordSpec() method which is called from the constructor
        private record recordSpec
            fieldCount          ,d3
            group fields        ,[<STRUCTURE_FIELDS>]a
                fieldType       ,a1         ;Field type (A/D/I)
                fieldSize       ,d5         ;Field length
                fieldDecimals   ,d2         ;Implied decimal places (for D)
            endgroup
        endrecord

        ;;; <summary>
        ;;; Constructor
        ;;; </summary>
        ;;; <param name="aDb">DatabaseConnection object</param>
        public method <StructureName>Table
            required in aDb, @DatabaseConnection
            endparams
            parent(aDb)
        proc
            loadRecordSpec()
            loadSqlStatements()
        endmethod

        ;;; <summary>
        ;;; Create a <StructureName> table in the database
        ;;; </summary>
        ;;; <returns>True for success, false for failure</returns>
        public method Create, boolean
            endparams
            stack record local_data
                ok          ,boolean    ;;Return status
                cursor      ,int        ;;Database cursor
                transaction ,boolean    ;;Transaction in process
            endrecord
        proc
            init local_data
            ok = true

            ;;Start a new transaction
            if (ok = startTransaction())
                transaction = true

            ;;Create the database table and primary key
            if (ok)
            begin
                if (ok=openNonSelectCursor(mCreateTableStatement,cursor))
                begin
                    ok = executeNonSelectCursor(cursor)
                    closeCursor(cursor,ok)
                end
            end

            <ALTERNATE_KEY_LOOP>
            ;;Create index <KEY_NUMBER> (<KEY_DESCRIPTION>)
            if (ok)
            begin
                if (ok=openNonSelectCursor("CREATE <KEY_UNIQUE> INDEX IX_<StructureName>_<KeyName> ON <StructureName>(<SEGMENT_LOOP><SegmentName> <SEGMENT_ORDER><,></SEGMENT_LOOP>)",cursor))
                begin
                    ok = executeNonSelectCursor(cursor)
                    closeCursor(cursor,ok)
                end
            end

            </ALTERNATE_KEY_LOOP>
            ;;Grant access permissions
            if (ok&&(ok=openNonSelectCursor("GRANT ALL ON <StructureName> TO PUBLIC",cursor)))
            begin
                ok = executeNonSelectCursor(cursor)
                closeCursor(cursor,ok)
            end

            ;;Commit or rollback the transaction
            if (transaction)
                ok = commitOrRollback(ok)

            mreturn ok

        endmethod

        ;;; <summary>
        ;;; Deletes the <StructureName> table from the database
        ;;; </summary>
        ;;; <returns>True for success, false for failure</returns>
        public method Drop, boolean
			endparams
			.include "CONNECTDIR:ssql.def"
            stack record local_data
                ok          ,boolean    ;;Return status
                cursor      ,int        ;;Database cursor
                transaction ,boolean    ;;Transaction in progress
            endrecord
        proc

            init local_data
            ok = true

            ;;Start a database transaction
            if (ok = startTransaction())
                transaction = true

            ;;Open cursor for DROP TABLE statement
            ;;
            if (ok)
                ok=openNonSelectCursor("DROP TABLE <StructureName>",cursor)

            ;;Execute DROP TABLE statement
            ;;
            if (ok)
            begin
                if (!(ok = executeNonSelectCursor(cursor)))
                begin
                    data dbErrText, a1024
                    data length, int
                    if (%ssc_getemsg(mDb.Channel,dbErrText,length,,mErrorNumber)==SSQL_NORMAL)
                    begin
                        ;;Check if the error was that the table did not exist
                        if (mErrorNumber==-3701) then
                        begin
                            clear mErrorMessage
                            ok = true
                        end
                        else
                            mErrorMessage = %atrim(dbErrText)
                    end
                end
            end

            ;;Close the cursor
            closeCursor(cursor,ok)

            ;;Commit or rollback the transaction
            if (transaction)
                ok = commitOrRollback(ok)

            mreturn ok

        endmethod

        ;;; <summary>
        ;;; Deletes all data from the <StructureName> table in the database
        ;;; </summary>
        ;;; <returns>True for success, false for failure</returns>
        public method Clear, boolean
            endparams
            stack record local_data
                ok          ,boolean    ;;Return status
                cursor      ,int        ;;Database cursor
                transaction ,boolean    ;;Transaction in process
            endrecord
        proc

            init local_data
            ok = true

            ;;Start a database transaction
            if (ok = startTransaction())
                transaction = true

            ;;Open cursor for the SQL statement
            if (ok)
                ok = openNonSelectCursor("TRUNCATE TABLE <StructureName>",cursor)

            ;;Execute SQL statement
            if (ok)
                ok = executeNonSelectCursor(cursor)

            ;;Close the cursor
            closeCursor(cursor,ok)

            ;;Commit or rollback the transaction
            if (transaction)
                ok = commitOrRollback(ok)

            mreturn ok

        endmethod

        ;;; <summary>
        ;;; Checks if the <StructureName> table exists in the database
        ;;; </summary>
        ;;; <returns>True if the table exists, false if not (or an error occurred)</returns>
        public method Exists, boolean
			endparams
			.include "CONNECTDIR:ssql.def"
            .include "<STRUCTURE_NOALIAS>" repository, stack record="<structure_name>"
            stack record local_data
                ok          ,boolean    ;;Return value
                cursor      ,int        ;;Database cursor
                table_name  ,a128       ;;Retrieved table name
            endrecord
        proc

            init <structure_name>,local_data

            ;;Open a cursor for the SELECT statement
            ;;
            ok = openSelectCursor("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='<StructureName>'",cursor)

            ;;Bind host variables to receive the data
            if (ok)
                if (%ssc_define(mDb.Channel,cursor,1,table_name)==SSQL_FAILURE)
                    ok = getDatabaseError("Failed to bind variable")

            ;;Move data to host variables
            if (ok)
                if (%ssc_move(mDb.Channel,cursor,1)==SSQL_FAILURE)
                    ok = false

            ;;Close the cursor
            closeCursor(cursor,ok)

            mreturn ok

        endmethod

        ;;; <summary>
        ;;; Inserts a new row into the <StructureName> table in the database
        ;;; </summary>
        ;;; <param name="arg<StructureName>">Record containing data to insert</param>
        ;;; <returns>True for success, false for failure</returns>
        public method InsertRow, boolean
            required in arg<StructureName>, str<StructureName>All
            endparams
            stack record local_data
                ok              ,boolean    ;;Return status
                cursor          ,int        ;;Database cursor
                transaction     ,boolean    ;;Transaction in progress
                rec<StructureName>, str<StructureName>All
            endrecord
        proc

            init local_data
            ok = true

            ;;Start a database transaction
            if (ok = startTransaction())
                transaction = true

            ;;Open a cursor for the INSERT statement
            if (ok)
                ok = openNonSelectCursor(mInsertStatement,cursor)

            ;;Prepare a structure definition to define where the data for each column
            ;;comes from within the record
            ;;
            if (ok)
                ok = defineStructure(cursor,1,recordSpec,rec<StructureName>)

            ;;Insert the row into the database
            if (ok)
            begin
                ;;Load the data into our local buffer
                rec<StructureName> = arg<StructureName>

                ;;If requested, clean the data
                if (mCleanData)
                    clean<StructureName>Data(rec<StructureName>)

                ;;If requested, null terminate empty alpha fields
                if (mEmptyAlphaNull)
                    nullTerminateEmptyAlphas(rec<StructureName>)

                ;;Execute the INSERT statement
                ok = executeNonSelectCursor(cursor)
            end

            ;;Close the cursor
            closeCursor(cursor,ok)

            ;;Commit or rollback the transaction
            if (transaction)
                ok = commitOrRollback(ok)

            mreturn ok

        endmethod

		;;; <summary>
		;;; Inserts multiple new rows into the <StructureName> table in the database.
		;;; </summary>
		;;; <param name="argRecords">Collection of any number of boxed <StructureName> records to insert.</param>
		;;; <returns>True for success, false for failure.</returns>
		public method InsertRows        ,boolean
			required in  argRecords     ,@ArrayList
			endparams
		proc
			mreturn doInsertRows(argRecords,^null,0)
		endmethod

		;;; <summary>
		;;; Inserts multiple new rows into the <StructureName> table in the database
		;;; and returns a collection containing the data for any rows that failed to
		;;; insert.
		;;; </summary>
		;;; <param name="argRecords">Collection of any number of boxed <StructureName> records to insert.</param>
		;;; <param name="argExceptions">Collection of records that failed to insert.</param>
		;;; <returns>True for success, false for failure.</returns>
		public method InsertRows        ,boolean
			required in  argRecords     ,@ArrayList
			required out argExceptions  ,@ArrayList
			endparams
		proc
			if (argExceptions==^null)
				argExceptions = new ArrayList()
			mreturn doInsertRows(argRecords,argExceptions,0)
		endmethod

		;;; <summary>
		;;; Inserts multiple new rows into the <StructureName> table in the database
		;;; and logs any errors to a supplied log channel.
		;;; </summary>
		;;; <param name="argRecords">Collection of any number of boxed <StructureName> records to insert.</param>
		;;; <param name="argLogCh">Channel to log error messages to.</param>
		;;; <returns>True for success, false for failure.</returns>
		public method InsertRows        ,boolean
			required in argRecords      ,@ArrayList
			required in argLogCh        ,i
			endparams
		proc
			mreturn doInsertRows(argRecords,^null,argLogCh)
		endmethod

		;;; <summary>
		;;; Inserts multiple new rows into the <StructureName> table in the database,
		;;; returns a collection containing the data for any rows that failed to
		;;; insert, and also logs errors to s supplied log channel.
		;;; </summary>
		;;; <param name="argRecords">Collection of any number of boxed <StructureName> records to insert.</param>
		;;; <param name="argExceptions">Collection of records that failed to inserted.</param>
		;;; <param name="argLogCh">Channel to log error messages to.</param>
		;;; <returns>True for success, false for failure.</returns>
		public method InsertRows        ,boolean
			required in  argRecords     ,@ArrayList
			required out argExceptions  ,@ArrayList
			required in  argLogCh       ,i
			endparams
		proc
			if (argExceptions==^null)
				argExceptions = new ArrayList()
			mreturn doInsertRows(argRecords,argExceptions,argLogCh)
		endmethod

		private method doInsertRows, boolean
			required in argRecords      ,@ArrayList
			required in argExceptions   ,@ArrayList
			required in argLogCh        ,i
			endparams
			stack record local_data
				ok          ,boolean    ;;Return status
				cursor      ,int        ;;Database cursor
				transaction ,boolean    ;;Transaction in progress
				continue    ,int        ;;Continue after an error
				rec<StructureName>, str<StructureName>All
				obj<StructureName>, @str<StructureName>All
			endrecord
		proc

			init local_data
			ok = true

			;;Start a database transaction
			if (ok = startTransaction())
				transaction = true

			;;Open a cursor for the INSERT statement
			if (ok)
				ok = openNonSelectCursor(mInsertStatement,cursor)

			;;Prepare a structure definition to define where the data for each column
			;;comes from within the record
			if (ok)
				ok = defineStructure(cursor,1,recordSpec,rec<StructureName>)

			;;Insert the rows into the database
			if (ok)
			begin
				data cnt, int
				foreach obj<StructureName> in argRecords
				begin
					;;Load data into the bound record
					rec<StructureName> = (str<StructureName>All)obj<StructureName>

					;;If requested, clean the data
					if (mCleanData)
						clean<StructureName>Data(rec<StructureName>)

					;;If requested, null terminate empty alpha fields
					if (mEmptyAlphaNull)
						nullTerminateEmptyAlphas(rec<StructureName>)

					;;Execute the INSERT statement
					if (!(ok = executeNonSelectCursor(cursor)))
					begin
						;;We got an error, lets decide what to do with it
						clear continue

						;;Are we logging errors?
						if (argLogCh)
						begin
							writes(argLogCh,mErrorMessage)
							continue=1
						end

						;;Are we processing exceptions?
						if (argExceptions!=^null)
						begin
							argExceptions.Add((@str<StructureName>All)rec<StructureName>)
							continue=1
						end

						if (continue)
						begin
							ok = true
							nextloop
						end

						exitloop
					end
				end
			end

			;;Close the cursor
			closeCursor(cursor,ok)

			;;Commit or rollback the transaction
			if (transaction)
				ok = commitOrRollback(ok)

			mreturn ok

		endmethod

        ;;; <summary>
        ;;; Retrieves a row from the <StructureName> table in the database
        ;;; </summary>
        <PRIMARY_KEY>
        <SEGMENT_LOOP>
        ;;; <param name="arg<SegmentName>">Primary key segment <segment_name></param>
        </SEGMENT_LOOP>
        </PRIMARY_KEY>
        ;;; <param name="arg<StructureName>"><StructureName> record to return data in</param>
        ;;; <returns>True for success, false for failure</returns>
        public method SelectRow, boolean
            <PRIMARY_KEY>
            <SEGMENT_LOOP>
            required in  arg<SegmentName>, a
            </SEGMENT_LOOP>
            </PRIMARY_KEY>
            required out arg<StructureName>, str<StructureName>All
			endparams
			.include "CONNECTDIR:ssql.def"
            stack record local_data
                ok              ,boolean    ;;OK to continue
                cursor          ,int        ;;Database cursor
            endrecord
        proc

            ok = true

            ;;Open a cursor for the SELECT statement
            if (%ssc_open(mDb.Channel,cursor,mSelectByKeyStatement,SSQL_SELECT,,<PRIMARY_KEY><KEY_SEGMENTS></PRIMARY_KEY>,<PRIMARY_KEY><SEGMENT_LOOP>arg<SegmentName><,></SEGMENT_LOOP></PRIMARY_KEY>)==SSQL_FAILURE)
                ok = getDatabaseError("Failed to open cursor")

            ;;Prepare a structure definition to define where the data for each column
            ;;goes to within the record
            if (ok)
                ok = defineStructure(cursor,1,recordSpec,arg<StructureName>)

            ;;Move data to host variables
            if (ok)
                if (%ssc_move(mDb.Channel,cursor,1)==SSQL_FAILURE)
                    ok = getDatabaseError("Failed to execute SQL statement")

            ;;Close the cursor
            closeCursor(cursor,ok)

            mreturn ok

        endmethod

        ;;; <summary>
        ;;; Retrieves multiple rows from the <StructureName> table in the database
        ;;; </summary>
        ;;; <param name="argWhere">WHERE clause to identify the rows to retrieve (don't include the WHERE keyword)</param>
        ;;; <param name="argRows">Collectio of returned rows</param>
        ;;; <returns>True for success, false for failure</returns>
        public method SelectRows, boolean
            required in  argWhere, string
            required out argRows,  @ArrayList
			endparams
			.include "CONNECTDIR:ssql.def"
            stack record local_data
                ok, boolean                             ;;OK to continue
                cursor, int                             ;;Database cursor
                rec<StructureName>, str<StructureName>All  ;;IO buffer
            endrecord
        proc

            argRows = new ArrayList()

            ;;Open a cursor for the SELECT statement
            if (^passed(argWhere) && argWhere.Length>0) then
                ok = openSelectCursor(mSelectAllStatement+" WHERE "+argWhere,cursor)
            else
                ok = openSelectCursor(mSelectAllStatement,cursor)

            ;;Prepare a structure definition to define where the data for each column
            ;;goes to within the record
            if (ok)
                ok = defineStructure(cursor,1,recordSpec,rec<StructureName>)

            ;;Move data to host variables
            if (ok)
            begin
                repeat
                begin
                    using (%ssc_move(mDb.Channel,cursor,1)) select
                    (SSQL_NORMAL),
                        argRows.Add((@str<StructureName>All)rec<StructureName>)
                    (SSQL_NOMORE),
                        exitloop
                    (SSQL_FAILURE),
                    begin
                        ok = getDatabaseError("Failed to execute SQL statement")
                        exitloop
                    end
                    endusing
                end
            end

            ;;Close the cursor
            closeCursor(cursor,ok)

            mreturn ok

        endmethod

        ;;; <summary>
        ;;; Deletes a row from the <StructureName> table in the database
        ;;; </summary>
        <PRIMARY_KEY>
        <SEGMENT_LOOP>
        ;;; <param name="arg<SegmentName>">Primary key segment <SegmentName></param>
        </SEGMENT_LOOP>
        </PRIMARY_KEY>
        ;;; <returns>True for success, false for failure</returns>
        public method DeleteRow, boolean
            <PRIMARY_KEY>
            <SEGMENT_LOOP>
            required in  arg<SegmentName> ,a
            </SEGMENT_LOOP>
            </PRIMARY_KEY>
			endparams
			.include "CONNECTDIR:ssql.def"
            stack record local_data
                ok          ,boolean    ;;Return status
                transaction ,boolean    ;;Transaction in progress
                cursor      ,int        ;;Database cursor
            endrecord
        proc

            init local_data
            ok = true

            ;;Start a database transaction
            if (ok = startTransaction())
                transaction = true

            ;;Open a cursor for the DELETE statement
            if (ok)
                if (%ssc_open(mDb.Channel,cursor,mDeleteByKeyStatement,SSQL_NONSEL,,<PRIMARY_KEY><KEY_SEGMENTS></PRIMARY_KEY>,<PRIMARY_KEY><SEGMENT_LOOP>arg<SegmentName><,></SEGMENT_LOOP></PRIMARY_KEY>)==SSQL_FAILURE)
                    ok = getDatabaseError("Failed to open cursor")

            ;;Execute the query
            if (ok)
                ok = executeNonSelectCursor(cursor)

            ;;Close the cursor
            closeCursor(cursor,ok)

            ;;Commit or rollback the transaction
            if (transaction)
                ok = commitOrRollback(ok)

            mreturn ok

        endmethod

        ;;; <summary>
        ;;; Deletes one or more rows from the <StructureName> table in the
        ;;; database based on a WHERE clause expression.
        ;;; </summary>
        ;;; <param name="argWhere">
        ;;; WHERE clause to identify the rows to be deleted (don't include the
        ;;; WHERE keyword)
        ;;; </param>
        ;;; <returns>True for success, false for failure</returns>
        public method DeleteRows, boolean
            required in argWhere, string
            endparams
            stack record local_data
                ok          ,boolean    ;;Return status
                transaction ,boolean    ;;Transaction in progress
                cursor      ,int        ;;Database cursor
            endrecord
        proc

            init local_data
            ok = true

            ;;Start a database transaction
            if (ok = startTransaction())
                transaction = true

            ;;Open a cursor for the DELETE statement
            if (ok)
                ok = openNonSelectCursor("DELETE FROM <StructureName> WHERE "+argWhere,cursor)

            ;;Execute the query
            if (ok)
                ok = executeNonSelectCursor(cursor)

            ;;Close the cursor
            closeCursor(cursor,ok)

            ;;Commit or rollback the transaction
            if (transaction)
                ok = commitOrRollback(ok)

            mreturn ok

        endmethod

        ;;; <summary>
        ;;; Updates a row in the <StructureName> in the database
        ;;; </summary>
        ;;; <param name="a_data">Record containing data to be updated</param>
        ;;; <returns>True if the row is updated, otherwise false</returns>
        public method UpdateRow, boolean
            required in  arg<StructureName>, str<StructureName>All
            endparams
            stack record local_data
                ok              ,boolean    ;;OK to continue
                transaction     ,boolean    ;;Transaction in progress
                cursor          ,int        ;;Database cursor
                sql             ,string     ;;SQL statement
                rec<StructureName>, str<StructureName>All
            endrecord
        proc

            init local_data
            ok = true

            ;;Load the data into the bound record
            rec<StructureName> = arg<StructureName>

            ;;Start a database transaction
            if (ok = startTransaction())
                transaction = true

            ;;Open a cursor for the UPDATE statement
            if (ok)
            begin
                sql = "UPDATE <StructureName> SET "
                <FIELD_LOOP>
                & "<FieldSqlName>=:<FIELD#LOGICAL><,>"
                </FIELD_LOOP>
                & " WHERE"
                <PRIMARY_KEY>
                <SEGMENT_LOOP>
                & " <SegmentName>='" + %atrim(^a(rec<StructureName>.<segment_name>)) + "' <AND>"
                </SEGMENT_LOOP>
                </PRIMARY_KEY>

                ok = openNonSelectCursor(sql,cursor)
            end

            ;;Prepare a structure definition to define where the data for each column
            ;;comes from within the record
            if (ok)
                ok = defineStructure(cursor,1,recordSpec,rec<StructureName>)

            ;;Update the row in the database
            if (ok)
                ok = executeNonSelectCursor(cursor)

            ;;Close the cursor
            closeCursor(cursor,ok)

            ;;Commit or rollback the transaction
            if (transaction)
                ok = commitOrRollback(ok)

            mreturn ok

        endmethod

		;;; <summary>
		;;; Loads data from the file <FILE_NAME> into the <StructureName> table in the database.
		;;; </summary>
		;;; <returns>True on successful load or false if an error occurred.</returns>
		public method Load, boolean
			endparams
			record 
				rows		,int
				failrows	,int
			endrecord
		proc
			mreturn Load(false,0,rows=0,failrows)
		endmethod

		;;; <summary>
		;;; Loads data from the file <FILE_NAME> into the <StructureName> table in the database.
		;;; </summary>
		;;; <param name="a_logex">Whether to log exception records to a file.</param>
		;;; <returns>
		;;; True on successful load or false if an error occurred.
		;;; If exceptions are encountered but logged to a file then the return status will be true.
		;;; </returns>
		public method Load, boolean
			required in    a_logex      ,boolean
			endparams
			record 
				rows		,int
				failrows	,int
			endrecord
		proc
			mreturn Load(a_logex,0,rows=0,failrows)
		endmethod

		;;; <summary>
		;;; Loads data from the file <FILE_NAME> into the <StructureName> table in the database.
		;;; </summary>
		;;; <param name="a_logchan">Open channel to log error messages to. Pass 0 to prevent logging.</param>
		;;; <param name="a_rows">Passed maximum number of rows to load, and returned number of rows successfully loaded</param>
		;;; <param name="a_failrows">Returned number of rows that failed to be inserted</param>
		;;; <returns>True on successful load or false if an error occurred.</returns>
		public method Load, boolean
			required in    a_logchan    ,int
			required inout a_rows       ,int
			required out   a_failrows   ,int
			endparams
		proc
			mreturn Load(false,a_logchan,a_rows,a_failrows)
		endmethod

		;;; <summary>
		;;; Loads data from the file <FILE_NAME> into the <StructureName> table in the database.
		;;; </summary>
		;;; <param name="a_logex">Whether to log exception records to a file.</param>
		;;; <param name="a_logchan">Open channel to log error messages to. Pass 0 to prevent logging.</param>
		;;; <param name="a_rows">Passed maximum number of rows to load, and returned number of rows successfully loaded</param>
		;;; <param name="a_failrows">Returned number of rows that failed to be inserted</param>
		;;; <returns>True on successful load or false if an error occurred. If exceptions are encountered but logged to a file then the return status will be true.</returns>
		public method Load, boolean
			required in    a_logex      ,boolean
			required in    a_logchan    ,int
			required inout a_rows       ,int
			required out   a_failrows   ,int
			endparams
			.define BUFFER_ROWS 1000        ;;How manr rows load at once
			stack record local_data
				ok              ,boolean    ;;Return status
				filechn         ,int        ;;Data file channel
				ex_ch           ,int        ;;Exception log file channel
				maxrows         ,int        ;;Max rows to load (for testing)
				goodrows        ,int        ;;Rows successfully inserted
				failrows        ,int        ;;Rows that failed to insert
				rowData         ,@ArrayList ;;Row data to load
				exceptionRows   ,@ArrayList ;;Rows that failed to load
				rec<StructureName>      , str<StructureName>All
				obj<StructureName>      , @str<StructureName>All
			endrecord
		proc

			init local_data
			ok = true

			maxrows = a_rows

			;;Open the data file associated with the structure
			try
			begin
				open(filechn=%syn_freechn,i:i,"<FILE_NAME>")
			end
			catch (ex)
			begin
				ok = false
				mErrorMessage = "Failed to open file <FILE_NAME>. " + ex.Message
				clear filechn
			end
			endtry

			if (ok)
			begin
				data rowsLoaded, int, 0

				rowData = new ArrayList()

				;;Read records from the input file
				repeat
				begin
					;;Get the next record from the input file
					try
					begin
						reads(filechn,rec<StructureName>)
					end
					catch (ex, @EndOfFileException)
					begin
						exitloop
					end
					endtry

					rowData.Add((@str<StructureName>All)rec<StructureName>)

					if ((maxrows)&&((rowsLoaded+=1)>=maxRows))
						exitloop

					;;If the buffer is full, write it to the database
					if (rowData.Count==BUFFER_ROWS)
						call insert_data

					if (!ok)
						exitloop
				end

				;;So we have any remaining records to insert?
				if (rowData.Count>0)
					call insert_data

				rowData = ^null

			end

			;;Close the file
			if (filechn)
				close filechn

			;;Close the exceptions log file
			if (ex_ch)
				close ex_ch

			;;Return number of rows inserted
			a_rows = goodrows

			;;Return number of failed rows
			a_failrows = failrows

			mreturn ok

		insert_data,

			if (this.InsertRows(rowData,exceptionRows,a_logchan))
			begin
				if (exceptionRows.Count==0) then
					goodrows += rowData.Count
				else
				begin
					;;Are we logging exceptions?
					if (a_logex) then
					begin
						;;Open the log file and log the exceptions
						if (!ex_ch)
							open(ex_ch=0,o:s,"Exceptions_<StructureName>.log")
						foreach obj<StructureName> in exceptionRows
							writes(ex_ch,(str<StructureName>All)obj<StructureName>)
						if (a_logchan)
							writes(a_logchan,"Exceptions were logged to Exceptions_<StructureName>.log")
						;;Update the lobal counters
						goodrows += (rowData.Count-exceptionRows.Count)
						failrows += exceptionRows.Count
					end
					else
					begin
						;;No logging, report and error
						ok = false
					end
				end
			end

			exceptionRows = ^null
			rowData = new ArrayList()

			return

		endmethod

        ;;; <summary>
        ;;; Cleans the data in a <StructureName> record before it is inserted
        ;;; into the database.
        ;;; </summary>
        ;;; <param name="argCustomer"><StructureName> record to be cleaned</param>
        private method clean<StructureName>Data, void
            required inout arg<StructureName>, str<StructureName>All
            endparams
        proc
            <FIELD_LOOP>
            <IF DECIMAL>
            if ((!arg<StructureName>.<field_sqlname>)||(!this.IsNumeric(^a(arg<StructureName>.<field_sqlname>))))
                clear arg<StructureName>.<field_sqlname>
            </IF DECIMAL>
            <IF DATE>
            if ((!arg<StructureName>.<field_sqlname>)||(!this.IsNumeric(^a(arg<StructureName>.<field_sqlname>))))
                ^a(arg<StructureName>.<field_sqlname>(1:1))=%char(0)
            </IF DATE>
            <IF TIME>
            if ((!arg<StructureName>.<field_sqlname>)||(!this.IsNumeric(^a(arg<StructureName>.<field_sqlname>))))
                ^a(arg<StructureName>.<field_sqlname>(1:1))=%char(0)
            </IF TIME>
            </FIELD_LOOP>
        endmethod

        ;;; <summary>
        ;;; Null terminate any empty alpha fields so that they show up as <NULL>
        ;;; in the database. By default SQL Connection inserts a single space.
        ;;; </summary>
        ;;; <param name="arg<StructureName>"><StructureName> record to be cleaned</param>
        private method nullTerminateEmptyAlphas, void
            required inout arg<StructureName>, str<StructureName>All
            endparams
        proc
            <FIELD_LOOP>
            <IF ALPHA>
            if(!arg<StructureName>.<field_sqlname>)
                arg<StructureName>.<field_sqlname>=%char(0)
            </IF ALPHA>
            </FIELD_LOOP>
        endmethod

        ;;; <summary>
        ;;; Loads field details into the recordSpec record
        ;;; </summary>
        private method loadRecordSpec, void
            endparams
        proc
            recordSpec.fieldCount = <STRUCTURE_FIELDS>
            <FIELD_LOOP>
            <IF DATEORTIME>
            recordSpec.fields[<FIELD#LOGICAL>].fieldType     = "A" ;;<FieldSqlName>
            <ELSE>
            recordSpec.fields[<FIELD#LOGICAL>].fieldType     = "<FIELD_TYPE>" ;;<FieldSqlName>
            </IF DATEORTIME>
            recordSpec.fields[<FIELD#LOGICAL>].fieldSize     = <FIELD_SIZE>
            recordSpec.fields[<FIELD#LOGICAL>].fieldDecimals = <IF PRECISION><FIELD_PRECISION></IF PRECISION><IF NOPRECISION>0</IF NOPRECISION>
            </FIELD_LOOP>
        endmethod

        ;;; <summary>
        ;;; Loads various SQL statements into "shared" static variables
        ;;; </summary>
        private method loadSqlStatements, void
            endparams
        proc

            if (mCreateTableStatement==^null)
                mCreateTableStatement = "CREATE TABLE <StructureName> ("
                <FIELD_LOOP>
                & "<FieldSqlName> <FIELD_SQLTYPE><IF REQUIRED> NOT NULL</IF REQUIRED>,"
                </FIELD_LOOP>
                & "CONSTRAINT PK_<StructureName> PRIMARY KEY CLUSTERED (<PRIMARY_KEY><SEGMENT_LOOP><SegmentName> <SEGMENT_ORDER><,></SEGMENT_LOOP></PRIMARY_KEY>))"

            if (mInsertStatement==^null)
                mInsertStatement = "INSERT INTO <StructureName> ("
                <FIELD_LOOP>
                & "<FieldSqlName><,>"
                </FIELD_LOOP>
                & ") VALUES(<FIELD_LOOP>:<FIELD#LOGICAL><,></FIELD_LOOP>)"

            if (mSelectByKeyStatement==^null)
                mSelectByKeyStatement = "SELECT "
                <FIELD_LOOP>
                <IF NOTDATE>
                & "<FieldSqlName><,>"
                </IF NOTDATE>
                <IF DATE_YYYYMMDD>
                & "CONVERT(VARCHAR(8),<FieldSqlName>,112) AS [YYYYMMDD]<,>"
                </IF DATE_YYYYMMDD>
                <IF DATE_YYMMDD>
                & "CONVERT(VARCHAR(6),<FieldSqlName>,12) AS [YYMMDD]<,>"
                </IF DATE_YYMMDD>
                </FIELD_LOOP>
                & " FROM <StructureName>"
                & " WHERE <PRIMARY_KEY><SEGMENT_LOOP> <SegmentName>=:<SEGMENT_NUMBER> <AND></SEGMENT_LOOP></PRIMARY_KEY>"

            if (mSelectAllStatement==^null)
                mSelectAllStatement = "SELECT "
                <FIELD_LOOP>
                <IF NOTDATE>
                & "<FieldSqlName><,>"
                </IF NOTDATE>
                <IF DATE_YYYYMMDD>
                & "CONVERT(VARCHAR(8),<FieldSqlName>,112) AS [YYYYMMDD]<,>"
                </IF DATE_YYYYMMDD>
                <IF DATE_YYMMDD>
                & "CONVERT(VARCHAR(6),<FieldSqlName>,12) AS [YYMMDD]<,>"
                </IF DATE_YYMMDD>
                </FIELD_LOOP>
                & " FROM <StructureName>"

            if (mDeleteByKeyStatement==^null)
                mDeleteByKeyStatement = "DELETE FROM <StructureName> WHERE <PRIMARY_KEY><SEGMENT_LOOP> <SegmentName>=:<SEGMENT_NUMBER> <AND></SEGMENT_LOOP></PRIMARY_KEY>"

        endmethod

    endclass

    .ifndef str<StructureName>All
    ;;Can't use a repository include when using SSQL_STRDEF because the FULL
    ;;record must be used, including the "NONAME_XXX" fields!
    structure str<StructureName>All
        <FIELD_LOOP>
        <field_sqlname>, <field_spec>
        </FIELD_LOOP>
    endstructure
    .endc

endnamespace


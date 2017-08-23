<CODEGEN_FILENAME><StructureName>.dbl</CODEGEN_FILENAME>
<REQUIRES_USERTOKEN>MVVM_DATA_NAMESPACE</REQUIRES_USERTOKEN>
<PROCESS_TEMPLATE>synnet_mvvm_data_util</PROCESS_TEMPLATE>
;//****************************************************************************
;//
;// Title:       mvvm_data.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: Template to generate a data class to represent a Synergy record.
;//              The class implements INotifyPropertyChanged and IDataErrorInfo.
;//
;// Date:        17th February 2011
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
;; File:        <StructureName>.dbl
;;
;; Description: Data class for structure <STRUCTURE_NOALIAS>
;;
;; Type:        Class
;;
;; Author:      <AUTHOR>, <COMPANY>
;;
;;*****************************************************************************
;;
;; WARNING:     This code was generated by CodeGen. Any changes that you make
;;              to this file will be lost if the code is regenerated.
;;
;;*****************************************************************************

import System
import System.ComponentModel

import System.Windows

namespace <MVVM_DATA_NAMESPACE>

    .include "<STRUCTURE_NOALIAS>" repository, structure="str<StructureName>", end

    public class <StructureName> implements INotifyPropertyChanged, IDataErrorInfo

        .region "Private members"

        ;;Store a copy of the Synergy record
        private m<StructureName>, str<StructureName>

        .endregion

        .region "Constructors"

        ;;Construct an empty <StructureName> object
        public method <StructureName>
            endparams
        proc
            init m<StructureName>
        endmethod

        ;;Construct a <StructureName> object containing the data from a <STRUCTURE_NOALIAS> record
        public method <StructureName>
            required in a<StructureName>, @String
            endparams
        proc
            ;;Save the record
            m<StructureName> = a<StructureName>
            ;;Notify changes to all of the fields (not sure if this is necessary?)
            <FIELD_LOOP>
            notifyPropertyChanged("<FieldSqlName>")
            </FIELD_LOOP>
        endmethod

        .endregion

        .region "Public properties (data)"

        ;;Expose the fields in the Synergy record as properties, using .NET types
        ;//TODO: Needs more work for additional field types (impled decimal, date, time, etc.)

        <FIELD_LOOP>
        ;;<FIELD_DESC> (<FIELD_NAME>, <FIELD_SPEC>)
        public property <FieldSqlName>, <FIELD_CSTYPE>
            method get
            proc
                <IF ALPHA>
                mreturn %atrim(m<StructureName>.<field_name>)
                </IF ALPHA>
                <IF DECIMAL>
                mreturn m<StructureName>.<field_name>
                </IF DECIMAL>
                <IF DATE>
                mreturn DataUtils.DateFromDecimal(m<StructureName>.<field_name>)
                </IF DATE>
                <IF TIME>
                mreturn DataUtils.TimeFromDecimal(m<StructureName>.<field_name>)
                </IF TIME>
                <IF INTEGER>
                mreturn m<StructureName>.<field_name>
                </IF INTEGER>
            endmethod
            method set
            proc
                m<StructureName>.<field_name> = value
                notifyPropertyChanged("<FieldSqlName>")
            endmethod
        endproperty

        </FIELD_LOOP>
        ;;Expose the full record (so it can be saved to a file, etc.)

        public property Record, @String
            method get
            proc
                mreturn (String)m<StructureName>
            endmethod
        endproperty

        .endregion

        .region "Public properties (meta-data)"

        ;;Expose field meta-data. These properties can be bound to from XAML to
        ;;enforce repository based "rules" and information.

        ;TODO: Probably need more meta-data to be exposed.

        <FIELD_LOOP>
        ;;<FIELD_DESC>

        public property <FieldSqlName>Length, int
            method get
            proc
                mreturn <FIELD_SIZE>
            endmethod
        endproperty

        public property <FieldSqlName>Prompt, @String
            method get
            proc
                mreturn "<FIELD_PROMPT>"
            endmethod
        endproperty

        public property <FieldSqlName>ToolTip, @String
            method get
            proc
                mreturn "<FIELD_INFOLINE>"
            endmethod
        endproperty

        </FIELD_LOOP>
        .endregion

        .region "Implement INotifyPropertyChanged"

        public event PropertyChanged, @PropertyChangedEventHandler

        private method notifyPropertyChanged, void
            required in aProperty, @String
            endparams
        proc
            PropertyChanged(this, new PropertyChangedEventArgs(aProperty))
        endmethod

        .endregion

        .region "Implement IDataErrorInfo"

        ;;;<summary>Gets an error message indicating what is wrong with this object.</summary>
        ;;;<returns>An error message indicating what is wrong with this object.</returns>
        public property Error, @String
            method get
            proc
                throw new NotImplementedException()
            endmethod
        endproperty

        ;;; <summary>Gets the error message for the property with the given name.</summary>
        ;;; <param name="aProperty">The name of the property to validate.</param>
        ;;; <returns>An error message indicating what is wrong with this object.</returns>
        public property Indexer, string
            required in aProperty, @String
            method get
                record
                    result, @String
                endrecord
            proc
                result = ^null

                ;//TODO: needs more work to enforce other repository validation rules
                using aProperty select
                <FIELD_LOOP>
                ("<FieldSqlName>"),
                begin
                    <IF REQUIRED>
                    <IF ALPHA>
                    ;;Required alpha field, check we have valid data
                    if (String.IsNullOrEmpty(<FieldSqlName>))
                        result = "<FIELD_PROMPT> is required!"
                    </IF ALPHA>
                    <IF DECIMAL>
                    ;;Required decimal or implied decimal field, check we have valid data
                    if ((<FieldSqlName><<FIELD_MINVALUE>)||(<FieldSqlName>><FIELD_MAXVALUE>))
                        result = "<FIELD_PROMPT> is not valid!"
                    </IF DECIMAL>
                    <IF DATE>
                    ;;Required date field, check we have valid data
                    ;TODO: Add validation for data fields (field <FIELD_NAME>
                    nop
                    </IF DATE>
                    <IF TIME>
                    ;;Required time field, check we have valid data
                    ;TODO: Add validation for data fields (field <FIELD_NAME>
                    nop
                    </IF TIME>
                    <IF INTEGER>
                    ;;Required integer field, check we have valid data
                    ;TODO: Add validation for integer fields (field <FIELD_NAME>
                    nop
                    </IF INTEGER>
                    <ELSE>
                    ;;Optional field
                    nop
                    </IF REQUIRED>
                end

                </FIELD_LOOP>
                endusing

                mreturn result

            endmethod
        endproperty

        .endregion

    endclass

endnamespace


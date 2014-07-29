<CODEGEN_FILENAME><Structure_Name>.dbl</CODEGEN_FILENAME>
;//****************************************************************************
;//
;// Title:       syn_data_class.tpl
;//
;// Type         CodeGen Template
;//
;// Description: This template generates a class which represents the data
;//              defined by a repository structure
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
;; Class:       <Structure_Name>
;;
;; Description: <STRUCTURE_DESC> Class
;;
;; Author:      <AUTHOR>
;;
;;*****************************************************************************
;;
namespace <NAMESPACE>

    public class <Structure_Name>

        ;;Private fields for storage of property data
        .include "<STRUCTURE_NOALIAS>" repository, private record="p<Structure_Name>"

        ;;Constructor
        public method <Structure_Name>
        proc
            mreturn
        endmethod

        ;;Destructor
        public method ~<Structure_Name>
        proc
            mreturn
        endmethod

        ;;Method to return data as a record
        public method ToString, a
        proc
            mreturn p<Structure_Name>
        endmethod

        ;;Properties

        <FIELD_LOOP>
        ;;<FIELD_DESC>
        public property <Field_Sqlname>, <field_type><FIELD_SIZE><FIELD_PRECISION2>
            method get
            proc
                mreturn p<Structure_Name>.<Field_Name>
            endmethod
            method set
            proc
                p<Structure_Name>.<Field_Name> = value
                mreturn
            endmethod
        endproperty

        </FIELD_LOOP>
    endclass

endnamespace

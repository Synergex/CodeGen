<CODEGEN_FILENAME><Structure_name>_DFM.CodeGen.dbc</CODEGEN_FILENAME>
;//****************************************************************************
;//
;// Title:       Symphony_DataFieldMapper.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: Template to define field mapping for the Symphony.Harmony data routines
;//
;// Author:      Richard C. Morris, Synergex Professional Services Group
;//
;// Copyright (c) 2012, Synergex International, Inc. All rights reserved.
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
;//****************************************************************************
;;****************************************************************************
;; WARNING: This code was generated by CodeGen. Any changes that you
;;          make to this code will be overwritten if the code is regenerated!
;;
;; Template author: Richard C. Morris, Synergex Professional Services Group
;;
;; Template Name:   Symphony Framework : <TEMPLATE>.tpl
;;
;;***************************************************************************

import Symphony.Harmony.Types
import Symphony.Harmony.Enumerations

namespace <NAMESPACE>


	public class <Structure_name>_DataDFM

		public method <Structure_name>_DataDFM
			endparams
		proc

		endmethod
		
		public method <Structure_name>_DataFieldMapper	,@FieldDataDefinition
			in req fieldName				,String
			endparams
			
			record
				actualName			,a255
				fieldDescription	,@FieldDataDefinition
			endrecord

		proc
		    
		    fieldDescription = new FieldDataDefinition()

		    ;;check if we have been given a field number
		    if (fieldName(1:1) == "#") then
		    begin
			    actualName = fieldName(2:^size(fieldName)-1)
			    using actualName select
			    <SYMPHONY_LOOPSTART>
			    <FIELD_LOOP>
			    <SYMPHONY_LOOPINCREMENT>
			    ("<SYMPHONY_LOOPVALUE> "),	actualName = "<FIELD_SQLNAME>"
			    </FIELD_LOOP>
			    endusing
		    end
		    else
		    begin
			    actualName = fieldName
		    end

		    using actualName select
		    <FIELD_LOOP>
		    ("<FIELD_SQLNAME> "),
		    begin
			    fieldDescription.LanguageName = "<FIELD_SQLNAME>"
			    <IF ALPHA>
			    fieldDescription.DataType = FieldDataType.AlphaField
			    </IF ALPHA>
			    <IF DECIMAL>
			    <IF PRECISION>
			    fieldDescription.DataType = FieldDataType.ImpliedDecimal
			    <ELSE>
			    fieldDescription.DataType = FieldDataType.DecimalField
			    </IF PRECISION>
			    </IF DECIMAL>
			    <IF INTEGER>
			    fieldDescription.DataType = FieldDataType.IntegerField
			    </IF INTEGER>
			    <IF DATE>
			    fieldDescription.DataType = FieldDataType.DecimalField
			    </IF DATE>
			    fieldDescription.ElementSize = <FIELD_SIZE>
			    fieldDescription.StructurePosition = <FIELD_POSITION>
			    fieldDescription.DecimalPrecision = 0<FIELD_PRECISION>
		    end
		    </FIELD_LOOP>
		    endusing

			mreturn fieldDescription
			
		endmethod
		
	endclass
		    

endnamespace

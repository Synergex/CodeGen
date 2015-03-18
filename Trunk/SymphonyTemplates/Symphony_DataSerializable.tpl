<CODEGEN_FILENAME><Structure_name>_DataSerializable.CodeGen.dbc</CODEGEN_FILENAME>
;//****************************************************************************
;//
;// Title:       Symphony_DataSerializable.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: Template to define structure based Data Object
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
;; Template author:	Richard C. Morris, Synergex Professional Services Group
;;
;; Template Name:	Symphony Framework : <TEMPLATE>.tpl
;;
;;***************************************************************************
import System
import System.Collections.Generic
import System.Text

namespace <NAMESPACE>

    public partial class <Structure_name>_DataSerializable extends <Structure_name>_Data

		public property Serialize, @<Structure_name>_DataSerialized
			method get
			proc
				data pd	,@<Structure_name>_DataSerializer	,new <Structure_name>_DataSerializer()
				pd.SynergyRecord = this.SynergyRecord
				mreturn new <Structure_name>_DataSerialized(pd.JSONRecord)
			endmethod
		endproperty

		public method DeSerialize	,void
			in req inData			,String
			endparams
		proc
			data pd	,@<Structure_name>_DataSerializer	,new <Structure_name>_DataSerializer()
			pd.JSONRecord = inData
			this.SynergyRecord = pd.SynergyRecord
		endmethod

    endclass

endnamespace


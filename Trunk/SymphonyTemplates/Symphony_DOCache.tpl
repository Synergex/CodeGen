<CODEGEN_FILENAME><Structure_name>_DOCache.CodeGen.dbc</CODEGEN_FILENAME>
<REQUIRES_USERTOKEN>ASSEMBLYNAME</REQUIRES_USERTOKEN>
<OPTIONAL_USERTOKEN>DATAFILENAME="<FILE_NAME>"</OPTIONAL_USERTOKEN>
;//****************************************************************************
;//
;// Title:       Symphony_DOCache.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: Template to provide cacheing of data objects
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
;;****************************************************************************


import System
import System.Collections.Generic
import System.Text

import Synergex.SynergyDE.Select

import <ASSEMBLYNAME>

namespace <NAMESPACE>
	
	public class <Structure_name>_DOCache
		
		private static mObjectCache	,@Dictionary<String, <Structure_name>_Data>	,new Dictionary<String, <Structure_name>_Data>()
		
		public static method DataObject	,@<Structure_name>_Data
			in req keyValue		,String
			endparams

			.include '<structure_name>' repository, record = "<structure_name>Record"

		proc
			data doObject	,@<Structure_name>_Data
			<PRIMARY_KEY>
		    <SEGMENT_LOOP>
		    <FIRST_SEGMENT>
			if (!mObjectCache.TryGetValue(<structure_name>Record.<Segment_name> = keyValue, doObject))
		    </FIRST_SEGMENT>
		    </SEGMENT_LOOP>
		    </PRIMARY_KEY>
			begin
				;;object not found in dictionary, load it.
				foreach <structure_name>Record in new Select(new From(<DATAFILENAME>, <structure_name>Record),
				<PRIMARY_KEY>
				<SEGMENT_LOOP>
				<FIRST_SEGMENT>
				&	(Where) <structure_name>Record.<Segment_name> .eqs. keyValue
				</FIRST_SEGMENT>
				</SEGMENT_LOOP>
				</PRIMARY_KEY>
				&	)
				begin
					doObject = new <Structure_name>_Data(<structure_name>Record)
					mObjectCache.Add(
					<PRIMARY_KEY>
					<SEGMENT_LOOP>
					<FIRST_SEGMENT>
					&	<structure_name>Record.<Segment_name>
					</FIRST_SEGMENT>
					</SEGMENT_LOOP>
					</PRIMARY_KEY>
					&	, doObject)
					exitloop
				end
			end
			
			mreturn doObject
		endmethod
		
		public static method InitCache, void
			endparams
		proc
			mObjectCache.Clear()
		endmethod

	endclass
	
endnamespace

<CODEGEN_FILENAME><StructureName>.dbl</CODEGEN_FILENAME>
;//****************************************************************************
;//
;// Title:       syn_multi_data_class.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: This template generates a data class which exposes properties
;//              associated with fields from multiple synergy structures.
;//              This template requires that at least two structures be
;//              processed at the same time using the -ms command line option.
;//
;// Date:        7th June 2012
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
;; Description: A data class which includes properties based on multiple
;;              repository structures
;;
;; Type:        Synergy/DE xfServerPlus Method
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
namespace <NAMESPACE>

    public class <StructureName>

        ;;---------------------------------------------------------------------
        ;;Private backing fields
<STRUCTURE_LOOP>
        ;;Fields from structure <STRUCTURE_NAME>
  <FIELD_LOOP>
        private m<StructureName><FieldName>, <field_spec>
  </FIELD_LOOP>
</STRUCTURE_LOOP>

        ;;---------------------------------------------------------------------
        ;;Public properties

<STRUCTURE_LOOP>
        ;;Properties from structure <STRUCTURE_NAME>

  <FIELD_LOOP>
        ;;;<summary>
        ;;;<FIELD_DESC>
        ;;;</summary>
        public property <StructureName><FieldName>, <field_spec>
            method get
            proc
                mreturn m<StructureName><FieldName>
            endmethod
            method set
            proc
                m<StructureName><FieldName> = value
            endmethod
        endproperty

  </FIELD_LOOP>
</STRUCTURE_LOOP>
    endclass

endnamespace

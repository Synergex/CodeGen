<CODEGEN_FILENAME><StructureName>MaintManager.dbl</CODEGEN_FILENAME>
;//****************************************************************************
;//
;// Title:       cs_mvvm_maint_manager.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: Template to generate C# MVVM maintenance manager class.
;//
;// Date:        14th December 2009
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
;; File:        <StructureName>MaintManager.cs
;;
;; Description: MVVM maintenance manager class for structure <structure_name>
;;
;; Type:        Class
;;
;; Author:      <CODEGEN_VERSION>
;;
;; Created:     <DATE> at <TIME>
;;
;;*****************************************************************************

.include "NETSRC:wpf.inc"
import <NAMESPACE>

namespace <NAMESPACE>

    public class <StructureName>MaintManager

        public Model        ,@<MVVM_DATA_NAMESPACE>.<StructureName>
        public View         ,@<MVVM_UI_NAMESPACE>.<StructureName>Maint
        public ViewModel    ,@<MVVM_DATA_NAMESPACE>.<StructureName>MaintViewModel

        ;;Instance of the underlying Synergy record
        .include "<STRUCTURE_NAME>" repository, public record="SynergyRecord", end

        ;;Constructor to create an empty environment
        public method <StructureName>MaintManager
            endparams
        proc
            clear SynergyRecord
            createObjects()
        endmethod

        ;;Constructor to create an environment with initial data
        public method <StructureName>MaintManager
            required in countryData, string
            endparams
        proc
            SynergyRecord = countryData
            createObjects()
        endmethod

        ;;;<summary>
        ;;;Method used by the ViewModel to signal UI Toolkit menu events
        ;;;</summary>
        ;;;<param name="menuName">Menu entry to signal</param>
        public static method MenuSignal ,void
            required in menuName, string
            endparams
        proc
            m_signal(menuName)
        endmethod

        ;;;<summary>
        ;;;Method used by the ViewModel to signal that the data has changed
        ;;;</summary>
        ;;;<param name="recordArea">Record containing data</param>
        ;;;<param name="fieldName">Name of field that changed</param>
        public method RecordChanged ,void
            in req recordArea, string
            in req fieldName,  string
            endparams
        proc
            SynergyRecord = recordArea
            ;;Execute change method if necessary
        endmethod

        ;;;<summary>
        ;;;Method used by the Synergy manager class to completely replace
        ;;;the record being maintained
        ;;;</summary>
        ;;;<param name="recordArea">Record containing new data</param>
        public method ReplaceRecord, void
            required in recordArea, string
            endparams
        proc
            Model.SynergyRecordArea = recordArea
        endmethod

        private method createObjects, void
            endparams
        proc
            ;;Instantiate the Model
            Model = new <MVVM_DATA_NAMESPACE>.<StructureName>(SynergyRecord)
            addHandler(Model.SynergyRecordChanged, RecordChanged)
            ;;Instantiate the ViewModel
            ViewModel  = new <MVVM_DATA_NAMESPACE>.<StructureName>MaintViewModel(Model)
            addHandler(ViewModel.MenuSignal, MenuSignal)
            ;;Instantiate the View
            View = New <MVVM_UI_NAMESPACE>.<StructureName>Maint(ViewModel)
        endmethod

    endclass

endnamespace

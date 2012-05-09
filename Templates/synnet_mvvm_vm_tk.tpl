<CODEGEN_FILENAME>ToolkitViewModel.dbl</CODEGEN_FILENAME>
<PROCESS_TEMPLATE>synnet_mvvm_vm</PROCESS_TEMPLATE>
;//****************************************************************************
;//
;// Title:       mvvm_vm_tk.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: Generates an MVVM base ViewModel class for use in Toolkit apps
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
;; File:        ToolkitViewModel.dbl
;;
;; Description: Base MVVM ViewModel class for UI Toolkit applications
;;
;; Type:        Class
;;
;; Author:      <AUTHOR>, <COMPANY>
;;
;; Created:     <DATE> at <TIME> by <CODEGEN_VERSION>
;;
;; WRANING:     This code was generated by a tool. Any changes that you make
;;              to this code will be lost if the code is regenerated.
;;
;;*****************************************************************************

import System
import System.ComponentModel
import System.Windows.Input

namespace <MVVM_DATA_NAMESPACE>

    public abstract class ToolkitViewModel extends ViewModel

        .region "UI Toolkit menu entry signalling"

        public delegate MenuSignalEventHandler, void
            required in menuName, @String
        enddelegate

        public event MenuSignal, @MenuSignalEventHandler

        public method RaiseMenuEvent, void
            required in menuName, @String
            endparams
        proc
            if (MenuSignal!=^null)
                MenuSignal(menuName)
        endmethod

        .endregion

    endclass

endnamespace


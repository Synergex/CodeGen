<CODEGEN_FILENAME><StructureName>MaintScreen.xaml.dbl</CODEGEN_FILENAME>
<REQUIRES_USERTOKEN>MVVM_UI_NAMESPACE</REQUIRES_USERTOKEN>
<REQUIRES_USERTOKEN>MVVM_DATA_NAMESPACE</REQUIRES_USERTOKEN>
;//****************************************************************************
;//
;// Title:       mvvm_view_maint_code.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: Generates View code-behind for use in a simple maintenance app
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
;; File:        <StructureName>MaintScreen.xaml.dbl
;;
;; Description: View class for structure <STRUCTURE_NOALIAS> (CODE)
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
import System.Windows
import System.Windows.Controls
import <MVVM_DATA_NAMESPACE>

namespace <MVVM_UI_NAMESPACE>

    ;;; <summary>
    ;;; Interaction logic for <StructureName>MaintScreen.xaml
    ;;; </summary>
    public partial class <StructureName>MaintScreen extends UserControl

        public method <StructureName>MaintScreen
            endparams
        proc
            this.InitializeComponent()
        endmethod

        public method <StructureName>MaintScreen
            required in aVm, @<StructureName>MaintVm
            endparams
            this()
        proc
            this.DataContext = aVm
        endmethod

    endclass

endnamespace

<CODEGEN_FILENAME>RelayCommand.dbl</CODEGEN_FILENAME>
<REQUIRES_USERTOKEN>MVVM_DATA_NAMESPACE</REQUIRES_USERTOKEN>
;//****************************************************************************
;//
;// Title:       mvvm_relay_command.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: Generates a MVVM commanding relay class.
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
;; File:        RelayCommand.dbl
;;
;; Description: MVVM ICommand relay class
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
import System.Diagnostics
import System.Windows.Input

namespace <MVVM_DATA_NAMESPACE>

    ;;;<summary>
    ;;;A command whose sole purpose is to relay its functionality to other
    ;;;objects by invoking delegates. The default return value for the
    ;;;CanExecute method is 'true'.
    ;;;</summary>
    public class RelayCommand implements ICommand

        .region "Delegates"

        public delegate RelayCommandAction, void
            parameter, @Object
        enddelegate

        public delegate RelayCommandPredicate, boolean
            parameter, @Object
        enddelegate

        .endregion

        .region "Private members"

        private readonly mExecute, @RelayCommandAction
        private readonly mCanExecute, @RelayCommandPredicate

        .endregion

        .region "Constructors"

        ;;;<summary>
        ;;;Creates a new command that can always execute.
        ;;;</summary>
        ;;;<param name="execute">The execution logic.</param>
        public method RelayCommand
            required in execute, @RelayCommandAction
            endparams
            this(execute, ^null)
        proc
        endmethod

        ;;;<summary>
        ;;;Creates a new command.
        ;;;</summary>
        ;;;<param name="execute">The execution logic.</param>
        ;;;<param name="canExecute">The execution status logic.</param>
        public method RelayCommand
            aExecute, @RelayCommandAction
            aCanExecute, @RelayCommandPredicate
            endparams
        proc
            ;;Make sure we're given a delegate to execute
            if (aExecute == ^null)
                throw new ArgumentNullException("execute")

            ;;Save the delegates
            mExecute = aExecute
            mCanExecute = aCanExecute

            ;; Workaround: Doing this because we don't have add/remove methods on events
            ;; Bind our "canExecuteChangedFired" method to CommandManager.RequerySuggested
            ;;
            ;; Excerpt from Microsoft's CommandManager.RequerySuggested documentation:
            ;;
            ;; "Since this event is static, it will only hold onto the handler as a weak
            ;; reference. Objects that listen for this event should keep a strong reference
            ;; to their event handler to avoid it being garbage collected. This can be
            ;; accomplished by having a private field and assigning the handler as the
            ;; value before or after attaching to this event."
            ;;
            mRequeryEventHandler = new EventHandler(canExecuteChangedFired)
            addhandler(CommandManager.RequerySuggested,mRequeryEventHandler)

        endmethod

        .endregion

        .region "ICommand Members"

        {DebuggerStepThrough}
        public method CanExecute, Boolean
            required in aParameter, @Object
            endparams
        proc
            if (mCanExecute==^null) then
                mreturn true
            else
                mreturn mCanExecute(aParameter)
        endmethod

        public event CanExecuteChanged, @EventHandler
        ;{                                                          ;Workaround (see discusion in comments in constructor)
        ;   add { CommandManager.RequerySuggested += value; }       ;
        ;   remove { CommandManager.RequerySuggested -= value; }    ;
        ;}                                                          ;
                                                                    ;
        private mRequeryEventHandler, @EventHandler                 ;Used to hold a strong reference to the event handler
                                                                    ;
        private method canExecuteChangedFired, void                 ;
            required in sender, @Object                             ;
            required in e, @EventArgs                               ;
            endparams                                               ;
        proc                                                        ;
            if (CanExecuteChanged!=^null)                           ;
                CanExecuteChanged(sender,e)                         ;
        endmethod                                                   ;

        public method Execute, void
            required in aParameter, @Object
            endparams
        proc
            mExecute(aParameter)
        endmethod

        .endregion

    endclass

endnamespace

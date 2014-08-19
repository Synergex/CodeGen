<CODEGEN_FILENAME>Frm<WindowName>.aspx</CODEGEN_FILENAME>
<PROCESS_TEMPLATE>vb_webform_codebehind.tpl</PROCESS_TEMPLATE>
;//****************************************************************************
;//
;// Title:       vb_webform_master.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: Template to generate a VB.NET / ASP.NET 2.0 Web From to
;//              represent a Synergy repository structure.  The web form is
;//              based on a master page called MasterPage.master
;//
;// Date:        22nd October 2007
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
;//****************************************************************************
<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" AutoEventWireup="false" CodeFile="Frm<WindowName>.aspx.vb" Inherits="Frm<WindowName>" title="<STRUCTURE_DESC>" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <h2><STRUCTURE_DESC> Maintenance</h2>
    <table border="0">
    <FIELD_LOOP>
    <tr>
        <td>
            <IF PROMPT><asp:Label id="lbl<Field_sqlname>" runat="server" CssClass="app_prompt" Text="<FIELD_PROMPT>" /></IF>&nbsp;
        </td>
        <td>
            <asp:TextBox id="txt<Field_sqlname>" runat="server" CssClass="app_field" MaxLength="<FIELD_SIZE>"<IF DISABLED> Enabled="False"</IF><IF READONLY> ReadOnly="True"</IF><IF INFOLINE> ToolTip="<FIELD_INFOLINE>"</IF>><IF DEFAULT><FIELD_DEFAULT></IF></asp:TextBox>
            <IF REQUIRED>
            <asp:RequiredFieldValidator id="val<Field_sqlname>" runat="server" CssClass="app_validator" ControlToValidate="txt<Field_sqlname>" ErrorMessage="*" />
            </IF>
        </td>
    </tr>
    </FIELD_LOOP>
    <tr>
        <td>&nbsp;</td>
        <td>
            <asp:Button ID="btnOk" runat="server" CssClass="app_button" Text="OK" />
            <asp:Button ID="btnCancel" runat="server" CssClass="app_button" Text="Cancel" />
        </td>
    </tr>
    </table>
</asp:Content>


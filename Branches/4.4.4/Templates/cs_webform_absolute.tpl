<CODEGEN_FILENAME>frm<WindowName>.aspx</CODEGEN_FILENAME>
<PROCESS_TEMPLATE>cs_webform_codebehind.tpl</PROCESS_TEMPLATE>
;//****************************************************************************
;//
;// Title:       cs_webform_absolute.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: Template to generate a C# / ASP.NET 2.0 Web From to
;//              represent a Synergy repository structure.
;//
;// Date:        4th April 2008
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
<%@ Page Language="C#" AutoEventWireup="true" CodeFile="frm<WindowName>.aspx.cs" Inherits="frm<WindowName>" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title><STRUCTURE_DESC></title>
</head>
<body>
    <form id="form1" runat="server">
        <FIELD_LOOP>
        <IF TEXTBOX>
        <IF PROMPT>
        <asp:Label id="lbl<Field_sqlname>" runat="server" CssClass="app_prompt" style="position: absolute; top: <PROMPT_PIXEL_ROW>px; left: <PROMPT_PIXEL_COL>px;" Text="<FIELD_PROMPT>" />
        </IF>
        <asp:TextBox id="txt<Field_sqlname>" runat="server" CssClass="app_field" style="position: absolute; top: <FIELD_PIXEL_ROW>px; left: <FIELD_PIXEL_COL>px" Width="<FIELD_PIXEL_WIDTH>px" MaxLength="<FIELD_SIZE>"<IF DISABLED> Enabled="False"</IF><IF READONLY> ReadOnly="True"</IF><IF INFOLINE> ToolTip="<FIELD_INFOLINE>"</IF>><IF DEFAULT><FIELD_DEFAULT></IF></asp:TextBox>
        <IF REQUIRED>
        <asp:RequiredFieldValidator id="val<Field_sqlname>" runat="server" CssClass="app_validator" style="position: absolute; top: <FIELD_PIXEL_ROW>px; left: <FIELD_DRILL_PIXEL_COL>px" ControlToValidate="txt<Field_sqlname>" ErrorMessage="*" />
        </IF>
        </IF>
        <IF CHECKBOX>
        <asp:CheckBox id="chk<Field_sqlname>" runat="server" CssClass="app_field" style="position: absolute; top: <FIELD_PIXEL_ROW>px; left: <FIELD_PIXEL_COL>px" Text="<FIELD_PROMPT>"<IF DISABLED> Enabled="False"</IF><IF INFOLINE> ToolTip="<FIELD_INFOLINE>"</IF>></asp:CheckBox>
        </IF>
        <IF COMBOBOX>
        <IF PROMPT>
        <asp:Label id="lbl<Field_sqlname>" runat="server" CssClass="app_prompt" style="position: absolute; top: <PROMPT_PIXEL_ROW>px; left: <PROMPT_PIXEL_COL>px;" Text="<FIELD_PROMPT>" />
        </IF>
        <asp:DropDownList ID="cbo<Field_sqlname>" runat="server" CssClass="app_field" style="position: absolute; top: <FIELD_PIXEL_ROW>px; left: <FIELD_PIXEL_COL>px" Width="<FIELD_PIXEL_WIDTH>px"<IF DISABLED> Enabled="False"</IF><IF INFOLINE> ToolTip="<FIELD_INFOLINE>"</IF>>
        <SELECTION_LOOP>
            <asp:ListItem Value="<SELECTION_VALUE>"<IF FIRST> Selected="True"</IF>><SELECTION_TEXT></asp:ListItem>
        </SELECTION_LOOP>
        </asp:DropDownList>
        </IF>
        <IF RADIOBUTTONS>
        </IF>
        </FIELD_LOOP>
        <asp:Button ID="btnOk" runat="server" CssClass="app_button" style="top: 500px; left: 600px; position: absolute;" Width="75px" Text="OK" />
        <asp:Button ID="btnCancel" runat="server" CssClass="app_button" style="top: 500px; left: 690px; position: absolute;" Width="75px" CausesValidation="false" Text="Cancel" />
    </form>
</body>
</html>

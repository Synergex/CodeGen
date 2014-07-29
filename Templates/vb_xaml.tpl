<CODEGEN_FILENAME>Frm<WindowName>.xaml</CODEGEN_FILENAME>
<PROCESS_TEMPLATE>vb_xaml_codebehind.tpl</PROCESS_TEMPLATE>
;//****************************************************************************
;//
;// Title:       vb_xaml.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: Template to generate a VB.NET WPF Windows From representing a
;//              Synergy repository structure.
;//
;// Date:        24th March 2008
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
<!--
    WARNING: This code was generated by CodeGen. Any changes that you
    make to this file will be lost if the code is regenerated.
-->
<Window x:Class="Frm<WindowName>"
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Name="Frm<WindowName>" Title="<STRUCTURE_DESC> Maintenance"
    Height="<WINDOW_HEIGHTPX>" Width="<WINDOW_WIDTHPX>"
    WindowStyle="SingleBorderWindow" ResizeMode="NoResize"
    ShowInTaskbar="False" WindowStartupLocation="CenterOwner"
    Loaded="Frm<WindowName>_Loaded">
    <Grid>
        <FIELD_LOOP>
        <IF TEXTBOX>
        <IF PROMPT>
        <Label Height="23"  Width="120" Margin="<PROMPT_PIXEL_COL>,<PROMPT_PIXEL_ROW>,0,0" Name="Lbl<Field_sqlname>" HorizontalAlignment="Left" VerticalAlignment="Top"><FIELD_PROMPT></Label>
        </IF>
        <TextBox Height="23" Width="<FIELD_PIXEL_WIDTH>" Margin="<FIELD_PIXEL_COL>,<FIELD_PIXEL_ROW>,0,0" Name="Txt<Field_sqlname>" HorizontalAlignment="Left" VerticalAlignment="Top" MaxLength="<FIELD_SIZE>"<IF DISABLED> IsEnabled="False"</IF><IF READONLY> IsReadOnly="True"</IF><IF INFOLINE> ToolTip="<FIELD_INFOLINE>"</IF><IF UPPERCASE> CharacterCasing="Upper" </IF><IF REVERSE> Background="Black" Foreground="White"</IF>><IF DEFAULT><FIELD_DEFAULT></IF></TextBox>
        </IF>
        </FIELD_LOOP>
        <Button Name="BtnOK" Height="23" Width="75" Margin="0,0,100,10"  HorizontalAlignment="Right" VerticalAlignment="Bottom" Click="BtnOK_Click">OK</Button>
        <Button Name="BtnCancel" Height="23" Width="75" Margin="0,0,10,10" HorizontalAlignment="Right" VerticalAlignment="Bottom" Click="BtnCancel_Click">Cancel</Button>
    </Grid>
</Window>

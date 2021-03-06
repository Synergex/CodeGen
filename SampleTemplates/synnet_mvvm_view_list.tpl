<CODEGEN_FILENAME><StructureName>ListScreen.xaml</CODEGEN_FILENAME>
<PROCESS_TEMPLATE>synnet_mvvm_view_list_code</PROCESS_TEMPLATE>
<PROCESS_TEMPLATE>synnet_mvvm_global_resources</PROCESS_TEMPLATE>
<PROCESS_TEMPLATE>synnet_mvvm_vm_list</PROCESS_TEMPLATE>
;//****************************************************************************
;//
;// Title:       mvvm_view_list.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: Generates a View for use in a simple list program
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
<!--
;;*****************************************************************************
;;
;; File:        <StructureName>ListScreen.xaml
;;
;; Description: View class for structure <STRUCTURE_NOALIAS> (XAML)
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
-->
<UserControl x:Class="<MVVM_UI_NAMESPACE>.<StructureName>ListScreen"
             xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
             xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
             xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
             xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
             mc:Ignorable="d"
             d:DesignHeight="279" d:DesignWidth="518">

    <UserControl.Resources>
        <ResourceDictionary Source="GlobalResources.xaml" />
    </UserControl.Resources>

    <Grid>

        <Grid.RowDefinitions>
            <RowDefinition/>
            <RowDefinition Height="35"/>
        </Grid.RowDefinitions>

        <DataGrid AutoGenerateColumns="False" Grid.Row="0" ItemsSource="{Binding Items}"
                  CanUserResizeRows="False" IsReadOnly="True" SelectionMode="Single"
                  SelectedItem="{Binding SelectedItem, Mode=TwoWay}" FontSize="14">
            <DataGrid.Columns>
                <FIELD_LOOP>
                <DataGridTextColumn Header="<FIELD_PROMPT>" Width="*" Binding="{Binding <FieldSqlName>}" />
                </FIELD_LOOP>
            </DataGrid.Columns>
        </DataGrid>

        <StackPanel Grid.Row="1" Orientation="Horizontal" HorizontalAlignment="Right">
            <Button Height="23" Width="60" Margin="4" Content="Select" Command="{Binding CommandSelect}" />
            <Button Height="23" Width="60" Margin="4" Content="Delete" Command="{Binding CommandDelete}" />
            <Button Height="23" Width="60" Margin="4" Content="Close" Command="{Binding CommandClose}" />
        </StackPanel>

    </Grid>

</UserControl>


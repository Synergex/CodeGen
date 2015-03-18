<CODEGEN_FILENAME><Structure_name>_CriteriaView.CodeGen.xaml</CODEGEN_FILENAME>
<REQUIRES_USERTOKEN>ASSEMBLYNAME</REQUIRES_USERTOKEN>
<PROCESS_TEMPLATE>Symphony_CriteriaView_code</PROCESS_TEMPLATE>
;//****************************************************************************
;//
;// Title:       Symphony_CriteraView.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: Template to provide lookup selection view xaml layout
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
<!--
 WARNING: This code was generated by CodeGen. Any changes that you
          make to this code will be overwritten if the code is regenerated!

 Template author:	Richard C. Morris, Synergex Professional Services Group

 Template Name:	Symphony Framework : SYMPHONY_LISTVIEW.tpl

-->
<UserControl x:Class="<NAMESPACE>.<Structure_name>_CriteriaView"
			 xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
			 xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
			 xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
			 xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
			 xmlns:i="clr-namespace:System.Windows.Interactivity;assembly=System.Windows.Interactivity"
			 xmlns:symphonyUI="clr-namespace:Symphony.Crescendo.Presentation;assembly=SymphonyCrescendo"
             xmlns:symphonyControls="clr-namespace:Symphony.Conductor.Controls;assembly=SymphonyConductor"
			 mc:Ignorable="d"
			 d:DesignHeight="300" d:DesignWidth="300">

	<UserControl.Resources>
		<ResourceDictionary>
			<ResourceDictionary.MergedDictionaries>
				<ResourceDictionary Source="pack://application:,,,/SymphonyConductor;component/Resources/Styles.xaml"/>
				<ResourceDictionary Source="pack://application:,,,/SymphonyConductor;component/Resources/Converters.xaml"/>
				<ResourceDictionary Source="pack://application:,,,/<ASSEMBLYNAME>;component/Resources/<Structure_name>_Content.CodeGen.xaml"/>
				<ResourceDictionary Source="pack://application:,,,/<ASSEMBLYNAME>;component/Resources/<Structure_name>_style.CodeGen.xaml"/>
			</ResourceDictionary.MergedDictionaries>
		</ResourceDictionary>
	</UserControl.Resources>

	<Grid VerticalAlignment="Stretch" HorizontalAlignment="Stretch">
		<Grid.Background>
			<LinearGradientBrush StartPoint="1,0" EndPoint="0,1" >
				<GradientStop Offset="0" Color="CadetBlue" />
				<GradientStop Offset="0.5" Color="White" />
			</LinearGradientBrush>
		</Grid.Background>

		<Grid.ColumnDefinitions>
			<ColumnDefinition Width="auto"></ColumnDefinition>
			<ColumnDefinition Width="*"></ColumnDefinition>
		</Grid.ColumnDefinitions>

		<Expander IsExpanded="False" Grid.Column="0" ExpandDirection="Right" Height="{Binding ElementName=criteriaEntry, Path=ActualHeight}">
			<Expander.Background>
				<LinearGradientBrush StartPoint="1,0" EndPoint="0,1" >
					<GradientStop Offset="0" Color="CadetBlue" />
					<GradientStop Offset="0.5" Color="White" />
				</LinearGradientBrush>
			</Expander.Background>
			<ScrollViewer Margin="5">
				<StackPanel Orientation="Vertical" HorizontalAlignment="Left">
					<FIELD_LOOP>
					<IF CUSTOM_NOT_SYMPHONY_ARRAY_FIELD>
					<IF LANGUAGE>
					<IF TOOLKIT>
					<IF REPORT>
					<CheckBox Margin="5" IsChecked="{Binding Path=CriteriaVisibility.<Field_sqlname>Visibility}" x:Name="chk<Field_sqlname>Visibility" Content="<FIELD_PROMPT>" />
					</IF REPORT>
					</IF TOOLKIT>
					</IF LANGUAGE>
					</IF CUSTOM_NOT_SYMPHONY_ARRAY_FIELD>
					</FIELD_LOOP>
				</StackPanel>
			</ScrollViewer>
		</Expander>

		<Grid Grid.Column="1" x:Name="criteriaEntry">
            <Grid.Background>
                <LinearGradientBrush StartPoint="1,0" EndPoint="0,1" >
                    <GradientStop Offset="0" Color="CadetBlue" />
                    <GradientStop Offset="0.5" Color="White" />
                </LinearGradientBrush>
            </Grid.Background>

			<Grid.RowDefinitions>
				<RowDefinition Height="*"></RowDefinition>
				<RowDefinition Height="auto"></RowDefinition>
			</Grid.RowDefinitions>

			<ScrollViewer Grid.Row="0" HorizontalScrollBarVisibility="Auto" VerticalScrollBarVisibility="Auto">
				<Grid>
					<Grid.RowDefinitions>
<FIELD_LOOP>
<IF CUSTOM_NOT_SYMPHONY_ARRAY_FIELD>
<IF LANGUAGE>
<IF TOOLKIT>
<IF REPORT>
						<RowDefinition Height="auto"/>
</IF REPORT>
</IF TOOLKIT>
</IF LANGUAGE>
</IF CUSTOM_NOT_SYMPHONY_ARRAY_FIELD>
</FIELD_LOOP>
					</Grid.RowDefinitions>
;//
					<Grid.ColumnDefinitions>
						<ColumnDefinition Width="auto" />
						<ColumnDefinition Width="auto" />
					</Grid.ColumnDefinitions>
<SYMPHONY_LOOPSTART>
<FIELD_LOOP>
<IF CUSTOM_NOT_SYMPHONY_ARRAY_FIELD>
<IF LANGUAGE>
<IF TOOLKIT>
<IF REPORT>
					<IF NOCHECKBOX>
					<Label Grid.Row="<SYMPHONY_LOOPVALUE>" Grid.Column="0"
						   Style="{StaticResource <Structure_name>_<Field_sqlname>_prompt}" DataContext="{Binding Path=CriteriaData}"
						   Visibility="{Binding ElementName=chk<Field_sqlname>Visibility, Path=IsChecked, Converter={StaticResource BooleanToVisibilityConverter}}"/>
					</IF NOCHECKBOX>
					<symphonyControls:FieldControl Grid.Row="<SYMPHONY_LOOPVALUE>" Grid.Column="1"
						Visibility="{Binding ElementName=chk<Field_sqlname>Visibility, Path=IsChecked, Converter={StaticResource BooleanToVisibilityConverter}}"
						DataContext="{Binding Path=CriteriaData}"
						Style="{StaticResource <Structure_name>_<Field_sqlname>_style}">
					</symphonyControls:FieldControl>
<SYMPHONY_LOOPINCREMENT>
</IF REPORT>
</IF TOOLKIT>
</IF LANGUAGE>
</IF CUSTOM_NOT_SYMPHONY_ARRAY_FIELD>
</FIELD_LOOP>
				</Grid>
			</ScrollViewer>

			<StackPanel Grid.Row="1" Orientation="Horizontal" HorizontalAlignment="Center">
				<Button Command="{Binding Path=Search}" IsDefault="True" Margin="0,0,10,0" Padding="0" Focusable="True">
					<Button.Content>
						<StackPanel Orientation="Horizontal">
							<Image Focusable="True" Width="16" Height="16" Margin="10,0,0,0" Source="pack://application:,,,/SymphonyCrescendo;component/Images/16x16/Search.png">
							</Image>
							<TextBlock Focusable="True" Text="Search"  Margin="10,2,10,2" Padding="0"></TextBlock>
						</StackPanel>
					</Button.Content>
				</Button>

				<TextBlock Text="Limit results set to " VerticalAlignment="Center" Margin="0" Padding="0"></TextBlock>

				<symphonyUI:SynergyIntBox
							HorizontalAlignment="Left"
							Width="50"  VerticalAlignment="Center" Margin="0" Padding="0"
							Text="{Binding Path=MaxLoadCount}">
				</symphonyUI:SynergyIntBox>

			</StackPanel>

		</Grid>
    </Grid>
</UserControl>

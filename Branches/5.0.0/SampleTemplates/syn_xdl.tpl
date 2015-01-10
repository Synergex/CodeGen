<CODEGEN_FILENAME><structure_name>.xdl</CODEGEN_FILENAME>
;//****************************************************************************
;//
;// Title:       syn_xdl.tpl
;//
;// Type         CodeGen Template
;//
;// Description: This template generates an XDL file that describes a data
;//              file defined in the Synergy/DE Repository
;//
;// Date:        6th November 2008
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
!   Synergy ISAM XDL File
FILE
    NAME        "<FILE_NAME>"
    ADDRESSING  <FILE_ADDRESSING>
    PAGE_SIZE   <FILE_PAGESIZE>
    DENSITY     <FILE_DENSITY>
    KEYS        <STRUCTURE_KEYS>

RECORD
    SIZE        <STRUCTURE_SIZE>
    FORMAT      <file_rectype>
    COMPRESS_DATA   <file_compression>
    STATIC_RFA  <file_static_rfa>

<KEY_LOOP>
KEY <KEY_NUMBER>
    START       <SEGMENT_LOOP><SEGMENT_POSITION><:></SEGMENT_LOOP>
    LENGTH      <SEGMENT_LOOP><SEGMENT_LENGTH><:></SEGMENT_LOOP>
    TYPE        <SEGMENT_LOOP><segment_type><:></SEGMENT_LOOP>
    ORDER       <SEGMENT_LOOP><segment_sequence><:></SEGMENT_LOOP>
    NAME        "<KEY_NAME>"
    DUPLICATES  <IF DUPLICATES>yes</IF><IF NODUPLICATES>no</IF>
    <IF DUPLICATES>
    DUPLICATE_ORDER <IF DUPLICATESATFRONT>lifo</IF><IF DUPLICATESATEND>fifo</IF>
    </IF>
    MODIFIABLE  <IF CHANGES>yes</IF><IF NOCHANGES>no</IF>
    <IF NULLKEY>
    NULL        <key_nulltype>
    <IF NULLVALUE>
    VALUE_NULL  <KEY_NULLVALUE>
    </IF>
    </IF>
    DENSITY     <KEY_DENSITY>

</KEY_LOOP>


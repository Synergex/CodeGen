<CODEGEN_FILENAME><structure_name>_codegen.htm</CODEGEN_FILENAME>
;//****************************************************************************
;//
;// Title:       html_codegen.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: This template generates an CodeGen HTML documentation for a
;//              repository structure.
;//
;// Date:        12th March 2008
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
<html>
<head>
    <title>Structure <STRUCTURE_NAME> CodeGen Information</title>
</head>
<body>
<a name="top"><h1><CODEGEN_VERSION> Repository Structure Report</h1></a>
<h2>Structure <STRUCTURE_NAME> (<STRUCTURE_DESC>)</h2>

<a href="#struct_tokens">Structure Tokens</a> :
<a href="#key_loops">Key Loops</a> :

<h3>Fields</h3>
<FIELD_LOOP>
<a href="#<field_name>"><FIELD_NAME></a> :
</FIELD_LOOP>

<h3>Keys</h3>
<KEY_LOOP>
<a href="#KY_<KEY_NAME>"><KEY_NAME></a> :
</KEY_LOOP>


<hr>
<a name="<field_name>"><h3>Structure Tokens</h3></a>
[<a href="#top">Top</a>]

<h4>&LT;DATA_FIELDS_LIST&GT;</h4>
<pre><DATA_FIELDS_LIST></pre>

<h4>&LT;DISPLAY_FIELD&GT;</h4>
<pre><DISPLAY_FIELD></pre>

<h4>&LT;STRUCTURE_FIELDS&GT;</h4>
<pre><STRUCTURE_FIELDS></pre>

<h4>&LT;FILE_DESC&GT;</h4>
<pre><FILE_DESC></pre>

<h4>&LT;FILE_NAME&GT;</h4>
<pre><FILE_NAME></pre>

<h4>&LT;FILE_RECTYPE&GT;</h4>
<pre><FILE_RECTYPE></pre>

<h4>&LT;FILE_TYPE&GT;</h4>
<pre><FILE_TYPE></pre>

<h4>&LT;FILE_UTEXT&GT;</h4>
<pre><FILE_UTEXT></pre>

<h4>&LT;STRUCTURE&GT;</h4>
<pre><STRUCTURE_NAME></pre>

<h4>&LT;structure&GT;</h4>
<pre><structure_name></pre>

<h4>&LT;Structure&GT;</h4>
<pre><Structure_Name></pre>

<h4>&LT;STRUCTURE_CHILDREN&GT;</h4>
<pre><STRUCTURE_CHILDREN></pre>

<h4>&LT;STRUCTURE_DESC&GT;</h4>
<pre><STRUCTURE_DESC></pre>

<h4>&LT;STRUCTURE_LDESC&GT;</h4>
<pre><STRUCTURE_LDESC></pre>

<h4>&LT;STRUCTURE_SIZE&GT;</h4>
<pre><STRUCTURE_SIZE></pre>

<h4>&LT;STRUCTURE_UTEXT&GT;</h4>
<pre><STRUCTURE_UTEXT></pre>

<!--Fields--------------------------------------------------------------------------------------->

<FIELD_LOOP>
<hr>
<a name="<field_name>"><h3>Field <FIELD_NAME></h3></a>
[<a href="#top">Top</a>]
<table border=0 width="100%">
<tr>
<td>&lt;FIELD_NAME&gt;</td>
<td width="100%"><pre><FIELD_NAME></pre></td>
</tr>
<tr>
<td>&lt;field_name&gt;</td>
<td width="100%"><pre><field_name></pre></td>
</tr>
<tr>
<td>&lt;Field_Name&gt;</td>
<td width="100%"><pre><Field_Name></pre></td>
</tr>
<tr>
<td>&lt;FIELD_ALTNAME&gt;</td>
<td width="100%"><pre><FIELD_ALTNAME></pre></td>
</tr>
<tr>
<td>&lt;field_altname&gt;</td>
<td width="100%"><pre><field_altname></pre></td>
</tr>
<tr>
<td>&lt;FIELD_BASENAME&gt;</td>
<td width="100%"><pre><FIELD_BASENAME></pre></td>
</tr>
<tr>
<td>&lt;field_basename&gt;</td>
<td width="100%"><pre><field_basename></pre></td>
</tr>
<tr>
<td>&lt;Field_Basename&gt;</td>
<td width="100%"><pre><Field_Basename></pre></td>
</tr>
<tr>
<td>&lt;FIELD_CSTYPE&gt;</td>
<td width="100%"><pre><FIELD_CSTYPE></pre></td>
</tr>
<tr>
<td>&lt;FIELD_DESC&gt;</td>
<td width="100%"><pre><FIELD_DESC></pre></td>
</tr>
<tr>
<td>&lt;FIELD_HELPID&gt;</td>
<td width="100%"><pre><FIELD_HELPID></pre></td>
</tr>
<tr>
<td>&lt;FIELD_PIXEL_COL&gt;</td>
<td width="100%"><pre><FIELD_PIXEL_COL></pre></td>
</tr>
<tr>
<td>&lt;FIELD_PIXEL_ROW&gt;</td>
<td width="100%"><pre><FIELD_PIXEL_ROW></pre></td>
</tr>
<tr>
<td>&lt;FIELD_PIXEL_WIDTH&gt;</td>
<td width="100%"><pre><FIELD_PIXEL_WIDTH></pre></td>
</tr>
<tr>
<td>&lt;FIELD_PATH&gt;</td>
<td width="100%"><pre><FIELD_PATH></pre></td>
</tr>
<tr>
<td>&lt;field_path&gt;</td>
<td width="100%"><pre><field_path></pre></td>
</tr>
<tr>
<td>&lt;FIELD_PATH_CONV&gt;</td>
<td width="100%"><pre><FIELD_PATH_CONV></pre></td>
</tr>
<tr>
<td>&lt;field_path_conv&gt;</td>
<td width="100%"><pre><field_path_conv></pre></td>
</tr>
<tr>
<td>&lt;FIELD#&gt;</td>
<td width="100%"><pre><FIELD#></pre></td>
</tr>
<tr>
<td>&lt;FIELD#LOGICAL&gt;</td>
<td width="100%"><pre><FIELD#LOGICAL></pre></td>
</tr>
<tr>
<td>&lt;FIELD_POSITION&gt;</td>
<td width="100%"><pre><FIELD_POSITION></pre></td>
</tr>
<tr>
<td>&lt;FIELD_PRECISION&gt;</td>
<td width="100%"><pre><FIELD_PRECISION></pre></td>
</tr>
<tr>
<td>&lt;FIELD_PRECISION2&gt;</td>
<td width="100%"><pre><FIELD_PRECISION2></pre></td>
</tr>
<tr>
<td>&lt;FIELD_PROMPT&gt;</td>
<td width="100%"><pre><FIELD_PROMPT></pre></td>
</tr>
<tr>
<td>&lt;FIELD_SIZE&gt;</td>
<td width="100%"><pre><FIELD_SIZE></pre></td>
</tr>
<tr>
<td>&lt;FIELD_SPEC&gt;</td>
<td width="100%"><pre><FIELD_SPEC></pre></td>
</tr>
<tr>
<td>&lt;FIELD_SQLNAME&gt;</td>
<td width="100%"><pre><FIELD_SQLNAME></pre></td>
</tr>
<tr>
<td>&lt;field_sqlname&gt;</td>
<td width="100%"><pre><field_sqlname></pre></td>
</tr>
<tr>
<td>&lt;Field_sqlname&gt;</td>
<td width="100%"><pre><Field_Sqlname></pre></td>
</tr>
<tr>
<td>&lt;FIELD_SQLTYPE&gt;</td>
<td width="100%"><pre><FIELD_SQLTYPE></pre></td>
</tr>
<td>&lt;FIELD_TKSCRIPT&gt;</td>
<td width="100%"><pre><FIELD_TKSCRIPT></pre></td>
</tr>
<tr>
<td>&lt;FIELD_TYPE&gt;</td>
<td width="100%"><pre><FIELD_TYPE></pre></td>
</tr>
<tr>
<td>&lt;field_type&gt;</td>
<td width="100%"><pre><field_type></pre></td>
</tr>
<tr>
<td>&lt;FIELD_TYPE_NAME&gt;</td>
<td width="100%"><pre><FIELD_TYPE_NAME></pre></td>
</tr>
<tr>
<td>&lt;FIELD_VBTYPE&gt;</td>
<td width="100%"><pre><FIELD_VBTYPE></pre></td>
</tr>
<tr>
<td>&lt;MAPPED_FIELD&gt;</td>
<td width="100%"><pre><MAPPED_FIELD></pre></td>
</tr>
<tr>
<td>&lt;mapped_field&gt;</td>
<td width="100%"><pre><mapped_field></pre></td>
</tr>
<tr>
<td>&lt;MAPPED_PATH&gt;</td>
<IF MAPPED>
<td width="100%"><IF MAPPEDSTR><pre><MAPPED_PATH></pre></IF>&nbsp;</td>
</IF>
</tr>
<tr>
<td>&lt;mapped_path&gt;</td>
<IF MAPPED>
<td width="100%"><IF MAPPEDSTR><pre><mapped_path></pre></IF>&nbsp;</td>
</IF>
</tr>
<tr>
<td>&lt;MAPPED_PATH_CONV&gt;</td>
<IF MAPPED>
<td width="100%"><IF MAPPEDSTR><pre><MAPPED_PATH_CONV></pre></IF>&nbsp;</td>
</IF>
</tr>
<tr>
<td>&lt;mapped_path_conv&gt;</td>
<IF MAPPED>
<td width="100%"><IF MAPPEDSTR><pre><mapped_path_conv></pre></IF>&nbsp;</td>
</IF>
</tr>
<tr>
<td>&lt;PROMPT_PIXEL_COL&gt;</td>
<td width="100%"><pre><PROMPT_PIXEL_COL></pre></td>
</tr>
<tr>
<td>&lt;PROMPT_PIXEL_ROW&gt;</td>
<td width="100%"><pre><PROMPT_PIXEL_ROW></pre></td>
</tr>
<tr>
<td>&lt;PROMPT_PIXEL_WIDTH&gt;</td>
<td width="100%"><pre><PROMPT_PIXEL_WIDTH></pre></td>
</tr>
<tr>
</table>
</FIELD_LOOP>

<hr>
<a name="key_loops"><h3>Key Loop Processing</h3></a>
[<a href="#top">Top</a>]

<h4>&LT;KEY_LOOP&GT;</h4>
These keys will be processed:
<pre>
<KEY_LOOP>
<KEY_NAME>
</KEY_LOOP>
</pre>

<h4>&LT;ALTERNATE_KEY_LOOP&GT;</h4>
These keys will be processed:
<pre>
<ALTERNATE_KEY_LOOP>
<KEY_NAME>
</ALTERNATE_KEY_LOOP>
</pre>

<KEY_LOOP>
<hr>
<a name="KY_<KEY_NAME>"><h3>Key <KEY_NAME></h3></a>
[<a href="#top">Top</a>]
<table border=0 width="100%">

<tr>
<td>&lt;KEY_CHANGES&gt;</td>
<td width="100%"><pre><KEY_CHANGES></pre></td>
</tr>

<tr>
<td>&lt;KEY_DESCRIPTION&gt;</td>
<td width="100%"><pre><KEY_DESCRIPTION></pre></td>
</tr>

<tr>
<td>&lt;KEY_DUPLICATES&gt;</td>
<td width="100%"><pre><KEY_DUPLICATES></pre></td>
</tr>

<tr>
<td>&lt;KEY_DUPLICATES_AT&gt;</td>
<td width="100%"><pre><KEY_DUPLICATES_AT></pre></td>
</tr>

<tr>
<td>&lt;KEY_LENGTH&gt;</td>
<td width="100%"><pre><KEY_LENGTH></pre></td>
</tr>

<tr>
<td>&lt;KEY_NAME&gt;</td>
<td width="100%"><pre><KEY_NAME></pre></td>
</tr>

<tr>
<td>&lt;KEY_NUMBER&gt;</td>
<td width="100%"><pre><KEY_NUMBER></pre></td>
</tr>

<tr>
<td>&lt;KEY_ORDER&gt;</td>
<td width="100%"><pre><KEY_ORDER></pre></td>
</tr>

<tr>
<td>&lt;KEY_SEGMENTS&gt;</td>
<td width="100%"><pre><KEY_SEGMENTS></pre></td>
</tr>

<tr>
<td>&lt;KEY_UNIQUE&gt;</td>
<td width="100%"><pre><KEY_UNIQUE></pre></td>
</tr>

</table>
</KEY_LOOP>

</body>
</html>

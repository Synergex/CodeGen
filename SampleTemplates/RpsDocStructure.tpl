<CODEGEN_FILENAME>STR_<StructureName>.htm</CODEGEN_FILENAME>
<HTML>
<HEAD>
    <TITLE>Structure <STRUCTURE_NAME></TITLE>
</HEAD>
<BODY>
    <H1><A NAME="TOP">Structure <STRUCTURE_NAME></A></H1>

    <p>
    [<a href="default.htm">Repository Home</a>]
    </p>
    
    <TABLE WIDTH="100%">
    <TR>
        <TD WIDTH="20%"><H2><A HREF="#FIELDS">Fields</A></H2></TD>
        <TD WIDTH="20%"><H2><A HREF="#KEYS">Keys</A></H2></TD>
        <TD WIDTH="20%"><H2><A HREF="#RELATIONS">Relations</A></H2></TD>
        <TD WIDTH="20%"><H2><A HREF="#FORMATS">Formats</A></H2></TD>
        <TD WIDTH="20%"><H2><A HREF="#TAGS">Tags</A></H2></TD>
        <TD WIDTH="20%"><H2><A HREF="#ALIASES">Aliases</A></H2></TD>
    </TR>
    <TR>
        <TD VALIGN="TOP">
            <FIELD_LOOP>
            <A HREF="#FIELD_<FIELD_NAME>"><FIELD_NAME></A><BR>
            </FIELD_LOOP>
        </TD>
        <TD VALIGN="TOP">
            <IF STRUCTURE_KEYS>
            <KEY_LOOP>
            <A HREF="#KEY_<KEY_NAME>"><KEY_NAME></A><BR>
            </KEY_LOOP>
            </IF STRUCTURE_KEYS>
        </TD>
        <TD VALIGN="TOP">
            <IF STRUCTURE_RELATIONS>
            <RELATION_LOOP>
            <A HREF="#RELATION_<RELATION_NAME>"><RELATION_NAME></A><BR>
            </KEY_LOOP>
            </IF STRUCTURE_RELATIONS>
        </TD>
        <TD VALIGN="TOP">
            <IF STRUCTURE_TAGS>
            <TAG_LOOP>
            <A HREF="#TAG_<TAG_NAME>"><TAG_NAME></A><BR>
            </TAG_LOOP>
            </IF STRUCTURE_TAGS>
        </TD>
    </TABLE>

;//----------------------------------------------------------------------------------------------------
    <!-- Fields -->
    <HR>
    <H2><A NAME="FIELDS">Fields</A></H2>
                
    <FILE:CODEGEN_TPLDIR:RpsDocStructureNav.inc>

<FIELD_LOOP>
    <A HREF="#FIELD_<FIELD_NAME>"><FIELD_NAME></A><BR>
</FIELD_LOOP>

<FIELD_LOOP>
    <HR>
    <H3><A NAME="FIELD_<FIELD_NAME>">Field <STRUCTURE_NAME>.<FIELD_NAME></A></H3>
                
    <FILE:CODEGEN_TPLDIR:RpsDocStructureNav.inc>

    <P>
    [<A HREF="#<FIELD_NAME>_TOKENS">Expansion Tokens</A>]
    [<A HREF="#<FIELD_NAME>_EXPRESSIONS">Expressions</A>]
    <IF SELECTIONS>[<A HREF="#<FIELD_NAME>_SELECTIONS">Selections</A>]</IF SELECTIONS>
    </P>

    <H4><A NAME="<FIELD_NAME>_TOKENS">Expansion Tokens</A></H4>
    <TABLE>
        <TR><TD><B>Token</B></TD><TD><B>Value</B></TD></TR>
        <TR><TD>&lt;FIELD_ALTNAME&gt;</TD><TD><FIELD_ALTNAME></TD></TR>
        <TR><TD>&lt;FIELD_ARRIVEM&gt;</TD><TD><FIELD_ARRIVEM></TD></TR>
        <TR><TD>&lt;FIELD_BASENAME&gt;</TD><TD><FIELD_BASENAME></TD></TR>
        <TR><TD>&lt;FIELD_BREAK_MODE&gt;</TD><TD><FIELD_BREAK_MODE></TD></TR>
        <TR><TD>&lt;FIELD_CHANGEM&gt;</TD><TD><FIELD_CHANGEM></TD></TR>
        <TR><TD>&lt;FIELD_COL&gt;</TD><TD><FIELD_COL></TD></TR>
        <TR><TD>&lt;FIELD_CSDEFAULT&gt;</TD><TD><FIELD_CSDEFAULT></TD></TR>
        <TR><TD>&lt;FIELD_CSTYPE&gt;</TD><TD><FIELD_CSTYPE></TD></TR>
        <TR><TD>&lt;FIELD_CSCONVERT&gt;</TD><TD><FIELD_CSCONVERT></TD></TR>
        <TR><TD>&lt;FIELD_DEFAULT&gt;</TD><TD><FIELD_DEFAULT></TD></TR>
        <TR><TD>&lt;FIELD_DESC&gt;</TD><TD><FIELD_DESC></TD></TR>
        <TR><TD>&lt;FIELD_DIMENSION1_INDEX&gt;</TD><TD><FIELD_DIMENSION1_INDEX></TD></TR>
        <TR><TD>&lt;FIELD_DIMENSION2_INDEX&gt;</TD><TD><FIELD_DIMENSION2_INDEX></TD></TR>
        <TR><TD>&lt;FIELD_DIMENSION3_INDEX&gt;</TD><TD><FIELD_DIMENSION3_INDEX></TD></TR>
        <TR><TD>&lt;FIELD_DIMENSION4_INDEX&gt;</TD><TD><FIELD_DIMENSION4_INDEX></TD></TR>
        <TR><TD>&lt;FIELD_DRILLM&gt;</TD><TD><FIELD_DRILLM></TD></TR>
        <TR><TD>&lt;FIELD_ELEMENT&gt;</TD><TD><FIELD_ELEMENT></TD></TR>
        <TR><TD>&lt;FIELD_ELEMENT0&gt;</TD><TD><FIELD_ELEMENT0></TD></TR>
        <TR><TD>&lt;FIELD_ENUMLENGTH&gt;</TD><TD><FIELD_ENUMLENGTH></TD></TR>
        <TR><TD>&lt;FIELD_ENUMWIDTH&gt;</TD><TD><FIELD_ENUMWIDTH></TD></TR>
        <TR><TD>&lt;FIELD_FORMATNAME&gt;</TD><TD><FIELD_FORMATNAME></TD></TR>
        <TR><TD>&lt;FIELD_HEADING&gt;</TD><TD><FIELD_HEADING></TD></TR>
        <TR><TD>&lt;FIELD_HELPID&gt;</TD><TD><FIELD_HELPID></TD></TR>
        <TR><TD>&lt;FIELD_HYPERM&gt;</TD><TD><FIELD_HYPERM></TD></TR>
        <TR><TD>&lt;FIELD_INFOLINE&gt;</TD><TD><FIELD_INFOLINE></TD></TR>
        <TR><TD>&lt;FIELD_LDESC&gt;</TD><TD><FIELD_LDESC></TD></TR>
        <TR><TD>&lt;FIELD_LEAVEM&gt;</TD><TD><FIELD_LEAVEM></TD></TR>
        <IF NUMERIC>
        <TR><TD>&lt;FIELD_MAXVALUE&gt;</TD><TD><FIELD_MAXVALUE></TD></TR>
        <TR><TD>&lt;FIELD_MINVALUE&gt;</TD><TD><FIELD_MINVALUE></TD></TR>
        </IF NUMERIC>
        <TR><TD>&lt;FIELD_NAME&gt;</TD><TD><FIELD_NAME></TD></TR>
        <TR><TD>&lt;FIELD_NETNAME&gt;</TD><TD><FIELD_NETNAME></TD></TR>
        <TR><TD>&lt;FIELD_NOECHO_CHAR&gt;</TD><TD><FIELD_NOECHO_CHAR></TD></TR>
        <TR><TD>&lt;FIELD_OCDEFAULT&gt;</TD><TD><FIELD_OCDEFAULT></TD></TR>
        <TR><TD>&lt;FIELD_OCTYPE&gt;</TD><TD><FIELD_OCTYPE></TD></TR>
        <TR><TD>&lt;FIELD_ORIGINAL_NAME&gt;</TD><TD><FIELD_ORIGINAL_NAME></TD></TR>
        <TR><TD>&lt;FIELD_PATH&gt;</TD><TD><FIELD_PATH></TD></TR>
        <TR><TD>&lt;FIELD_PATH_CONV&gt;</TD><TD><FIELD_PATH_CONV></TD></TR>
        <TR><TD>&lt;FIELD_PIXEL_COL&gt;</TD><TD><FIELD_PIXEL_COL></TD></TR>
        <TR><TD>&lt;FIELD_PIXEL_ROW&gt;</TD><TD><FIELD_PIXEL_ROW></TD></TR>
        <TR><TD>&lt;FIELD_PIXEL_WIDTH&gt;</TD><TD><FIELD_PIXEL_WIDTH></TD></TR>
        <TR><TD>&lt;FIELD_DRILL_PIXEL_COL&gt;</TD><TD><FIELD_DRILL_PIXEL_COL></TD></TR>
        <TR><TD>&lt;FIELD_INPUT_LENGTH&gt;</TD><TD><FIELD_INPUT_LENGTH></TD></TR>
        <TR><TD>&lt;FIELD_ODBCNAME&gt;</TD><TD><FIELD_ODBCNAME></TD></TR>
        <TR><TD>&lt;FIELD_POSITION&gt;</TD><TD><FIELD_POSITION></TD></TR>
        <TR><TD>&lt;FIELD_POSITION_ZERO&gt;</TD><TD><FIELD_POSITION_ZERO></TD></TR>
        <TR><TD>&lt;FIELD_PRECISION&gt;</TD><TD><FIELD_PRECISION></TD></TR>
        <TR><TD>&lt;FIELD_PRECISION0&gt;</TD><TD><FIELD_PRECISION0></TD></TR>
        <TR><TD>&lt;FIELD_PRECISION2&gt;</TD><TD><FIELD_PRECISION2></TD></TR>
        <TR><TD>&lt;FIELD_PROMPT&gt;</TD><TD><FIELD_PROMPT></TD></TR>
        <TR><TD>&lt;FIELD_RANGE_MAX&gt;</TD><TD><FIELD_RANGE_MAX></TD></TR>
        <TR><TD>&lt;FIELD_RANGE_MIN&gt;</TD><TD><FIELD_RANGE_MIN></TD></TR>
        <TR><TD>&lt;FIELD_REGEX&gt;</TD><TD><FIELD_REGEX></TD></TR>
        <TR><TD>&lt;FIELD_ROW&gt;</TD><TD><FIELD_ROW></TD></TR>
        <TR><TD>&lt;FIELD_SELECTION_COUNT&gt;</TD><TD><FIELD_SELECTION_COUNT></TD></TR>
        <TR><TD>&lt;FIELD_SELECTIONS&gt;</TD><TD><FIELD_SELECTIONS></TD></TR>
        <TR><TD>&lt;FIELD_SELECTIONS1&gt;</TD><TD><FIELD_SELECTIONS1></TD></TR>
        <TR><TD>&lt;FIELD_SELLENGTH&gt;</TD><TD><FIELD_SELLENGTH></TD></TR>
        <TR><TD>&lt;FIELD_SELWND&gt;</TD><TD><FIELD_SELWND></TD></TR>
        <TR><TD>&lt;FIELD_SELWND_ORIGINAL&gt;</TD><TD><FIELD_SELWND_ORIGINAL></TD></TR>
        <TR><TD>&lt;FIELD_SIZE&gt;</TD><TD><FIELD_SIZE></TD></TR>
        <TR><TD>&lt;FIELD_SNTYPE&gt;</TD><TD><FIELD_SNTYPE></TD></TR>
        <TR><TD>&lt;FIELD_SNDEFAULT&gt;</TD><TD><FIELD_SNDEFAULT></TD></TR>
        <TR><TD>&lt;FIELD_SPEC&gt;</TD><TD><FIELD_SPEC></TD></TR>
        <TR><TD>&lt;FIELD_SQLNAME&gt;</TD><TD><FIELD_SQLNAME></TD></TR>
        <TR><TD>&lt;FIELD_SQLTYPE&gt;</TD><TD><FIELD_SQLTYPE></TD></TR>
        <TR><TD>&lt;FIELD_TEMPLATE&gt;</TD><TD><FIELD_TEMPLATE></TD></TR>
        <TR><TD>&lt;FIELD_TKSCRIPT&gt;</TD><TD></TD></TR>
        <TR><TD>&lt;FIELD_TYPE&gt;</TD><TD><FIELD_TYPE></TD></TR>
        <TR><TD>&lt;FIELD_TYPE_NAME&gt;</TD><TD><FIELD_TYPE_NAME></TD></TR>
        <TR><TD>&lt;FIELD_UTEXT&gt;</TD><TD><FIELD_UTEXT></TD></TR>
        <TR><TD>&lt;FIELD_VBDEFAULT&gt;</TD><TD><FIELD_VBDEFAULT></TD></TR>
        <TR><TD>&lt;FIELD_VBTYPE&gt;</TD><TD><FIELD_VBTYPE></TD></TR>
        <TR><TD>&lt;FIELD#&gt;</TD><TD><FIELD#></TD></TR>
        <TR><TD>&lt;FIELD#_ZERO&gt;</TD><TD><FIELD#_ZERO></TD></TR>
        <TR><TD>&lt;FIELD#LOGICAL&gt;</TD><TD><FIELD#LOGICAL></TD></TR>
        <TR><TD>&lt;FIELD#LOGICAL_ZERO&gt;</TD><TD><FIELD#LOGICAL_ZERO></TD></TR>
        <IF MAPPED>
        <TR><TD>&lt;MAPPED_FIELD&gt;</TD><TD><MAPPED_FIELD></TD></TR>
        <TR><TD>&lt;MAPPED_PATH&gt;</TD><TD><MAPPED_PATH></TD></TR>
        <TR><TD>&lt;MAPPED_PATH_CONV&gt;</TD><TD><MAPPED_PATH_CONV></TD></TR>
        </IF MAPPED>
        <TR><TD>&lt;PROMPT_COL&gt;</TD><TD><PROMPT_COL></TD></TR>
        <TR><TD>&lt;PROMPT_PIXEL_COL&gt;</TD><TD><PROMPT_PIXEL_COL></TD></TR>
        <TR><TD>&lt;PROMPT_PIXEL_ROW&gt;</TD><TD><PROMPT_PIXEL_ROW></TD></TR>
        <TR><TD>&lt;PROMPT_PIXEL_WIDTH&gt;</TD><TD><PROMPT_PIXEL_WIDTH></TD></TR>
        <TR><TD>&lt;PROMPT_ROW&gt;</TD><TD><PROMPT_ROW></TD></TR>
    </TABLE>

    <H4><A NAME="<FIELD_NAME>_EXPRESSIONS">Expressions</A></H4>
    <TABLE>
        <TR><TD><B>Expression</B></TD><TD><B>Result</B></TD></TR>
        <TR><TD>&lt;IF ALPHA&gt;</TD><TD><IF ALPHA>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF ALLOW_LIST&gt;</TD><TD><IF ALLOW_LIST>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF ALTERNATE_NAME&gt;</TD><TD><IF ALTERNATE_NAME>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF ARRAY&gt;</TD><TD><IF ARRAY>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF ARRAY1&gt;</TD><TD><IF ARRAY1>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF ARRAY2&gt;</TD><TD><IF ARRAY2>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF ARRAY3&gt;</TD><TD><IF ARRAY3>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF ARRAY4&gt;</TD><TD><IF ARRAY4>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF ARRIVE&gt;</TD><TD><IF ARRIVE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF BINARY&gt;</TD><TD><IF BINARY>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF BOLD&gt;</TD><TD><IF BOLD>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF BOOLEAN&gt;</TD><TD><IF BOOLEAN>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF BZERO&gt;</TD><TD><IF BZERO>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF BREAK&gt;</TD><TD><IF BREAK>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF BREAK_ALWAYS&gt;</TD><TD><IF BREAK_ALWAYS>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF BREAK_CHANGE&gt;</TD><TD><IF BREAK_CHANGE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF BREAK_RETURN&gt;</TD><TD><IF BREAK_RETURN>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF CHANGE&gt;</TD><TD><IF CHANGE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF CHECKBOX&gt;</TD><TD><IF CHECKBOX>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF COERCE_BOOLEAN&gt;</TD><TD><IF COERCE_BOOLEAN>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF COMBOBOX&gt;</TD><TD><IF COMBOBOX>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DATE&gt;</TD><TD><IF DATE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DATEORTIME&gt;</TD><TD><IF DATEORTIME>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DATETODAY&gt;</TD><TD><IF DATETODAY>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DATE_JULIAN&gt;</TD><TD><IF DATE_JULIAN>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DATE_NOT_JULIAN&gt;</TD><TD><IF DATE_NOT_JULIAN>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DATE_NOT_NULLABLE&gt;</TD><TD><IF DATE_NOT_NULLABLE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DATE_NOT_PERIOD&gt;</TD><TD><IF DATE_NOT_PERIOD>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DATE_NOT_YMD&gt;</TD><TD><IF DATE_NOT_YMD>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DATE_NOT_YYYYMMDD&gt;</TD><TD><IF DATE_NOT_YYYYMMDD>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DATE_NULLABLE&gt;</TD><TD><IF DATE_NULLABLE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DATE_PERIOD&gt;</TD><TD><IF DATE_PERIOD>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DATE_YMD&gt;</TD><TD><IF DATE_YMD>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DATE_YYMMDD&gt;</TD><TD><IF DATE_YYMMDD>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DATE_YYYYMMDD&gt;</TD><TD><IF DATE_YYYYMMDD>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DATE_YYJJJ&gt;</TD><TD><IF DATE_YYJJJ>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DATE_YYYYJJJ&gt;</TD><TD><IF DATE_YYYYJJJ>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DATE_YYPP&gt;</TD><TD><IF DATE_YYPP>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DATE_YYYYPP&gt;</TD><TD><IF DATE_YYYYPP>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DECIMAL&gt;</TD><TD><IF DECIMAL>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DEFAULT&gt;</TD><TD><IF DEFAULT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DESCRIPTION&gt;</TD><TD><IF DESCRIPTION>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DISABLED&gt;</TD><TD><IF DISABLED>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DISPLAY&gt;</TD><TD><IF DISPLAY>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DISPLAY_LENGTH&gt;</TD><TD><IF DISPLAY_LENGTH>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DRILL&gt;</TD><TD><IF DRILL>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF ECHO&gt;</TD><TD><IF ECHO>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF EDITFORMAT&gt;</TD><TD><IF EDITFORMAT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF ENABLED&gt;</TD><TD><IF ENABLED>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF ENUM&gt;</TD><TD><IF ENUM>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF ENUMERATED&gt;</TD><TD><IF ENUMERATED>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF FIELD_POSITION&gt;</TD><TD><IF FIELD_POSITION>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF FORMAT&gt;</TD><TD><IF FORMAT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF GROUP_EXPAND&gt;</TD><TD><IF GROUP_EXPAND>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF GROUP_NO_EXPAND&gt;</TD><TD><IF GROUP_NO_EXPAND>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF HEADING&gt;</TD><TD><IF HEADING>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF HELPID&gt;</TD><TD><IF HELPID>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF HYPERLINK&gt;</TD><TD><IF HYPERLINK>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF I1&gt;</TD><TD><IF I1>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF I2&gt;</TD><TD><IF I2>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF I4&gt;</TD><TD><IF I4>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF I8&gt;</TD><TD><IF I8>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF I124&gt;</TD><TD><IF I124>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF INFOLINE&gt;</TD><TD><IF INFOLINE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF INPUT_CENTER&gt;</TD><TD><IF INPUT_CENTER>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF INPUT_LEFT&gt;</TD><TD><IF INPUT_LEFT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF INPUT_RIGHT&gt;</TD><TD><IF INPUT_RIGHT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF INTEGER&gt;</TD><TD><IF INTEGER>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF LANGUAGE&gt;</TD><TD><IF LANGUAGE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF LEAVE&gt;</TD><TD><IF LEAVE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF LONGDESC&gt;</TD><TD><IF LONGDESC>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF MAPPED&gt;</TD><TD><IF MAPPED>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF MAPPEDSTR&gt;</TD><TD><IF MAPPEDSTR>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NEGATIVE_ALLOWED&gt;</TD><TD><IF NEGATIVE_ALLOWED>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NEGATIVE_ORZERO&gt;</TD><TD><IF NEGATIVE_ORZERO>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NEGATIVE_REQUIRED&gt;</TD><TD><IF NEGATIVE_REQUIRED>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOALLOW_LIST&gt;</TD><TD><IF NOALLOW_LIST>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOALTERNATE_NAME&gt;</TD><TD><IF NOALTERNATE_NAME>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOARRIVE&gt;</TD><TD><IF NOARRIVE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOBREAK&gt;</TD><TD><IF NOBREAK>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOCHANGE&gt;</TD><TD><IF NOCHANGE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOCHECKBOX&gt;</TD><TD><IF NOCHECKBOX>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NODEFAULT&gt;</TD><TD><IF NODEFAULT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NODESCRIPTION&gt;</TD><TD><IF NODESCRIPTION>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NODISPLAY&gt;</TD><TD><IF NODISPLAY>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NODISPLAY_LENGTH&gt;</TD><TD><IF NODISPLAY_LENGTH>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NODRILL&gt;</TD><TD><IF NODRILL>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOECHO&gt;</TD><TD><IF NOECHO>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOEDITFORMAT&gt;</TD><TD><IF NOEDITFORMAT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOFORMAT&gt;</TD><TD><IF NOFORMAT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOHELPID&gt;</TD><TD><IF NOHELPID>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOHYPERLINK&gt;</TD><TD><IF NOHYPERLINK>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOINFOLINE&gt;</TD><TD><IF NOINFOLINE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOLANGUAGE&gt;</TD><TD><IF NOLANGUAGE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOLEAVE&gt;</TD><TD><IF NOLEAVE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOLONGDESC&gt;</TD><TD><IF NOLONGDESC>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NONEGATIVE&gt;</TD><TD><IF NONEGATIVE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOPAINTCHAR&gt;</TD><TD><IF NOPAINTCHAR>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOPRECISION&gt;</TD><TD><IF NOPRECISION>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOPROMPT&gt;</TD><TD><IF NOPROMPT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NORANGE&gt;</TD><TD><IF NORANGE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOREPORT&gt;</TD><TD><IF NOREPORT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOSELECTIONS&gt;</TD><TD><IF NOSELECTIONS>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOSELWND&gt;</TD><TD><IF NOSELWND>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOTALPHA&gt;</TD><TD><IF NOTALPHA>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOTARRAY&gt;</TD><TD><IF NOTARRAY>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOTBINARY&gt;</TD><TD><IF NOTBINARY>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOTBOOLEAN&gt;</TD><TD><IF NOTBOOLEAN>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOTBZERO&gt;</TD><TD><IF NOTBZERO>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOTDATE&gt;</TD><TD><IF NOTDATE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOTDATEORTIME&gt;</TD><TD><IF NOTDATEORTIME>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOTDATETODAY&gt;</TD><TD><IF NOTDATETODAY>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOTDECIMAL&gt;</TD><TD><IF NOTDECIMAL>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOTENUM&gt;</TD><TD><IF NOTENUM>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOTENUMERATED&gt;</TD><TD><IF NOTENUMERATED>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOTIMEOUT&gt;</TD><TD><IF NOTIMEOUT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOTINTEGER&gt;</TD><TD><IF NOTINTEGER>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOTNUMERIC&gt;</TD><TD><IF NOTNUMERIC>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOTOVERLAY&gt;</TD><TD><IF NOTOVERLAY>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOTPKSEGMENT&gt;</TD><TD><IF NOTPKSEGMENT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOTRADIOBUTTONS&gt;</TD><TD><IF NOTRADIOBUTTONS>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOTSTRUCTFIELD&gt;</TD><TD><IF NOTSTRUCTFIELD>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOTOOLKIT&gt;</TD><TD><IF NOTOOLKIT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOTUPPERCASE&gt;</TD><TD><IF NOTUPPERCASE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOTUSER&gt;</TD><TD><IF NOTUSER>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOUSERTEXT&gt;</TD><TD><IF NOUSERTEXT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOVIEW_LENGTH&gt;</TD><TD><IF NOVIEW_LENGTH>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOTTIME&gt;</TD><TD><IF NOTTIME>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOTUSERTIMESTAMP&gt;</TD><TD><IF NOTUSERTIMESTAMP>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOWEB&gt;</TD><TD><IF NOWEB>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NUMERIC&gt;</TD><TD><IF NUMERIC>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF OCNATIVE&gt;</TD><TD><IF OCNATIVE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF OCOBJECT&gt;</TD><TD><IF OCOBJECT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF OPTIONAL&gt;</TD><TD><IF OPTIONAL>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF OVERLAY&gt;</TD><TD><IF OVERLAY>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF PAINTCHAR&gt;</TD><TD><IF PAINTCHAR>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF PKSEGMENT&gt;</TD><TD><IF PKSEGMENT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF PRECISION&gt;</TD><TD><IF PRECISION>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF PROMPT&gt;</TD><TD><IF PROMPT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF PROMPT_POSITION&gt;</TD><TD><IF PROMPT_POSITION>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF RADIOBUTTONS&gt;</TD><TD><IF RADIOBUTTONS>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF RANGE&gt;</TD><TD><IF RANGE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF READONLY&gt;</TD><TD><IF READONLY>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF READWRITE&gt;</TD><TD><IF READWRITE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF REPORT&gt;</TD><TD><IF REPORT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF REPORT_CENTER&gt;</TD><TD><IF REPORT_CENTER>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF REPORT_LEFT&gt;</TD><TD><IF REPORT_LEFT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF REPORT_RIGHT&gt;</TD><TD><IF REPORT_RIGHT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF REQUIRED&gt;</TD><TD><IF REQUIRED>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF REVERSE&gt;</TD><TD><IF REVERSE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF SELECTIONS&gt;</TD><TD><IF SELECTIONS>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF SELWND&gt;</TD><TD><IF SELWND>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF STRUCTFIELD&gt;</TD><TD><IF STRUCTFIELD>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF TEXTBOX&gt;</TD><TD><IF TEXTBOX>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF TIME&gt;</TD><TD><IF TIME>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF TIME_HHMM&gt;</TD><TD><IF TIME_HHMM>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF TIME_HHMMSS&gt;</TD><TD><IF TIME_HHMMSS>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF TIMEOUT&gt;</TD><TD><IF TIMEOUT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF TIMENOW&gt;</TD><TD><IF TIMENOW>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF TOOLKIT&gt;</TD><TD><IF TOOLKIT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF UNDERLINE&gt;</TD><TD><IF UNDERLINE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF UPPERCASE&gt;</TD><TD><IF UPPERCASE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF USER&gt;</TD><TD><IF USER>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF USERTEXT&gt;</TD><TD><IF USERTEXT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF VIEW_LENGTH&gt;</TD><TD><IF VIEW_LENGTH>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF USERTIMESTAMP&gt;</TD><TD><IF USERTIMESTAMP>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF WEB&gt;</TD><TD><IF WEB>TRUE<ELSE>FALSE</IF></TD></TR>
    </TABLE>
</FIELD_LOOP>

    <H4><A NAME="FIELD_SELECTIONS">Selection Lists</A></H4>

<FIELD_LOOP>
  <IF SELECTIONS>
    <A HREF="#<FIELD_NAME>_SELECTIONS"><FIELD_NAME></A><BR>
  </IF SELECTIONS>
</FIELD_LOOP>

<FIELD_LOOP>
  <IF SELECTIONS>
    <H3><A NAME="<FIELD_NAME>_SELECTIONS"><STRUCTURE_NAME>.<FIELD_NAME> Selections</A></H3>
    <TABLE>
        <TR><TD><B>Token</B></TD><TD><B>Value</B></TD></TR>
        <SELECTION_LOOP>
        <TR><TD>&lt;SELECTION_COUNT&GT;</TD><TD><SELECTION_COUNT></TD></TR>
        <TR><TD>&lt;SELECTION_NUMBER&GT;</TD><TD><SELECTION_NUMBER></TD></TR>
        <TR><TD>&lt;SELECTION_TEXT&GT;</TD><TD><SELECTION_TEXT></TD></TR>
        <TR><TD>&lt;SELECTION_VALUE&GT;</TD><TD><SELECTION_VALUE></TD></TR>
        </SELECTION_LOOP>
    </TABLE>
  </IF SELECTIONS>
</FIELD_LOOP>

;//----------------------------------------------------------------------------------------------------
    <!-- Keys -->
    <HR>
    <H2><A NAME="KEYS">Keys</A></H2>
                
    <FILE:CODEGEN_TPLDIR:RpsDocStructureNav.inc>
    
<IF STRUCTURE_KEYS>
  <KEY_LOOP>
    <A HREF="#KEY_<KEY_NAME>"><KEY_NAME></A><BR>
  </KEY_LOOP>
</IF STRUCTURE_KEYS>

<IF STRUCTURE_KEYS>
  <KEY_LOOP>
    <HR>
    <H3><A NAME="KEY_<KEY_NAME>">Key <STRUCTURE_NAME>.<KEY_NAME></A></H3>
    <FILE:CODEGEN_TPLDIR:RpsDocStructureNav.inc>
    <H4>Expansion Tokens</H4>
    <TABLE>
        <TR><TD><B>Token</B></TD><TD><B>Value</B></TD></TR>
        <TR><TD>&lt;KEY_CHANGES&gt;</TD><TD><KEY_CHANGES></TD></TR>
        <TR><TD>&lt;KEY_DENSITY&gt;</TD><TD><KEY_DENSITY></TD></TR>
        <TR><TD>&lt;KEY_DESCRIPTION&gt;</TD><TD><KEY_DESCRIPTION></TD></TR>
        <TR><TD>&lt;KEY_DUPLICATES&gt;</TD><TD><KEY_DUPLICATES></TD></TR>
        <TR><TD>&lt;KEY_DUPLICATES_AT&gt;</TD><TD><KEY_DUPLICATES_AT></TD></TR>
        <TR><TD>&lt;KEY_LENGTH&gt;</TD><TD><KEY_LENGTH></TD></TR>
        <TR><TD>&lt;KEY_NAME&gt;</TD><TD><KEY_NAME></TD></TR>
        <TR><TD>&lt;KEY_NULLTYPE&gt;</TD><TD><KEY_NULLTYPE></TD></TR>
        <TR><TD>&lt;KEY_NULLVALUE&gt;</TD><TD><KEY_NULLVALUE></TD></TR>
        <TR><TD>&lt;KEY_NUMBER&gt;</TD><TD><KEY_NUMBER></TD></TR>
        <TR><TD>&lt;KEY_ORDER&gt;</TD><TD><KEY_ORDER></TD></TR>
        <TR><TD>&lt;KEY_SEGMENTS&gt;</TD><TD><KEY_SEGMENTS></TD></TR>
        <TR><TD>&lt;KEY_UNIQUE&gt;</TD><TD><KEY_UNIQUE></TD></TR>
    </TABLE>
    <H4>Expressions</H4>
    <TABLE>
        <TR><TD><B>Expression</B></TD><TD><B>Result</B></TD></TR>
        <TR><TD>&lt;IF ASCENDING&gt;</TD><TD><IF ASCENDING>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF AUTO_SEQUENCE&gt;</TD><TD><IF AUTO_SEQUENCE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF AUTO_TIMESTAMP&gt;</TD><TD><IF AUTO_TIMESTAMP>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF CHANGES&gt;</TD><TD><IF CHANGES>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DESCENDING&gt;</TD><TD><IF DESCENDING>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DUPLICATES&gt;</TD><TD><IF DUPLICATES>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DUPLICATESATEND&gt;</TD><TD><IF DUPLICATESATEND>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF DUPLICATESATFRONT&gt;</TD><TD><IF DUPLICATESATFRONT>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF MULTIPLE_SEGMENTS&gt;</TD><TD><IF MULTIPLE_SEGMENTS>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NOCHANGES&gt;</TD><TD><IF NOCHANGES>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NODUPLICATES&gt;</TD><TD><IF NODUPLICATES>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NULLKEY&gt;</TD><TD><IF NULLKEY>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF NULLVALUE&gt;</TD><TD><IF NULLVALUE>TRUE<ELSE>FALSE</IF></TD></TR>
        <TR><TD>&lt;IF SINGLE_SEGMENT&gt;</TD><TD><IF SINGLE_SEGMENT>TRUE<ELSE>FALSE</IF></TD></TR>
    </TABLE>
  </KEY_LOOP>
<ELSE>
    No keys defined.
</IF STRUCTURE_KEYS>

;//----------------------------------------------------------------------------------------------------
    <!-- Relations -->
    <HR>
    <H2><A NAME="RELATIONS">Relations</A></H2>

    <FILE:CODEGEN_TPLDIR:RpsDocStructureNav.inc>

<IF STRUCTURE_RELATIONS>
  <RELATION_LOOP>
    <A HREF="#RELATION_<RELATION_NAME>"><RELATION_NAME></A><BR>
  </RELATION_LOOP>
</IF STRUCTURE_RELATIONS>

<IF STRUCTURE_RELATIONS>
  <RELATION_LOOP>
    <HR>
    <H3><A NAME="RELATION_<RELATION_NAME>">Relation <STRUCTURE_NAME>.<RELATION_NAME></A></H3>
    <FILE:CODEGEN_TPLDIR:RpsDocStructureNav.inc>
    <TABLE>
        <TR><TD>Token</TD><TD>Value</TD></TR>
    </TABLE>
  </RELATION_LOOP>
<ELSE>
    No relations defined.
</IF STRUCTURE_RELATIONS>
                
;//----------------------------------------------------------------------------------------------------
    <!-- Formats -->
    <HR>
    <H2><A NAME="FORMATS">Formats</A></H2>

    <FILE:CODEGEN_TPLDIR:RpsDocStructureNav.inc>

;//<IF STRUCTURE_FORMATS>
;//  <FORMAT_LOOP>
;//    <HR>
;//    <H3><A NAME="FORMAT_<FORMAT_NAME>">Format <STRUCTURE_NAME>.<FORMAT_NAME></A></H3>
;//    <FILE:CODEGEN_TPLDIR:RpsDocStructureNav.inc>
;//    <TABLE>
;//        <TR><TD>Token</TD><TD>Value</TD></TR>
;//    </TABLE>
;//  </FORMAT_LOOP>
;//<ELSE>
;//    No formats defined.
;//</IF STRUCTURE_FORMATS>
;//

;//----------------------------------------------------------------------------------------------------
    <!-- Tags -->
    <HR>
    <H2><A NAME="TAGS">Tags</A></H2>
                
    <FILE:CODEGEN_TPLDIR:RpsDocStructureNav.inc>

<IF STRUCTURE_TAGS>
  <TAG_LOOP>
    <A HREF="#TAG_<TAG_NAME>"><TAG_NAME></A><BR>
  </TAG_LOOP>
</IF STRUCTURE_TAGS>

<IF STRUCTURE_TAGS>
  <TAG_LOOP>
    <HR>
    <H3><A NAME="TAG_<TAG_NAME>">Tag <STRUCTURE_NAME>.<TAG_NAME></A></H3>
    <FILE:CODEGEN_TPLDIR:RpsDocStructureNav.inc>
    <TABLE>
        <TR><TD>Token</TD><TD>Value</TD></TR>
    </TABLE>
  </TAG_LOOP>
<ELSE>
    No tags defined.
</IF STRUCTURE_TAGS>

;//----------------------------------------------------------------------------------------------------
    <!-- Aliases -->
    <HR>
    <H2><A NAME="ALIASES">Aliases</A></H2>

    <FILE:CODEGEN_TPLDIR:RpsDocStructureNav.inc>

;//<IF STRUCTURE_ALIASES>
;//  <ALIAS_LOOP>
;//    <HR>
;//    <H3><A NAME="ALIAS_<ALIAS_NAME>">Alias <STRUCTURE_NAME>.<ALIAS_NAME></A></H3>
;//    <FILE:CODEGEN_TPLDIR:RpsDocStructureNav.inc>
;//    <TABLE>
;//        <TR><TD>Token</TD><TD>Value</TD></TR>
;//    </TABLE>
;//  </ALIAS_LOOP>
;//<ELSE>
;//    No aliases defined.
;//</IF STRUCTURE_ALIASES>
;//
</BODY>
</HTML>

//*****************************************************************************
//
// Title:       Tokenizer.cs
//
// Type:        Class
//
// Description: Transforms raw template file data into a list of tokens
//
// Date:        30th August 2014
//
// Author:      Jeff Greene, Synergex Development
//              http://www.synergex.com
//
//*****************************************************************************
//
// Copyright (c) 2014, Synergex International, Inc.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
//
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
//*****************************************************************************

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace CodeGen.Engine
{
    /// <summary>
    /// 
    /// </summary>
    public class Tokenizer
    {
        //_typeLookup contains an entry for every supported non-expression token (expansion, loops, control, file header, etc.)
        //and defines the type of token (TokenType).
        private Dictionary<string, TokenType> typeLookup = new Dictionary<string, TokenType>();
        //_validityLookup contains an entry for every supported non-expression token (expansion, loops, control, file header, etc.)
        //and defines where in a template each is valid.
        private Dictionary<string, List<TokenValidity>> validityLookup = new Dictionary<string, List<TokenValidity>>();
        //_modifierLookup contains an entry for every supported expansion token variation
        private Dictionary<string, TokenModifier> modifierLookup = new Dictionary<string, TokenModifier>();

        //_expressionLookup has an entry for every supported expression token, and defines where in a template each is valid
        private Dictionary<String, List<TokenValidity>> expressionLookup = new Dictionary<string, List<TokenValidity>>();

        //_closerLookup is a collection of valid closer token names. It is used to determine if a token name beginning with / is valid
        private HashSet<string> closerLookup = new HashSet<string>();
        //_canonicalNameLookup seems lind of pointless. It seems to contain matching names for opener and closer tokens,
        //but the kay and value are always the same? I assume it isn't being used anywhere?
        private Dictionary<string, string> canonicalNameLookup = new Dictionary<string, string>();

        private List<TokenValidity> customValidity;
        private List<TokenValidity> userTokenValidity;

        private CodeGenContext context;
        private bool errorsReported = false;

        /// <summary>
        /// This constructor should be used if you're trying to do "real" tokenization. 
        /// Context is passed in so that the tokenizer is aware of user-defined tokens and custom extensions.
        /// </summary>
        /// <param name="aContext">Current code generator context.</param>
        public Tokenizer(CodeGenContext aContext)
            : this()
        {
            //For use later (error reporting during Tokenize)
            context = aContext;

            loadUserTokens();
            loadCustomExpanders();
            loadCustomEvaluators();
        }

        /// <summary>
        /// This constructor is only used unit tests that are testing the tokenization of template code
        /// that does not require the tokenization of user-defined tokens, or custom tokens or expressions.
        /// If user-token or custom extension processing is required then use the other constructor.
        /// </summary>
        public Tokenizer()
        {
            customValidity = new List<TokenValidity>();
            customValidity.Add(TokenValidity.FieldLoop);

            userTokenValidity = new List<TokenValidity>();
            userTokenValidity.Add(TokenValidity.Anywhere);

            //Declare all of the expansion tokens that we support
            List<TokenMeta> metaLookup = new List<TokenMeta>
            {
                new TokenMeta { Name = "CODEGEN_FILENAME", TypeOfToken = TokenType.FileHeader, IsPaired = true, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "PROCESS_TEMPLATE", TypeOfToken = TokenType.FileHeader, IsPaired = true, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "PROVIDE_FILE", TypeOfToken = TokenType.FileHeader, IsPaired = true, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "REQUIRES_USERTOKEN", TypeOfToken = TokenType.FileHeader, IsPaired = true, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "OPTIONAL_USERTOKEN", TypeOfToken = TokenType.FileHeader, IsPaired = true, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "REQUIRES_OPTION", TypeOfToken = TokenType.FileHeader, IsPaired = true, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "REQUIRES_CUSTOM_BUTTON_TOKEN", TypeOfToken = TokenType.FileHeader, IsPaired = true, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "REQUIRES_CUSTOM_ENUM_TOKEN", TypeOfToken = TokenType.FileHeader, IsPaired = true, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "REQUIRES_CUSTOM_ENUM_MEMBER_TOKEN", TypeOfToken = TokenType.FileHeader, IsPaired = true, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "REQUIRES_CUSTOM_FIELD_TOKEN", TypeOfToken = TokenType.FileHeader, IsPaired = true, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "REQUIRES_CUSTOM_FILE_TOKEN", TypeOfToken = TokenType.FileHeader, IsPaired = true, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "REQUIRES_CUSTOM_KEY_TOKEN", TypeOfToken = TokenType.FileHeader, IsPaired = true, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "REQUIRES_CUSTOM_RELATION_TOKEN", TypeOfToken = TokenType.FileHeader, IsPaired = true, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "REQUIRES_CUSTOM_SEGMENT_TOKEN", TypeOfToken = TokenType.FileHeader, IsPaired = true, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "REQUIRES_CUSTOM_SELECTION_TOKEN", TypeOfToken = TokenType.FileHeader, IsPaired = true, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "REQUIRES_CUSTOM_TOKEN", TypeOfToken = TokenType.FileHeader, IsPaired = true, Validity = TokenValidity.Anywhere },

                new TokenMeta { Name = "ENV", TypeOfToken = TokenType.PreProcessor, IsPaired = true, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "ENVIFEXIST", TypeOfToken = TokenType.PreProcessor, IsPaired = true, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "FILE", TypeOfToken = TokenType.PreProcessor, IsPaired = true, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "FILEIFEXIST", TypeOfToken = TokenType.PreProcessor, IsPaired = true, Validity = TokenValidity.Anywhere },

                new TokenMeta { Name = "STRUCTURE_LOOP", TypeOfToken = TokenType.Loop, IsPaired = true, Validity = TokenValidity.NotInLoop },

                new TokenMeta { Name = "FIELD_LOOP", TypeOfToken = TokenType.Loop, IsPaired = true, Validity = TokenValidity.NotInLoop|TokenValidity.StructureLoop },
                new TokenMeta { Name = "KEY_LOOP", TypeOfToken = TokenType.Loop, IsPaired = true, Validity = TokenValidity.NotInLoop|TokenValidity.StructureLoop },
                new TokenMeta { Name = "ALTERNATE_KEY_LOOP", TypeOfToken = TokenType.Loop, IsPaired = true, Validity = TokenValidity.NotInLoop|TokenValidity.StructureLoop },
                new TokenMeta { Name = "PRIMARY_KEY", TypeOfToken = TokenType.Loop, IsPaired = true, Validity = TokenValidity.NotInLoop|TokenValidity.StructureLoop },
                new TokenMeta { Name = "ENUM_LOOP", TypeOfToken = TokenType.Loop, IsPaired = true, Validity = TokenValidity.NotInLoop|TokenValidity.StructureLoop },
                new TokenMeta { Name = "ENUM_LOOP_STRUCTURE", TypeOfToken = TokenType.Loop, IsPaired = true, Validity = TokenValidity.NotInLoop|TokenValidity.StructureLoop },
                new TokenMeta { Name = "RELATION_LOOP", TypeOfToken = TokenType.Loop, IsPaired = true, Validity = TokenValidity.NotInLoop|TokenValidity.StructureLoop },
                new TokenMeta { Name = "FILE_LOOP", TypeOfToken = TokenType.Loop, IsPaired = true, Validity = TokenValidity.NotInLoop|TokenValidity.StructureLoop },
                new TokenMeta { Name = "TAG_LOOP", TypeOfToken = TokenType.Loop, IsPaired = true, Validity = TokenValidity.NotInLoop|TokenValidity.StructureLoop },
                new TokenMeta { Name = "BUTTON_LOOP", TypeOfToken = TokenType.Loop, IsPaired = true, Validity = TokenValidity.NotInLoop },

                new TokenMeta { Name = "SELECTION_LOOP", TypeOfToken = TokenType.Loop, IsPaired = true, Validity = TokenValidity.FieldLoop },
                new TokenMeta { Name = "SEGMENT_LOOP", TypeOfToken = TokenType.Loop, IsPaired = true, Validity = TokenValidity.KeyLoop },
                new TokenMeta { Name = "SEGMENT_LOOP_FILTER", TypeOfToken = TokenType.Loop, IsPaired = true, Validity = TokenValidity.KeyLoop },
                new TokenMeta { Name = "FIRST_SEGMENT", TypeOfToken = TokenType.Loop, IsPaired = true, Validity = TokenValidity.KeyLoop },
                new TokenMeta { Name = "SECOND_SEGMENT", TypeOfToken = TokenType.Loop, IsPaired = true, Validity = TokenValidity.KeyLoop },
                new TokenMeta { Name = "ENUM_MEMBER_LOOP", TypeOfToken = TokenType.Loop, IsPaired = true, Validity = TokenValidity.EnumLoop },

                new TokenMeta { Name = "AUTHOR", TypeOfToken = TokenType.Generic, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "CODEGEN_VERSION", TypeOfToken = TokenType.Generic, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "COMPANY", TypeOfToken = TokenType.Generic, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "DATE", TypeOfToken = TokenType.Generic, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "DATE1", TypeOfToken = TokenType.Generic, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "DAY", TypeOfToken = TokenType.Generic, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "FIELD_PREFIX", TypeOfToken = TokenType.Generic, IsPaired = false, Validity= TokenValidity.Anywhere },    
                new TokenMeta { Name = "GUID1", TypeOfToken = TokenType.Generic, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "GUID2", TypeOfToken = TokenType.Generic, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "GUID3", TypeOfToken = TokenType.Generic, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "MONTH", TypeOfToken = TokenType.Generic, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "MONTHNAME", TypeOfToken = TokenType.Generic, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "MONTHSHORTNAME", TypeOfToken = TokenType.Generic, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "NAMESPACE", TypeOfToken = TokenType.Generic, IsPaired = false, Validity= TokenValidity.Anywhere },
                makeCasedLimited(TokenType.Generic, TokenValidity.Anywhere, "TEMPLATE"),
                new TokenMeta { Name = "TIME", TypeOfToken = TokenType.Generic, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "WEEKDAY", TypeOfToken = TokenType.Generic, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "YEAR", TypeOfToken = TokenType.Generic, IsPaired = false, Validity= TokenValidity.Anywhere },

                new TokenMeta { Name = "DATA_FIELDS_LIST", TypeOfToken = TokenType.StructureInfo, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "DISPLAY_FIELD", TypeOfToken = TokenType.StructureInfo, IsPaired = false, Validity= TokenValidity.Anywhere },    
                new TokenMeta { Name = "FILE_ADDRESSING", TypeOfToken = TokenType.StructureInfo, IsPaired = false, Validity= TokenValidity.Anywhere },
                makeCasedLimited(TokenType.StructureInfo, TokenValidity.Anywhere, "FILE", "CHANGE", "TRACKING"),
                makeCasedLimited(TokenType.StructureInfo, TokenValidity.Anywhere, "FILE", "COMPRESSION"),
                new TokenMeta { Name = "FILE_DENSITY", TypeOfToken = TokenType.StructureInfo, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "FILE_DESC", TypeOfToken = TokenType.StructureInfo, IsPaired = false, Validity= TokenValidity.Anywhere },    
                new TokenMeta { Name = "FILE_NAME", TypeOfToken = TokenType.StructureInfo, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "FILE_NAME_NOEXT", TypeOfToken = TokenType.StructureInfo, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "FILE_PAGESIZE", TypeOfToken = TokenType.StructureInfo, IsPaired = false, Validity= TokenValidity.Anywhere },
                makeCasedLimited(TokenType.StructureInfo, TokenValidity.Anywhere, "FILE", "RECTYPE"),
                makeCasedLimited(TokenType.StructureInfo, TokenValidity.Anywhere, "FILE", "STATIC", "RFA"),
                makeCasedLimited(TokenType.StructureInfo, TokenValidity.Anywhere, "FILE", "STORED", "GRFA"),
                new TokenMeta { Name = "FILE_TYPE", TypeOfToken = TokenType.StructureInfo, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "FILE_UTEXT", TypeOfToken = TokenType.StructureInfo, IsPaired = false, Validity= TokenValidity.Anywhere },
                makeCased(TokenType.StructureInfo, TokenValidity.Anywhere, "MAPPED", "FILE"),
                makeCasedLimited(TokenType.StructureInfo, TokenValidity.Anywhere, "MAPPED", "STRUCTURE"),
                makeCased(TokenType.StructureInfo, TokenValidity.Anywhere, "PRIMARY", "KEY", "FIELD"),

                new TokenMeta { Name = "STRUCTURE_CHILDREN", TypeOfToken = TokenType.StructureInfo, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "STRUCTURE_DESC", TypeOfToken = TokenType.StructureInfo, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "STRUCTURE_FIELDS", TypeOfToken = TokenType.StructureInfo, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "STRUCTURE_KEYS", TypeOfToken = TokenType.StructureInfo, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "STRUCTURE_LDESC", TypeOfToken = TokenType.StructureInfo, IsPaired = false, Validity= TokenValidity.Anywhere },
                makeCased(TokenType.StructureInfo, TokenValidity.Anywhere, "STRUCTURE", "NAME"),
                makeCased(TokenType.StructureInfo, TokenValidity.Anywhere, "STRUCTURE", "NOALIAS"),
                new TokenMeta { Name = "STRUCTURE_SIZE", TypeOfToken = TokenType.StructureInfo, IsPaired = false, Validity= TokenValidity.Anywhere },
                new TokenMeta { Name = "STRUCTURE_UTEXT", TypeOfToken = TokenType.StructureInfo, IsPaired = false, Validity= TokenValidity.Anywhere },

                new TokenMeta { Name = ",", TypeOfToken = TokenType.LoopUtility, IsPaired = false, Validity = TokenValidity.AnyLoop },
                new TokenMeta { Name = "+", TypeOfToken = TokenType.LoopUtility, IsPaired = false, Validity = TokenValidity.AnyLoop },
                new TokenMeta { Name = ":", TypeOfToken = TokenType.LoopUtility, IsPaired = false, Validity = TokenValidity.AnyLoop },
                new TokenMeta { Name = "&&", TypeOfToken = TokenType.LoopUtility, IsPaired = false, Validity = TokenValidity.AnyLoop },
                new TokenMeta { Name = ".AND.", TypeOfToken = TokenType.LoopUtility, IsPaired = false, Validity = TokenValidity.AnyLoop },
                new TokenMeta { Name = "AND", TypeOfToken = TokenType.LoopUtility, IsPaired = false, Validity = TokenValidity.AnyLoop },
                new TokenMeta { Name = "||", TypeOfToken = TokenType.LoopUtility, IsPaired = false, Validity = TokenValidity.AnyLoop },
                new TokenMeta { Name = ".OR.", TypeOfToken = TokenType.LoopUtility, IsPaired = false, Validity = TokenValidity.AnyLoop },
                new TokenMeta { Name = "OR", TypeOfToken = TokenType.LoopUtility, IsPaired = false, Validity = TokenValidity.AnyLoop },

                new TokenMeta { Name = "FIELD#", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD#_ZERO", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD#LOGICAL", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD#LOGICAL_ZERO", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                makeCased(TokenType.FieldLoop, TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop, "FIELD", "ALTNAME"),
                makeCased(TokenType.FieldLoop, TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop, "FIELD", "ARRIVEM"),
                makeCased(TokenType.FieldLoop, TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop, "FIELD", "BASENAME"),
                new TokenMeta { Name = "FIELD_BREAK_MODE", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                makeCased(TokenType.FieldLoop, TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop, "FIELD", "CHANGEM"),
                new TokenMeta { Name = "FIELD_COL", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_CSCONVERT", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_CSDEFAULT", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_CSTYPE", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_DEFAULT", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_DESC", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_DIMENSION1_INDEX", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_DIMENSION2_INDEX", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_DIMENSION3_INDEX", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_DIMENSION4_INDEX", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                makeCased(TokenType.FieldLoop, TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop, "FIELD", "DRILLM"),
                new TokenMeta { Name = "FIELD_DRILL_PIXEL_COL", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_ELEMENT", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_ELEMENT0", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_ENUMLENGTH", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_ENUMWIDTH", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_FORMATNAME", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_HEADING", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_HELPID", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                makeCased(TokenType.FieldLoop, TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop, "FIELD", "HYPERM"),
                new TokenMeta { Name = "FIELD_INFOLINE", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_INPUT_LENGTH", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_LDESC", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                makeCased(TokenType.FieldLoop, TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop, "FIELD", "LEAVEM"),
                new TokenMeta { Name = "FIELD_MAXVALUE", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_MINVALUE", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                makeCased(TokenType.FieldLoop, TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop, "FIELD", "NAME"),
                makeCased(TokenType.FieldLoop, TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop, "FIELD", "NETNAME"),
                new TokenMeta { Name = "FIELD_NOECHO_CHAR", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_OCDEFAULT", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_OCTYPE", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                makeCased(TokenType.FieldLoop, TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop, "FIELD", "ODBCNAME"),
                makeCased(TokenType.FieldLoop, TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop, "FIELD", "ORIGINAL", "NAME"),
                makeCased(TokenType.FieldLoop, TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop, "FIELD", "PATH"),
                makeCasedLimited(TokenType.FieldLoop, TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop, "FIELD", "PATH", "CONV"),
                new TokenMeta { Name = "FIELD_PIXEL_COL", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_PIXEL_ROW", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_PIXEL_WIDTH", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_POSITION", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_POSITION_ZERO", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_PRECISION", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_PRECISION2", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_PROMPT", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_RANGE_MAX", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_RANGE_MIN", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_REGEX", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_ROW", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_SELECTIONS", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_SELECTIONS1", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_SELLENGTH", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                makeCased(TokenType.FieldLoop, TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop, "FIELD", "SELWND"),
                new TokenMeta { Name = "FIELD_SELWND_ORIGINAL", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_SIZE", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_SNDEFAULT", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_SNTYPE", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                makeCased(TokenType.FieldLoop, TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop, "FIELD", "SPEC"),
                makeFieldSqlName(TokenType.FieldLoop, TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop),
                new TokenMeta { Name = "FIELD_SQLTYPE", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_TEMPLATE", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_TKSCRIPT", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                makeCased(TokenType.FieldLoop, TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop, "FIELD", "TYPE"),
                new TokenMeta { Name = "FIELD_TYPE_NAME", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_UTEXT", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_VBDEFAULT", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "FIELD_VBTYPE", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                makeCased(TokenType.FieldLoop, TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop, "MAPPED", "FIELD"),
                makeCasedLimited(TokenType.FieldLoop, TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop, "MAPPED", "PATH"),
                makeCasedLimited(TokenType.FieldLoop, TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop, "MAPPED", "PATH", "CONV"),
                new TokenMeta { Name = "PROMPT_COL", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "PROMPT_PIXEL_COL", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "PROMPT_PIXEL_ROW", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "PROMPT_PIXEL_WIDTH", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "PROMPT_ROW", TypeOfToken = TokenType.FieldLoop, IsPaired = false, Validity = TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop },

                new TokenMeta { Name = "SELECTION_COUNT", TypeOfToken = TokenType.FieldSelectionLoop, IsPaired = false, Validity = TokenValidity.FieldSelectionLoop },
                new TokenMeta { Name = "SELECTION_NUMBER", TypeOfToken = TokenType.FieldSelectionLoop, IsPaired = false, Validity = TokenValidity.FieldSelectionLoop },
                new TokenMeta { Name = "SELECTION_TEXT", TypeOfToken = TokenType.FieldSelectionLoop, IsPaired = false, Validity = TokenValidity.FieldSelectionLoop },
                new TokenMeta { Name = "SELECTION_VALUE", TypeOfToken = TokenType.FieldSelectionLoop, IsPaired = false, Validity = TokenValidity.FieldSelectionLoop },

                new TokenMeta { Name = "KEY_CHANGES", TypeOfToken = TokenType.KeyLoop, IsPaired = false, Validity = TokenValidity.KeyLoop },
                new TokenMeta { Name = "KEY_DENSITY", TypeOfToken = TokenType.KeyLoop, IsPaired = false, Validity = TokenValidity.KeyLoop },
                new TokenMeta { Name = "KEY_DESCRIPTION", TypeOfToken = TokenType.KeyLoop, IsPaired = false, Validity = TokenValidity.KeyLoop },
                new TokenMeta { Name = "KEY_DUPLICATES", TypeOfToken = TokenType.KeyLoop, IsPaired = false, Validity = TokenValidity.KeyLoop },
                new TokenMeta { Name = "KEY_DUPLICATES_AT", TypeOfToken = TokenType.KeyLoop, IsPaired = false, Validity = TokenValidity.KeyLoop },
                new TokenMeta { Name = "KEY_LENGTH", TypeOfToken = TokenType.KeyLoop, IsPaired = false, Validity = TokenValidity.KeyLoop },
                makeCased(TokenType.KeyLoop, TokenValidity.KeyLoop, "KEY", "NAME"),
                makeCasedLimited(TokenType.KeyLoop, TokenValidity.KeyLoop, "KEY", "NULLTYPE"),
                new TokenMeta { Name = "KEY_NULLVALUE", TypeOfToken = TokenType.KeyLoop, IsPaired = false, Validity = TokenValidity.KeyLoop },
                new TokenMeta { Name = "KEY_NUMBER", TypeOfToken = TokenType.KeyLoop, IsPaired = false, Validity = TokenValidity.KeyLoop },
                new TokenMeta { Name = "KEY_ORDER", TypeOfToken = TokenType.KeyLoop, IsPaired = false, Validity = TokenValidity.KeyLoop },
                new TokenMeta { Name = "KEY_SEGMENTS", TypeOfToken = TokenType.KeyLoop, IsPaired = false, Validity = TokenValidity.KeyLoop },
                new TokenMeta { Name = "KEY_UNIQUE", TypeOfToken = TokenType.KeyLoop, IsPaired = false, Validity = TokenValidity.KeyLoop },

                new TokenMeta { Name = "SEGMENT_CSTYPE", TypeOfToken = TokenType.KeySegmentLoop, IsPaired = false, Validity = TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "SEGMENT_DESC", TypeOfToken = TokenType.KeySegmentLoop, IsPaired = false, Validity = TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "SEGMENT_IDXTYPE", TypeOfToken = TokenType.KeySegmentLoop, IsPaired = false, Validity = TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "SEGMENT_KIND", TypeOfToken = TokenType.KeySegmentLoop, IsPaired = false, Validity = TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "SEGMENT_LENGTH", TypeOfToken = TokenType.KeySegmentLoop, IsPaired = false, Validity = TokenValidity.KeySegmentLoop },
                new TokenMeta { Name = "SEGMENT_LITVAL", TypeOfToken = TokenType.KeySegmentLoop, IsPaired = false, Validity = TokenValidity.KeySegmentLoop },
                makeCased(TokenType.KeySegmentLoop, TokenValidity.KeySegmentLoop, "SEGMENT", "MAPPEDNAME"),
                makeCased(TokenType.KeySegmentLoop, TokenValidity.KeySegmentLoop, "SEGMENT", "NAME"),
                new TokenMeta { Name = "SEGMENT_NUMBER", TypeOfToken = TokenType.KeySegmentLoop, IsPaired = false, Validity = TokenValidity.KeySegmentLoop },
                makeCasedLimited(TokenType.KeySegmentLoop, TokenValidity.KeySegmentLoop, "SEGMENT", "ORDER"),
                new TokenMeta { Name = "SEGMENT_POSITION", TypeOfToken = TokenType.KeySegmentLoop, IsPaired = false, Validity = TokenValidity.KeySegmentLoop },
                makeCasedLimited(TokenType.KeySegmentLoop, TokenValidity.KeySegmentLoop, "SEGMENT", "SEQUENCE"),
                new TokenMeta { Name = "SEGMENT_SNTYPE", TypeOfToken = TokenType.KeySegmentLoop, IsPaired = false, Validity = TokenValidity.KeySegmentLoop },
                makeCasedLimited(TokenType.KeySegmentLoop, TokenValidity.KeySegmentLoop, "SEGMENT", "SPEC"),
                new TokenMeta { Name = "SEGMENT_STRUCTURE", TypeOfToken = TokenType.KeySegmentLoop, IsPaired = false, Validity = TokenValidity.KeySegmentLoop },
                makeCasedLimited(TokenType.KeySegmentLoop, TokenValidity.KeySegmentLoop, "SEGMENT", "TYPE"),
                new TokenMeta { Name = "SEGMENT_VBTYPE", TypeOfToken = TokenType.KeySegmentLoop, IsPaired = false, Validity = TokenValidity.KeySegmentLoop },

                new TokenMeta { Name = "ENUM_COUNT", TypeOfToken = TokenType.EnumLoop, IsPaired = false, Validity = TokenValidity.EnumLoop },
                new TokenMeta { Name = "ENUM_DESCRIPTION", TypeOfToken = TokenType.EnumLoop, IsPaired = false, Validity = TokenValidity.EnumLoop },
                new TokenMeta { Name = "ENUM_LONG_DESCRIPTION", TypeOfToken = TokenType.EnumLoop, IsPaired = false, Validity = TokenValidity.EnumLoop },
                new TokenMeta { Name = "ENUM_MEMBER_COUNT", TypeOfToken = TokenType.EnumLoop, IsPaired = false, Validity = TokenValidity.EnumLoop },
                makeCased(TokenType.EnumLoop, TokenValidity.EnumLoop, "ENUM", "NAME"),
                new TokenMeta { Name = "ENUM_NUMBER", TypeOfToken = TokenType.EnumLoop, IsPaired = false, Validity = TokenValidity.EnumLoop },

                makeCased(TokenType.EnumMemberLoop, TokenValidity.EnumMemberLoop, "ENUM", "MEMBER", "NAME"),
                new TokenMeta { Name = "ENUM_MEMBER_EXPLICIT_VALUE", TypeOfToken = TokenType.EnumMemberLoop, IsPaired = false, Validity = TokenValidity.EnumMemberLoop },
                new TokenMeta { Name = "ENUM_MEMBER_IMPLICIT_VALUE", TypeOfToken = TokenType.EnumMemberLoop, IsPaired = false, Validity = TokenValidity.EnumMemberLoop },

                new TokenMeta { Name = "RELATION_NUMBER", TypeOfToken = TokenType.RelationLoop, IsPaired = false, Validity = TokenValidity.RelationLoop },
                new TokenMeta { Name = "RELATION_NAME", TypeOfToken = TokenType.RelationLoop, IsPaired = false, Validity = TokenValidity.RelationLoop },
                new TokenMeta { Name = "RELATION_FROMKEY", TypeOfToken = TokenType.RelationLoop, IsPaired = false, Validity = TokenValidity.RelationLoop },
                new TokenMeta { Name = "RELATION_TOKEY", TypeOfToken = TokenType.RelationLoop, IsPaired = false, Validity = TokenValidity.RelationLoop },
                new TokenMeta { Name = "RELATION_TOSTRUCTURE", TypeOfToken = TokenType.RelationLoop, IsPaired = false, Validity = TokenValidity.RelationLoop },

                new TokenMeta { Name = "BUTTON_CAPTION", TypeOfToken = TokenType.ButtonLoop, IsPaired = false, Validity = TokenValidity.ButtonLoop },
                new TokenMeta { Name = "BUTTON_COLPX", TypeOfToken = TokenType.ButtonLoop, IsPaired = false, Validity = TokenValidity.ButtonLoop },
                new TokenMeta { Name = "BUTTON_ELB", TypeOfToken = TokenType.ButtonLoop, IsPaired = false, Validity = TokenValidity.ButtonLoop },
                new TokenMeta { Name = "BUTTON_IMAGE", TypeOfToken = TokenType.ButtonLoop, IsPaired = false, Validity = TokenValidity.ButtonLoop },
                new TokenMeta { Name = "BUTTON_METHOD", TypeOfToken = TokenType.ButtonLoop, IsPaired = false, Validity = TokenValidity.ButtonLoop },
                new TokenMeta { Name = "BUTTON_NAME", TypeOfToken = TokenType.ButtonLoop, IsPaired = false, Validity = TokenValidity.ButtonLoop },
                new TokenMeta { Name = "BUTTON_NUMBER", TypeOfToken = TokenType.ButtonLoop, IsPaired = false, Validity = TokenValidity.ButtonLoop },
                new TokenMeta { Name = "BUTTON_QUICKSELECT", TypeOfToken = TokenType.ButtonLoop, IsPaired = false, Validity = TokenValidity.ButtonLoop },
                new TokenMeta { Name = "BUTTON_ROWPX", TypeOfToken = TokenType.ButtonLoop, IsPaired = false, Validity = TokenValidity.ButtonLoop },
                new TokenMeta { Name = "BUTTON_WIDTHPX", TypeOfToken = TokenType.ButtonLoop, IsPaired = false, Validity = TokenValidity.ButtonLoop },

                new TokenMeta { Name = "FLOOP_ADDRESSING", TypeOfToken = TokenType.FileLoop, IsPaired = false, Validity = TokenValidity.FileLoop },
                makeCasedLimited(TokenType.FileLoop, TokenValidity.FileLoop, "FLOOP", "COMPRESSION"),
                makeCasedLimited(TokenType.FileLoop, TokenValidity.FileLoop, "FLOOP","CHANGE","TRACKING"),
                new TokenMeta { Name = "FLOOP_DESC", TypeOfToken = TokenType.FileLoop, IsPaired = false, Validity = TokenValidity.FileLoop },
                new TokenMeta { Name = "FLOOP_DENSITY", TypeOfToken = TokenType.FileLoop, IsPaired = false, Validity = TokenValidity.FileLoop },
                new TokenMeta { Name = "FLOOP_NAME", TypeOfToken = TokenType.FileLoop, IsPaired = false, Validity = TokenValidity.FileLoop },
                new TokenMeta { Name = "FLOOP_NAME_NOEXT", TypeOfToken = TokenType.FileLoop, IsPaired = false, Validity = TokenValidity.FileLoop },
                new TokenMeta { Name = "FLOOP_PAGESIZE", TypeOfToken = TokenType.FileLoop, IsPaired = false, Validity = TokenValidity.FileLoop },
                makeCasedLimited(TokenType.FileLoop, TokenValidity.FileLoop, "FLOOP", "RECTYPE"),
                makeCasedLimited(TokenType.FileLoop, TokenValidity.FileLoop, "FLOOP", "STATIC", "RFA"),
                makeCasedLimited(TokenType.FileLoop, TokenValidity.FileLoop, "FLOOP", "STORED", "GRFA"),
                new TokenMeta { Name = "FLOOP_TYPE", TypeOfToken = TokenType.FileLoop, IsPaired = false, Validity = TokenValidity.FileLoop },
                new TokenMeta { Name = "FLOOP_UTEXT", TypeOfToken = TokenType.FileLoop, IsPaired = false, Validity = TokenValidity.FileLoop },

                new TokenMeta { Name = "TAGLOOP_CONNECTOR_C", TypeOfToken = TokenType.TagLoop, IsPaired = false, Validity = TokenValidity.TagLoop },
                makeCasedLimited(TokenType.TagLoop, TokenValidity.TagLoop, "TAGLOOP", "CONNECTOR", "DBL"),
                makeCased(TokenType.TagLoop, TokenValidity.TagLoop, "TAGLOOP", "FIELD", "ALTNAME"),
                makeCased(TokenType.TagLoop, TokenValidity.TagLoop, "TAGLOOP", "FIELD", "BASENAME"),
                makeCased(TokenType.TagLoop, TokenValidity.TagLoop, "TAGLOOP", "FIELD", "NAME"),
                makeCased(TokenType.TagLoop, TokenValidity.TagLoop, "TAGLOOP", "FIELD", "ODBCNAME"),
                makeCased(TokenType.TagLoop, TokenValidity.TagLoop, "TAGLOOP", "FIELD", "ORIGINALNAME"),
                makeCased(TokenType.TagLoop, TokenValidity.TagLoop, "TAGLOOP", "FIELD", "SQLNAME"),
                makeCasedLimited(TokenType.TagLoop, TokenValidity.TagLoop, "TAGLOOP", "OPERATOR", "DBL"),
                new TokenMeta { Name = "TAGLOOP_OPERATOR_C", TypeOfToken = TokenType.TagLoop, IsPaired = false, Validity = TokenValidity.TagLoop },
                new TokenMeta { Name = "TAGLOOP_SEQUENCE", TypeOfToken = TokenType.TagLoop, IsPaired = false, Validity = TokenValidity.TagLoop },
                new TokenMeta { Name = "TAGLOOP_TAG_NAME", TypeOfToken = TokenType.TagLoop, IsPaired = false, Validity = TokenValidity.TagLoop },
                new TokenMeta { Name = "TAGLOOP_TAG_VALUE", TypeOfToken = TokenType.TagLoop, IsPaired = false, Validity = TokenValidity.TagLoop },

                new TokenMeta { Name = "WINDOW_HEIGHT", TypeOfToken = TokenType.Window, IsPaired = false, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "WINDOW_HEIGHTPX", TypeOfToken = TokenType.Window, IsPaired = false, Validity = TokenValidity.Anywhere },
                makeCased(TokenType.Window, TokenValidity.Anywhere, "WINDOW", "NAME"),
                new TokenMeta { Name = "WINDOW_WIDTH", TypeOfToken = TokenType.Window, IsPaired = false, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "WINDOW_WIDTHPX", TypeOfToken = TokenType.Window, IsPaired = false, Validity = TokenValidity.Anywhere },

                new TokenMeta { Name = "COUNTER_1_INCREMENT", TypeOfToken = TokenType.CounterInstruction, IsPaired = false, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "COUNTER_1_DECREMENT", TypeOfToken = TokenType.CounterInstruction, IsPaired = false, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "COUNTER_1_RESET", TypeOfToken = TokenType.CounterInstruction, IsPaired = false, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "COUNTER_1_VALUE", TypeOfToken = TokenType.Counter, IsPaired = false, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "COUNTER_2_INCREMENT", TypeOfToken = TokenType.CounterInstruction, IsPaired = false, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "COUNTER_2_DECREMENT", TypeOfToken = TokenType.CounterInstruction, IsPaired = false, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "COUNTER_2_RESET", TypeOfToken = TokenType.CounterInstruction, IsPaired = false, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "COUNTER_2_VALUE", TypeOfToken = TokenType.Counter, IsPaired = false, Validity = TokenValidity.Anywhere },

                new TokenMeta { Name = "IF", TypeOfToken = TokenType.Control, IsPaired = true, Validity = TokenValidity.Anywhere },
                new TokenMeta { Name = "ELSE", TypeOfToken = TokenType.Control, IsPaired = true, Validity = TokenValidity.Anywhere },

                new TokenMeta { Name = "STRUCTURE#1", TypeOfToken = TokenType.NotInLoop, IsPaired = false, Validity = TokenValidity.NotInLoop},
                new TokenMeta { Name = "STRUCTURE#2", TypeOfToken = TokenType.NotInLoop, IsPaired = false, Validity = TokenValidity.NotInLoop},
                new TokenMeta { Name = "STRUCTURE#3", TypeOfToken = TokenType.NotInLoop, IsPaired = false, Validity = TokenValidity.NotInLoop},
                new TokenMeta { Name = "STRUCTURE#4", TypeOfToken = TokenType.NotInLoop, IsPaired = false, Validity = TokenValidity.NotInLoop},
                new TokenMeta { Name = "STRUCTURE#5", TypeOfToken = TokenType.NotInLoop, IsPaired = false, Validity = TokenValidity.NotInLoop}
            };

            //Now process each of the replacement tokens that we have defined, adding them to our various lookup collections

            foreach (TokenMeta tokenMeta in metaLookup)
            {
                addLookupToken(tokenMeta);
            }

            //This lambda processes the Dictionary of expression tokens declared below into the _expresionLookup collection.
            //It is required because the declaration of expressions can a include bitwise OR of multiple valid TokenValidity
            //settings. The lambda parses those out into a List<TokenVisibility> for ease of use elsewhere.

            Func<Dictionary<string, TokenValidity>, Dictionary<string, List<TokenValidity>>> expressionLookupHelper = (initial) =>
            {
                Dictionary<string, List<TokenValidity>> result = new Dictionary<string, List<TokenValidity>>();

                foreach (KeyValuePair<string, TokenValidity> exprTpl in initial)
                {
                    List<TokenValidity> expressionTypes = new List<TokenValidity>();
                    foreach (Enum enumValue in Enum.GetValues(exprTpl.Value.GetType()))
                        if (exprTpl.Value.HasFlag(enumValue))
                            expressionTypes.Add((TokenValidity)enumValue);

                    result.Add(exprTpl.Key, expressionTypes);
                }
                return result;
            };

            //Declare all of the expression tokens that we support. Multiple TokenValidity options can
            //be specified by bitwair ORing the values together. See the notes on the expressionLookupHelper
            //lambda above.

            Dictionary<string, TokenValidity> expressions = new Dictionary<string, TokenValidity>();

            expressions.Add("ALLOW_LIST", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("ALPHA", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("ALTERNATE_NAME", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("ARRAY", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("ARRAY1", TokenValidity.FieldLoop);
            expressions.Add("ARRAY2", TokenValidity.FieldLoop);
            expressions.Add("ARRAY3", TokenValidity.FieldLoop);
            expressions.Add("ARRAY4", TokenValidity.FieldLoop);
            expressions.Add("ARRIVE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("ASCENDING", TokenValidity.KeyLoop);
            expressions.Add("ASCII", TokenValidity.FileLoop);
            expressions.Add("AUTO_SEQUENCE", TokenValidity.KeyLoop);
            expressions.Add("AUTO_TIMESTAMP", TokenValidity.KeyLoop);
            expressions.Add("BINARY", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("BOLD", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("BOOLEAN", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("BREAK", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("BREAK_ALWAYS", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("BREAK_CHANGE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("BREAK_RETURN", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("BZERO", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("CANCEL_BUTTON", TokenValidity.ButtonLoop);
            expressions.Add("CANCELBUTTON", TokenValidity.ButtonLoop);
            expressions.Add("CAPTION", TokenValidity.ButtonLoop);
            expressions.Add("CHANGE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("CHANGE_TRACKING", TokenValidity.FileLoop);
            expressions.Add("CHANGES", TokenValidity.KeyLoop);
            expressions.Add("CHECKBOX", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("COERCEBOOLEAN", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("COMBOBOX", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("COMPARISON_EQ", TokenValidity.TagLoop);
            expressions.Add("COMPARISON_GE", TokenValidity.TagLoop);
            expressions.Add("COMPARISON_GT", TokenValidity.TagLoop);
            expressions.Add("COMPARISON_LE", TokenValidity.TagLoop);
            expressions.Add("COMPARISON_LT", TokenValidity.TagLoop);
            expressions.Add("COMPARISON_NE", TokenValidity.TagLoop);
            expressions.Add("COMPARISON_NOT_EQ", TokenValidity.TagLoop);
            expressions.Add("COMPARISON_NOT_GE", TokenValidity.TagLoop);
            expressions.Add("COMPARISON_NOT_GT", TokenValidity.TagLoop);
            expressions.Add("COMPARISON_NOT_LE", TokenValidity.TagLoop);
            expressions.Add("COMPARISON_NOT_LT", TokenValidity.TagLoop);
            expressions.Add("COMPARISON_NOT_NE", TokenValidity.TagLoop);
            expressions.Add("CONNECTOR_AND", TokenValidity.TagLoop);
            expressions.Add("CONNECTOR_NONE", TokenValidity.TagLoop);
            expressions.Add("CONNECTOR_NOT_AND", TokenValidity.TagLoop);
            expressions.Add("CONNECTOR_NOT_NONE", TokenValidity.TagLoop);
            expressions.Add("CONNECTOR_NOT_OR", TokenValidity.TagLoop);
            expressions.Add("CONNECTOR_OR", TokenValidity.TagLoop);
            expressions.Add("COUNTER_1", TokenValidity.Anywhere);
            expressions.Add("COUNTER_2", TokenValidity.Anywhere);
            expressions.Add("CUSTOM_", TokenValidity.FieldLoop);
            expressions.Add("CUSTOM_NOT_", TokenValidity.FieldLoop);
            expressions.Add("DATE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DATE_JULIAN", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DATE_NOT_JULIAN", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DATE_NOT_NULLABLE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DATE_NOT_PERIOD", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DATE_NOT_YMD", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DATE_NOT_YYYYMMDD", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DATE_NULLABLE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DATE_PERIOD", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DATE_YMD", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DATE_YYJJJ", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DATE_YYMMDD", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DATE_YYPP", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DATE_YYYYJJJ", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DATE_YYYYMMDD", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DATE_YYYYPP", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DATEORTIME", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DATETODAY", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DECIMAL", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DEFAULT", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DESCENDING", TokenValidity.KeyLoop);
            expressions.Add("DESCRIPTION", TokenValidity.FieldLoop | TokenValidity.EnumLoop | TokenValidity.FileLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DISABLED", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DISPLAY", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DISPLAY_LENGTH", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DRILL", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("DUPLICATES", TokenValidity.KeyLoop);
            expressions.Add("DUPLICATESATFRONT", TokenValidity.KeyLoop);
            expressions.Add("DUPLICATESATEND", TokenValidity.KeyLoop);
            expressions.Add("ECHO", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("EDITFORMAT", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("ELB", TokenValidity.ButtonLoop);
            expressions.Add("ENABLED", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("ENUM", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("ENUMERATED", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("EXPLICIT_VALUE", TokenValidity.EnumMemberLoop);
            expressions.Add("FIELD_POSITION", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("FIRST", TokenValidity.FieldLoop | TokenValidity.FieldSelectionLoop | TokenValidity.ButtonLoop | TokenValidity.EnumLoop | TokenValidity.EnumMemberLoop | TokenValidity.FileLoop | TokenValidity.KeyLoop | TokenValidity.TagLoop);
            expressions.Add("FORMAT", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("GENERICBUTTON", TokenValidity.ButtonLoop);
            expressions.Add("GROUP_EXPAND", TokenValidity.FieldLoop);
            expressions.Add("GROUP_NO_EXPAND", TokenValidity.FieldLoop);
            expressions.Add("HEADING", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("HELPID", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("HYPERLINK", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("I1", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("I124", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("I2", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("I4", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("I8", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("IMAGE", TokenValidity.ButtonLoop);
            expressions.Add("INCREMENT", TokenValidity.KeySegmentLoop);
            expressions.Add("INFOLINE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop | TokenValidity.FieldSelectionLoop);
            expressions.Add("INPUT_CENTER", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("INPUT_LEFT", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("INPUT_RIGHT", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("INTEGER", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("ISAM", TokenValidity.FileLoop);
            expressions.Add("LANGUAGE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("LAST", TokenValidity.FieldLoop | TokenValidity.FieldSelectionLoop | TokenValidity.TagLoop);
            expressions.Add("LEAVE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("LONG_DESCRIPTION", TokenValidity.EnumLoop);
            expressions.Add("LONGDESC", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("MAPPED", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("MAPPEDSTR", TokenValidity.FieldLoop);
            expressions.Add("METHOD", TokenValidity.ButtonLoop);
            expressions.Add("MORE", TokenValidity.AnyLoop);
            expressions.Add("MULTIPLE_SEGMENTS", TokenValidity.KeyLoop);
            expressions.Add("MULTIPLE_TAGS", TokenValidity.TagLoop);
            expressions.Add("NEGATIVE_ALLOWED", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NEGATIVE_ORZERO", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NEGATIVE_REQUIRED", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOALLOW_LIST", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOALTERNATE_NAME", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOARRIVE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOBREAK", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOCHANGE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOCHANGE_TRACKING", TokenValidity.FileLoop);
            expressions.Add("NOCHANGES", TokenValidity.KeyLoop);
            expressions.Add("NOCHECKBOX", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOCOERCEBOOLEAN", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NODEFAULT", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NODESCRIPTION", TokenValidity.FieldLoop | TokenValidity.FileLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NODISPLAY", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NODISPLAY_LENGTH", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NODRILL", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NODUPLICATES", TokenValidity.KeyLoop);
            expressions.Add("NOECHO", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOEDITFORMAT", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOEXPLICIT_VALUE", TokenValidity.EnumMemberLoop);
            expressions.Add("NOFORMAT", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOHELPID", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOHYPERLINK", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOINCREMENT", TokenValidity.KeySegmentLoop);
            expressions.Add("NOINFOLINE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOLANGUAGE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOLEAVE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOLONGDESC", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOMORE", TokenValidity.AnyLoop);
            expressions.Add("NONEGATIVE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOPAINTCHAR", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOPRECISION", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOPROMPT", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NORANGE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NORECORDCOMPRESSION", TokenValidity.FileLoop);
            expressions.Add("NOREPORT", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOSELECTIONS", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOSELWND", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOSTORED_GRFA", TokenValidity.FileLoop);
            expressions.Add("NOT_COUNTER_1", TokenValidity.Anywhere);
            expressions.Add("NOT_COUNTER_2", TokenValidity.Anywhere);
            expressions.Add("NOT_USERTOKEN_", TokenValidity.Anywhere);
            expressions.Add("NOTALPHA", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOTARRAY", TokenValidity.FieldLoop);
            expressions.Add("NOTASCII", TokenValidity.FileLoop);
            expressions.Add("NOTBINARY", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOTBOOLEAN", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOTBZERO", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOTDATE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOTDATEORTIME", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOTDATETODAY", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOTDECIMAL", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOTENUM", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOTENUMERATED", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOTIMEOUT", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOTINTEGER", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOTISAM", TokenValidity.FileLoop);
            expressions.Add("NOTNUMERIC", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOTOOLKIT", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOTOVERLAY", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOTPKSEGMENT", TokenValidity.FieldLoop);
            expressions.Add("NOTRADIOBUTTONS", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOTRECORDTYPEFIXED", TokenValidity.FileLoop);
            expressions.Add("NOTRECORDTYPEMULTIPLE", TokenValidity.FileLoop);
            expressions.Add("NOTRECORDTYPEVARIABLE", TokenValidity.FileLoop);
            expressions.Add("NOTRELATIVE", TokenValidity.FileLoop);
            expressions.Add("NOTSTATICRFA", TokenValidity.FileLoop);
            expressions.Add("NOTSTRUCTFIELD", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOTTERABYTE", TokenValidity.FileLoop);
            expressions.Add("NOTTIME", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOTUPPERCASE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOTUSER", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOTUSERDEFINED", TokenValidity.FileLoop);
            expressions.Add("NOTUSERTIMESTAMP", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOUSERTEXT", TokenValidity.FieldLoop | TokenValidity.FileLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOVIEW_LENGTH", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NOWEB", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("NULLKEY", TokenValidity.KeyLoop);
            expressions.Add("NULLVALUE", TokenValidity.KeyLoop);
            expressions.Add("NUMERIC", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("OCNATIVE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("OCOBJECT", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("OKBUTTON", TokenValidity.ButtonLoop);
            expressions.Add("OPTIONAL", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("OVERLAY", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("PAGESIZE1024", TokenValidity.FileLoop);
            expressions.Add("PAGESIZE16384", TokenValidity.FileLoop);
            expressions.Add("PAGESIZE2048", TokenValidity.FileLoop);
            expressions.Add("PAGESIZE32768", TokenValidity.FileLoop);
            expressions.Add("PAGESIZE4096", TokenValidity.FileLoop);
            expressions.Add("PAGESIZE8192", TokenValidity.FileLoop);
            expressions.Add("PAGESIZE512", TokenValidity.FileLoop);
            expressions.Add("PAINTCHAR", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("PKSEGMENT", TokenValidity.FieldLoop);
            expressions.Add("PRECISION", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("PROMPT", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("PROMPT_POSITION", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("QUICKSELECT", TokenValidity.ButtonLoop);
            expressions.Add("RADIOBUTTONS", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("RANGE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("READONLY", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("READWRITE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("RECORDCOMPRESSION", TokenValidity.FileLoop);
            expressions.Add("RECORDTYPEFIXED", TokenValidity.FileLoop);
            expressions.Add("RECORDTYPEMULTIPLE", TokenValidity.FileLoop);
            expressions.Add("RECORDTYPEVARIABLE", TokenValidity.FileLoop);
            expressions.Add("RELATIVE", TokenValidity.FileLoop);
            expressions.Add("REPORT", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("REPORT_CENTER", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("REPORT_LEFT", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("REPORT_RIGHT", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("REQUIRED", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("REVERSE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("SEG_ALPHA", TokenValidity.KeySegmentLoop);
            expressions.Add("SEG_ASCENDING", TokenValidity.KeySegmentLoop);
            expressions.Add("SEG_AUTO_SEQUENCE", TokenValidity.KeySegmentLoop);
            expressions.Add("SEG_AUTO_TIMESTAMP", TokenValidity.KeySegmentLoop);
            expressions.Add("SEG_DECIMAL", TokenValidity.KeySegmentLoop);
            expressions.Add("SEG_DESCENDING", TokenValidity.KeySegmentLoop);
            expressions.Add("SEG_NOCASE", TokenValidity.KeySegmentLoop);
            expressions.Add("SEG_SIGNED", TokenValidity.KeySegmentLoop);
            expressions.Add("SEG_TYPE_EXTERNAL", TokenValidity.KeySegmentLoop);
            expressions.Add("SEG_TYPE_FIELD", TokenValidity.KeySegmentLoop);
            expressions.Add("SEG_TYPE_LITERAL", TokenValidity.KeySegmentLoop);
            expressions.Add("SEG_TYPE_RECNUM", TokenValidity.KeySegmentLoop);
            expressions.Add("SEG_UNSIGNED", TokenValidity.KeySegmentLoop);
            expressions.Add("SELECTIONS", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("SELWND", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("SINGLE_SEGMENT", TokenValidity.KeyLoop);
            expressions.Add("SINGLE_TAG", TokenValidity.TagLoop);
            expressions.Add("STATICRFA", TokenValidity.FileLoop);
            expressions.Add("STORED_GRFA", TokenValidity.FileLoop);
            expressions.Add("STRUCTFIELD", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("TERABYTE", TokenValidity.FileLoop);
            expressions.Add("TEXTBOX", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("TIME", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("TIME_HHMM", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("TIME_HHMMSS", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("TIMENOW", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("TIMEOUT", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("TOOLKIT", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("UNDERLINE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("UPPERCASE", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("USER", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("USERDEFINED", TokenValidity.FileLoop);
            expressions.Add("USERTEXT", TokenValidity.FieldLoop | TokenValidity.FileLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("USERTIMESTAMP", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("USERTOKEN_", TokenValidity.Anywhere);
            expressions.Add("VIEW_LENGTH", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("WEB", TokenValidity.FieldLoop | TokenValidity.KeySegmentLoop);
            expressions.Add("STRUCTURE_LDESC", TokenValidity.Anywhere);

            expressionLookup = expressionLookupHelper(expressions);

        }

        /// <summary>
        /// This method takes the declaration of an expansion token and registers the token into
        /// the lookup tables that are used to process supported token variations and validate the
        /// location of tokens.
        /// </summary>
        /// <param name="meta">Token metadata object</param>
        private void addLookupToken(TokenMeta meta)
        {
            if (meta.Modifiers.Count == 0)
                modifierLookup.Add(meta.Name, TokenModifier.None);
            else
            {
                foreach (KeyValuePair<string, TokenModifier> modifier in meta.Modifiers)
                {
                    modifierLookup.Add(modifier.Key, modifier.Value);
                    if (modifier.Value == TokenModifier.PascalCase)
                    {
                        string upperName = modifier.Key.ToUpper();
                        if (upperName != meta.Name)
                        {
                            typeLookup.Add(upperName, meta.TypeOfToken);
                            canonicalNameLookup.Add(upperName, meta.Name);
                        }
                    }
                }
            }

            validityLookup.Add(meta.Name, meta.SeperatedValidity);

            typeLookup.Add(meta.Name, meta.TypeOfToken);
            canonicalNameLookup.Add(meta.Name, meta.Name);

            //If this is a paired token then add the closer to the closer lookup table
            if (meta.IsPaired)
            {
                closerLookup.Add(meta.Name);
            }
        }

        private string metaUpper(string name)
        {
            return name.ToUpper();
        }

        private string metaLower(string name)
        {
            return name;
        }

        private string metaMixed(string name)
        {
            return name.First().ToString().ToUpper() + String.Join("", name.Skip(1));
        }

        private string metaXf(string name, int index)
        {
            if (index == 0)
                return name.First().ToString().ToUpper() + String.Join("", name.Skip(1));
            else
                return name;
        }

        private string metaPascal(string name)
        {
            return name.First().ToString().ToUpper() + String.Join("", name.Skip(1));
        }

        private string metaCamel(string name, int index)
        {
            if (index > 0)
                return name.First().ToString().ToUpper() + String.Join("", name.Skip(1));
            else
                return name;
        }

        //TODO: This overload is a workaround for a Synergy .NET compiler bug with params arguments
        private TokenMeta makeCased(TokenType aType, TokenValidity aValidity, string aPart1)
        {
            return makeCased(aType, aValidity, new string[] { aPart1 });
        }

        //TODO: This overload is a workaround for a Synergy .NET compiler bug with params arguments
        private TokenMeta makeCased(TokenType aType, TokenValidity aValidity, string aPart1, string aPart2)
        {
            return makeCased(aType, aValidity, new string[] { aPart1, aPart2 });
        }

        //TODO: This overload is a workaround for a Synergy .NET compiler bug with params arguments
        private TokenMeta makeCased(TokenType aType, TokenValidity aValidity, string aPart1, string aPart2, string aPart3)
        {
            return makeCased(aType, aValidity, new string[] { aPart1, aPart2, aPart3 });
        }

        //TODO: This overload is a workaround for a Synergy .NET compiler bug with params arguments
        private TokenMeta makeCased(TokenType aType, TokenValidity aValidity, string aPart1, string aPart2, string aPart3, string aPart4)
        {
            return makeCased(aType, aValidity, new string[] { aPart1, aPart2, aPart3, aPart4 });
        }

        /// <summary>
        /// This method makes a new TokenMeta object for a token that supports all case variation options.
        /// </summary>
        /// <param name="aType">Token type</param>
        /// <param name="aValidity">Token validity</param>
        /// <param name="aParts">Parts of token name (e.g. "FIELD_NAME" should be passed as "FIELD", "NAME")</param>
        /// <returns>TokenMeta object</returns>
        private TokenMeta makeCased(TokenType aType, TokenValidity aValidity, params string[] aParts)
        {
            List<string> lowerCaseParts = aParts.Select(str => str.ToLower()).ToList();
            List<string> upperCaseParts = aParts.Select(str => str.ToUpper()).ToList();
            string upperCase = string.Join("_", lowerCaseParts.Select(metaUpper));
            string lowerCase = string.Join("_", lowerCaseParts.Select(metaLower));
            string mixedCase = string.Join("_", lowerCaseParts.Select(metaMixed));
            string xfCase = string.Join("_", lowerCaseParts.Select(metaXf));
            string pascalCase = string.Join("", lowerCaseParts.Select(metaPascal));
            string camelCase = string.Join("", lowerCaseParts.Select(metaCamel));

            TokenMeta result = new TokenMeta();
            result.TypeOfToken = aType;
            result.Name = string.Join("_", upperCaseParts);
            result.Modifiers = new Dictionary<string, TokenModifier>();
            result.Modifiers.Add(upperCase, TokenModifier.None);
            result.Modifiers.Add(lowerCase, TokenModifier.LowerCase);
            result.Modifiers.Add(pascalCase, TokenModifier.PascalCase);
            if (aParts.Length > 1)
            {
                result.Modifiers.Add(xfCase, TokenModifier.XfCase);
                result.Modifiers.Add(mixedCase, TokenModifier.MixedCase);
                result.Modifiers.Add(camelCase, TokenModifier.CamelCase);
            }
            result.Validity = aValidity;

            return result;
        }

        private TokenMeta makeFieldSqlName(TokenType aType, TokenValidity aValidity)
        {
            //Had to hard code this one because the token does not follow usual rules!!!
            TokenMeta result = new TokenMeta();
            result.TypeOfToken = aType;
            result.Name = "FIELD_SQLNAME";
            result.Modifiers = new Dictionary<string, TokenModifier>();
            result.Modifiers.Add("FIELD_SQLNAME", TokenModifier.None);
            result.Modifiers.Add("field_sqlname", TokenModifier.LowerCase);
            result.Modifiers.Add("Field_Sqlname", TokenModifier.MixedCase);
            result.Modifiers.Add("Field_sqlname", TokenModifier.XfCase);
            result.Modifiers.Add("FieldSqlName", TokenModifier.PascalCase);
            result.Modifiers.Add("fieldSqlName", TokenModifier.CamelCase);
            result.Validity = aValidity;
            return result;
        }

        //TODO: These overloads are a workaround to a Synergy .NET compiler bug with params arguments

        private TokenMeta makeCasedLimited(TokenType aType, TokenValidity aValidity, string part1)
        {
            return makeCasedLimited(aType, aValidity, new string[] { part1 });
        }

        private TokenMeta makeCasedLimited(TokenType aType, TokenValidity aValidity, string part1, string part2)
        {
            return makeCasedLimited(aType, aValidity, new string[] { part1, part2 });
        }

        private TokenMeta makeCasedLimited(TokenType aType, TokenValidity aValidity, string part1, string part2, string part3)
        {
            return makeCasedLimited(aType, aValidity, new string[] { part1, part2, part3 });
        }

        private TokenMeta makeCasedLimited(TokenType aType, TokenValidity aValidity, string part1, string part2, string part3, string part4)
        {
            return makeCasedLimited(aType, aValidity, new string[] { part1, part2, part3, part4 });
        }

        /// <summary>
        /// This method makes a new TokenMeta object for a token that supports only upper and lower case variation options.
        /// </summary>
        /// <param name="aType">Token type</param>
        /// <param name="aValidity">Token validity</param>
        /// <param name="aParts">Parts of token name (e.g. "FIELD_NAME" should be passed as "FIELD", "NAME")</param>
        /// <returns>TokenMeta object</returns>
        private TokenMeta makeCasedLimited(TokenType aType, TokenValidity aValidity, params string[] aParts)
        {
            List<string> lowerCaseParts = aParts.Select(str => str.ToLower()).ToList();
            List<string> upperCaseParts = aParts.Select(str => str.ToUpper()).ToList();
            string upperCase = string.Join("_", lowerCaseParts.Select(metaUpper));
            string lowerCase = string.Join("_", lowerCaseParts.Select(metaLower));

            TokenMeta result = new TokenMeta();
            result.TypeOfToken = aType;
            result.Name = string.Join("_", upperCaseParts);
            result.Modifiers = new Dictionary<string, TokenModifier>();
            result.Modifiers.Add(upperCase, TokenModifier.None);
            result.Modifiers.Add(lowerCase, TokenModifier.LowerCase);
            result.Validity = aValidity;
            return result;
        }

        /// <summary>
        /// Expands Synergy logical names in a path specification.
        /// </summary>
        /// <param name="path">Path that may or may not contain Synergy logical name specifications.</param>
        /// <returns>Path with logical name specifications expanded</returns>
        private string expandLogicals(String path)
        {
            string newPath = path;
            if (FileTools.ExpandLogicalName(ref newPath))
                return newPath;
            else
                throw new ApplicationException(String.Format("Failed to expand logical names in {0}", path));
        }

        /// <summary>
        /// This method is used to process pre-processor tokens, the resulting value of which could contain
        /// other tokens. First the "value" associated with the token is obtained (from a file or environment
        /// variable) and then that value is tokenized. The resulting tokens become part of the overall
        /// token stream for the template file.
        /// </summary>
        /// <param name="initialToken">Value of pre-processor token (e.g. FILE:name.ext)</param>
        /// <returns>Collection of tokens</returns>
        private List<Token> tokenizePreProcessorToken(string initialToken)
        {
            //initialToken will contain one of:
            //  ENV:envvar
            //  ENVIFEXIST:data
            //  FILE:filespec
            //  FILEIFEXIST:filespec

            string token = initialToken.Substring(0, initialToken.IndexOf(":"));
            string data = initialToken.Replace(token + ":", "");
            string filespec;
            List<Token> tokens = new List<Token>();

            switch (token)
            {
                case "FILE":
                    filespec = expandLogicals(data);
                    try
                    {
                        tokens = Tokenize(filespec);
                    }
                    catch (Exception)
                    {
                        throw new ApplicationException(String.Format("Failed to read file {0} while processing a the token <{1}>", filespec, initialToken));
                    }
                    break;

                case "FILEIFEXIST":
                    try
                    {
                        filespec = expandLogicals(data);
                        if (File.Exists(filespec))
                            tokens = Tokenize(filespec);
                    }
                    catch (Exception)
                    {
                        //That's OK, there was a problem expanding a logical, so we treat it as "file not found" for this token.
                    }
                    break;

                case "ENV":
                    if (Environment.GetEnvironmentVariable(data) == null)
                        throw new ApplicationException(String.Format("Token <ENV:{0}> requires that environment variable {1} is defined!", data, data));
                    tokens = Tokenize(Environment.GetEnvironmentVariable(data));
                    break;

                case "ENVIFEXIST":
                    if (!string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable(data)))
                        tokens = Tokenize(Environment.GetEnvironmentVariable(data));
                    break;
            }
            return tokens;
        }

        /// <summary>
        /// This is the Tokenize method that is used by GodeGenerator
        /// </summary>
        /// <param name="tokens"></param>
        /// <returns></returns>
        public bool TokenizeCurrentTemplate(out List<Token> tokens)
        {
            tokens = Tokenize(context.CurrentTemplate);
            return (!errorsReported);
        }

        private void reportError(string message)
        {
            if (context != null)
                context.CurrentTask.ErrorLog(message);
            else
                throw new ApplicationException(message);
            errorsReported = true;
        }

        /// <summary>
        /// This is the main entry point to the functionality of this class. The method can be called
        /// with a string that contains either a full file specification, or just one or more tokens.
        /// If the passed value is found to be a file then the content of the file is read and
        /// tokenized. If the passed value is not found to be a file spec then the value is tokenized. 
        /// </summary>
        /// <param name="fileSpecOrTemplateCode">Full path to a template file, or a string to be tokenized.</param>
        /// <returns>Collection of tokens</returns>
        public List<Token> Tokenize(string fileSpecOrTemplateCode)
        {
            string text;
            string fileName;

            //If we were passed a file spec then we'll try to read data from it. Otherwise we were just passed text
            //that will be injected into the template code stream, e.g. from an <ENV:text> token.
            if (File.Exists(fileSpecOrTemplateCode))
            {
                //We have a file spec, read template code from the file
                try
                {
                    text = File.ReadAllText(fileSpecOrTemplateCode);
                    fileName = fileSpecOrTemplateCode;
                }
                catch (Exception ex)
                {
                    reportError(String.Format("Failed to read file {0}. Error was {1}", fileSpecOrTemplateCode, ex.Message));
                    return null;
                }
            }
            else
            {
                text = fileSpecOrTemplateCode;
                fileName = "";
            }

            int[] lineStarts = buildLineStarts(text);
            List<Token> result = new List<Token>();

            for (int i = 0; i < text.Length; )
            {
                PossibleToken nextToken = nextPossibleToken(i, text);

                if (nextToken == null)
                {
                    //There was no next token, so add the remaining data as a final Text token
                    result.Add(new Token(fileName, i, text.Length, false, text.Substring(i), TokenType.Text, TokenModifier.None, null, lineStarts));
                    break;
                }
                else
                {
                    //Remove the <> parts, and an uppercase copy without any leading /
                    string nextTokenValue = text.Substring(nextToken.StartIndex + 1, (nextToken.EndIndex - 1) - (nextToken.StartIndex));
                    string nextTokenValueUpper = nextTokenValue.ToUpper().TrimStart('/');

                    //Is the token a closer?
                    bool closer = nextTokenValue.StartsWith("/");

                    //The next token isn't here, so we have just text. Add a Text token.
                    if (nextToken.StartIndex != i)
                        result.Add(new Token(fileName, i, nextToken.StartIndex - 1, false, text.Substring(i, nextToken.StartIndex - i), TokenType.Text, TokenModifier.None, null, lineStarts));

                    if (nextToken.Comment)
                    {
                        //It's a template file comment. Ignore it!
                    }
                    else if (nextToken.Preprocessor)
                    {
                        //It's a pre-processor token. Tokenize it's "content".
                        try
                        {
                            result.AddRange(tokenizePreProcessorToken(nextTokenValue));
                        }
                        catch (ApplicationException ex)
                        {
                            reportError(ex.Message);
                            return null;
                        }
                    }
                    else
                    {
                        //It's just a token (it's already been validated by nextPossibleToken)
                        string cannonicalExpressionValue = canonicalNameLookup[nextTokenValueUpper];
                        result.Add(new Token(fileName, nextToken.StartIndex, nextToken.EndIndex, closer, cannonicalExpressionValue,
                            typeLookup[nextTokenValueUpper], modifierLookup[nextTokenValue.TrimStart('/')],
                            validityLookup[cannonicalExpressionValue], lineStarts));
                    }

                    i = nextToken.EndIndex + 1;

                    if (nextToken.Expression)
                    {
                        Tuple<int, int, List<TokenValidity>> nextExpression = nextExpressionToken(i, text);
                        if (nextExpression != null)
                        {
                            string expressionValue = text.Substring(nextExpression.Item1, nextExpression.Item2 - nextExpression.Item1);
                            result.Add(new Token(fileName, nextExpression.Item1, nextExpression.Item2, false, expressionValue, TokenType.Expression, TokenModifier.None, nextExpression.Item3, lineStarts));
                            i = nextExpression.Item2 + 1;
                        }
                    }
                }
            }
            return result;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="text"></param>
        /// <returns></returns>
        private static int[] buildLineStarts(string text)
        {
            List<int> lineStarts = new List<int>();
            lineStarts.Add(0);

            for (int i = 0; i < text.Length; i++)
            {
                if ((text[i] == '\r' && text.Length > i + 1 && text[i + 1] == '\n') || text[i] == '\n')
                {
                    if (text[i] == '\n')
                    {
                        lineStarts.Add(i + 1);
                    }
                    else
                    {
                        lineStarts.Add(i + 2);
                        i++;
                    }
                }
            }
            return lineStarts.ToArray();
        }

        private class PossibleToken
        {
            public int StartIndex;
            public int EndIndex;
            public bool Closer;
            public bool Expression;
            public bool Comment;
            public bool Preprocessor;

            public PossibleToken(int aStartIndex, int aEndIndex, bool aCloser, bool aExpression, bool aComment, bool aPreprocessor)
            {
                StartIndex = aStartIndex;
                EndIndex = aEndIndex;
                Closer = aCloser;
                Expression = aExpression;
                Comment = aComment;
                Preprocessor = aPreprocessor;
            }
        }

        private PossibleToken nextPossibleToken(int startIndex, string text)
        {
            bool startedBracket = false;
            bool closer = false;
            bool comment = false;
            bool expression = false;
            int startedBracketIndex = -1;

            //Character by character looking for a token
            for (int i = startIndex; i < text.Length; i++)
            {
                //Did we find a newline?
                bool newLine = ((text[i] == '\r' && text.Length > i + 1 && text[i + 1] == '\n') || text[i] == '\n');

                //Did we find the start of a template file comment (;//)?
                if (text.Length > i + 2 && text[i] == ';' && text[i + 1] == '/' && text[i + 2] == '/')
                {
                    startedBracketIndex = i;
                    comment = true;
                }
                else if (comment && newLine)
                {
                    //We found the END of a template file comment
                    if (text[i] == '\r' && text.Length > i + 1 && text[i + 1] == '\n')
                        i++;
                    return new PossibleToken(startedBracketIndex, i, false, false, true, false);
                }
                else if (comment)
                {
                    //We're looking for the newline at the end of a comment and didn't find it.
                    //Move on to the next character.
                    continue;
                }
                else if (!startedBracket)   //Did we already find an < earlier?
                {
                    //No, do we have one now?
                    if (text[i] == '<')
                    {
                        //Yes, this MIGHT be the start of a token
                        closer = false;
                        startedBracket = true;
                        startedBracketIndex = i;
                    }
                }
                else //(if startedBracket)
                {
                    //We previously found < and are winding forward to figure out what it is

                    //Did we find the end of a possible token?
                    //Or a space MIGHT indicate an expression

                    if (text[i] == '/' && i - startedBracketIndex == 1)
                    {
                        //It's a / and it's next to the <. so it's a possible closer token
                        closer = true;
                    }
                    else if (char.IsControl(text[i]))
                    {
                        //It's a control character, so the token we were looking at can't be a token
                        startedBracket = false;
                        startedBracketIndex = -1;
                        expression = false;
                    }
                    else if (text[i] == '>' || text[i] == ' ')
                    {
                        //So we found a > or a space after an <

                        //For it to be a POSSIBLE expression the previous two characters need to be IF
                        if ((text[i] == ' ') && (i >= 2) && (text[i - 2] == 'I') && (text[i - 1] == 'F'))
                            expression = true;

                        //Get the start and end indexes of the VALUE of the possible token (withoit the < > or " ")
                        int realStartIndex = (startedBracketIndex + 1);
                        int realEndIndex = i - 1;
                        if (closer)
                            realStartIndex += 1;

                        //Make sure we aren't looking at a > or " " immediately after the <
                        if ((realEndIndex - realStartIndex + 1) > 0)
                        {
                            string nextToken = text.Substring(realStartIndex, realEndIndex - realStartIndex + 1);
                            if (nextToken.Contains(':') && nextToken != ":")
                            {
                                nextToken = nextToken.Split(':')[0];
                                if (isPreProcessorToken(nextToken))
                                {
                                    return new PossibleToken(startedBracketIndex, i, closer, expression, false, true);
                                }
                                else
                                {
                                    //So we thought we had a token, but it turns out we don't!
                                    startedBracket = false;
                                    startedBracketIndex = -1;
                                }
                            }
                            else
                            {
                                if (isValidToken(nextToken))
                                    return new PossibleToken(startedBracketIndex, i, closer, expression, false, false);
                                else
                                {
                                    //So we thought we had a token, but it turns out we don't!
                                    startedBracket = false;
                                    startedBracketIndex = -1;
                                }
                            }
                        }
                        else
                        {
                            //The > or " " was right after the <
                            //Ignore the < and move on
                            startedBracketIndex = -1;
                            closer = false;
                            expression = false;
                            startedBracket = false;
                        }
                    }
                }
            }
            //TODO: I think the intention was never to get here, but sometimes we do!
            return null;
        }

        /// <summary>
        /// Determines if the content of a string represents the name of a token
        /// </summary>
        /// <param name="tokenValue">Value to test</param>
        /// <returns>Returns true if the value is the name of a token</returns>
        private bool isValidToken(string tokenValue)
        {
            if (tokenValue.StartsWith("/"))
                return closerLookup.Contains(tokenValue.ToUpper());
            else
                return modifierLookup.ContainsKey(tokenValue);
        }

        /// <summary>
        /// Determines if the content of a string represents the name of a pre-processor token
        /// </summary>
        /// <param name="tokenValue">Value to test</param>
        /// <returns>Returns true if the value is the name of a pre-processor token</returns>
        private bool isPreProcessorToken(string tokenValue)
        {
            if (typeLookup.ContainsKey(tokenValue.ToUpper()))
                return (typeLookup[tokenValue.ToUpper()] == TokenType.PreProcessor);
            else
                return false;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="startIndex"></param>
        /// <param name="text"></param>
        /// <returns></returns>
        private Tuple<int, int, List<TokenValidity>> nextExpressionToken(int startIndex, string text)
        {
            bool startedToken = false;
            int startedTokenIndex = -1;
            for (int i = startIndex; i < text.Length; i++)
            {
                if (!startedToken)
                {
                    if (char.IsLetter(text[i]))
                    {
                        startedToken = true;
                        startedTokenIndex = i;
                    }
                }
                else
                {
                    if (char.IsLetterOrDigit(text[i]) || text[i] == '_')
                    {
                        continue;
                    }
                    else if (text[i] == ' ' || text[i] == '>')
                    {
                        List<TokenValidity> expressionType;

                        string expstring = text.Substring(startedTokenIndex, i - startedTokenIndex);

                        if (expressionLookup.TryGetValue(expstring, out expressionType))
                        {
                            return Tuple.Create(startedTokenIndex, i, expressionType);
                        }
                        else if (expstring.ToUpper().StartsWith("CUSTOM_"))
                        {
                            return Tuple.Create(startedTokenIndex, i, customValidity);
                        }
                        else if ((expstring.ToUpper().StartsWith("USERTOKEN_")) || (expstring.ToUpper().StartsWith("NOT_USERTOKEN_")))
                        {
                            return Tuple.Create(startedTokenIndex, i, userTokenValidity);
                        }
                        else
                        {
                            //Invalid expression
                            reportError(String.Format("Invalid expression <IF {0}> at offset {1}!", expstring, startedTokenIndex - 4, ""));
                            break;
                        }
                    }
                    else if (char.IsControl(text[i]))
                        break;
                    else
                    {
                        startedToken = false;
                        startedTokenIndex = -1;
                    }
                }
            }
            return null;
        }


        /// <summary>
        /// Writes the current collection of tokens to a file for debugging purposes.
        /// </summary>
        /// <param name="tokens">Collection of tokens.</param>
        /// <param name="fileSpec">File to write tokens to.</param>
        /// <returns>Returns true if the file was successfully created</returns>
        public static bool WriteTokensToFile(List<Token> tokens, string fileSpec)
        {
            try
            {
                using (StreamWriter file = File.CreateText(fileSpec))
                {
                    foreach (Token tkn in tokens)
                    {
                        file.WriteLine(tkn.ToString());
                    }
                    file.Close();
                }
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        private void loadUserTokens()
        {
            //Plug in user-defined tokens
            if ((context.UserTokens != null) && (context.UserTokens.Count > 0))
            {
                foreach (UserToken userToken in context.UserTokens)
                {
                    TokenMeta newMeta = new TokenMeta();
                    newMeta.Name = userToken.Name;
                    newMeta.TypeOfToken = TokenType.User;
                    newMeta.Validity = TokenValidity.Anywhere;
                    addLookupToken(newMeta);
                }
            }
        }

        private void loadCustomExpanders()
        {
            //Plug in custom token expanders
            if (context.CustomTokenExpanders != null && context.CustomTokenExpanders.Count > 0)
            {
                foreach (Tuple<String, String, TokenValidity, TokenCaseMode, Func<Token, FileNode, IEnumerable<LoopNode>, String>> customexpander in context.CustomTokenExpanders)
                {
                    switch (customexpander.Item3)
                    {
                        case TokenValidity.Anywhere:
                            switch (customexpander.Item4)
                            {
                                case TokenCaseMode.AllCasingOptions:
                                    addLookupToken(makeCased(TokenType.Generic, TokenValidity.Anywhere, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseAndLowerCase:
                                    addLookupToken(makeCasedLimited(TokenType.Generic, TokenValidity.Anywhere, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseOnly:
                                    addLookupToken(new TokenMeta { Name = customexpander.Item1, TypeOfToken = TokenType.Generic, Validity = TokenValidity.Anywhere });
                                    break;
                                default:
                                    break;
                            }
                            break;

                        case TokenValidity.NotInLoop:
                            switch (customexpander.Item4)
                            {
                                case TokenCaseMode.AllCasingOptions:
                                    break;
                                case TokenCaseMode.UppercaseAndLowerCase:
                                    break;
                                case TokenCaseMode.UppercaseOnly:
                                    break;
                                default:
                                    break;
                            }
                            break;

                        case TokenValidity.AnyLoop:
                            switch (customexpander.Item4)
                            {
                                case TokenCaseMode.AllCasingOptions:
                                    addLookupToken(makeCased(TokenType.LoopUtility, TokenValidity.AnyLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseAndLowerCase:
                                    addLookupToken(makeCasedLimited(TokenType.LoopUtility, TokenValidity.AnyLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseOnly:
                                    addLookupToken(new TokenMeta { Name = customexpander.Item1, TypeOfToken = TokenType.LoopUtility, Validity = TokenValidity.AnyLoop });
                                    break;
                                default:
                                    break;
                            }
                            break;

                        case TokenValidity.FieldLoop:
                            switch (customexpander.Item4)
                            {
                                case TokenCaseMode.AllCasingOptions:
                                    addLookupToken(makeCased(TokenType.FieldLoop, TokenValidity.FieldLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseAndLowerCase:
                                    addLookupToken(makeCasedLimited(TokenType.FieldLoop, TokenValidity.FieldLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseOnly:
                                    addLookupToken(new TokenMeta { Name = customexpander.Item1, TypeOfToken = TokenType.FieldLoop, Validity = TokenValidity.FieldLoop });
                                    break;
                                default:
                                    break;
                            }
                            break;

                        case TokenValidity.FieldSelectionLoop:
                            switch (customexpander.Item4)
                            {
                                case TokenCaseMode.AllCasingOptions:
                                    addLookupToken(makeCased(TokenType.FieldSelectionLoop, TokenValidity.FieldSelectionLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseAndLowerCase:
                                    addLookupToken(makeCasedLimited(TokenType.FieldSelectionLoop, TokenValidity.FieldSelectionLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseOnly:
                                    addLookupToken(new TokenMeta { Name = customexpander.Item1, TypeOfToken = TokenType.FieldSelectionLoop, Validity = TokenValidity.FieldSelectionLoop });
                                    break;
                                default:
                                    break;
                            }
                            break;

                        case TokenValidity.KeyLoop:
                            switch (customexpander.Item4)
                            {
                                case TokenCaseMode.AllCasingOptions:
                                    addLookupToken(makeCased(TokenType.KeyLoop, TokenValidity.KeyLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseAndLowerCase:
                                    addLookupToken(makeCasedLimited(TokenType.KeyLoop, TokenValidity.KeyLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseOnly:
                                    addLookupToken(new TokenMeta { Name = customexpander.Item1, TypeOfToken = TokenType.KeyLoop, Validity = TokenValidity.KeyLoop });
                                    break;
                                default:
                                    break;
                            }
                            break;

                        case TokenValidity.KeySegmentLoop:
                            switch (customexpander.Item4)
                            {
                                case TokenCaseMode.AllCasingOptions:
                                    addLookupToken(makeCased(TokenType.KeySegmentLoop, TokenValidity.KeySegmentLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseAndLowerCase:
                                    addLookupToken(makeCasedLimited(TokenType.KeySegmentLoop, TokenValidity.KeySegmentLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseOnly:
                                    addLookupToken(new TokenMeta { Name = customexpander.Item1, TypeOfToken = TokenType.KeySegmentLoop, Validity = TokenValidity.KeySegmentLoop });
                                    break;
                                default:
                                    break;
                            }
                            break;

                        case TokenValidity.EnumLoop:
                            switch (customexpander.Item4)
                            {
                                case TokenCaseMode.AllCasingOptions:
                                    addLookupToken(makeCased(TokenType.EnumLoop, TokenValidity.EnumLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseAndLowerCase:
                                    addLookupToken(makeCasedLimited(TokenType.EnumLoop, TokenValidity.EnumLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseOnly:
                                    addLookupToken(new TokenMeta { Name = customexpander.Item1, TypeOfToken = TokenType.EnumLoop, Validity = TokenValidity.EnumLoop });
                                    break;
                                default:
                                    break;
                            }
                            break;

                        case TokenValidity.EnumMemberLoop:
                            switch (customexpander.Item4)
                            {
                                case TokenCaseMode.AllCasingOptions:
                                    addLookupToken(makeCased(TokenType.EnumMemberLoop, TokenValidity.EnumMemberLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseAndLowerCase:
                                    addLookupToken(makeCasedLimited(TokenType.EnumMemberLoop, TokenValidity.EnumMemberLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseOnly:
                                    addLookupToken(new TokenMeta { Name = customexpander.Item1, TypeOfToken = TokenType.EnumMemberLoop, Validity = TokenValidity.EnumMemberLoop });
                                    break;
                                default:
                                    break;
                            }
                            break;

                        case TokenValidity.RelationLoop:
                            switch (customexpander.Item4)
                            {
                                case TokenCaseMode.AllCasingOptions:
                                    addLookupToken(makeCased(TokenType.RelationLoop, TokenValidity.RelationLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseAndLowerCase:
                                    addLookupToken(makeCasedLimited(TokenType.RelationLoop, TokenValidity.RelationLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseOnly:
                                    addLookupToken(new TokenMeta { Name = customexpander.Item1, TypeOfToken = TokenType.RelationLoop, Validity = TokenValidity.RelationLoop });
                                    break;
                                default:
                                    break;
                            }
                            break;

                        case TokenValidity.TagLoop:
                            switch (customexpander.Item4)
                            {
                                case TokenCaseMode.AllCasingOptions:
                                    addLookupToken(makeCased(TokenType.TagLoop, TokenValidity.TagLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseAndLowerCase:
                                    addLookupToken(makeCasedLimited(TokenType.TagLoop, TokenValidity.TagLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseOnly:
                                    addLookupToken(new TokenMeta { Name = customexpander.Item1, TypeOfToken = TokenType.TagLoop, Validity = TokenValidity.TagLoop });
                                    break;
                                default:
                                    break;
                            }
                            break;

                        case TokenValidity.StructureLoop:
                            switch (customexpander.Item4)
                            {
                                case TokenCaseMode.AllCasingOptions:
                                    addLookupToken(makeCased(TokenType.StructureLoop, TokenValidity.StructureLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseAndLowerCase:
                                    addLookupToken(makeCasedLimited(TokenType.StructureLoop, TokenValidity.StructureLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseOnly:
                                    addLookupToken(new TokenMeta { Name = customexpander.Item1, TypeOfToken = TokenType.StructureLoop, Validity = TokenValidity.StructureLoop });
                                    break;
                                default:
                                    break;
                            }
                            break;

                        case TokenValidity.ButtonLoop:
                            switch (customexpander.Item4)
                            {
                                case TokenCaseMode.AllCasingOptions:
                                    addLookupToken(makeCased(TokenType.ButtonLoop, TokenValidity.ButtonLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseAndLowerCase:
                                    addLookupToken(makeCasedLimited(TokenType.ButtonLoop, TokenValidity.ButtonLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseOnly:
                                    addLookupToken(new TokenMeta { Name = customexpander.Item1, TypeOfToken = TokenType.ButtonLoop, Validity = TokenValidity.ButtonLoop });
                                    break;
                                default:
                                    break;
                            }
                            break;

                        case TokenValidity.FileLoop:
                            switch (customexpander.Item4)
                            {
                                case TokenCaseMode.AllCasingOptions:
                                    addLookupToken(makeCased(TokenType.FileLoop, TokenValidity.FileLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseAndLowerCase:
                                    addLookupToken(makeCasedLimited(TokenType.FileLoop, TokenValidity.FileLoop, customexpander.Item1.Split('_')));
                                    break;
                                case TokenCaseMode.UppercaseOnly:
                                    addLookupToken(new TokenMeta { Name = customexpander.Item1, TypeOfToken = TokenType.FileLoop, Validity = TokenValidity.FileLoop });
                                    break;
                                default:
                                    break;
                            }
                            break;
                    }
                }
            }
        }

        private void loadCustomEvaluators()
        {
            //Plug in custom expression evaluators
            if (context.CustomExpressionEvaluators != null && context.CustomExpressionEvaluators.Count > 0)
            {
                foreach (Tuple<string, string, TokenValidity, Func<Token, FileNode, IEnumerable<LoopNode>, bool>> extension in context.CustomExpressionEvaluators)
                {
                    List<TokenValidity> expressionTypes = new List<TokenValidity>();
                    foreach (Enum enumValue in Enum.GetValues(extension.Item3.GetType()))
                    {
                        if (extension.Item3.HasFlag(enumValue))
                        {
                            expressionTypes.Add((TokenValidity)enumValue);
                        }
                    }
                    expressionLookup.Add(extension.Item1, expressionTypes);
                }
            }
        }
    }
}

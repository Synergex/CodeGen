//*****************************************************************************
//
// Title:       TokenValidation.cs
//
// Type:        Class
//
// Description: Validates that tokens are in a valid location within the tree
//
// Date:        30th August 2014
//
// Author:      Steve Ives, Synergex Professional Services Group
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
using System.Linq;

namespace CodeGen.Engine
{

    /// <summary>
    /// Validates the location of a token based on the TokenValidity of the token and the location of the
    /// token in the tree. For example, field loop tokens may only exist in a field loop.
    /// </summary>
    class TokenValidation
    {
        Dictionary<TokenValidity, Func<FileNode, IEnumerable<LoopNode>, bool>> tokenValidators;

        public TokenValidation()
        {
            tokenValidators = new Dictionary<TokenValidity, Func<FileNode, IEnumerable<LoopNode>, bool>>();
            tokenValidators.Add(TokenValidity.Anywhere, isGenericTokenValid);
            tokenValidators.Add(TokenValidity.NotInLoop, isNotInLoopTokenValid);
            tokenValidators.Add(TokenValidity.FieldLoop, isFieldLoopTokenValid);
            tokenValidators.Add(TokenValidity.FieldSelectionLoop, isSelectionLoopTokenValid);
            tokenValidators.Add(TokenValidity.KeyLoop, isKeyLoopTokenValid);
            tokenValidators.Add(TokenValidity.KeySegmentLoop, isKeySegmentLoopTokenValid);
            tokenValidators.Add(TokenValidity.EnumLoop, isEnumLoopTokenValid);
            tokenValidators.Add(TokenValidity.EnumMemberLoop, isEnumMemberLoopTokenValid);
            tokenValidators.Add(TokenValidity.RelationLoop, isRelationLoopTokenValid);
            tokenValidators.Add(TokenValidity.ButtonLoop, isButtonLoopTokenValid);
            tokenValidators.Add(TokenValidity.FileLoop, isFileLoopTokenValid);
            tokenValidators.Add(TokenValidity.TagLoop, isTagLoopTokenValid);
            tokenValidators.Add(TokenValidity.StructureLoop, isStructureLoopTokenValid);
            tokenValidators.Add(TokenValidity.AnyLoop, isAnyLoopTokenValid);
        }

        //TODO: I don't believe this class is actually required. It should be possible to write code to impose these rules based on Validity and location. This class just hard-codes the rules that the Validity options express.

        /// <summary>
        /// Called by ErrorReporting to determine if a token is in a valid location.
        /// </summary>
        /// <param name="validityType">Token type.</param>
        /// <param name="file">Tree root node.</param>
        /// <param name="loops">Current loop heirarchy.</param>
        /// <returns>True indicates that the location of the token is valid.</returns>
        public bool IsValid(TokenValidity validityType, FileNode file, IEnumerable<LoopNode> loops)
        {
            return tokenValidators[validityType](file, loops);
        }

        static bool isGenericTokenValid(FileNode file, IEnumerable<LoopNode> loops)
        {
            return true;
        }

        static bool isNotInLoopTokenValid(FileNode file, IEnumerable<LoopNode> loops)
        {
            return loops.Count() == 0;
        }

        static bool isFieldLoopTokenValid(FileNode file, IEnumerable<LoopNode> loops)
        {
            return ((loops.Count() > 0) && (loops.FirstOrDefault((node) => node is FieldLoopNode) != null));
            //if (loops.Count() == 0)
            //    return false;
            //else
            //    return (loops.Last().OpenToken.Value == "FIELD_LOOP");
        }

        static bool isSelectionLoopTokenValid(FileNode file, IEnumerable<LoopNode> loops)
        {
            return ((loops.Count() > 0) && (loops.Last() is SelectionLoopNode));
            //if (loops.Count() == 0)
            //    return false;
            //else
            //    return (loops.Last().OpenToken.Value == "SELECTION_LOOP");
        }

        static bool isKeyLoopTokenValid(FileNode file, IEnumerable<LoopNode> loops)
        {
            return ((loops.Count() > 0) && (loops.FirstOrDefault((node) => node is KeyLoopNode) != null));
            //if (loops.Count() == 0)
            //    return false;
            //else
            //{
            //    switch (loops.Last().OpenToken.Value)
            //    {
            //        case "KEY_LOOP":
            //        case "ALTERNATE_KEY_LOOP":
            //        case "PRIMARY_KEY":
            //            return true;
            //        default:
            //            return false;
            //    }
            //}
        }

        static bool isKeySegmentLoopTokenValid(FileNode file, IEnumerable<LoopNode> loops)
        {
            return ((loops.Count() > 0) && (loops.Last() is SegmentLoopNode));
            //if (loops.Count() == 0)
            //    return false;
            //else
            //{
            //    switch (loops.Last().OpenToken.Value)
            //    {
            //        case "SEGMENT_LOOP":
            //        case "SEGMENT_LOOP_FILTER":
            //            return true;
            //        default:
            //            return false;
            //    }
            //}
        }

        static bool isEnumLoopTokenValid(FileNode file, IEnumerable<LoopNode> loops)
        {
            return ((loops.Count() > 0) && (loops.FirstOrDefault((node) => node is EnumLoopNode) != null));
            //if (loops.Count() == 0)
            //    return false;
            //else
            //{
            //    switch (loops.Last().OpenToken.Value)
            //    {
            //        case "ENUM_LOOP":
            //        case "ENUM_LOOP_STRUCTURE":
            //            return true;
            //        default:
            //            return false;
            //    }
            //}
        }

        static bool isEnumMemberLoopTokenValid(FileNode file, IEnumerable<LoopNode> loops)
        {
            return ((loops.Count() > 0) && (loops.Last() is EnumMemberLoopNode));
            //if (loops.Count() == 0)
            //    return false;
            //else
            //    return (loops.Last().OpenToken.Value == "ENUM_MEMBER_LOOP");
        }

        static bool isRelationLoopTokenValid(FileNode file, IEnumerable<LoopNode> loops)
        {
            return ((loops.Count() > 0) && (loops.Last() is RelationLoopNode));
            //if (loops.Count() == 0)
            //    return false;
            //else
            //    return (loops.Last().OpenToken.Value == "RELATION_LOOP");
        }

        static bool isButtonLoopTokenValid(FileNode file, IEnumerable<LoopNode> loops)
        {
            return ((loops.Count() > 0) && (loops.Last() is ButtonLoopNode));
            //if (loops.Count() == 0)
            //    return false;
            //else
            //    return (loops.Last().OpenToken.Value == "BUTTON_LOOP");
        }

        static bool isFileLoopTokenValid(FileNode file, IEnumerable<LoopNode> loops)
        {
            return ((loops.Count() > 0) && (loops.Last() is FileLoopNode));
            //if (loops.Count() == 0)
            //    return false;
            //else
            //    return (loops.Last().OpenToken.Value == "FILE_LOOP");
        }

        static bool isTagLoopTokenValid(FileNode file, IEnumerable<LoopNode> loops)
        {
            return ((loops.Count() > 0) && (loops.Last() is TagLoopNode));
            //if (loops.Count() == 0)
            //    return false;
            //else
            //    return (loops.Last().OpenToken.Value == "TAG_LOOP");
        }

        static bool isStructureLoopTokenValid(FileNode file, IEnumerable<LoopNode> loops)
        {
            return ((loops.Count() > 0) && (loops.Last() is StructureLoopNode));
            //if (loops.Count() == 0)
            //    return false;
            //else
            //    return (loops.Last().OpenToken.Value == "STRUCTURE_LOOP");
        }

        static bool isAnyLoopTokenValid(FileNode file, IEnumerable<LoopNode> loops)
        {
            return loops.Count() > 0;
        }

    }
}

//*****************************************************************************
//
// Title:       LoopExpander.cs
//
// Type:        Class
//
// Description: Implements logic to iterate various template file loop constructs
//
// Date:        30th August 2014
//
// Authors:     Steve Ives, Synergex Professional Services Group
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

using CodeGen.RepositoryAPI;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace CodeGen.Engine
{
    class LoopExpander
    {
        static Dictionary<string, Action<LoopNode, FileNode, IEnumerable<LoopNode>, ITreeNodeVisitor>> loopProcessors;

        static LoopExpander()
        {
            loopProcessors = new Dictionary<string, Action<LoopNode, FileNode, IEnumerable<LoopNode>, ITreeNodeVisitor>>();
            loopProcessors.Add("FIELD_LOOP",processFieldLoop);
            loopProcessors.Add("KEY_LOOP",processKeyLoop);
            loopProcessors.Add("ALTERNATE_KEY_LOOP",processAlternateKeyLoop);
            loopProcessors.Add("PRIMARY_KEY",processPrimaryKeyLoop);
            loopProcessors.Add("UNIQUE_KEY", processUniqueKeyLoop);
            loopProcessors.Add("ENUM_LOOP",processEnumLoop);
            loopProcessors.Add("ENUM_LOOP_STRUCTURE",processStructureEnumLoop);
            loopProcessors.Add("RELATION_LOOP",processRelationLoop);
            loopProcessors.Add("BUTTON_LOOP",processButtonLoop);
            loopProcessors.Add("FILE_LOOP",processFileLoop);
            loopProcessors.Add("TAG_LOOP",processTagLoop);
            loopProcessors.Add("SELECTION_LOOP",processFieldSelectionLoop);
            loopProcessors.Add("SEGMENT_LOOP", processKeySegmentLoop);
            loopProcessors.Add("SEGMENT_LOOP_FILTER", processKeySegmentFilterLoop);
            loopProcessors.Add("FIRST_SEGMENT", processFirstKeySegmentLoop);
            loopProcessors.Add("SECOND_SEGMENT", ProcessSecondKeySegmentLoop);
            loopProcessors.Add("ENUM_MEMBER_LOOP", processEnumMemberLoop);
            loopProcessors.Add("STRUCTURE_LOOP", processStructureLoop);
        }

        /// <summary>
        /// This method is called by TreeExpander whenever a loop node is encountered in the tree.
        /// It determines which method should be used to expand the loop and calls that method.
        /// </summary>
        /// <param name="node"></param>
        /// <param name="file"></param>
        /// <param name="loopContext"></param>
        /// <param name="visitor"></param>
        public static void ProcessLoop(LoopNode node, FileNode file, IEnumerable<LoopNode> loopContext, ITreeNodeVisitor visitor)
        {
            if (loopProcessors.ContainsKey(node.OpenToken.Value))
                loopProcessors[node.OpenToken.Value](node, file, loopContext, visitor);
            else
                throw new ApplicationException(
                    String.Format(
                    "CODEGEN BUG: LoopExpander doesn't define a processor for <{0}>!",
                    node.OpenToken.Value));
        }

        private static void processFieldLoop(LoopNode node, FileNode file, IEnumerable<LoopNode> loops, ITreeNodeVisitor expander)
        {
            FieldLoopNode loop = node as FieldLoopNode;
            CodeGenContext context = file.Context;

            if (file.Context.CurrentStructure.Fields.Count == 0)
                throw new ApplicationException(
                    String.Format("The <{0}> loop at line {1} in template {2} can't be processed because structure {3} has no fields!", 
                    node.OpenToken.Value,
                    node.OpenToken.StartLineNumber,
                    file.Context.CurrentTemplateBaseName,
                    file.Context.CurrentStructure.Name));

            loop.MaxIndex = file.Context.CurrentStructure.Fields.Count - 1;

            context.CurrentTask.DebugLog(String.Format("   - {0,-30} -> {1} fields", string.Format("<{0}>", loop.OpenToken.Value), loop.MaxIndex + 1));

            for (int ix = 0; ix < file.Context.CurrentStructure.Fields.Count; ix++)
            {
                loop.CurrentField = file.Context.CurrentStructure.Fields[ix];
                loop.CurrentIndex = ix;
                foreach (ITreeNode child in node.Body)
                    child.Accept(expander);
            }
        }

        private static void processKeyLoop(LoopNode node, FileNode file, IEnumerable<LoopNode> loops, ITreeNodeVisitor expander)
        {
            KeyLoopNode loop = node as KeyLoopNode;
            CodeGenContext context = file.Context;

            if (file.Context.CurrentStructure.Keys.Count == 0)
                throw new ApplicationException(
                    String.Format(
                    "The <{0}> loop at line {1} in template {2} can't be processed because structure {3} has no keys!",
                    node.OpenToken.Value, 
                    node.OpenToken.StartLineNumber, 
                    file.Context.CurrentTemplateBaseName, 
                    file.Context.CurrentStructure.Name));

            loop.MaxIndex = file.Context.CurrentStructure.Keys.Count - 1;

            context.CurrentTask.DebugLog(String.Format("   - {0,-30} -> {1} keys", string.Format("<{0}>", loop.OpenToken.Value), loop.MaxIndex + 1));

            for (int ix = 0; ix < file.Context.CurrentStructure.Keys.Count; ix++)
            {
                loop.CurrentKey = file.Context.CurrentStructure.Keys[ix];
                loop.CurrentIndex = ix;
                foreach (ITreeNode child in node.Body)
                    child.Accept(expander);
            }
        }

        private static void processAlternateKeyLoop(LoopNode node, FileNode file, IEnumerable<LoopNode> loops, ITreeNodeVisitor expander)
        {
            KeyLoopNode loop = node as KeyLoopNode;
            CodeGenContext context = file.Context;

            if (file.Context.CurrentStructure.Keys.Count == 0)
                throw new ApplicationException(
                    String.Format(
                    "The <{0}> loop at line {1} in template {2} can't be processed because structure {3} has no keys!",
                    node.OpenToken.Value,
                    node.OpenToken.StartLineNumber,
                    file.Context.CurrentTemplateBaseName,
                    file.Context.CurrentStructure.Name));

            loop.MaxIndex = file.Context.CurrentStructure.Keys.Count - 1;

            context.CurrentTask.DebugLog(String.Format("   - {0,-30} -> {1} keys", string.Format("<{0}>", loop.OpenToken.Value), loop.MaxIndex + 1));

            for (int ix = 0; ix < file.Context.CurrentStructure.Keys.Count; ix++)
            {
                //Skip the first key
                if (ix == 0)
                    continue;
                //Process as normal
                loop.CurrentKey = file.Context.CurrentStructure.Keys[ix];
                loop.CurrentIndex = ix;
                foreach (ITreeNode child in node.Body)
                    child.Accept(expander);
            }
        }

        private static void processPrimaryKeyLoop(LoopNode node, FileNode file, IEnumerable<LoopNode> loops, ITreeNodeVisitor expander)
        {
            KeyLoopNode loop = node as KeyLoopNode;
            CodeGenContext context = file.Context;

            if (file.Context.CurrentStructure.Keys.Count == 0)
                throw new ApplicationException(
                    String.Format(
                    "The <{0}> loop at line {1} in template {2} can't be processed because structure {3} has no keys!",
                    node.OpenToken.Value,
                    node.OpenToken.StartLineNumber,
                    file.Context.CurrentTemplateBaseName,
                    file.Context.CurrentStructure.Name));

            if (file.Context.CurrentTask.PrimaryKeyNumber > 0 && (file.Context.CurrentTask.PrimaryKeyNumber > (file.Context.CurrentStructure.Keys.Count - 1)))
                throw new ApplicationException(
                    String.Format(
                    "The <{0}> loop at line {1} in template {2} can't be processed using alternate key {3} because structure {4} only has {5} keys!",
                    node.OpenToken.Value,
                    node.OpenToken.StartLineNumber,
                    file.Context.CurrentTemplateBaseName,
                    file.Context.CurrentTask.PrimaryKeyNumber,
                    file.Context.CurrentStructure.Name,
                    file.Context.CurrentStructure.Keys.Count + 1));

            loop.CurrentKey = file.Context.CurrentStructure.Keys[file.Context.CurrentTask.PrimaryKeyNumber];
            loop.CurrentIndex = file.Context.CurrentTask.PrimaryKeyNumber;
            loop.MaxIndex = file.Context.CurrentTask.PrimaryKeyNumber;

            context.CurrentTask.DebugLog(String.Format("   - {0,-30} -> 1 key", string.Format("<{0}>", loop.OpenToken.Value)));

            foreach (ITreeNode child in node.Body)
                child.Accept(expander);
        }

        private static void processUniqueKeyLoop(LoopNode node, FileNode file, IEnumerable<LoopNode> loops, ITreeNodeVisitor expander)
        {
            KeyLoopNode loop = node as KeyLoopNode;
            CodeGenContext context = file.Context;

            if (file.Context.CurrentStructure.Keys.Count == 0)
                throw new ApplicationException(
                    String.Format(
                    "The <{0}> loop at line {1} in template {2} can't be processed because structure {3} has no keys!",
                    node.OpenToken.Value,
                    node.OpenToken.StartLineNumber,
                    file.Context.CurrentTemplateBaseName,
                    file.Context.CurrentStructure.Name));

            if (!file.Context.CurrentStructure.Keys.Any(k => (k.Duplicates == RpsKeyDuplicates.NoDuplicates)))
                throw new ApplicationException(
                    String.Format(
                    "The <{0}> loop at line {1} in template {2} can't be processed because structure {3} has no unique keys!",
                    node.OpenToken.Value,
                    node.OpenToken.StartLineNumber,
                    file.Context.CurrentTemplateBaseName,
                    file.Context.CurrentStructure.Name));

            loop.CurrentKey = file.Context.CurrentStructure.Keys.First(k => (k.Duplicates == RpsKeyDuplicates.NoDuplicates));
            loop.CurrentIndex = file.Context.CurrentStructure.Keys.IndexOf(loop.CurrentKey);
            loop.MaxIndex = loop.CurrentIndex;

            context.CurrentTask.DebugLog(String.Format("   - {0,-30} -> 1 key", string.Format("<{0}>", loop.OpenToken.Value)));

            foreach (ITreeNode child in node.Body)
                child.Accept(expander);
        }

        private static void processEnumLoop(LoopNode node, FileNode file, IEnumerable<LoopNode> loops, ITreeNodeVisitor expander)
        {
            EnumLoopNode loop = node as EnumLoopNode;
            CodeGenContext context = file.Context;

            if (file.Context.Enumerations.Count == 0)
                throw new ApplicationException(
                    String.Format(
                    "The <{0}> loop at line {1} in template {2} can't be processed because no enumerations are defined!",
                    node.OpenToken.Value,
                    node.OpenToken.StartLineNumber,
                    file.Context.CurrentTemplateBaseName));

            loop.MaxIndex = file.Context.Enumerations.Count - 1;

            context.CurrentTask.DebugLog(String.Format("   - {0,-30} -> {1} enums", string.Format("<{0}>", loop.OpenToken.Value), loop.MaxIndex + 1));

            for (int ix = 0; ix < file.Context.Enumerations.Count; ix++)
            {
                loop.CurrentEnumeration = file.Context.Enumerations[ix];
                loop.CurrentIndex = ix;
                foreach (ITreeNode child in node.Body)
                    child.Accept(expander);
            }
        }

        private static void processStructureEnumLoop(LoopNode node, FileNode file, IEnumerable<LoopNode> loops, ITreeNodeVisitor expander)
        {
            EnumLoopNode loop = node as EnumLoopNode;
            CodeGenContext context = file.Context;

            if (file.Context.Enumerations.Count == 0)
                throw new ApplicationException(
                    String.Format("The <{0}> loop at line {1} in template {2} can't be processed because no enumerations are defined!",
                    node.OpenToken.Value,
                    node.OpenToken.StartLineNumber,
                    file.Context.CurrentTemplateBaseName));

            //TODO: Needs work because we don't visit all enumerations in the collection!
            loop.MaxIndex = file.Context.Enumerations.Count - 1;

            context.CurrentTask.DebugLog(String.Format("   - {0,-30} -> {1} enums", string.Format("<{0}>", loop.OpenToken.Value), loop.MaxIndex + 1));

            for (int ix = 0; ix < file.Context.Enumerations.Count; ix++)
            {
                loop.CurrentEnumeration = file.Context.Enumerations[ix];

                foreach (RpsField field in file.Context.CurrentStructure.Fields)
                {
                    if ((field.DataType == RpsFieldDataType.Enum) && (field.EnumName == loop.CurrentEnumeration.Name))
                    {
                        loop.CurrentIndex = ix;
                        foreach (ITreeNode child in node.Body)
                            child.Accept(expander);
                    }
                }
            }
        }

        private static void processRelationLoop(LoopNode node, FileNode file, IEnumerable<LoopNode> loops, ITreeNodeVisitor expander)
        {
            RelationLoopNode loop = node as RelationLoopNode;
            CodeGenContext context = file.Context;

            if (file.Context.CurrentStructure.Relations.Count == 0)
                throw new ApplicationException(
                    String.Format(
                    "The <{0}> loop at line {1} in template {2} can't be processed because structure {3} has no relations!",
                    node.OpenToken.Value,
                    node.OpenToken.StartLineNumber,
                    file.Context.CurrentTemplateBaseName,
                    file.Context.CurrentStructure.Name));

            loop.MaxIndex = file.Context.CurrentStructure.Relations.Count - 1;

            context.CurrentTask.DebugLog(String.Format("   - {0,-30} -> {1} relations", string.Format("<{0}>", loop.OpenToken.Value), loop.MaxIndex + 1));

            for (int ix = 0; ix < file.Context.CurrentStructure.Relations.Count; ix++)
            {
                loop.CurrentRelation = file.Context.CurrentStructure.Relations[ix];
                loop.CurrentIndex = ix;
                foreach (ITreeNode child in node.Body)
                    child.Accept(expander);
            }
        }

        private static void processButtonLoop(LoopNode node, FileNode file, IEnumerable<LoopNode> loops, ITreeNodeVisitor expander)
        {
            //TODO: Button loops need context data

            ButtonLoopNode loop = node as ButtonLoopNode;
            CodeGenContext context = file.Context;

            file.Context.Buttons = new WscButtonCollection();

            if ((file.Context.Buttons == null) || (file.Context.Buttons.Count == 0))
                return;

            loop.MaxIndex = file.Context.Buttons.Count - 1;

            context.CurrentTask.DebugLog(String.Format("   - {0,-30} -> {1} buttons", string.Format("<{0}>", loop.OpenToken.Value), loop.MaxIndex + 1));

            for (int ix = 0; ix < file.Context.Buttons.Count; ix++)
            {
                loop.CurrentButton = file.Context.Buttons[ix];
                loop.CurrentIndex = ix;
                foreach (ITreeNode child in node.Body)
                    child.Accept(expander);
            }
        }

        private static void processFileLoop(LoopNode node, FileNode file, IEnumerable<LoopNode> loops, ITreeNodeVisitor expander)
        {
            FileLoopNode loop = node as FileLoopNode;
            CodeGenContext context = file.Context;

            if (context.CurrentStructure.Files.Count == 0)
                throw new ApplicationException(
                    String.Format(
                    "The <{0}> loop at line {1} in template {2} can't be processed because structure {3} is not assigned to any files!",
                    node.OpenToken.Value,
                    node.OpenToken.StartLineNumber,
                    file.Context.CurrentTemplateBaseName,
                    context.CurrentStructure.Name));

            loop.MaxIndex = context.CurrentStructure.Files.Count - 1;

            context.CurrentTask.DebugLog(String.Format("   - {0,-30} -> {1} files", string.Format("<{0}>", loop.OpenToken.Value), loop.MaxIndex + 1));

            for (int ix = 0; ix < context.CurrentStructure.Files.Count; ix++)
            {
                loop.CurrentFile = context.CurrentStructure.Files[ix];
                loop.CurrentIndex = ix;
                foreach (ITreeNode child in node.Body)
                    child.Accept(expander);
            }
        }

        private static void processTagLoop(LoopNode node, FileNode file, IEnumerable<LoopNode> loops, ITreeNodeVisitor expander)
        {
            TagLoopNode loop = node as TagLoopNode;
            CodeGenContext context = file.Context;

            loop.MaxIndex = file.Context.CurrentStructure.Tags.Count - 1;

            context.CurrentTask.DebugLog(String.Format("   - {0,-30} -> {1} tags", string.Format("<{0}>", loop.OpenToken.Value), loop.MaxIndex + 1));

            //Tag loops kust do nothing if no tags are defined!
            for (int ix = 0; ix < file.Context.CurrentStructure.Tags.Count; ix++)
            {
                loop.CurrentTag = file.Context.CurrentStructure.Tags[ix];
                loop.CurrentIndex = ix;
                foreach (ITreeNode child in node.Body)
                    child.Accept(expander);
            }
        }

        private static void processFieldSelectionLoop(LoopNode node, FileNode file, IEnumerable<LoopNode> loops, ITreeNodeVisitor expander)
        {
            FieldLoopNode outerLoop = loops.First((loopnode) => loopnode is FieldLoopNode) as FieldLoopNode;
            SelectionLoopNode loop = node as SelectionLoopNode;
            CodeGenContext context = file.Context;

            if (outerLoop.CurrentField.SelectionList.Count > 0)
            {
                loop.MaxIndex = outerLoop.CurrentField.SelectionList.Count - 1;
                loop.CurrentField = outerLoop.CurrentField;

                context.CurrentTask.DebugLog(String.Format("   - {0,-30} -> {1} selections", string.Format("<{0}>", loop.OpenToken.Value), loop.MaxIndex + 1));

                for (int ix = 0; ix < outerLoop.CurrentField.SelectionList.Count; ix++)
                {
                    loop.CurrentSelection = outerLoop.CurrentField.SelectionList[ix];
                    loop.CurrentIndex = ix;
                    foreach (ITreeNode child in node.Body)
                        child.Accept(expander);
                }
            }
        }

        private static void processKeySegmentLoop(LoopNode node, FileNode file, IEnumerable<LoopNode> loops, ITreeNodeVisitor expander)
        {
            KeyLoopNode outerLoop = loops.First((loopnode) => loopnode is KeyLoopNode) as KeyLoopNode;
            SegmentLoopNode loop = node as SegmentLoopNode;
            CodeGenContext context = file.Context;

            if (outerLoop.CurrentKey.Segments.Count > 0)
            {
                loop.CurrentKey = outerLoop.CurrentKey;
                loop.MaxIndex = outerLoop.CurrentKey.Segments.Count - 1;

                context.CurrentTask.DebugLog(String.Format("   - {0,-30} -> {1} segments", string.Format("<{0}>", loop.OpenToken.Value), loop.MaxIndex + 1));

                for (int ix = 0; ix < outerLoop.CurrentKey.Segments.Count; ix++)
                {
                    loop.CurrentSegment = outerLoop.CurrentKey.Segments[ix];
                    loop.CurrentIndex = ix;
                    loop.CurrentField = getFieldForSegment(context.CurrentStructure, loop.CurrentSegment);
                    
                    foreach (ITreeNode child in node.Body)
                        child.Accept(expander);
                }
            }
        }

        private static RpsField getFieldForSegment(RpsStructure str, RpsKeySegment seg)
        {
            if (seg.SegmentType == RpsKeySegmentType.Field)
            {
                try
                {
                    var matchingField = str.Fields.First(fld => (fld.Name == seg.Field));
                    return matchingField;
                }
                catch (Exception)
                {
                    throw new ApplicationException(String.Format("When processing structure {0} key segment field {1} was not found.", str.Name, seg.Field));
                }
            }
            else
                return null;
        }

        private static void processKeySegmentFilterLoop(LoopNode node, FileNode file, IEnumerable<LoopNode> loops, ITreeNodeVisitor expander)
        {
            KeyLoopNode outerLoop = loops.First((loopnode) => loopnode is KeyLoopNode) as KeyLoopNode;
            SegmentLoopNode loop = node as SegmentLoopNode;
            CodeGenContext context = file.Context;

            if (outerLoop.CurrentKey.Segments.Count > 0)
            {
                loop.CurrentKey = outerLoop.CurrentKey;
                loop.MaxIndex = outerLoop.CurrentKey.Segments.Count - 2;

                context.CurrentTask.DebugLog(String.Format("   - {0,-30} -> {1} segments", string.Format("<{0}>", loop.OpenToken.Value), loop.MaxIndex + 1));

                for (int ix = 0; ix < outerLoop.CurrentKey.Segments.Count - 1; ix++)
                {
                    loop.CurrentSegment = outerLoop.CurrentKey.Segments[ix];
                    loop.CurrentIndex = ix;
                    loop.CurrentField = getFieldForSegment(context.CurrentStructure, loop.CurrentSegment);

                    foreach (ITreeNode child in node.Body)
                        child.Accept(expander);
                }
            }
        }

        private static void processFirstKeySegmentLoop(LoopNode node, FileNode file, IEnumerable<LoopNode> loops, ITreeNodeVisitor expander)
        {
            KeyLoopNode outerLoop = loops.First((loopnode) => loopnode is KeyLoopNode) as KeyLoopNode;
            SegmentLoopNode loop = node as SegmentLoopNode;
            CodeGenContext context = file.Context;

            if (outerLoop.CurrentKey.Segments.Count > 0)
            {
                //Only process the first segment
                loop.CurrentKey = outerLoop.CurrentKey;
                loop.CurrentSegment = outerLoop.CurrentKey.Segments[0];
                loop.CurrentIndex = 0;
                loop.MaxIndex = 0;
                loop.CurrentField = getFieldForSegment(context.CurrentStructure, loop.CurrentSegment);

                context.CurrentTask.DebugLog(String.Format("   - {0,-30} -> 1 segment", string.Format("<{0}>", loop.OpenToken.Value)));

                foreach (ITreeNode child in node.Body)
                    child.Accept(expander);
            }
        }

        private static void ProcessSecondKeySegmentLoop(LoopNode node, FileNode file, IEnumerable<LoopNode> loops, ITreeNodeVisitor expander)
        {
            KeyLoopNode outerLoop = loops.First((loopnode) => loopnode is KeyLoopNode) as KeyLoopNode;
            SegmentLoopNode loop = node as SegmentLoopNode;
            CodeGenContext context = file.Context;

            if (outerLoop.CurrentKey.Segments.Count > 1)
            {
                //Only process the second segment
                loop.CurrentKey = outerLoop.CurrentKey;
                loop.CurrentSegment = outerLoop.CurrentKey.Segments[1];
                loop.CurrentIndex = 1;
                loop.MaxIndex = 1;
                loop.CurrentField = getFieldForSegment(context.CurrentStructure, loop.CurrentSegment);

                context.CurrentTask.DebugLog(String.Format("   - {0,-30} -> 1 segment", string.Format("<{0}>", loop.OpenToken.Value)));

                foreach (ITreeNode child in node.Body)
                    child.Accept(expander);
            }
        }

        private static void processEnumMemberLoop(LoopNode node, FileNode file, IEnumerable<LoopNode> loops, ITreeNodeVisitor expander)
        {
            EnumLoopNode outerLoop = loops.First((loopnode) => loopnode is EnumLoopNode) as EnumLoopNode;
            EnumMemberLoopNode loop = node as EnumMemberLoopNode;
            CodeGenContext context = file.Context;

            loop.CurrentEnumeration = outerLoop.CurrentEnumeration;
            loop.MaxIndex = outerLoop.CurrentEnumeration.Members.Count - 1;

            context.CurrentTask.DebugLog(String.Format("   - {0,-30} -> {1} enum members", string.Format("<{0}>", loop.OpenToken.Value), loop.MaxIndex + 1));

            for (int ix = 0; ix < outerLoop.CurrentEnumeration.Members.Count; ix++)
            {
                loop.CurrentMember = loop.CurrentEnumeration.Members[ix];
                loop.CurrentIndex = ix;

                foreach (ITreeNode child in node.Body)
                    child.Accept(expander);
            }
        }

        private static void processStructureLoop(LoopNode node, FileNode file, IEnumerable<LoopNode> loops, ITreeNodeVisitor expander)
        {
            StructureLoopNode loop = node as StructureLoopNode;
            CodeGenContext context = file.Context;
            CodeGenTask task = context.CurrentTask;

            if (!context.MultiStructureMode)
                throw new ApplicationException(
                    String.Format(
                    "The <{0}> loop at line {1} in template {2} can't be processed because multi-structure mode (-ms) has not been enabled!",
                    node.OpenToken.Value,
                    node.OpenToken.StartLineNumber,
                    context.CurrentTemplateBaseName));

            loop.MaxIndex = context.Structures.Count - 1;

            //Debug log beginning of structure loop
            context.CurrentTask.DebugLog(String.Format("   - {0,-30} -> {1} structures", string.Format("<{0}>", loop.OpenToken.Value), context.Structures.Count));

            for (int ix = 0; ix < context.Structures.Count; ix++)
            {
                context.CurrentTask.DebugLog(String.Format("   - {0,-30} -> {1}", String.Format("Structure {0}/{1}", ix + 1, context.Structures.Count-1), context.Structures[ix].Name), true, false);
                context.CurrentStructure = context.Structures[ix];
                loop.CurrentIndex = ix;
                foreach (ITreeNode child in node.Body)
                    child.Accept(expander);
            }

            //Debug log end of structure loop
            context.CurrentTask.DebugLog(String.Format("   - {0,-30} ->", string.Format("</{0}>", loop.CloseToken.Value)));

        }
    }
}

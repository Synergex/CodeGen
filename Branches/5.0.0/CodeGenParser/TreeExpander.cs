//*****************************************************************************
//
// Title:       TreeExpander.cs
//
// Type:        Class
//
// Description: Tree visitor that expands a tree into a stream of output data (code)
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
    public class TreeExpander : ITreeNodeVisitor
    {
        private FileNode _currentFileNode;
        private List<LoopNode> _currentLoops = new List<LoopNode>();
        private TokenExpander _expander;
        private ExpressionEvaluator _evaluator;
        private TextWriter _outputStream;
        private TokenValidation _validator = new TokenValidation();
        private bool _killTextSibling = false;

        /// <summary>
        /// Constructor used when expanding the whole tree. After constructing the object,
        /// call Visit(@FileNode) to initiate code generation.
        /// </summary>
        /// <param name="context">Current CodeGenContext object.</param>
        /// <param name="stream">Stream to write output code to.</param>
        public TreeExpander(CodeGenContext context, TextWriter stream)
        {
            _expander = new TokenExpander(context);
            _evaluator = new ExpressionEvaluator(context);
            _outputStream = stream;
        }

        /// <summary>
        /// Constructor used when expanding part of a tree, e.g. output file name.
        /// </summary>
        /// <param name="tree">Full or partial tree to expand.</param>
        /// <param name="expander">TokenExpander instance.</param>
        /// <param name="evaluator">ExpressionEvaluator instance.</param>
        /// <param name="stream">Stream to write output code to.</param>
        public TreeExpander(FileNode tree, TokenExpander expander, ExpressionEvaluator evaluator, TextWriter stream)
        {
            _currentFileNode = tree;
            _expander = expander;
            _evaluator = evaluator;
            _outputStream = stream;
        }

        /// <summary>
        /// Called by the consumer application to generate the actual output text.
        /// </summary>
        /// <param name="node">Tree to generate output from.</param>
        public void Visit(FileNode node)
        {
            _killTextSibling = false;
            //This should be the only property that may have residual data from the last use.
            node.OutputFileName = String.Empty;

            //try
            //{
            _currentFileNode = node;
            node.Context.CurrentTask.DebugLog("   Tree expansion begins", true, false);

            Visit(node.Body);
            
            setOutputFileName(node);
            
            node.Context.CurrentTask.DebugLog(String.Format("   - {0,-30} -> {1}", "Output file", node.OutputFileName));
            node.Context.CurrentTask.DebugLog("   Tree expansion ends", false, true);
            //}
            //catch (ApplicationException ex)
            //{
            //    node.Context.CurrentTask.ErrorLog(ex.Message);
            //    throw;
            //}
        }

        /// <summary>
        /// Main dispatcher for expanding the body of a node (FileNode.Body, IfNode.Body, ElseNode.Body)
        /// </summary>
        /// <param name="nodes">Collection of nodes to visit</param>
        private void Visit(List<ITreeNode> nodes)
        {
            foreach (ITreeNode node in nodes)
            {
                node.Accept(this);
            }
        }

        /// <summary>
        /// This method is called when a loop node is encountered during tree expansion.
        /// It uses LoopExpander to expand the loop.
        /// </summary>
        /// <param name="loop">The loop node that was encountered in the tree.</param>
        public void Visit(LoopNode loop)
        {
            _killTextSibling = false;
            _currentLoops.Add(loop);
            LoopExpander.ProcessLoop(loop, _currentFileNode, _currentLoops, this);
            _currentLoops.Remove(loop);
        }

        /// <summary>
        /// Visit an IfNode tree member to process the IF/THEN/ELSE logic and output the appropriate code.
        /// </summary>
        /// <param name="node">Node to visit.</param>
        public void Visit(IfNode node)
        {
            _killTextSibling = false;

            //Make sure we have an expression node to process
            if (node.Expression == null)
                throw new ApplicationException("CODEGEN BUG: TreeExpander.Visit(IfNode) encountered an IfNode without an associated ExpressionNode. This indicates a Parser bug!");

            if (_evaluator.EvaluateExpression(getContextForExpression(node.Expression), node.Expression, _currentFileNode, _currentLoops))
            {
                if (_currentFileNode.Context.DebugLoggingEnabled)
                    _currentFileNode.Context.CurrentTask.DebugLog(String.Format("   - {0,-30} -> {1}", String.Format("<IF {0}>", node.Expression.Value.Value), true));

                Visit(node.Body);

                if (_currentFileNode.Context.DebugLoggingEnabled)
                    _currentFileNode.Context.CurrentTask.DebugLog(String.Format("   - {0,-30} ->", String.Format("</IF {0}>", node.Expression.Value.Value)));
            }
            else if (node.Else != null)
            {
                if (_currentFileNode.Context.DebugLoggingEnabled)
                    _currentFileNode.Context.CurrentTask.DebugLog(String.Format("   - {0,-30} ->", "</ELSE>"));

                Visit(node.Else.Body);
            }
            else
                _killTextSibling = true;
        }

        /// <summary>
        /// Visit an ExpressionNode. If this method is called it indicates a problem in Parser.Parse, because
        /// ExpresssionNode nodes are really just part of an IfNode and should be processed by Visit(IfNode).
        /// </summary>
        /// <param name="node">ExpressionNode to viait</param>
        public void Visit(ExpressionNode node)
        {
            throw new ApplicationException("CODEGEN BUG: TreeExpander.Visit(ExpressionNode) should not be called. This indicates a Parser bug.");
        }

        /// <summary>
        /// Visit an ElseNode. If this method is called it indicates a problem in Parser.Parse, because
        /// ElseNode nodes are really just part of an IfNode and should be processed by Visit(IfNode).
        /// </summary>
        /// <param name="node"></param>
        public void Visit(ElseNode node)
        {
            throw new ApplicationException("CODEGEN BUG: TreePreExpander.Visit(ElseNode) should not be called. This indicates a Parser bug.");
        }

        /// <summary>
        /// Processes an expansion token, writing the resulting text value to the output stream.
        /// </summary>
        /// <param name="node">ExpansionMode to visit.</param>
        public void Visit(ExpansionNode node)
        {
            _killTextSibling = false;

            //Use TokenExpander to expand the expansion token to it's text value
            string expandedText = _expander.ExpandToken(node.Value, _currentFileNode, _currentLoops);

            //And add the text to the output stream
            _outputStream.Write(expandedText);

            //Debug logging? Log the token expansion.
            if (_currentFileNode.Context.DebugLoggingEnabled)
                _currentFileNode.Context.CurrentTask.DebugLog(String.Format("   - {0,-30} -> {1}", String.Format("<{0}>", node.Value.Value), expandedText));
        }

        /// <summary>
        /// Processes a text token, writing the text to the output stream.
        /// </summary>
        /// <param name="node">TextNode to visit.</param>
        public void Visit(TextNode node)
        {
            //Apply the text processing rules that were established by TreePreExpander
            string cleanedOutput = CleanOutput(node, _killTextSibling ? (bool?)true : null);

            _killTextSibling = false;

            //Write the text to the output stream
            _outputStream.Write(cleanedOutput);

            //Debug logging? Log the text.
            if (_currentFileNode.Context.DebugLoggingEnabled)
            {
                if (cleanedOutput.Length > 0)
                {
                    cleanedOutput = cleanedOutput.Replace(" ", "<SP>").Replace("\t", "<TAB>").Replace("\r", "<CR>").Replace("\n", "<LF>");
                    if (cleanedOutput.Length > 30)
                        cleanedOutput = cleanedOutput.Substring(0, 30) + "...";
                }
                _currentFileNode.Context.CurrentTask.DebugLog(String.Format("   - {0,-30} -> {1}", "Text", cleanedOutput));
            }
        }

        /// <summary>
        /// Returns a TokenType that indicates the context in which an expression is being evaluated.
        /// </summary>
        /// <param name="expnode">Expression node being processed</param>
        /// <returns>TokeyType indicating the context in which the expression is being processed.</returns>
        private TokenType getContextForExpression(ExpressionNode expnode)
        {
            List<TokenValidity> expressionValidityList = expnode.Value.Bucket as List<TokenValidity>;
            List<TokenType> validLocations = new List<TokenType>();

            foreach (TokenValidity validity in expressionValidityList)
            {
                if (_validator.IsValid(validity, _currentFileNode, _currentLoops))
                {
                    switch (validity)
                    {
                        case TokenValidity.Anywhere:
                            return TokenType.Generic;

                        case TokenValidity.AnyLoop:
                            return TokenType.LoopUtility;

                        case TokenValidity.FieldLoop:
                            validLocations.Add(TokenType.FieldLoop);
                            break;

                        case TokenValidity.FieldSelectionLoop:
                            validLocations.Add(TokenType.FieldSelectionLoop);
                            break;

                        case TokenValidity.KeyLoop:
                            validLocations.Add(TokenType.KeyLoop);
                            break;

                        case TokenValidity.KeySegmentLoop:
                            validLocations.Add(TokenType.KeySegmentLoop);
                            break;

                        case TokenValidity.EnumLoop:
                            validLocations.Add(TokenType.EnumLoop);
                            break;

                        case TokenValidity.EnumMemberLoop:
                            validLocations.Add(TokenType.EnumMemberLoop);
                            break;

                        case TokenValidity.RelationLoop:
                            validLocations.Add(TokenType.RelationLoop);
                            break;

                        case TokenValidity.ButtonLoop:
                            validLocations.Add(TokenType.ButtonLoop);
                            break;

                        case TokenValidity.FileLoop:
                            validLocations.Add(TokenType.FileLoop);
                            break;

                        case TokenValidity.TagLoop:
                            validLocations.Add(TokenType.TagLoop);
                            break;

                        default:
                            break;
                    }
                }
            }

            if (validLocations.Count == 1)
                return validLocations[0];
            else if (validLocations.Count > 1)
            {
                foreach (LoopNode loop in _currentLoops)
                {
                    if (validLocations.Contains(loop.OpenToken.TypeOfToken))
                        return loop.OpenToken.TypeOfToken;
                }
                return validLocations[0];
            }
            else
                return TokenType.Text;
        }

        /// <summary>
        /// This method cleans the output of a TextNode according to the rules established by TreePreExpander
        /// </summary>
        /// <param name="node">TextNode to clean</param>
        /// <param name="firstLineNotInResult"></param>
        /// <returns>Cleaned string</returns>
        public static string CleanOutput(TextNode node, bool? firstLineNotInResult = null)
        {
            var realFirstLineNotInResult = firstLineNotInResult ?? node.FirstLineNotInResult;
            string cleanedOutput = node.Value.Value;

            if (node.LastLineNotInResult)
            {
                //Find the last <CR><LF>
                int lastNewline = cleanedOutput.LastIndexOf("\r\n");

                if (lastNewline == 0 && cleanedOutput.Length == 2)
                {
                    //All we have is a <CR><LF> ... leave it alone
                }
                else if (lastNewline != -1 && cleanedOutput.Length > (lastNewline + 2))
                {
                    //We have a <CR><LF>, there may or may not be data before the <CR><LF>, and there IS data after the <CR><LF>
                    //Remove all the data from the last <CR><LF> to the end, then put it back again, then remove trailing whitespace!!!
                    cleanedOutput = cleanedOutput.Remove(lastNewline + 2) + cleanedOutput.Substring(lastNewline + 2).TrimEnd(' ', '\t');

                    //TODO: That can't be right, try this:
                    //cleanedOutput = cleanedOutput.Remove(lastNewline,2).TrimEnd(' ', '\t');
                }
                else if (lastNewline == -1)
                {
                    cleanedOutput = cleanedOutput.TrimEnd(' ', '\t');
                }
            }
            if (realFirstLineNotInResult)
            {
                //Find the first <CR><LF>
                int firstNewline = cleanedOutput.IndexOf("\r\n");
                if (firstNewline > 0 && cleanedOutput.Take(firstNewline).Any((ch) => !char.IsWhiteSpace(ch)))
                {

                }
                else if (firstNewline > 0 && cleanedOutput.Take(firstNewline).All(ch => ch == ' ' || ch == '\t'))
                {
                    //We have a CRLF that has characters before it, and those characters are all whitespace
                    //Remove the whitespace before the <CR><LF>
                    cleanedOutput = cleanedOutput.TrimStart(' ', '\t');
                    //Remove the <CR><LF>
                    cleanedOutput = cleanedOutput.Remove(cleanedOutput.IndexOf("\r\n"), 2);
                }
                else if (firstNewline != -1)
                {
                    //We have a <CR><LF> somewhere in the string, maybe at the beggining, maybe after some other data.
                    //Just remove the <CR><LF>

                    //TODO: Is this right, or should be be removing everything UP TO AND INCLUDING the Crlf?

                    cleanedOutput = cleanedOutput.Remove(firstNewline, 2);
                }
            }
            return cleanedOutput;
        }

        /// <summary>
        /// Defines the name of the output file that will be created. The name of the output file
        /// is stored in the passed FileNode's OutputFileName property. This method is called after
        /// code generation has completed.
        /// </summary>
        /// <param name="file"></param>
        private void setOutputFileName(FileNode file)
        {
            //If we're processing multiple structures at the same time then make sure we
            //reset the current structure to the first structure so file names will be
            //based on it.
            if (file.Context.MultiStructureMode)
                file.Context.CurrentStructure = file.Context.Structures[0];

            //Do we have any output file name tokens that were specified via <CODEGEN_FILENAME>?
            if (file.OutputFileNameTokens != null)
            {
                //Yes, we'll be using a custom output file name.
                using (StringWriter sw = new StringWriter())
                {
                    TreeExpander expander = new TreeExpander(file, _expander, _evaluator, sw);
                    foreach (ITreeNode node in file.OutputFileNameTokens)
                        node.Accept(expander);
                    file.OutputFileName = sw.ToString();
                }
            }
            else
            {
                //No, we'll be going with a default output file name
                file.OutputFileName = String.Format("{0}_{1}.dbl",
                    file.Context.CurrentStructure.Name.ToLower(),
                    file.Context.CurrentTemplateBaseName.ToLower());
            }
        }
    }
}

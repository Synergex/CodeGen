//*****************************************************************************
//
// Title:       Parser.cs
//
// Type:        Class
//
// Description: Parses a list of tokens into a tree of nodes
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
    public enum ParserState
    {
        /// <summary>
        /// 
        /// </summary>
        None,
        /// <summary>
        /// 
        /// </summary>
        InLoop,
        /// <summary>
        /// 
        /// </summary>
        LookingForElse,
        /// <summary>
        /// 
        /// </summary>
        LookingForCloser,
        /// <summary>
        /// 
        /// </summary>
        LookingForFile
    }

    /// <summary>
    /// 
    /// </summary>
    public class Parser
    {
        /// <summary>
        /// Parser wrapper used by CodeGenerator class. This method writes error messages to the current
        /// CodeGenTask as well as returning a fail status.
        /// </summary>
        /// <param name="tokens">Collection of tokens to be parsed.</param>
        /// <param name="context">Current CodeGen context (for provisioning of user tokens, extensions, etc.)</param>
        /// <param name="file">Returned tree of tokens represented by a FileNode object.</param>
        /// <returns>Returns true if the parse was successful, otherwise false and reports errors via context.CurrentTask.Messages.</returns>
        public static bool Parse(CodeGen.Engine.CodeGenContext context, List<Token> tokens, ref FileNode file)
        {
            List<Tuple<int, int, String>> errors = null;

            file = Parser.Parse(tokens, ref errors);

            if ((errors == null) || (errors.Count == 0))
            {
                errors = null;
                return true;
            }
            else
            {
                foreach (Tuple<int, int, String> error in errors)
                {
                    String message = String.Format("{0} At line {1} column {2} in template {3}", errors[0].Item3, errors[0].Item1, errors[0].Item2, Path.GetFileName(context.CurrentTemplate));
                    context.CurrentTask.ErrorLog(message);
                }
                return false;
            }
        }

        /// <summary>
        /// This overload is used by the Parse method above, and also by unit tests.
        /// </summary>
        /// <param name="tokens">Collection of tokens to be parsed.</param>
        /// <param name="errors">Returned collection of errors that occurred during the parse.</param>
        /// <returns>Tree of tokens represented by a FileNode</returns>
        public static FileNode Parse(List<Token> tokens, ref List<Tuple<int, int, String>> errors)
        {
            //Create the FileNode
            FileNode topLevelNode = new FileNode { Body = new List<ITreeNode>() };

            //Initialize the state stack
            Stack<ParserState> state = new Stack<ParserState>();
            state.Push(ParserState.None);
            state.Push(ParserState.LookingForFile);

            //Work through the collection of tokens that we got from tokenizer
            for (int i = 0; i < tokens.Count; i++)
            {
                Token tkn = tokens[i];
                switch (state.Peek())
                {
                    case ParserState.LookingForFile:
                        if (tkn.TypeOfToken == TokenType.FileHeader)
                        {
                            int endOfTag = getTagContentBounds(tokens, i + 1);
                            if (endOfTag != -1)
                            {
                                switch (tkn.Value)
                                {
                                    case "CODEGEN_FILENAME":
                                        if (topLevelNode.OutputFileNameTokens == null)
                                            topLevelNode.OutputFileNameTokens = nodesFromTokens(tokens, i + 1, endOfTag);
                                        else
                                            reportParserError(ref errors, tkn, "Token <CODEGEN_FILENAME> can only be used once in a template file!");
                                        break;
                                    case "REQUIRES_USERTOKEN":
                                        if (topLevelNode.RequiredUserTokens == null)
                                            topLevelNode.RequiredUserTokens = new List<string>();
                                        topLevelNode.RequiredUserTokens.Add(tokens[i + 1].Value.ToUpper());
                                        break;
                                    case "OPTIONAL_USERTOKEN":
                                        break;
                                    case "PROCESS_TEMPLATE":
                                        if (topLevelNode.ProcessTemplates == null)
                                            topLevelNode.ProcessTemplates = new List<string>();
                                        topLevelNode.ProcessTemplates.Add(tokens[i + 1].Value);
                                        break;
                                    case "PROVIDE_FILE":
                                        if (topLevelNode.ProvideFiles == null)
                                            topLevelNode.ProvideFiles = new List<string>();
                                        topLevelNode.ProvideFiles.Add(tokens[i + 1].Value);
                                        break;
                                    case "REQUIRES_OPTION":
                                        if (topLevelNode.RequiredOptions == null)
                                            topLevelNode.RequiredOptions = new List<string>();
                                        string optionValue = tokens[i + 1].Value.Trim().ToUpper();
                                        switch (optionValue)
                                        {
                                            case "FL":
                                            case "FO":
                                            case "FR":
                                            case "FT":
                                            case "FW":
                                            case "PREFIX":
                                            case "SUBSET":
                                                topLevelNode.RequiredOptions.Add(optionValue);
                                                break;
                                            default:
                                                reportParserError(ref errors, tkn, String.Format("Invalid option {0} detected in <REQUIRES_OPTION> token.", optionValue));
                                                break;
                                        }
                                        break;
                                    case "REQUIRES_CUSTOM_TOKEN":
                                        if (topLevelNode.RequiredCustomTokens == null)
                                            topLevelNode.RequiredCustomTokens = new List<Tuple<TokenValidity, string>>();
                                        topLevelNode.RequiredCustomTokens.Add(Tuple.Create(TokenValidity.Anywhere, tokens[i + 1].Value));
                                        break;
                                    case "REQUIRES_CUSTOM_BUTTON_TOKEN":
                                        if (topLevelNode.RequiredCustomTokens == null)
                                            topLevelNode.RequiredCustomTokens = new List<Tuple<TokenValidity, string>>();
                                        topLevelNode.RequiredCustomTokens.Add(Tuple.Create(TokenValidity.ButtonLoop, tokens[i + 1].Value));
                                        break;
                                    case "REQUIRES_CUSTOM_ENUM_TOKEN":
                                        if (topLevelNode.RequiredCustomTokens == null)
                                            topLevelNode.RequiredCustomTokens = new List<Tuple<TokenValidity, string>>();
                                        topLevelNode.RequiredCustomTokens.Add(Tuple.Create(TokenValidity.EnumLoop, tokens[i + 1].Value));
                                        break;
                                    case "REQUIRES_CUSTOM_ENUM_MEMBER_TOKEN":
                                        if (topLevelNode.RequiredCustomTokens == null)
                                            topLevelNode.RequiredCustomTokens = new List<Tuple<TokenValidity, string>>();
                                        topLevelNode.RequiredCustomTokens.Add(Tuple.Create(TokenValidity.EnumMemberLoop, tokens[i + 1].Value));
                                        break;
                                    case "REQUIRES_CUSTOM_FIELD_TOKEN":
                                        if (topLevelNode.RequiredCustomTokens == null)
                                            topLevelNode.RequiredCustomTokens = new List<Tuple<TokenValidity, string>>();
                                        topLevelNode.RequiredCustomTokens.Add(Tuple.Create(TokenValidity.FieldLoop, tokens[i + 1].Value));
                                        break;
                                    case "REQUIRES_CUSTOM_FILE_TOKEN":
                                        if (topLevelNode.RequiredCustomTokens == null)
                                            topLevelNode.RequiredCustomTokens = new List<Tuple<TokenValidity, string>>();
                                        topLevelNode.RequiredCustomTokens.Add(Tuple.Create(TokenValidity.FileLoop, tokens[i + 1].Value));
                                        break;
                                    case "REQUIRES_CUSTOM_KEY_TOKEN":
                                        if (topLevelNode.RequiredCustomTokens == null)
                                            topLevelNode.RequiredCustomTokens = new List<Tuple<TokenValidity, string>>();
                                        topLevelNode.RequiredCustomTokens.Add(Tuple.Create(TokenValidity.KeyLoop, tokens[i + 1].Value));
                                        break;
                                    case "REQUIRES_CUSTOM_RELATION_TOKEN":
                                        if (topLevelNode.RequiredCustomTokens == null)
                                            topLevelNode.RequiredCustomTokens = new List<Tuple<TokenValidity, string>>();
                                        topLevelNode.RequiredCustomTokens.Add(Tuple.Create(TokenValidity.RelationLoop, tokens[i + 1].Value));
                                        break;
                                    case "REQUIRES_CUSTOM_SEGMENT_TOKEN":
                                        if (topLevelNode.RequiredCustomTokens == null)
                                            topLevelNode.RequiredCustomTokens = new List<Tuple<TokenValidity, string>>();
                                        topLevelNode.RequiredCustomTokens.Add(Tuple.Create(TokenValidity.KeySegmentLoop, tokens[i + 1].Value));
                                        break;
                                    case "REQUIRES_CUSTOM_SELECTION_TOKEN":
                                        if (topLevelNode.RequiredCustomTokens == null)
                                            topLevelNode.RequiredCustomTokens = new List<Tuple<TokenValidity, string>>();
                                        topLevelNode.RequiredCustomTokens.Add(Tuple.Create(TokenValidity.FieldSelectionLoop, tokens[i + 1].Value));
                                        break;
                                }

                                i = endOfTag;
                            }
                            //else errors!
                        }
                        else if (tkn.TypeOfToken == TokenType.Text)
                        {
                            tkn.Value = tkn.Value.TrimStart(' ', '\n', '\r', '\t');
                            topLevelNode.Body.Add(new TextNode { Value = tkn });
                        }
                        else
                        {
                            i--;
                            state.Pop();
                        }
                        break;
                    case ParserState.InLoop:
                    case ParserState.LookingForElse:
                    case ParserState.LookingForCloser:
                    case ParserState.None:
                        int endIndex = process(topLevelNode.Body, tokens, i, state, ref errors, null);
                        if (endIndex != -1)
                            i = endIndex;
                        break;
                }
            }

            if ((errors != null) && (errors.Count == 0))
                errors = null;

            return topLevelNode;
        }

        /// <summary>
        /// Adds an error to the collection of errors generated by the current parse
        /// </summary>
        /// <param name="errors">Collection of errors</param>
        /// <param name="tkn">Token being processes</param>
        /// <param name="message">Error message</param>
        private static void reportParserError(ref List<Tuple<int, int, string>> errors, Token tkn, string message)
        {
            if (errors == null)
                errors = new List<Tuple<int, int, string>>();
            errors.Add(Tuple.Create(tkn.StartLineNumber, tkn.StartColumn, message));
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="list"></param>
        /// <param name="tokens"></param>
        /// <param name="startIndex"></param>
        /// <param name="state"></param>
        /// <param name="errors"></param>
        /// <param name="currentIfNode"></param>
        /// <returns></returns>
        private static int process(List<ITreeNode> list, List<Token> tokens, int startIndex, Stack<ParserState> state, ref List<Tuple<int, int, String>> errors, IfNode currentIfNode)
        {
            for (int i = startIndex; i < tokens.Count; i++)
            {
                Token tkn = tokens[i];

                if (tkn.Closer)
                    return i;

                //change state if we see a loop token or a control token

                switch (tkn.TypeOfToken)
                {
                    case TokenType.Loop:
                        int endOfLoop = processLoop(list, tokens, i, state, ref errors);
                        if (endOfLoop != -1)
                            i = endOfLoop;
                        break;

                    case TokenType.Control:
                        {
                            if (tokens[i].Value == "ELSE")
                            {
                                //int endOfElse = processElse(list, tokens, i, state, ref errors);
                                int endOfElse = processElse(currentIfNode, tokens, i, state, ref errors);
                                if (endOfElse != -1)
                                {
                                    i = endOfElse;
                                    if (state.Count > 0 && state.First() == ParserState.LookingForElse)
                                        return i;
                                }

                            }
                            else
                            {
                                int endOfControl = processControl(list, tokens, i, state, ref errors);
                                if (endOfControl != -1)
                                    i = endOfControl;
                            }
                        }
                        break;

                    case TokenType.Text:
                        list.Add(new TextNode() { Value = tkn });
                        break;

                    default:
                        list.Add(new ExpansionNode { Value = tkn });
                        break;
                }
            }
            return tokens.Count;
        }

        private static int processLoop(List<ITreeNode> list, List<Token> tokens, int startIndex, Stack<ParserState> state, ref List<Tuple<int, int, String>> errors)
        {
            LoopNode loop;

            switch (tokens[startIndex].Value)
            {
                case "FIELD_LOOP":
                    loop = new FieldLoopNode
                    {
                        OpenToken = tokens[startIndex],
                        Body = new List<ITreeNode>()
                    };
                    break;

                case "SELECTION_LOOP":
                    loop = new SelectionLoopNode
                    {
                        OpenToken = tokens[startIndex],
                        Body = new List<ITreeNode>()
                    };
                    break;

                case "KEY_LOOP":
                case "ALTERNATE_KEY_LOOP":
                case "PRIMARY_KEY":
                    loop = new KeyLoopNode()
                    {
                        OpenToken = tokens[startIndex],
                        Body = new List<ITreeNode>()
                    };
                    break;

                case "SEGMENT_LOOP":
                case "SEGMENT_LOOP_FILTER":
                case "FIRST_SEGMENT":
                case "SECOND_SEGMENT":
                    loop = new SegmentLoopNode
                    {
                        OpenToken = tokens[startIndex],
                        Body = new List<ITreeNode>()
                    };
                    break;

                case "ENUM_LOOP":
                case "ENUM_LOOP_STRUCTURE":
                    loop = new EnumLoopNode
                    {
                        OpenToken = tokens[startIndex],
                        Body = new List<ITreeNode>()
                    };
                    break;

                case "ENUM_MEMBER_LOOP":
                    loop = new EnumMemberLoopNode
                    {
                        OpenToken = tokens[startIndex],
                        Body = new List<ITreeNode>()
                    };
                    break;

                case "RELATION_LOOP":
                    loop = new RelationLoopNode
                    {
                        OpenToken = tokens[startIndex],
                        Body = new List<ITreeNode>()
                    };
                    break;

                case "BUTTON_LOOP":
                    loop = new ButtonLoopNode
                    {
                        OpenToken = tokens[startIndex],
                        Body = new List<ITreeNode>()
                    };
                    break;

                case "FILE_LOOP":
                    loop = new FileLoopNode
                    {
                        OpenToken = tokens[startIndex],
                        Body = new List<ITreeNode>()
                    };
                    break;

                case "TAG_LOOP":
                    loop = new TagLoopNode
                    {
                        OpenToken = tokens[startIndex],
                        Body = new List<ITreeNode>()
                    };
                    break;

                case "STRUCTURE_LOOP":
                    loop = new StructureLoopNode
                    {
                        OpenToken = tokens[startIndex],
                        Body = new List<ITreeNode>()
                    };
                    break;

                default:
                    loop = null;
                    break;
            }

            list.Add(loop);

            int closer = process(loop.Body, tokens, startIndex + 1, state, ref errors, null);

            if (closer != -1 && closer != tokens.Count)
            {
                //TODO: There is a problem here somewhere. With the folowing template, the </IF> is being associated with the loop.CloseToken!
                /*
                 * <FIELD_LOOP>
                 * <IF PROMPT>
                 * Prompt
                 * </ELSE>
                 * No prompt
                 * </IF>
                 * </FIELD_LOOP>
                 */

                loop.CloseToken = tokens[closer];
            }
            return closer;
        }

        private static int processControl(List<ITreeNode> list, List<Token> tokens, int startIndex, Stack<ParserState> state, ref List<Tuple<int, int, String>> errors)
        {
            IfNode ctrlNode = new IfNode
            {
                Body = new List<ITreeNode>(),
                OpenToken = tokens[startIndex]
            };
            list.Add(ctrlNode);

            Token tkn = null;

            try
            {
                for (int i = startIndex + 1; i < tokens.Count; i++)
                {
                    tkn = tokens[i];
                    switch (tkn.TypeOfToken)
                    {
                        case TokenType.Expression:
                            ctrlNode.Expression = new ExpressionNode { Value = tkn };
                            break;

                        default:
                            state.Push(ParserState.LookingForElse);
                            try
                            {
                                int endOfProcessed = process(ctrlNode.Body, tokens, i, state, ref errors, ctrlNode);
                                if (endOfProcessed != -1 && tokens[endOfProcessed].Closer)
                                {
                                    ctrlNode.CloseToken = tokens[endOfProcessed];
                                }
                                //check if we've got a trailing expression, this is not validated/required it is simply ignored
                                if (endOfProcessed != -1 && (tokens.Count - 1) > (endOfProcessed + 1) && tokens[endOfProcessed + 1].TypeOfToken == TokenType.Expression)
                                {
                                    endOfProcessed++;
                                }
                                return endOfProcessed;
                            }
                            finally
                            {
                                state.Pop();
                            }
                    }
                }
            }
            finally
            {
                if (ctrlNode.Expression == null)
                    reportParserError(ref errors, tkn, "CODEGEN BUG: Parser encountered an IfNode without an associated ExpressionNode. This indicates a bug in Tokenizer.");
            }
            return -1;

        }

        private static int processElse(IfNode ctrlNode, List<Token> tokens, int startIndex, Stack<ParserState> state, ref List<Tuple<int, int, String>> errors)
        {
            for (int i = startIndex; i < tokens.Count; i++)
            {
                Token tkn = tokens[i];
                if (tkn.TypeOfToken == TokenType.Control && tkn.Value == "ELSE")
                {
                    ctrlNode.Else = new ElseNode
                    {
                        OpenToken = tkn,
                        Body = new List<ITreeNode>()
                    };
                    int endOfProcessed = process(ctrlNode.Else.Body, tokens, i + 1, state, ref errors, null);
                    if (endOfProcessed != -1 && endOfProcessed < tokens.Count && tokens[endOfProcessed].Closer)
                    {
                        ctrlNode.CloseToken = ctrlNode.Else.CloseToken = tokens[endOfProcessed];
                    }
                    return endOfProcessed;
                }
                else if (tkn.TypeOfToken == TokenType.Text)
                    continue;
                else
                    break;
            }
            return startIndex;
        }

        //Not sure what the intention of this overload was, but it seems to do the wrong thing, and is no longer called.
        //private static int processElse(List<ITreeNode> list, List<Token> tokens, int startIndex, Stack<ParserState> state, ref List<Tuple<int, int, String>> errors)
        //{
        //    for (int i = startIndex; i < tokens.Count; i++)
        //    {
        //        Token tkn = tokens[i];
        //        if (tkn.TypeOfToken == TokenType.Control && tkn.Value == "ELSE")
        //        {
        //            ElseNode ctrlNode = new ElseNode { Body = new List<ITreeNode>() };
        //            list.Add(ctrlNode);
        //            return process(ctrlNode.Body, tokens, i + 1, state, ref errors, null);
        //        }
        //        else if (tkn.TypeOfToken == TokenType.Text)
        //            continue;
        //        else
        //            break;
        //    }
        //    return startIndex;
        //}

        private static List<ITreeNode> nodesFromTokens(List<Token> tokens, int startIndex, int endIndex)
        {
            List<ITreeNode> results = new List<ITreeNode>();
            for (int i = startIndex; i < endIndex; i++)
            {
                if (tokens[i].TypeOfToken == TokenType.Text)
                    results.Add(new TextNode { Value = tokens[i] });
                else
                    results.Add(new ExpansionNode { Value = tokens[i] });
            }
            return results;
        }

        private static int getTagContentBounds(List<Token> tokens, int startIndex)
        {
            for (int i = startIndex; i < tokens.Count; i++)
            {
                if (tokens[i].Closer)
                    return i;
            }
            return -1;
        }

    }
}

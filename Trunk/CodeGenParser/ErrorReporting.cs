//*****************************************************************************
//
// Title:       ErrorReporting.cs
//
// Type:        Class
//
// Description: Tree visitor that logs the structure of the tree to a file
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

namespace CodeGen.Engine
{
    /// <summary>
    /// 
    /// </summary>
    public class ErrorReporting : ITreeNodeVisitor
    {
        private FileNode currentFileNode;
        private List<LoopNode> currentLoops = new List<LoopNode>();
        private TokenValidation tokenValidation = new TokenValidation();

        /// <summary>
        /// 
        /// </summary>
        public List<Tuple<string, int, int, string>> Errors = new List<Tuple<string, int, int, string>>();

        private void reportValidity(Token tkn)
        {
            List<TokenValidity> validity = tkn.Bucket as List<TokenValidity>;
            foreach (TokenValidity valid in validity)
            {
                if (tokenValidation.IsValid(valid, currentFileNode, currentLoops))
                    return;
            }
            Errors.Add(Tuple.Create(String.Format("Token {0} was found in an invalid location.",tkn.Value), tkn.StartLineNumber, tkn.StartColumn, tkn.File));
        }

        private void Visit(IEnumerable<ITreeNode> nodes)
        {
            foreach (ITreeNode node in nodes)
            {
                node.Accept(this);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="node"></param>
        public void Visit(LoopNode node)
        {
            reportValidity(node.OpenToken);
            currentLoops.Add(node);
            Visit(node.Body);
            currentLoops.Remove(node);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="node"></param>
        public void Visit(IfNode node)
        {
            Visit(node.Expression);
            Visit(node.Body);
            if (node.Else != null)
                Visit(node.Else);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="node"></param>
        public void Visit(ExpressionNode node)
        {
            reportValidity(node.Value);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="node"></param>
        public void Visit(ElseNode node)
        {
            Visit(node.Body);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="node"></param>
        public void Visit(ExpansionNode node)
        {
            reportValidity(node.Value);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="node"></param>
        public void Visit(TextNode node)
        {

        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="node"></param>
        public void Visit(FileNode node)
        {
            //Analyze the structure of the tree
            currentFileNode = node;
            Visit(node.Body);

            //Check for required user-defined tokens
            if ((node.RequiredUserTokens != null) && node.RequiredUserTokens.Count > 0)
            {
                foreach (string requiredToken in node.RequiredUserTokens)
                {
                    bool foundUserToken = false;
                    foreach (UserToken userToken in node.Context.UserTokens)
                    {
                        if (userToken.Name == requiredToken)
                        {
                            foundUserToken = true;
                            break;
                        }
                    }
                    if (!foundUserToken)
                    {
                        string message = String.Format("Template {0} requires a user-defined token {1} which is not defined.", node.Context.CurrentTemplateBaseName, requiredToken);
                        Errors.Add(Tuple.Create(message, (int)0, (int)0, node.Context.CurrentTemplate));
                    }
                }
            }

            //Check for required custom token expanders
            if ((node.RequiredCustomTokens != null) && (node.RequiredCustomTokens.Count > 0))
            {
                foreach (Tuple<TokenValidity,string> requiredToken in node.RequiredCustomTokens)
                {
                    bool tokenFound = false;
                    foreach (Tuple<string, string, TokenValidity, TokenCaseMode, Func<Token, FileNode, IEnumerable<LoopNode>, string>> customToken in node.Context.CustomTokenExpanders)
                    {
                        if ((customToken.Item3 == requiredToken.Item1) && (customToken.Item1 == requiredToken.Item2))
                        {
                            tokenFound = true;
                            break;
                        }
                    }
                    if (!tokenFound)
                    {
                        string message = String.Format("Template {0} requires a custom {1} token {2} which has not been loaded.", node.Context.CurrentTemplateBaseName, requiredToken.Item1, requiredToken.Item2);
                        Errors.Add(Tuple.Create(message, (int)0, (int)0, node.Context.CurrentTemplate));
                    }
                }
            }

            //Check for required custom expression processors
            if ((node.RequiredCustomExpressions != null) && (node.RequiredCustomExpressions.Count > 0))
            {
                foreach (Tuple<TokenValidity, string> requiredExpression in node.RequiredCustomExpressions)
                {
                    bool expressionFound = false;
                    foreach (Tuple<string, string, TokenValidity, Func<Token, FileNode, IEnumerable<LoopNode>, bool>> customExpression in node.Context.CustomExpressionEvaluators)
                    {
                        if ((customExpression.Item3 == requiredExpression.Item1) && (customExpression.Item1 == requiredExpression.Item2))
                        {
                            expressionFound = true;
                            break;
                        }
                    }
                    if (!expressionFound)
                    {
                        string message = String.Format("Template {0} requires a custom {1} expression {2} which has not been loaded.", node.Context.CurrentTemplateBaseName, requiredExpression.Item1, requiredExpression.Item2);
                        Errors.Add(Tuple.Create(message, (int)0, (int)0, node.Context.CurrentTemplate));
                    }
                }
            }

            //Check for required processing options
            if ((node.RequiredOptions != null) && (node.RequiredOptions.Count > 0))
            {
                foreach (string requiredOption in node.RequiredOptions)
                {
                    switch (requiredOption)
                    {
                        case "FL":
                            if (!node.Context.CurrentTask.IgnoreExcludeLanguage)
                            {
                                string message = String.Format("Template {0} requires that the 'ignore excluded by language' option (-f l) is used.", node.Context.CurrentTemplateBaseName);
                                Errors.Add(Tuple.Create(message, (int)0, (int)0, node.Context.CurrentTemplate));
                            }
                            break;
                        case "FO":
                            if (!node.Context.CurrentTask.IncludeOverlayFields)
                            {
                                string message = String.Format("Template {0} requires that the 'include overlay fields' option (-f o) is used.", node.Context.CurrentTemplateBaseName);
                                Errors.Add(Tuple.Create(message, (int)0, (int)0, node.Context.CurrentTemplate));
                            }
                            break;
                        case "FR":
                            if (!node.Context.CurrentTask.HonorExcludeReportWriter)
                            {
                                string message = String.Format("Template {0} requires that the 'honor excluded by ReportWriter' option (-f r) is used.", node.Context.CurrentTemplateBaseName);
                                Errors.Add(Tuple.Create(message, (int)0, (int)0, node.Context.CurrentTemplate));
                            }
                            break;
                        case "FT":
                            if (!node.Context.CurrentTask.HonorExcludeToolkit)
                            {
                                string message = String.Format("Template {0} requires that the 'honor excluded by Toolkit' option (-f t) is used.", node.Context.CurrentTemplateBaseName);
                                Errors.Add(Tuple.Create(message, (int)0, (int)0, node.Context.CurrentTemplate));
                            }
                            break;
                        case "FW":
                            if (!node.Context.CurrentTask.HonorExcludeWeb)
                            {
                                string message = String.Format("Template {0} requires that the 'honor excluded by Web' option (-f w) is used.", node.Context.CurrentTemplateBaseName);
                                Errors.Add(Tuple.Create(message, (int)0, (int)0, node.Context.CurrentTemplate));
                            }
                            break;
                        case "PREFIX":
                            if (String.IsNullOrWhiteSpace(node.Context.CurrentTask.FieldPrefix))
                            {
                                string message = String.Format("Template {0} requires that the 'field prefix' option (-prefix) is used.", node.Context.CurrentTemplateBaseName);
                                Errors.Add(Tuple.Create(message, (int)0, (int)0, node.Context.CurrentTemplate));
                            }
                            break;
                        case "SUBSET":
                            if (String.IsNullOrWhiteSpace(node.Context.CurrentTask.Subset) && (node.Context.CurrentTask.SubsetFields.Count == 0))
                            {
                                string message = String.Format("Template {0} requires that subset processing is (-subset or -fields) is used.", node.Context.CurrentTemplateBaseName);
                                Errors.Add(Tuple.Create(message, (int)0, (int)0, node.Context.CurrentTemplate));
                            }
                            break;
                    }
                }
            }
        }
    }
}
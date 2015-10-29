//*****************************************************************************
//
// Title:       TreeLogger.cs
//
// Type:        Class
//
// Description: Tree visitor that performs error checking and reporting on a tree
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
using System.IO;
using System.Linq;

namespace CodeGen.Engine
{
    /// <summary>
    /// Validates the structure of a template file tree by walking the tree and analyzing its structure.
    /// Uses TokenValidation.IsValid to determine whether each node in the tree is in an appropriate
    /// position, based on the rules defined by the TokenValidity enum.
    /// </summary>
    public class TreeLogger : ITreeNodeVisitor
    {
        private FileNode currentFileNode;
        private List<LoopNode> currentLoops = new List<LoopNode>();
        private StreamWriter sw;
        private String logFile;
        private string indentText = "";

        /// <summary>
        /// 
        /// </summary>
        /// <param name="logFileName"></param>
        public TreeLogger(string logFileName)
        {
            logFile = logFileName;
        }

        private void logToken(string text)
        {
            sw.WriteLine(String.Format("{0}{1}", indentText, text));
        }

        private void indent()
        {
            indentText += "\t";
        }

        private void unindent()
        {
            indentText = indentText.Substring(0, indentText.Length - 1);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="node"></param>
        public void Visit(FileNode node)
        {
            //Write the structure of the tree to a file
            using (sw = File.CreateText(logFile))
            {
                currentFileNode = node;
                Visit(node.Body);

                sw.Close();
            }
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
            logToken(String.Format("<{0}>",node.OpenToken.Value));

            currentLoops.Add(node);

            indent();
            Visit(node.Body);
            unindent();

            currentLoops.Remove(node);

            logToken(String.Format("</{0}>", node.OpenToken.Value));
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="node"></param>
        public void Visit(IfNode node)
        {
            if (node.Expression == null)
                throw new ApplicationException("CODEGEN BUG: TreeLogger.Visit(IfNode) encountered an IfNode without an associated ExpressionNode. This indicates a Parser bug!");

            logToken(String.Format("<IF {0}>",node.Expression.Value.Value));
            indent();
            Visit(node.Body);
            unindent();

            
            if (node.Else != null)
            {
                logToken("<ELSE>");
                indent();
                Visit(node.Else.Body);
                unindent();
            }

            logToken(String.Format("</IF {0}>", node.Expression.Value.Value));

        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="node"></param>
        public void Visit(ExpressionNode node)
        {
            throw new NotImplementedException("CODEGEN BUG: TreeLogger.Visit(ExpressionNode) should not be called. This indicates a Parser bug.");
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="node"></param>
        public void Visit(ElseNode node)
        {
            throw new NotImplementedException("CODEGEN BUG: TreeLogger.Visit(ElseNode) should not be called. This indicates a Parser bug.");
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="node"></param>
        public void Visit(ExpansionNode node)
        {
            logToken(node.Value.ToString());
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="node"></param>
        public void Visit(TextNode node)
        {
            logToken(TreeExpander.CleanOutput(node).Replace("\r", "<CR>").Replace("\n", "<LF>").Replace("\t", "<TAB>"));
        }
    }
}

//*****************************************************************************
//
// Title:       TreePreExpander.cs
//
// Type:        Class
//
// Description: Tree visitor performing pre-expansion of the tree, including
//              loop expansion.
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
using System.Linq;

namespace CodeGen.Engine
{
    /// <summary>
    /// This class is used to pre-process the tree that was created by Parser and tag various nodes as
    /// not being part of the final output stream.
    /// </summary>
    public class TreePreExpander : ITreeNodeVisitor
	{
        /// <summary>
        /// Pre-processes a collection of nodes, generally from the Body of another node.
        /// </summary>
        /// <param name="nodes">Collection of tree nodes to process.</param>
		private void TagPriorToControlBody(List<ITreeNode> nodes)
		{
			for (int i = 0; i < nodes.Count; i++)
			{
                if (nodes[i] is ControlNode && i > 0 && nodes[i - 1] is TextNode)
                {
                    ControlNode cnode = nodes[i] as ControlNode;
                    if (cnode.CloseToken != null && cnode.OpenToken.StartLineNumber != cnode.CloseToken.EndLineNumber)
                    {
                        TextNode tnode = nodes[i - 1] as TextNode;
                        tnode.LastLineNotInResult = true;
                    }
                }
                if (nodes[i] is ControlNode && i < (nodes.Count - 1) && nodes[i + 1] is TextNode)
                {
                    ControlNode cnode = nodes[i] as ControlNode;
                    if (cnode.CloseToken != null && cnode.OpenToken.StartLineNumber != cnode.CloseToken.EndLineNumber)
                    {
                        TextNode tnode = nodes[i + 1] as TextNode;
                        tnode.FirstLineNotInResult = true;
                    }
                }

                //also do expansion tokens like Counters
                if (nodes[i] is ExpansionNode && i > 0 && nodes[i - 1] is TextNode)
                {
                    ExpansionNode cnode = nodes[i] as ExpansionNode;
                    if (cnode.Value.TypeOfToken == TokenType.CounterInstruction)
                    {
                        TextNode tnode = nodes[i - 1] as TextNode;
                        tnode.LastLineNotInResult = true;
                    }
                }
                if (nodes[i] is ExpansionNode && i < (nodes.Count - 1) && nodes[i + 1] is TextNode)
                {
                    ExpansionNode cnode = nodes[i] as ExpansionNode;
                    if (cnode.Value.TypeOfToken == TokenType.CounterInstruction)
                    {
                        TextNode tnode = nodes[i + 1] as TextNode;
                        tnode.FirstLineNotInResult = true;
                    }
                }

			}
		}

        /// <summary>
        /// Pre-processes control nodes, setting the FirstLineNotInResult and LastLineNotInResult properties of
        /// various nodes based on the location of the control node. Control nodes include all LOOP, IF and ELSE nodes.
        /// </summary>
        /// <param name="cnode">Control node to process. </param>
        private void TagFirstLastControlBody(ControlNode cnode)
		{
            //If there is a close token (there always should be) and the open and close tokens are not on the same line
            //then we'll park the 
            if (cnode.CloseToken != null && cnode.OpenToken.StartLineNumber != cnode.CloseToken.EndLineNumber)
			{
                TextNode firstTextNode = cnode.Body.First() as TextNode;
                TextNode lastTextNode = cnode.Body.Last() as TextNode;

				if (firstTextNode != null)
				{
					firstTextNode.FirstLineNotInResult = true;
				}
				if (lastTextNode != null)
				{
					lastTextNode.LastLineNotInResult = true;
				}
			}
		}

        /// <summary>
        /// Called by the consumer application to prepare the tree for expansion.
        /// Removes new lines around loop tokens, etc.
        /// </summary>
        /// <param name="node">Tree to generate output from.</param>
        public void Visit(FileNode node)
        {
            Visit(node.Body);
        }

        /// <summary>
        /// Visit a collection of nodes
        /// </summary>
        /// <param name="nodes"></param>
        private void Visit(List<ITreeNode> nodes)
		{
			TagPriorToControlBody(nodes);
			foreach (ITreeNode node in nodes)
			{
				node.Accept(this);
			}
		}

        /// <summary>
        /// Visit any LOOP node.
        /// </summary>
        /// <param name="loop"></param>
		public void Visit(LoopNode loop)
		{
			TagFirstLastControlBody(loop);
			Visit(loop.Body);
		}

        /// <summary>
        /// Visit an IF node
        /// </summary>
        /// <param name="node"></param>
		public void Visit(IfNode node)
		{
            if (node.Expression == null)
                throw new ApplicationException("CODEGEN BUG: TreePreExpander.Visit(IfNode) encountered an IfNode without an associated ExpressionNode. This indicates a Parser bug!");

			TagFirstLastControlBody(node);
			Visit(node.Body);
			
			if (node.Else != null)
			{
				TagFirstLastControlBody(node.Else);
				Visit(node.Else.Body);
			}
		}

        /// <summary>
        /// Visit an EXPRESSION node. In theory this should never happen because expression nodes
        /// are processed as part of an enclosing IF node.
        /// </summary>
        /// <param name="node"></param>
		public void Visit(ExpressionNode node)
		{
            throw new ApplicationException("CODEGEN BUG: TreePreExpander.Visit(ExpressionNode) should not be called. This indicates a Parser bug.");
        }

        /// <summary>
        /// Visit an ELSE node. In theory this should never happen because else nodes
        /// are processed as part of an associated IF node.
        /// </summary>
        /// <param name="node"></param>
		public void Visit(ElseNode node)
		{
            throw new ApplicationException("CODEGEN BUG: TreePreExpander.Visit(ElseNode) should not be called. This indicates a Parser bug.");
		}

		/// <summary>
		/// Visit an EXPANSION node.
		/// </summary>
		/// <param name="node"></param>
		public void Visit(ExpansionNode node)
		{

		}

        /// <summary>
        /// Visit a TEXT node.
        /// </summary>
        /// <param name="node"></param>
		public void Visit(TextNode node)
		{
			
		}

    }
}

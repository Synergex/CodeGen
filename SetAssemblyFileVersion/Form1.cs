using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SetAssemblyFileVersion
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            String root = Environment.GetEnvironmentVariable("DEVROOT");
            if (!String.IsNullOrWhiteSpace(root))
                txtRootFolder.Text = root;
        }

        private void btnGo_Click(object sender, EventArgs e)
        {
            int filesWritten = 0;

    		foreach (String fileName in lstFiles.Items)
            {
			    //Get the data from the file
			    List<String> sourceLines = new List<String>(File.ReadAllLines(fileName));

			    for (int ix=0 ; ix < sourceLines.Count; ix++)
                {
				    String sourceLine = sourceLines[ix];
				    if (sourceLine.StartsWith("{assembly: AssemblyFileVersion("))
				    {
                        sourceLines[ix] = "{assembly: AssemblyFileVersion(\"" + txtNewVersionNumbers.Text + "\")}";
					    break;
				    }
				    else if (sourceLine.StartsWith("[assembly: AssemblyFileVersion("))
    				{
                        sourceLines[ix] = "[assembly: AssemblyFileVersion(\"" + txtNewVersionNumbers.Text + "\")]";
					    break;
                    }
                }

                //If the file is read-only, make it writable
                FileAttributes attributes = File.GetAttributes(fileName);
                if ((attributes & FileAttributes.ReadOnly) == FileAttributes.ReadOnly)
                {
                    // Make the file RW
                    attributes = attributes & ~FileAttributes.ReadOnly;
                    File.SetAttributes(fileName, attributes);
                }

			    //Re-write the file
			    File.WriteAllLines(fileName,sourceLines);
                filesWritten += 1;
            }

            MessageBox.Show(this, String.Format("{0} files updated.", filesWritten));

        }

        private static FileAttributes RemoveAttribute(FileAttributes attributes, FileAttributes attributesToRemove)
        {
            return attributes & ~FileAttributes.ReadOnly;
        }


        private void btnFolderLookup_Click(object sender, EventArgs e)
        {
            if (folderBrowserDialog1.ShowDialog(this) == DialogResult.OK)
                txtRootFolder.Text = folderBrowserDialog1.SelectedPath;
        }

        private void txtRootFolder_TextChanged(object sender, EventArgs e)
        {
            getFiles();
        }

        private void chkIncludeSubFolders_CheckedChanged(object sender, EventArgs e)
        {
            getFiles();
        }

        private void getFiles()
        {
            SearchOption option = chkIncludeSubFolders.Checked ? SearchOption.AllDirectories : SearchOption.TopDirectoryOnly;

            foreach (String fileName in Directory.GetFiles(txtRootFolder.Text, "AssemblyInfo.*", option))
                lstFiles.Items.Add(fileName);

            btnGo.Enabled = lstFiles.Items.Count > 0;

        }

    }
}

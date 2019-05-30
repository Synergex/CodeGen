using CodeGen.RepositoryAPI;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HarmonyCoreGenerator
{
    public class StructureRow
    {
        /// <summary>
        /// Constructor for deserialization
        /// </summary>
        public StructureRow()
        {
            ProcessingMode = "None";
        }

        /// <summary>
        /// Constructor for initial repository population
        /// </summary>
        /// <param name="str">Repository structure object</param>
        public StructureRow(RpsStructure str)
            : this()
        {
            Name = str.Name;
            Alias = str.Alias.Equals(str.Name) ? String.Empty : str.Alias;
        }

        public string Name { get; set; }

        public string Alias { get; set; }

        public string ProcessingMode { get; set; }
    }
}

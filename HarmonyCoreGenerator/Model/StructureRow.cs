using CodeGen.RepositoryAPI;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HarmonyCoreGenerator.Model
{
    public class StructureRow : ModelBase
    {
        /// <summary>
        /// Constructor for deserialization
        /// </summary>
        public StructureRow()
        {
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
            ProcessingMode = "None";
        }

        private string _Name = String.Empty;
        public string Name
        {
            get { return _Name; }
            set
            {
                if (!_Name.Equals(value))
                    _Name = value;
                NotifyPropertyChanged(nameof(Name));
            }
        }

        private string _Alias = String.Empty;
        public string Alias
        {
            get { return _Alias; }
            set
            {
                var upperValue = value.ToUpper();
                if (!_Alias.Equals(upperValue))
                    _Alias = upperValue;
                NotifyPropertyChanged(nameof(Alias));
            }
        }

        private string _ProcessingMode = String.Empty;
        public string ProcessingMode
        {
            get { return _ProcessingMode; }
            set
            {
                if (!_ProcessingMode.Equals(value))
                    _ProcessingMode = value;
                NotifyPropertyChanged(nameof(ProcessingMode));
            }
        }
    }
}

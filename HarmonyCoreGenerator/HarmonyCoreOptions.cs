using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HarmonyCoreGenerator
{
    public class HarmonyCoreOptions
    {

        public HarmonyCoreOptions()
        {
            ProcessingModes = new ObservableCollection<ProcessingMode>();
            ProcessingModes.Add(new ProcessingMode() { Id = "None", Description = "None" });
            ProcessingModes.Add(new ProcessingMode() { Id = "StructureAndFile", Description = "Structure and File" });
            ProcessingModes.Add(new ProcessingMode() { Id = "StructureOnly", Description = "Structure Only" });
            ProcessingModes.Add(new ProcessingMode() { Id = "CustomCodeOnly", Description = "Custom Code Only" });

            Structures = new ObservableCollection<StructureRow>();
        }

        //Repository files and structures
        public string RepositoryMainFile { get; set; }
        public string RepositoryTextFile { get; set; }
        public ObservableCollection<StructureRow> Structures { get; set; }

        //Structure processing modes
        public ObservableCollection<ProcessingMode> ProcessingModes { get; set; }

        //Output location settings
        public string ServicesFolder { get; set; }
        public string ControllersFolder { get; set; }
        public string ModelsFolder { get; set; }
        public string SelfHostFolder { get; set; }
        public string UnitTestFolder { get; set; }

        //Code generation options - controller endpoints

       public bool FullCollectionEndpoints { get; set; }
       public bool PrimaryKeyEndpoints { get; set; }
       public bool AlternateKeyEndpoints { get; set; }

       public bool CollectionCountEndpoints { get; set; }
       public bool IndividualPropertyEndpoints { get; set; }

       public bool PutEndpoints { get; set; }
       public bool PostEndpoints { get; set; }
       public bool PatchEndpoints { get; set; }
       public bool DeleteEndpoints { get; set; }

        //Code generation options - OData optional functionality

       public bool ODataSelect { get; set; }
       public bool ODataFilter { get; set; }
       public bool ODataOrderBy { get; set; }
       public bool ODataTop { get; set; }
       public bool ODataSkip { get; set; }
       public bool ODataRelations { get; set; }

        //Code generation options - self hosting and unit testing

       public bool GenerateSelfHost { get; set; }
       public bool CreateTestFiles { get; set; }
       public bool GeneratePostmanTests { get; set; }
       public bool GenerateUnitTests { get; set; }

        //Code generation options - documentation and versioning

       public bool GenerateSwaggerDocs { get; set; }
       public bool DocumentPropertyEndpoints { get; set; }
       public bool EnableApiVersioning { get; set; }

        //Code generation options - security

       public bool Authentication { get; set; }
       public bool CustomAuthentication { get; set; }
       public bool FieldSecurity { get; set; }

        //Code generation options - miscellaneous

       public bool AdapterRouting { get; set; }
       public bool StoredProcedureRouting { get; set; }
       public bool CaseSensitiveUrls { get; set; }
       public bool CrossDomainBrowsing { get; set; }
       public bool IISSupport { get; set; }
       public bool FieldOverlays { get; set; }
       public bool AlternateFieldNames { get; set; }
       public bool ReadOnlyProperties { get; set; }

    }
}

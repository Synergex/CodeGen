using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HarmonyCoreGenerator.Model
{
    public class HarmonyCoreOptions : ModelBase
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

        private string _RepositoryMainFile;
        public string RepositoryMainFile
        {
            get
            {
                return _RepositoryMainFile;
            }
            set
            {
                _RepositoryMainFile = value;
                NotifyPropertyChanged(nameof(RepositoryMainFile));
            }
        }

        private string _RepositoryTextFile;
        public string RepositoryTextFile
        {
            get
            {
                return _RepositoryTextFile;
            }
            set
            {
                _RepositoryTextFile = value;
                NotifyPropertyChanged(nameof(RepositoryTextFile));
            }
        }

        private ObservableCollection<StructureRow> _Structures;
        public ObservableCollection<StructureRow> Structures
        {
            get
            {
                return _Structures;
            }
            set
            {
                _Structures = value;
                NotifyPropertyChanged(nameof(Structures));
            }
        }

        //Structure processing modes

        private ObservableCollection<ProcessingMode> _ProcessingModes;
        public ObservableCollection<ProcessingMode> ProcessingModes
        {
            get
            {
                return _ProcessingModes;
            }
            set
            {
                _ProcessingModes = value;
                NotifyPropertyChanged(nameof(ProcessingModes));
            }
        }

        //Output location settings

        private string _ServicesFolder;
        public string ServicesFolder
        {
            get
            {
                return _ServicesFolder;
            }
            set
            {
                _ServicesFolder = value;
                NotifyPropertyChanged(nameof(ServicesFolder));
            }
        }

        private string _ControllersFolder;
        public string ControllersFolder
        {
            get
            {
                return _ControllersFolder;
            }
            set
            {
                _ControllersFolder = value;
                NotifyPropertyChanged(nameof(ControllersFolder));
            }
        }

        private string _ModelsFolder;
        public string ModelsFolder
        {
            get
            {
                return _ModelsFolder;
            }
            set
            {
                _ModelsFolder = value;
                NotifyPropertyChanged(nameof(ModelsFolder));
            }
        }

        private string _SelfHostFolder;
        public string SelfHostFolder
        {
            get
            {
                return _SelfHostFolder;
            }
            set
            {
                _SelfHostFolder = value;
                NotifyPropertyChanged(nameof(SelfHostFolder));
            }
        }

        private string _UnitTestFolder;
        public string UnitTestFolder
        {
            get
            {
                return _UnitTestFolder;
            }
            set
            {
                _UnitTestFolder = value;
                NotifyPropertyChanged(nameof(UnitTestFolder));
            }
        }

        //Code generation options - controller endpoints

        private bool _FullCollectionEndpoints;
        public bool FullCollectionEndpoints
        {
            get
            {
                return _FullCollectionEndpoints;
            }
            set
            {
                _FullCollectionEndpoints = value;
                NotifyPropertyChanged(nameof(FullCollectionEndpoints));
            }
        }

        private bool _PrimaryKeyEndpoints;
        public bool PrimaryKeyEndpoints
        {
            get
            {
                return _PrimaryKeyEndpoints;
            }
            set
            {
                _PrimaryKeyEndpoints = value;
                NotifyPropertyChanged(nameof(PrimaryKeyEndpoints));
            }
        }

        private bool _AlternateKeyEndpoints;
        public bool AlternateKeyEndpoints
        {
            get
            {
                return _AlternateKeyEndpoints;
            }
            set
            {
                _AlternateKeyEndpoints = value;
                NotifyPropertyChanged(nameof(AlternateKeyEndpoints));
            }
        }


        private bool _CollectionCountEndpoints;
        public bool CollectionCountEndpoints
        {
            get
            {
                return _CollectionCountEndpoints;
            }
            set
            {
                _CollectionCountEndpoints = value;
                NotifyPropertyChanged(nameof(CollectionCountEndpoints));
            }
        }

        private bool _IndividualPropertyEndpoints;
        public bool IndividualPropertyEndpoints
        {
            get
            {
                return _IndividualPropertyEndpoints;
            }
            set
            {
                _IndividualPropertyEndpoints = value;
                NotifyPropertyChanged(nameof(IndividualPropertyEndpoints));
            }
        }


        private bool _PutEndpoints;
        public bool PutEndpoints
        {
            get
            {
                return _PutEndpoints;
            }
            set
            {
                _PutEndpoints = value;
                NotifyPropertyChanged(nameof(PutEndpoints));
            }
        }

        private bool _PostEndpoints;
        public bool PostEndpoints
        {
            get
            {
                return _PostEndpoints;
            }
            set
            {
                _PostEndpoints = value;
                NotifyPropertyChanged(nameof(PostEndpoints));
            }
        }

        private bool _PatchEndpoints;
        public bool PatchEndpoints
        {
            get
            {
                return _PatchEndpoints;
            }
            set
            {
                _PatchEndpoints = value;
                NotifyPropertyChanged(nameof(PatchEndpoints));
            }
        }

        private bool _DeleteEndpoints;
        public bool DeleteEndpoints
        {
            get
            {
                return _DeleteEndpoints;
            }
            set
            {
                _DeleteEndpoints = value;
                NotifyPropertyChanged(nameof(DeleteEndpoints));
            }
        }

        //Code generation options - OData optional functionality


        private bool _ODataSelect;
        public bool ODataSelect
        {
            get
            {
                return _ODataSelect;
            }
            set
            {
                _ODataSelect = value;
                NotifyPropertyChanged(nameof(ODataSelect));
            }
        }

        private bool _ODataFilter;
        public bool ODataFilter
        {
            get
            {
                return _ODataFilter;
            }
            set
            {
                _ODataFilter = value;
                NotifyPropertyChanged(nameof(ODataFilter));
            }
        }

        private bool _ODataOrderBy;
        public bool ODataOrderBy
        {
            get
            {
                return _ODataOrderBy;
            }
            set
            {
                _ODataOrderBy = value;
                NotifyPropertyChanged(nameof(ODataOrderBy));
            }
        }

        private bool _ODataTop;
        public bool ODataTop
        {
            get
            {
                return _ODataTop;
            }
            set
            {
                _ODataTop = value;
                NotifyPropertyChanged(nameof(ODataTop));
            }
        }

        private bool _ODataSkip;
        public bool ODataSkip
        {
            get
            {
                return _ODataSkip;
            }
            set
            {
                _ODataSkip = value;
                NotifyPropertyChanged(nameof(ODataSkip));
            }
        }

        private bool _ODataRelations;
        public bool ODataRelations
        {
            get
            {
                return _ODataRelations;
            }
            set
            {
                _ODataRelations = value;
                NotifyPropertyChanged(nameof(ODataRelations));
            }
        }

        //Code generation options - self hosting and unit testing


        private bool _GenerateSelfHost;
        public bool GenerateSelfHost
        {
            get
            {
                return _GenerateSelfHost;
            }
            set
            {
                _GenerateSelfHost = value;
                NotifyPropertyChanged(nameof(GenerateSelfHost));
            }
        }

        private bool _CreateTestFiles;
        public bool CreateTestFiles
        {
            get
            {
                return _CreateTestFiles;
            }
            set
            {
                _CreateTestFiles = value;
                NotifyPropertyChanged(nameof(CreateTestFiles));
            }
        }

        private bool _GeneratePostmanTests;
        public bool GeneratePostmanTests
        {
            get
            {
                return _GeneratePostmanTests;
            }
            set
            {
                _GeneratePostmanTests = value;
                NotifyPropertyChanged(nameof(GeneratePostmanTests));
            }
        }

        private bool _GenerateUnitTests;
        public bool GenerateUnitTests
        {
            get
            {
                return _GenerateUnitTests;
            }
            set
            {
                _GenerateUnitTests = value;
                NotifyPropertyChanged(nameof(GenerateUnitTests));
            }
        }

        //Code generation options - documentation and versioning


        private bool _GenerateSwaggerDocs;
        public bool GenerateSwaggerDocs
        {
            get
            {
                return _GenerateSwaggerDocs;
            }
            set
            {
                _GenerateSwaggerDocs = value;
                NotifyPropertyChanged(nameof(GenerateSwaggerDocs));
            }
        }

        private bool _DocumentPropertyEndpoints;
        public bool DocumentPropertyEndpoints
        {
            get
            {
                return _DocumentPropertyEndpoints;
            }
            set
            {
                _DocumentPropertyEndpoints = value;
                NotifyPropertyChanged(nameof(DocumentPropertyEndpoints));
            }
        }

        private bool _EnableApiVersioning;
        public bool EnableApiVersioning
        {
            get
            {
                return _EnableApiVersioning;
            }
            set
            {
                _EnableApiVersioning = value;
                NotifyPropertyChanged(nameof(EnableApiVersioning));
            }
        }

        //Code generation options - security


        private bool _Authentication;
        public bool Authentication
        {
            get
            {
                return _Authentication;
            }
            set
            {
                _Authentication = value;
                NotifyPropertyChanged(nameof(Authentication));
            }
        }

        private bool _CustomAuthentication;
        public bool CustomAuthentication
        {
            get
            {
                return _CustomAuthentication;
            }
            set
            {
                _CustomAuthentication = value;
                NotifyPropertyChanged(nameof(CustomAuthentication));
            }
        }

        private bool _FieldSecurity;
        public bool FieldSecurity
        {
            get
            {
                return _FieldSecurity;
            }
            set
            {
                _FieldSecurity = value;
                NotifyPropertyChanged(nameof(FieldSecurity));
            }
        }

        //Code generation options - miscellaneous


        private bool _AdapterRouting;
        public bool AdapterRouting
        {
            get
            {
                return _AdapterRouting;
            }
            set
            {
                _AdapterRouting = value;
                NotifyPropertyChanged(nameof(AdapterRouting));
            }
        }

        private bool _StoredProcedureRouting;
        public bool StoredProcedureRouting
        {
            get
            {
                return _StoredProcedureRouting;
            }
            set
            {
                _StoredProcedureRouting = value;
                NotifyPropertyChanged(nameof(StoredProcedureRouting));
            }
        }

        private bool _CaseSensitiveUrls;
        public bool CaseSensitiveUrls
        {
            get
            {
                return _CaseSensitiveUrls;
            }
            set
            {
                _CaseSensitiveUrls = value;
                NotifyPropertyChanged(nameof(CaseSensitiveUrls));
            }
        }

        private bool _CrossDomainBrowsing;
        public bool CrossDomainBrowsing
        {
            get
            {
                return _CrossDomainBrowsing;
            }
            set
            {
                _CrossDomainBrowsing = value;
                NotifyPropertyChanged(nameof(CrossDomainBrowsing));
            }
        }

        private bool _IISSupport;
        public bool IISSupport
        {
            get
            {
                return _IISSupport;
            }
            set
            {
                _IISSupport = value;
                NotifyPropertyChanged(nameof(IISSupport));
            }
        }

        private bool _FieldOverlays;
        public bool FieldOverlays
        {
            get
            {
                return _FieldOverlays;
            }
            set
            {
                _FieldOverlays = value;
                NotifyPropertyChanged(nameof(FieldOverlays));
            }
        }

        private bool _AlternateFieldNames;
        public bool AlternateFieldNames
        {
            get
            {
                return _AlternateFieldNames;
            }
            set
            {
                _AlternateFieldNames = value;
                NotifyPropertyChanged(nameof(AlternateFieldNames));
            }
        }

        private bool _ReadOnlyProperties;
        public bool ReadOnlyProperties
        {
            get
            {
                return _ReadOnlyProperties;
            }
            set
            {
                _ReadOnlyProperties = value;
                NotifyPropertyChanged(nameof(ReadOnlyProperties));
            }
        }

    }
}

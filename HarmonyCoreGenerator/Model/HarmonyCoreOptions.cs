using Newtonsoft.Json;
using System.Collections.ObjectModel;

namespace HarmonyCoreGenerator.Model
{
    public class HarmonyCoreOptions : ModelBase
    {

        [JsonIgnore]
        public bool TrackChanges { get; set; }

        private bool _UnsavedChanges;
        [JsonIgnore]
        public bool UnsavedChanges
        {
            get
            {
                return _UnsavedChanges;
            }
            private set
            {
                if (_UnsavedChanges != value)
                {
                    _UnsavedChanges = value;
                    NotifyPropertyChanged(nameof(UnsavedChanges));
                }
            }
        }

        public void ChangesSaved()
        {
            UnsavedChanges = false;
        }

        //Repository files and structures

        private string _RepositoryMainFile = string.Empty;
        public string RepositoryMainFile
        {
            get { return _RepositoryMainFile; }
            set
            {
                if (!_RepositoryMainFile.Equals(value))
                {
                    _RepositoryMainFile = value;
                    NotifyPropertyChanged(nameof(RepositoryMainFile));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private string _RepositoryTextFile = string.Empty;
        public string RepositoryTextFile
        {
            get { return _RepositoryTextFile; }
            set
            {
                if (!_RepositoryTextFile.Equals(value))
                {
                    _RepositoryTextFile = value;
                    NotifyPropertyChanged(nameof(RepositoryTextFile));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private ObservableCollection<StructureRow> _Structures = new ObservableCollection<StructureRow>();
        public ObservableCollection<StructureRow> Structures
        {
            get { return _Structures; }
            set
            {
                if (_Structures != value)
                {
                    _Structures = value;
                    NotifyPropertyChanged(nameof(Structures));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        //Code generator files and folders

        private string _TemplatesFolder = string.Empty;
        public string TemplatesFolder
        {
            get { return _TemplatesFolder; }
            set
            {
                if (!_TemplatesFolder.Equals(value))
                {
                    _TemplatesFolder = value;
                    NotifyPropertyChanged(nameof(TemplatesFolder));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private string _UserTokensFile = string.Empty;
        public string UserTokensFile
        {
            get { return _UserTokensFile; }
            set
            {
                if (!_UserTokensFile.Equals(value))
                {
                    _UserTokensFile = value;
                    NotifyPropertyChanged(nameof(UserTokensFile));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        //Output location settings

        private string _ServicesFolder = string.Empty;
        public string ServicesFolder
        {
            get { return _ServicesFolder; }
            set
            {
                if (!_ServicesFolder.Equals(value))
                {
                    _ServicesFolder = value;
                    NotifyPropertyChanged(nameof(ServicesFolder));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private string _ControllersFolder = string.Empty;
        public string ControllersFolder
        {
            get { return _ControllersFolder; }
            set
            {
                if (!_ControllersFolder.Equals(value))
                {
                    _ControllersFolder = value;
                    NotifyPropertyChanged(nameof(ControllersFolder));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private string _ModelsFolder = string.Empty;
        public string ModelsFolder
        {
            get { return _ModelsFolder; }
            set
            {
                if (!_ModelsFolder.Equals(value))
                {
                    _ModelsFolder = value;
                    NotifyPropertyChanged(nameof(ModelsFolder));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private string _SelfHostFolder = string.Empty;
        public string SelfHostFolder
        {
            get { return _SelfHostFolder; }
            set
            {
                if (!_SelfHostFolder.Equals(value))
                {
                    _SelfHostFolder = value;
                    NotifyPropertyChanged(nameof(SelfHostFolder));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private string _UnitTestFolder = string.Empty;
        public string UnitTestFolder
        {
            get { return _UnitTestFolder; }
            set
            {
                if (!_UnitTestFolder.Equals(value))
                {
                    _UnitTestFolder = value;
                    NotifyPropertyChanged(nameof(UnitTestFolder));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private string _IsolatedFolder = string.Empty;
        public string IsolatedFolder
        {
            get { return _IsolatedFolder; }
            set
            {
                if (!_IsolatedFolder.Equals(value))
                {
                    _IsolatedFolder = value;
                    NotifyPropertyChanged(nameof(IsolatedFolder));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        //Code generation options - controller endpoints

        private bool _FullCollectionEndpoints;
        public bool FullCollectionEndpoints
        {
            get { return _FullCollectionEndpoints; }
            set
            {
                if (_FullCollectionEndpoints != value)
                {
                    _FullCollectionEndpoints = value;
                    NotifyPropertyChanged(nameof(FullCollectionEndpoints));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _PrimaryKeyEndpoints;
        public bool PrimaryKeyEndpoints
        {
            get { return _PrimaryKeyEndpoints; }
            set
            {
                if (_PrimaryKeyEndpoints != value)
                {
                    _PrimaryKeyEndpoints = value;
                    NotifyPropertyChanged(nameof(PrimaryKeyEndpoints));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _AlternateKeyEndpoints;
        public bool AlternateKeyEndpoints
        {
            get { return _AlternateKeyEndpoints; }
            set
            {
                if (_AlternateKeyEndpoints != value)
                {
                    _AlternateKeyEndpoints = value;
                    NotifyPropertyChanged(nameof(AlternateKeyEndpoints));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }


        private bool _CollectionCountEndpoints;
        public bool CollectionCountEndpoints
        {
            get { return _CollectionCountEndpoints; }
            set
            {
                if (_CollectionCountEndpoints != value)
                {
                    _CollectionCountEndpoints = value;
                    NotifyPropertyChanged(nameof(CollectionCountEndpoints));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _IndividualPropertyEndpoints;
        public bool IndividualPropertyEndpoints
        {
            get { return _IndividualPropertyEndpoints; }
            set
            {
                if (_IndividualPropertyEndpoints != value)
                {
                    _IndividualPropertyEndpoints = value;
                    NotifyPropertyChanged(nameof(IndividualPropertyEndpoints));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }


        private bool _PutEndpoints;
        public bool PutEndpoints
        {
            get { return _PutEndpoints; }
            set
            {
                if (_PutEndpoints != value)
                {
                    _PutEndpoints = value;
                    NotifyPropertyChanged(nameof(PutEndpoints));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _PostEndpoints;
        public bool PostEndpoints
        {
            get { return _PostEndpoints; }
            set
            {
                if (_PostEndpoints != value)
                {
                    _PostEndpoints = value;
                    NotifyPropertyChanged(nameof(PostEndpoints));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _PatchEndpoints;
        public bool PatchEndpoints
        {
            get { return _PatchEndpoints; }
            set
            {
                if (_PatchEndpoints != value)
                {
                    _PatchEndpoints = value;
                    NotifyPropertyChanged(nameof(PatchEndpoints));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _DeleteEndpoints;
        public bool DeleteEndpoints
        {
            get { return _DeleteEndpoints; }
            set
            {
                if (_DeleteEndpoints != value)
                {
                    _DeleteEndpoints = value;
                    NotifyPropertyChanged(nameof(DeleteEndpoints));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        //Code generation options - OData optional functionality


        private bool _ODataSelect;
        public bool ODataSelect
        {
            get { return _ODataSelect; }
            set
            {
                if (_ODataSelect != value)
                {
                    _ODataSelect = value;
                    NotifyPropertyChanged(nameof(ODataSelect));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _ODataFilter;
        public bool ODataFilter
        {
            get { return _ODataFilter; }
            set
            {
                if (_ODataFilter != value)
                {
                    _ODataFilter = value;
                    NotifyPropertyChanged(nameof(ODataFilter));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _ODataOrderBy;
        public bool ODataOrderBy
        {
            get { return _ODataOrderBy; }
            set
            {
                if (_ODataOrderBy != value)
                {
                    _ODataOrderBy = value;
                    NotifyPropertyChanged(nameof(ODataOrderBy));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _ODataTop;
        public bool ODataTop
        {
            get { return _ODataTop; }
            set
            {
                if (_ODataTop != value)
                {
                    _ODataTop = value;
                    NotifyPropertyChanged(nameof(ODataTop));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _ODataSkip;
        public bool ODataSkip
        {
            get { return _ODataSkip; }
            set
            {
                if (_ODataSkip != value)
                {
                    _ODataSkip = value;
                    NotifyPropertyChanged(nameof(ODataSkip));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _ODataRelations;
        public bool ODataRelations
        {
            get { return _ODataRelations; }
            set
            {
                if (_ODataRelations != value)
                {
                    _ODataRelations = value;
                    NotifyPropertyChanged(nameof(ODataRelations));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        //Code generation options - self hosting and unit testing


        private bool _GenerateSelfHost;
        public bool GenerateSelfHost
        {
            get { return _GenerateSelfHost; }
            set
            {
                if (_GenerateSelfHost != value)
                {
                    _GenerateSelfHost = value;
                    NotifyPropertyChanged(nameof(GenerateSelfHost));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _CreateTestFiles;
        public bool CreateTestFiles
        {
            get { return _CreateTestFiles; }
            set
            {
                if (_CreateTestFiles != value)
                {
                    _CreateTestFiles = value;
                    NotifyPropertyChanged(nameof(CreateTestFiles));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _GeneratePostmanTests;
        public bool GeneratePostmanTests
        {
            get { return _GeneratePostmanTests; }
            set
            {
                if (_GeneratePostmanTests != value)
                {
                    _GeneratePostmanTests = value;
                    NotifyPropertyChanged(nameof(GeneratePostmanTests));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _GenerateUnitTests;
        public bool GenerateUnitTests
        {
            get { return _GenerateUnitTests; }
            set
            {
                if (_GenerateUnitTests != value)
                {
                    _GenerateUnitTests = value;
                    NotifyPropertyChanged(nameof(GenerateUnitTests));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        //Code generation options - documentation and versioning


        private bool _GenerateSwaggerDocs;
        public bool GenerateSwaggerDocs
        {
            get { return _GenerateSwaggerDocs; }
            set
            {
                if (_GenerateSwaggerDocs != value)
                {
                    _GenerateSwaggerDocs = value;
                    NotifyPropertyChanged(nameof(GenerateSwaggerDocs));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _DocumentPropertyEndpoints;
        public bool DocumentPropertyEndpoints
        {
            get { return _DocumentPropertyEndpoints; }
            set
            {
                if (_DocumentPropertyEndpoints != value)
                {
                    _DocumentPropertyEndpoints = value;
                    NotifyPropertyChanged(nameof(DocumentPropertyEndpoints));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _EnableApiVersioning;
        public bool EnableApiVersioning
        {
            get { return _EnableApiVersioning; }
            set
            {
                if (_EnableApiVersioning != value)
                {
                    _EnableApiVersioning = value;
                    NotifyPropertyChanged(nameof(EnableApiVersioning));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        //Code generation options - security


        private bool _Authentication;
        public bool Authentication
        {
            get { return _Authentication; }
            set
            {
                if (_Authentication != value)
                {
                    _Authentication = value;
                    NotifyPropertyChanged(nameof(Authentication));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _CustomAuthentication;
        public bool CustomAuthentication
        {
            get { return _CustomAuthentication; }
            set
            {
                if (_CustomAuthentication != value)
                {
                    _CustomAuthentication = value;
                    NotifyPropertyChanged(nameof(CustomAuthentication));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _FieldSecurity;
        public bool FieldSecurity
        {
            get { return _FieldSecurity; }
            set
            {
                if (_FieldSecurity != value)
                {
                    _FieldSecurity = value;
                    NotifyPropertyChanged(nameof(FieldSecurity));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        //Code generation options - miscellaneous

        private bool _AdapterRouting;
        public bool AdapterRouting
        {
            get { return _AdapterRouting; }
            set
            {
                if (_AdapterRouting != value)
                {
                    _AdapterRouting = value;
                    NotifyPropertyChanged(nameof(AdapterRouting));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _StoredProcedureRouting;
        public bool StoredProcedureRouting
        {
            get { return _StoredProcedureRouting; }
            set
            {
                if (_StoredProcedureRouting != value)
                {
                    _StoredProcedureRouting = value;
                    NotifyPropertyChanged(nameof(StoredProcedureRouting));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _CaseSensitiveUrls;
        public bool CaseSensitiveUrls
        {
            get { return _CaseSensitiveUrls; }
            set
            {
                if (_CaseSensitiveUrls != value)
                {
                    _CaseSensitiveUrls = value;
                    NotifyPropertyChanged(nameof(CaseSensitiveUrls));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _CrossDomainBrowsing;
        public bool CrossDomainBrowsing
        {
            get { return _CrossDomainBrowsing; }
            set
            {
                if (_CrossDomainBrowsing != value)
                {
                    _CrossDomainBrowsing = value;
                    NotifyPropertyChanged(nameof(CrossDomainBrowsing));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _IISSupport;
        public bool IISSupport
        {
            get { return _IISSupport; }
            set
            {
                if (_IISSupport != value)
                {
                    _IISSupport = value;
                    NotifyPropertyChanged(nameof(IISSupport));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _FieldOverlays;
        public bool FieldOverlays
        {
            get { return _FieldOverlays; }
            set
            {
                if (_FieldOverlays != value)
                {
                    _FieldOverlays = value;
                    NotifyPropertyChanged(nameof(FieldOverlays));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _AlternateFieldNames;
        public bool AlternateFieldNames
        {
            get { return _AlternateFieldNames; }
            set
            {
                if (_AlternateFieldNames != value)
                {
                    _AlternateFieldNames = value;
                    NotifyPropertyChanged(nameof(AlternateFieldNames));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }

        private bool _ReadOnlyProperties;
        public bool ReadOnlyProperties
        {
            get { return _ReadOnlyProperties; }
            set
            {
                if (_ReadOnlyProperties != value)
                {
                    _ReadOnlyProperties = value;
                    NotifyPropertyChanged(nameof(ReadOnlyProperties));
                    if (TrackChanges)
                        UnsavedChanges = true;
                }
            }
        }
    }
}


using CodeGen.Engine;
using CodeGen.RepositoryAPI;
using HarmonyCoreGenerator.Model;
using Microsoft.Win32;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Windows;
using System.Windows.Input;

namespace HarmonyCoreGenerator.ViewModel
{
    public class GeneratorViewModel : ViewModelBase
    {

        #region Data binding properties

        private string _SolutionFolder;
        private string _SolutionFile;
        public string SolutionFile
        {
            get { return _SolutionFile; }
            set
            {
                _SolutionFile = value;
                NotifyPropertyChanged(nameof(SolutionFile));
            }
        }

        private string _SettingsFile;
        public string SettingsFile
        {
            get { return _SettingsFile; }
            set
            {
                _SettingsFile = value;
                NotifyPropertyChanged(nameof(SettingsFile));
            }
        }

        private bool _SolutionOpen;
        public bool SolutionOpen
        {
            get { return _SolutionOpen; }
            set
            {
                _SolutionOpen = value;
                NotifyPropertyChanged(nameof(SolutionOpen));
            }
        }

        private HarmonyCoreOptions _Options;

        public HarmonyCoreOptions Options
        {
            get { return _Options; }
            set
            {
                _Options = value;
                NotifyPropertyChanged(nameof(Options));
            }
        }

        private int _SelectedTabIndex;

        public int SelectedTabIndex
        {
            get { return _SelectedTabIndex; }
            set
            {
                _SelectedTabIndex = value;
                NotifyPropertyChanged(nameof(SelectedTabIndex));
            }
        }

        private string _CodeGenOutput;
        public string CodeGenOutput
        {
            get { return _CodeGenOutput; }
            set
            {
                _CodeGenOutput = value;
                NotifyPropertyChanged(nameof(CodeGenOutput));
            }
        }

        private StructureRow _SelectedStructure;

        public StructureRow SelectedStructure
        {
            get { return _SelectedStructure; }
            set
            {
                if (_SelectedStructure != value)
                {
                    _SelectedStructure = value;
                    NotifyPropertyChanged(nameof(SelectedStructure));
                }
            }
        }

        #endregion

        #region OpenSolutionCommand

        private ICommand _OpenSolutionCommand;

        public ICommand OpenSolutionCommand
        {
            get
            {
                if (_OpenSolutionCommand == null)
                    _OpenSolutionCommand = new RelayCommand(
                        param =>
                        {
                            openSolution();
                        }
                        );
                return _OpenSolutionCommand;
            }
        }

        #endregion

        #region CloseSolutionCommand

        private ICommand _CloseSolutionCommand;

        public ICommand CloseSolutionCommand
        {
            get
            {
                if (_CloseSolutionCommand == null)
                    _CloseSolutionCommand = new RelayCommand(
                        param =>
                        {
                            closeSolution();
                        },
                        param =>
                        {
                            return _SolutionOpen;
                        }
                        );
                return _CloseSolutionCommand;
            }
        }

        #endregion

        #region SaveSettingsCommand

        private ICommand _SaveSettingsCommand;

        public ICommand SaveSettingsCommand
        {
            get
            {
                if (_SaveSettingsCommand == null)
                    _SaveSettingsCommand = new RelayCommand(
                        param =>
                        {
                            saveSettings();
                        },
                        param =>
                        {
                            //Can execute code goes here!
                            return _SolutionOpen;
                        }
                        );
                return _SaveSettingsCommand;
            }
        }

        #endregion

        #region RefreshRepositoryCommand

        private ICommand _RefreshRepositoryCommand;

        public ICommand RefreshRepositoryCommand
        {
            get
            {
                if (_RefreshRepositoryCommand == null)
                    _RefreshRepositoryCommand = new RelayCommand(
                        param =>
                        {
                            refreseRepository();
                        },
                        param =>
                        {
                            return _SolutionOpen;
                        }
                        );
                return _RefreshRepositoryCommand;
            }
        }

        #endregion

        #region GenerateCodeCommand

        private ICommand _GenerateCodeCommand;

        public ICommand GenerateCodeCommand
        {
            get
            {
                if (_GenerateCodeCommand == null)
                    _GenerateCodeCommand = new RelayCommand(
                        param =>
                        {
                            generateCode();
                        },
                        param =>
                        {
                            return _SolutionOpen;
                        }
                        );
                return _GenerateCodeCommand;
            }
        }

        #endregion

        #region ExitCommand

        private ICommand _ExitCommand;

        public ICommand ExitCommand
        {
            get
            {
                if (_ExitCommand == null)
                    _ExitCommand = new RelayCommand(
                        param =>
                        {
                            Environment.Exit(0);
                        }
                        );
                return _ExitCommand;
            }
        }

        #endregion

        #region Helper Methods

        private void openSolution()
        {
            if (_SolutionOpen)
            {
                closeSolution();
            }


            var dlg = new OpenFileDialog();

            //If we have a last folder, use it
            var lastFolder = Properties.Settings.Default.LastFolder;
            if (!String.IsNullOrWhiteSpace(lastFolder) && Directory.Exists(lastFolder))
                dlg.InitialDirectory = lastFolder;

            dlg.Filter = "Solution Files (*.sln)|*.sln";
            dlg.CheckFileExists = true;
            dlg.Multiselect = false;

            Nullable<bool> result = dlg.ShowDialog();

            if (result == true)
            {
                SolutionFile = dlg.FileName;
                _SolutionFolder = Path.GetDirectoryName(_SolutionFile);
                SettingsFile = Path.Combine(Path.GetDirectoryName(_SolutionFile), Path.GetFileNameWithoutExtension(_SolutionFile) + ".hcproj");

                var errors = new List<string>();
                string temp;

                if (File.Exists(_SettingsFile))
                {
                    //Load existing settings file
                    var settingsJson = File.ReadAllText(_SettingsFile);
                    Options = JsonConvert.DeserializeObject<HarmonyCoreOptions>(settingsJson);
                    Options.TrackChanges = true;

                    //Repository files

                    if (!File.Exists(Options.RepositoryMainFile))
                        errors.Add("File 'rpsmain.ism' was not found in the expected location!");

                    if (!File.Exists(Options.RepositoryTextFile))
                        errors.Add("File 'rpstext.ism' was not found in the expected location!");

                    //User tokens file should be in the solution folder
                    if (!File.Exists(Options.UserTokensFile))
                        errors.Add("File 'UserDefinedTokens.tkn' was not found in the solution directory!");

                    //Verify the services folder is present
                    if (!Directory.Exists(Options.ServicesFolder))
                        errors.Add("Folder 'Services' was not found in the solution directory!");

                    //Verify the controllers folder is present
                    if (!Directory.Exists(Options.ControllersFolder))
                        errors.Add("Folder 'Services.Controllers' was not found in the solution directory!");

                    //Verify the self host folder is present
                    if (!Directory.Exists(Options.SelfHostFolder))
                        errors.Add("Folder 'Services.Host' was not found in the solution directory!");

                    //Verify the isolated folder is present
                    if (!Directory.Exists(Options.IsolatedFolder))
                        errors.Add("Folder 'Services.Isolated' was not found in the solution directory!");

                    //Verify the models folder is present
                    if (!Directory.Exists(Options.ModelsFolder))
                        errors.Add("Folder 'Services.Models' was not found in the solution directory!");

                    //Do we have a unit tests folder?
                    if (!String.IsNullOrWhiteSpace(Options.UnitTestFolder))
                        if (!Directory.Exists(Options.UnitTestFolder))
                            errors.Add("Unit test \folder was not found!");

                    //Templates folder should be right below the solution folder.
                    if (!Directory.Exists(Options.TemplatesFolder))
                        errors.Add("Folder 'Templates' was not found in the solution directory!");

                    //For existing projects, shjow the code generation page
                    if (errors.Count == 0)
                        SelectedTabIndex = 3;
                }
                else
                {
                    //No settings file, start from scratch
                    Options = new HarmonyCoreOptions();
                    Options.TrackChanges = true;

                    //TODO: For now we're assuming the repository project is in "schema centric" mode and Debug mode is being used

                    //Repository files

                    temp = Path.Combine(_SolutionFolder, "Repository", "bin", "Debug", "rpsmain.ism");
                    if (File.Exists(temp))
                        Options.RepositoryMainFile = temp;
                    else
                        errors.Add("File 'rpsmain.ism' was not found in the expected location!");

                    temp = Path.Combine(_SolutionFolder, "Repository", "bin", "Debug", "rpstext.ism");
                    if (File.Exists(temp))
                        Options.RepositoryTextFile = temp;
                    else
                        errors.Add("File 'rpstext.ism' was not found in the expected location!");

                    //User tokens file should be in the solution folder
                    temp = Path.Combine(_SolutionFolder, "UserDefinedTokens.tkn");
                    if (File.Exists(temp))
                        Options.UserTokensFile = temp;
                    else
                        errors.Add("File 'UserDefinedTokens.tkn' was not found in the solution directory!");

                    //Verify the services folder is present
                    temp = Path.Combine(_SolutionFolder, "Services");
                    if (Directory.Exists(temp))
                        Options.ServicesFolder = temp;
                    else
                        errors.Add("Folder 'Services' was not found in the solution directory!");

                    //Verify the controllers folder is present
                    temp = Path.Combine(_SolutionFolder, "Services.Controllers");
                    if (Directory.Exists(temp))
                        Options.ControllersFolder = temp;
                    else
                        errors.Add("Folder 'Services.Controllers' was not found in the solution directory!");

                    //Verify the self host folder is present
                    temp = Path.Combine(_SolutionFolder, "Services.Host");
                    if (Directory.Exists(temp))
                        Options.SelfHostFolder = temp;
                    else
                        errors.Add("Folder 'Services.Host' was not found in the solution directory!");

                    //Verify the isolated folder is present
                    temp = Path.Combine(_SolutionFolder, "Services.Isolated");
                    if (Directory.Exists(temp))
                        Options.IsolatedFolder = temp;
                    else
                        errors.Add("Folder 'Services.Isolated' was not found in the solution directory!");

                    //Verify the models folder is present
                    temp = Path.Combine(_SolutionFolder, "Services.Models");
                    if (Directory.Exists(temp))
                        Options.ModelsFolder = temp;
                    else
                        errors.Add("Folder 'Services.Models' was not found in the solution directory!");

                    //Do we have a unit tests folder?
                    temp = Path.Combine(_SolutionFolder, "Services.Test");
                    if (Directory.Exists(temp))
                        Options.UnitTestFolder = temp;
                    else
                        Options.UnitTestFolder = String.Empty;

                    //Load the repository
                    if (errors.Count == 0)
                    {
                        var rps = new Repository(Options.RepositoryMainFile, Options.RepositoryTextFile, false);
                        foreach (var str in rps.Structures)
                            Options.Structures.Add(new StructureRow(str));

                        //For new projects, show the structure selection page
                        if (errors.Count == 0)
                            SelectedTabIndex = 1;
                    }

                    //Templates folder should be right below the solution folder.
                    temp = Path.Combine(_SolutionFolder, "Templates");
                    if (Directory.Exists(temp))
                        Options.TemplatesFolder = temp;
                    else
                        errors.Add("Folder 'Templates' was not found in the solution directory!");
                }

                if (errors.Count == 0)
                {
                    if (Options.Structures.Count > 0)
                        SelectedStructure = Options.Structures.First();

                    //Save the last used folder
                    Properties.Settings.Default.LastFolder = Path.GetDirectoryName(_SolutionFile);
                    Properties.Settings.Default.Save();

                    SolutionOpen = true;
                }
                else
                {
                    var message = "The solution configuration was not as expected";
                    foreach (string error in errors)
                        message = message + Environment.NewLine + " - " + error;
                    MessageBox.Show(message, "Unsupported Configuration", MessageBoxButton.OK, MessageBoxImage.Exclamation);

                    //Clear things down so the UI is blank
                    SolutionFile = String.Empty;
                    _SolutionFolder = String.Empty;
                    SettingsFile = String.Empty;
                    Options = new HarmonyCoreOptions();
                }
            }

        }

        private void closeSolution()
        {
            if (_SolutionOpen)
            {
                if (Options.UnsavedChanges)
                {
                    if (MessageBox.Show("Save changes before closing the solution?", "Unsaved Changes", MessageBoxButton.YesNo, MessageBoxImage.Question, MessageBoxResult.Yes) == MessageBoxResult.Yes)
                    {
                        saveSettings();
                    }
                }
                SolutionOpen = false;
                SolutionFile = String.Empty;
                SettingsFile = String.Empty;
                CodeGenOutput = String.Empty;
                Options = new HarmonyCoreOptions();

                SelectedTabIndex = 0;

            }
        }

        private void saveSettings()
        {
            try
            {
                File.WriteAllText(_SettingsFile, JsonConvert.SerializeObject(Options, Formatting.Indented));
                Options.ChangesSaved();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Failed to save settings! Error was " + ex.Message);
            }
        }

        private void refreseRepository()
        {
            //Ensure the code generation page is visible
            if (SelectedTabIndex != 1)
                SelectedTabIndex = 1;

            MessageBox.Show("You wish!");
            return;

        }

        private void generateCode()
        {
            //Ensure the code generation page is visible
            if (SelectedTabIndex != 3)
            {
                SelectedTabIndex = 3;
            }

            //MessageBox.Show("You wish!");
            //return;

            CodeGenOutput = String.Empty;

            var taskset = new CodeGenTaskSet()
            {
                RepositoryMainFile = Options.RepositoryMainFile,
                RepositoryTextFile = Options.RepositoryTextFile,
                TemplateFolder = Options.TemplatesFolder,
                EchoCommands = true,
                ListGeneratedFiles = true
            };

            if (Options.FullCollectionEndpoints)
            {
                taskset.Defines.Add("ENABLE_GET_ALL");
            }

            if (Options.PrimaryKeyEndpoints)
            {
                taskset.Defines.Add("ENABLE_GET_ONE");
            }

            if (Options.CreateTestFiles)
            {
                taskset.Defines.Add("ENABLE_CREATE_TEST_FILES");
            }

            if (Options.GenerateSwaggerDocs)
            {
                taskset.Defines.Add("ENABLE_SWAGGER_DOCS");
            }

            if (Options.EnableApiVersioning)
            {
                taskset.Defines.Add("ENABLE_API_VERSIONING");
            }

            if (Options.AlternateKeyEndpoints)
            {
                taskset.Defines.Add("ENABLE_ALTERNATE_KEYS");
            }

            if (Options.CollectionCountEndpoints)
            {
                taskset.Defines.Add("ENABLE_COUNT");
            }

            if (Options.IndividualPropertyEndpoints)
            {
                taskset.Defines.Add("ENABLE_PROPERTY_ENDPOINTS");
            }

            if (Options.DocumentPropertyEndpoints)
            {
                taskset.Defines.Add("ENABLE_PROPERTY_VALUE_DOCS");
            }

            if (Options.ODataSelect)
            {
                taskset.Defines.Add("ENABLE_SELECT");
            }

            if (Options.ODataFilter)
            {
                taskset.Defines.Add("ENABLE_FILTER");
            }

            if (Options.ODataOrderBy)
            {
                taskset.Defines.Add("ENABLE_ORDERBY");
            }

            if (Options.ODataTop)
            {
                taskset.Defines.Add("ENABLE_TOP");
            }

            if (Options.ODataSkip)
            {
                taskset.Defines.Add("ENABLE_SKIP");
            }

            if (Options.ODataRelations)
            {
                taskset.Defines.Add("ENABLE_RELATIONS");
            }

            if (Options.PutEndpoints)
            {
                taskset.Defines.Add("ENABLE_PUT");
            }

            if (Options.PostEndpoints)
            {
                taskset.Defines.Add("ENABLE_POST");
            }

            if (Options.PatchEndpoints)
            {
                taskset.Defines.Add("ENABLE_PATCH");
            }

            if (Options.DeleteEndpoints)
            {
                taskset.Defines.Add("ENABLE_DELETE");
            }

            if (Options.StoredProcedureRouting)
            {
                taskset.Defines.Add("ENABLE_SPROC");
            }

            if (Options.AdapterRouting)
            {
                taskset.Defines.Add("ENABLE_ADAPTER_ROUTING");
            }

            if (Options.Authentication)
            {
                taskset.Defines.Add("ENABLE_AUTHENTICATION");
            }

            if (Options.CustomAuthentication)
            {
                taskset.Defines.Add("ENABLE_CUSTOM_AUTHENTICATION");
            }

            if (Options.FieldSecurity)
            {
                taskset.Defines.Add("ENABLE_FIELD_SECURITY");
            }

            if (Options.CaseSensitiveUrls)
            {
                taskset.Defines.Add("ENABLE_CASE_SENSITIVE_URL");
            }

            if (Options.CrossDomainBrowsing)
            {
                taskset.Defines.Add("ENABLE_CORS");
            }

            if (Options.IISSupport)
            {
                taskset.Defines.Add("ENABLE_IIS_SUPPORT");
            }

            if (Options.ReadOnlyProperties)
            {
                taskset.Defines.Add("ENABLE_READ_ONLY_PROPERTIES");
            }

            if (Options.ODataSelect || Options.ODataFilter || Options.ODataOrderBy || Options.ODataTop || Options.ODataSkip || Options.ODataRelations)
            {
                taskset.Defines.Add("PARAM_OPTIONS_PRESENT");
            }

            CodeGenTask task;

            //Create a task to generate model and metadata classes

            task = new CodeGenTask();
            task.Description = "Generate model and metadata classes";
            task.Templates.Add("ODataModel");
            task.Templates.Add("ODataMetaData");
            task.OutputFolder = Options.ModelsFolder;
            task.Namespace = "Services.Models";
            addStructureAndFileStructures(task);
            addStructureOnlyStructures(task);
            addCustomCodeStructures(task);
            addStandardOptions(task);
            taskset.Tasks.Add(task);

            //Create a task to generate controller classes

            task = new CodeGenTask();
            task.Description = "Generate controller classes";
            task.Templates.Add("ODataController");
            task.OutputFolder = Options.ControllersFolder;
            task.Namespace = "Services.Controllers";
            addStructureAndFileStructures(task);
            addStructureOnlyStructures(task);
            addStandardOptions(task);
            taskset.Tasks.Add(task);

            //Create a task to generate the DBContext class

            task = new CodeGenTask();
            task.Description = "Generate the DBContext class";
            task.Templates.Add("ODataDbContext");
            task.OutputFolder = Options.ModelsFolder;
            task.Namespace = "Services.Models";
            task.MultipleStructures = true;
            addStructureAndFileStructures(task);
            addStructureOnlyStructures(task);
            addStandardOptions(task);
            taskset.Tasks.Add(task);

            //Create a task to generate the EdbBuilder and Startup classes

            task = new CodeGenTask();
            task.Description = "Generate the EdbBuilder and Startup classes";
            task.Templates.Add("ODataEdmBuilder");
            task.Templates.Add("ODataStartup");
            task.OutputFolder = Options.ServicesFolder;
            task.Namespace = "Services";
            task.MultipleStructures = true;
            task.UserTokens.Add(new UserToken("CONTROLLERS_NAMESPACE", "Services.Controllers"));
            task.UserTokens.Add(new UserToken("MODELS_NAMESPACE", "Services.Models"));
            addStructureAndFileStructures(task);
            addStructureOnlyStructures(task);
            addStandardOptions(task);
            taskset.Tasks.Add(task);

            //Create a task to generate self hosting program and environment

            if (Options.GenerateSelfHost)
            {
                task = new CodeGenTask();
                task.Description = "Generate self hosting program and environment";
                task.Templates.Add("ODataSelfHost");
                task.Templates.Add("ODataSelfHostEnvironment");
                task.OutputFolder = Options.SelfHostFolder;
                task.Namespace = "Services.Host";
                task.MultipleStructures = true;
                addStructureAndFileStructures(task);
                //TODO: if we have a parameter file structure we need to add that here also
                addStandardOptions(task);
                taskset.Tasks.Add(task);
            }

            //Create tasks to generate swagger docs
            if (Options.GenerateSwaggerDocs)
            {
                task = new CodeGenTask();
                task.Description = "Generate swagger documentation";
                task.Templates.Add("ODataSwaggerYaml");
                task.OutputFolder = Path.Combine(Options.ServicesFolder,"wwwroot");
                task.MultipleStructures = true;
                addStructureAndFileStructures(task);
                addStructureOnlyStructures(task);
                addStandardOptions(task);
                taskset.Tasks.Add(task);

                task = new CodeGenTask();
                task.Description = "Generate swagger complex types documentation";
                task.Templates.Add("ODataSwaggerType");
                task.OutputFolder = Path.Combine(Options.ServicesFolder, "wwwroot");
                addStructureAndFileStructures(task);
                addStructureOnlyStructures(task);
                addStandardOptions(task);
                taskset.Tasks.Add(task);
            }

            //Create a task to generate Postman tests
            if (Options.GeneratePostmanTests)
            {
                task = new CodeGenTask();
                task.Description = "Generate Postman tests";
                task.Templates.Add("ODataPostManTests");
                task.OutputFolder = _SolutionFolder;
                task.MultipleStructures = true;
                addStructureAndFileStructures(task);
                addStructureOnlyStructures(task);
                addStandardOptions(task);
                taskset.Tasks.Add(task);
            }

            //Create tass to generatea unit test environment
            if (Options.GenerateUnitTests)
            {
                task = new CodeGenTask();
                task.Description = "Generate client-side models, data loaders and unit tests";
                task.Templates.Add("ODataClientModel");
                task.Templates.Add("ODataTestDataLoader");
                task.Templates.Add("ODataUnitTests");
                task.OutputFolder = Options.UnitTestFolder;
                task.Namespace = "Services.Test";
                addStructureAndFileStructures(task);
                addStructureOnlyStructures(task);
                addStandardOptions(task);
                taskset.Tasks.Add(task);

                task = new CodeGenTask();
                task.Description = "Generate test environment";
                task.Templates.Add("ODataTestEnvironment");
                task.OutputFolder = Options.UnitTestFolder;
                task.Namespace = "Services.Test";
                task.MultipleStructures = true;
                addStructureAndFileStructures(task);
                //TODO: if we have a parameter file structure we need to add that here also
                addStandardOptions(task);
                taskset.Tasks.Add(task);

                task = new CodeGenTask();
                task.Description = "Generate unit test environment and hosting program";
                task.Templates.Add("ODataUnitTestEnvironment");
                task.Templates.Add("ODataUnitTestHost");
                task.OutputFolder = Options.UnitTestFolder;
                task.Namespace = "Services.Test";
                task.MultipleStructures = true;
                addStructureAndFileStructures(task);
                addStandardOptions(task);
                taskset.Tasks.Add(task);

                task = new CodeGenTask();
                task.Description = "Generate test constants class";
                task.Templates.Add("ODataTestConstantsProperties");
                task.OutputFolder = Options.UnitTestFolder;
                task.Namespace = "Services.Test";
                task.MultipleStructures = true;
                addStructureAndFileStructures(task);
                addStructureOnlyStructures(task);
                addStandardOptions(task);
                taskset.Tasks.Add(task);

                task = new CodeGenTask();
                task.Description = "Generate test constants values";
                task.Templates.Add("ODataTestConstantsValues");
                task.OutputFolder = Options.UnitTestFolder;
                task.Namespace = "Services.Test";
                task.MultipleStructures = true;
                addStructureAndFileStructures(task);
                addStructureOnlyStructures(task);
                addNoReplaceOptions(task);
                taskset.Tasks.Add(task);
            }

            //Do it all!

            var codegen = new CodeGenerator(taskset);
            bool success;

            try
            {
                success = codegen.GenerateCode();
                if (success)
                {

                }
                else
                {

                }
            }
            catch (Exception)
            {

            }

            //Clear down for next time
            structureAndFileStructures = null;
            structureAndFileAliases = null;
        }

        private static List<string> structureAndFileStructures;
        private static List<string> structureAndFileAliases;

        private void addStructureAndFileStructures(CodeGenTask task)
        {
            //One time only per code generation pass
            if (structureAndFileStructures == null)
            {
                structureAndFileStructures = new List<string>();
                structureAndFileAliases = new List<string>();
                foreach (StructureRow row in Options.Structures.Where(row => row.ProcessingMode.Equals("Structure and File")))
                {
                    structureAndFileStructures.Add(row.Name);
                    structureAndFileAliases.Add(String.IsNullOrWhiteSpace(row.Alias) ? row.Name : row.Alias);
                }
            }
            //Add the structures to the current task
            for (int ix = 0; ix < structureAndFileStructures.Count; ix++)
            {
                task.Structures.Add(structureAndFileStructures[ix]);
                task.Aliases.Add(structureAndFileAliases[ix]);
            }
        }

        private static List<string> structureOnlyStructures;
        private static List<string> structureOnlyAliases;

        private void addStructureOnlyStructures(CodeGenTask task)
        {
            //One time only per code generation pass
            if (structureOnlyStructures == null)
            {
                structureOnlyStructures = new List<string>();
                structureOnlyAliases = new List<string>();
                foreach (StructureRow row in Options.Structures.Where(row => row.ProcessingMode.Equals("Structure Only")))
                {
                    structureOnlyStructures.Add(row.Name);
                    structureOnlyAliases.Add(String.IsNullOrWhiteSpace(row.Alias) ? row.Name : row.Alias);
                }
            }
            //Add the structures to the current task
            for (int ix = 0; ix < structureOnlyStructures.Count; ix++)
            {
                task.Structures.Add(structureOnlyStructures[ix]);
                task.Aliases.Add(structureOnlyAliases[ix]);
            }
        }

        private static List<string> customCodeStructures;
        private static List<string> customCodeAliases;

        private void addCustomCodeStructures(CodeGenTask task)
        {
            //One time only per code generation pass
            if (customCodeStructures == null)
            {
                customCodeStructures = new List<string>();
                customCodeAliases = new List<string>();
                foreach (StructureRow row in Options.Structures.Where(row => row.ProcessingMode.Equals("Custom Code Only")))
                {
                    customCodeStructures.Add(row.Name);
                    customCodeAliases.Add(String.IsNullOrWhiteSpace(row.Alias) ? row.Name : row.Alias);
                }
            }
            //Add the structures to the current task
            for (int ix = 0; ix < customCodeStructures.Count; ix++)
            {
                task.Structures.Add(customCodeStructures[ix]);
                task.Aliases.Add(customCodeAliases[ix]);
            }
        }

        private void addStandardOptions(CodeGenTask task)
        {
            addNoReplaceOptions(task);
            task.ReplaceFiles = true;
        }

        private void addNoReplaceOptions(CodeGenTask task)
        {
            task.UserTokenFile = Options.UserTokensFile;
            task.IncludeOverlayFields = Options.FieldOverlays;
            task.UseAlternateFieldNames = Options.AlternateFieldNames;
        }

        #endregion

    }
}

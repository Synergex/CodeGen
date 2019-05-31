
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
                        {
                            Options.Structures.Add(new StructureRow(str));
                        }

                        //For new projects, shjow the structure selection page
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
                SelectedTabIndex = 3;

            //MessageBox.Show("You wish!");
            //return;


            CodeGenOutput = String.Empty;

            var taskSet = new CodeGenTaskSet()
            {
                RepositoryMainFile = Options.RepositoryMainFile,
                RepositoryTextFile = Options.RepositoryTextFile,
                TemplateFolder = "",
                OutputFolder = ""
            };

            //TODO: Not sure if I need to use the display values instead.
            //"Structure and File", "Structure Only" and "Custom Code Only"

            var structureAndFileStructures = new List<string>();
            var structureAndFileAliases = new List<string>();

            var structureOnlyStructures = new List<string>();
            var structureOnlyAliases = new List<string>();

            var customCodeStructures = new List<string>();
            var customCodeAliases = new List<string>();

            foreach (StructureRow row in Options.Structures.Where(row => row.ProcessingMode.Equals("StructureAndFile")))
            {
                structureAndFileStructures.Add(row.Name);
                structureAndFileAliases.Add(String.IsNullOrWhiteSpace(row.Alias) ? row.Name : row.Alias);
            }

            foreach (StructureRow row in Options.Structures.Where(row => row.ProcessingMode.Equals("StructureOnly")))
            {
                structureOnlyStructures.Add(row.Name);
                structureOnlyAliases.Add(String.IsNullOrWhiteSpace(row.Alias) ? row.Name : row.Alias);
            }

            foreach (StructureRow row in Options.Structures.Where(row => row.ProcessingMode.Equals("CustomCodeOnly")))
            {
                customCodeStructures.Add(row.Name);
                customCodeAliases.Add(String.IsNullOrWhiteSpace(row.Alias) ? row.Name : row.Alias);
            }




        }

        #endregion

    }
}

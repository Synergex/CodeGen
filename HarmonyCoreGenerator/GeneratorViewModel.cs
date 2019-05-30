using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;

namespace HarmonyCoreGenerator
{
    public class GeneratorViewModel : ViewModelBase
    {

        private HarmonyCoreOptions mProjectOptions;

        public HarmonyCoreOptions ProjectOptions
        {
            get
            {
                return mProjectOptions;
            }
            set
            {
                mProjectOptions = value;
                NotifyPropertyChanged(nameof(ProjectOptions));
            }
        }


        private bool _projectOpen;

        public bool ProjectOpen
        {
            get
            {
                return _projectOpen;
            }
            set
            {
                _projectOpen = value;
                NotifyPropertyChanged(nameof(ProjectOpen));
            }
        }

        private bool _allowRepositorySelection;

        public bool AllowRepositorySelection
        {
            get
            {
                return _allowRepositorySelection;
            }
            set
            {
                _allowRepositorySelection = value;
                NotifyPropertyChanged(nameof(AllowRepositorySelection));
            }
        }

        #region GetRepositoryMainFileCommand

        private ICommand _GetRepositoryMainFileCommand;

        public ICommand GetRepositoryMainFileCommand
        {
            get
            {
                if (_GetRepositoryMainFileCommand == null)
                    _GetRepositoryMainFileCommand = new RelayCommand(
                        param =>
                        {
                            OpenFileDialog dlg = new OpenFileDialog();

                            //If we have a last folder, use it
                            var lastFolder = Properties.Settings.Default.LastFolder;
                            if (!String.IsNullOrWhiteSpace(lastFolder) && Directory.Exists(lastFolder))
                                dlg.InitialDirectory = lastFolder;

                            dlg.Filter = "Repository Main File (rpsmain.ism)|rpsmain.ism|All Files (*.*)|*.*";
                            dlg.CheckFileExists = true;
                            dlg.Multiselect = false;

                            Nullable<bool> result = dlg.ShowDialog();

                            if (result==true)
                            {
                                ProjectOptions.RepositoryMainFile = dlg.FileName;

                                if (dlg.FileName.ToLower().Contains("rpsmain.ism"))
                                {
                                    ProjectOptions.RepositoryTextFile = dlg.FileName.ToLower().Replace("rpsmain", "rpstext");
                                }
                            }

                        }
                        );
                return _GetRepositoryMainFileCommand;
            }
        }

        #endregion

        #region RepositoryDoneCommand

        private ICommand _RepositoryDoneCommand;

        public ICommand RepositoryDoneCommand
        {
            get
            {
                if (_RepositoryDoneCommand == null)
                    _RepositoryDoneCommand = new RelayCommand(
                        param =>
                        {
                            //Execute code goes here!
                        },
                        param =>
                        {
                            //Can execute code goes here!
                            return true;
                        }
                        );
                return _RepositoryDoneCommand;
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
                            //Execute code goes here!
                        },
                        param =>
                        {
                            //Can execute code goes here!
                            return true;
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
                            //Execute code goes here!
                        },
                        param =>
                        {
                            //Can execute code goes here!
                            return true;
                        }
                        );
                return _GenerateCodeCommand;
            }
        }

        #endregion

        #region NewProjectCommand

        private ICommand _NewProjectCommand;

        public ICommand NewProjectCommand
        {
            get
            {
                if (_NewProjectCommand == null)
                    _NewProjectCommand = new RelayCommand(
                        param =>
                        {
                            if (_projectOpen)
                            {
                                //TODO: Need to add code to save any changes to the current project.



                            }

                            ProjectOptions = new HarmonyCoreOptions();

                            AllowRepositorySelection = true;
                        });
                return _NewProjectCommand;
            }
        }

        #endregion

        #region OpenProjectCommand

        private ICommand _OpenProjectCommand;

        public ICommand OpenProjectCommand
        {
            get
            {
                if (_OpenProjectCommand == null)
                    _OpenProjectCommand = new RelayCommand(
                        param =>
                        {
                            //Execute code goes here!
                        }
                        );
                return _OpenProjectCommand;
            }
        }

        #endregion

        #region SaveProjectCommand

        private ICommand _SaveProjectCommand;

        public ICommand SaveProjectCommand
        {
            get
            {
                if (_SaveProjectCommand == null)
                    _SaveProjectCommand = new RelayCommand(
                        param =>
                        {
                            //Execute code goes here!
                        },
                        param =>
                        {
                            //Can execute code goes here!
                            return _projectOpen;
                        }
                        );
                return _SaveProjectCommand;
            }
        }

        #endregion

        #region SaveProjectAsCommand

        private ICommand _SaveProjectAsCommand;

        public ICommand SaveProjectAsCommand
        {
            get
            {
                if (_SaveProjectAsCommand == null)
                    _SaveProjectAsCommand = new RelayCommand(
                        param =>
                        {
                            //Execute code goes here!
                        },
                        param =>
                        {
                            //Can execute code goes here!
                            return _projectOpen;
                        }
                        );
                return _SaveProjectAsCommand;
            }
        }

        #endregion

        #region CloseProjectCommand

        private ICommand _CloseProjectCommand;

        public ICommand CloseProjectCommand
        {
            get
            {
                if (_CloseProjectCommand == null)
                    _CloseProjectCommand = new RelayCommand(
                        param =>
                        {
                            //Execute code goes here!
                        },
                        param =>
                        {
                            //Can execute code goes here!
                            return _projectOpen;
                        }
                        );
                return _CloseProjectCommand;
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
    }
}

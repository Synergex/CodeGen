 
;  SYNERGY DATA LANGUAGE OUTPUT
;
;  REPOSITORY     : D:\CodeGen\Trunk\SymphonyOrchestratorRepository\rpsmain.ism
;                 : D:\CodeGen\Trunk\SymphonyOrchestratorRepository\rpstext.ism
;                 : Version 10.1.1c
;
;  GENERATED      : 13-FEB-2015, 12:52:55
;                 : Version 10.3.1
;  EXPORT OPTIONS : [ALL] 
 
 
Structure CODEGEN_COMMAND   DBL ISAM
   Description "Codegen command options"
 
Field SELECT_TO_BUILD   Type DECIMAL   Size 1
   Description "if selected, generate it"
   Prompt "Generate?"   Checkbox
 
Field RPS_MAIN_FILE   Type ALPHA   Size 255
   Description "repository main file"
   Long Description
      "<SYMPHONY_ALPHA_SIZE=500>"
      "<SYMPHONY_SEARCHBOX_COMMAND=DataContext.FindFileCommand>"
      "<SYMPHONY_UPDATE_TRIGGER=PropertyChanged>"
   Prompt "Repository main file"
   Required
   Drill Method "FindRPSMAIN"
 
Field RPS_MAIN_FILE_NAME   Type ALPHA   Size 255   Script Noview
   Description "repository main file"
 
Field RPS_TEXT_FILE   Type ALPHA   Size 255
   Description "repository text file"
   Long Description
      "<SYMPHONY_ALPHA_SIZE=500>"
      "<SYMPHONY_SEARCHBOX_COMMAND=DataContext.FindFileCommand>"
      "<SYMPHONY_UPDATE_TRIGGER=PropertyChanged>"
   Prompt "Repository text file"
   Required
   Drill Method "FindRPSTEXT"
 
Field RPS_TEXT_FILE_NAME   Type ALPHA   Size 255   Script Noview
   Description "repository text file"
 
Field STRUCTURE_NAME   Type ALPHA   Size 30
   Description "name of RPS structure"
   Prompt "Structure name"
   Uppercase
   Required
   Selection Window 0 0 "Repository"
 
Field TEMPLATE_NAME   Type ALPHA   Size 255
   Description "name of required template"
   Long Description
      "<SYMPHONY_ALPHA_SIZE=500>"
      "<SYMPHONY_SEARCHBOX_COMMAND=DataContext.FindFileCommand>"
      "<SYMPHONY_UPDATE_TRIGGER=PropertyChanged>"
   Prompt "Template name"
   Required
   Drill Method "FindTemplate"
 
Field TEMPLATE_FILE_NAME   Type ALPHA   Size 255   Script Noview
   Description "name of template file"
 
Field OUTPUT_FOLDER   Type ALPHA   Size 255
   Description "output folder (relative)"
   Long Description
      "<SYMPHONY_ALPHA_SIZE=500>"
      "<SYMPHONY_SEARCHBOX_COMMAND=DataContext.FindFolderCommand>"
      "<SYMPHONY_UPDATE_TRIGGER=PropertyChanged>"
   Prompt "Output folder"
   Required
   Drill Method "FindOutput"
 
Field REPLACE_FILE   Type DECIMAL   Size 1
   Description "repalce existing file"
   Prompt "Replace exiting file?"
   Default "1"   Automatic
   Selection List 0 0 0  Entries "No", "Yes"
   Enumerated 3 0 1
 
Field NAMESPACE   Type ALPHA   Size 100
   Description "namespace"
   Long Description
      "<SYMPHONY_ALPHA_SIZE=300>"
      "<SYMPHONY_UPDATE_TRIGGER=PropertyChanged>"
   Prompt "Namespace"
   Required
 
Field NO_OVERRIDE_NAMESPACE   Type DECIMAL   Size 1
   Description "do not override the namespace"
   Prompt "Don't override namespace"   Checkbox
 
Field CHARACTER_WIDTH   Type DECIMAL   Size 3
   Description "character width"
   Prompt "Character width"
 
Field PREFIX   Type ALPHA   Size 30
   Description "field previf value"
   Prompt "Field prefix value"
   Default "m"   Automatic
 
Group USER_TOKENS   Type ALPHA   Size 200   Dimension 50   Script Noview
   Long Description
      "<SYMPHONY_ARRAY_FIELD>"
 
   Field TOKEN_NAME   Type ALPHA   Size 100
 
   Field TOKEN_VALUE   Type ALPHA   Size 100
 
Endgroup
 
Field USER_TOKENS_ENTERED   Type DECIMAL   Size 1
   Required
 
Field WSC_FILE   Type ALPHA   Size 255
   Description "WSC folder/file name"
   Long Description
      "<SYMPHONY_ALPHA_SIZE=500>"
      "<SYMPHONY_SEARCHBOX_COMMAND=DataContext.FindFileCommand>"
      "<SYMPHONY_UPDATE_TRIGGER=PropertyChanged>"
   Prompt "WSC file"
   Drill Method "FindWSC"
 
Field USE_WSC_FIELDS_ONLY   Type DECIMAL   Size 1
   Prompt "Use WSC field information only"   Checkbox
 
Field INCLUDEOVERLAYFIELDS   Type DECIMAL   Size 1
   Prompt "Include overlay fields"   Checkbox
   Default "0"   Automatic
 
Field IGNOREEXCLUDELANGUAGE   Type DECIMAL   Size 1
   Prompt "Exclude fields which are 'Excluded by Language'"   Checkbox
   Default "0"   Automatic
 
Field HONOREXCLUDETOOLKIT   Type DECIMAL   Size 1
   Prompt "Exclude fields which are 'Excluded by Toolkit'"   Checkbox
   Default "0"   Automatic
 
Field HONOREXCLUDEREPORTWRITER   Type DECIMAL   Size 1
   Prompt "Exclude fields which are 'Excluded by ReportWriter'"   Checkbox
   Default "0"   Automatic
 
Field HONOREXCLUDEWEB   Type DECIMAL   Size 1
   Prompt "Exclude fields which are 'Excluded by Web'"   Checkbox
   Default "0"   Automatic
 
Field GROUPFIELDNOPREFIX   Type DECIMAL   Size 1
   Prompt "Don't prefix group fields with group name"   Checkbox
   Default "0"   Automatic
 
Field GROUPNOEXPAND   Type DECIMAL   Size 1
   Prompt "Don't expand implicit groups to individual fields"   Checkbox
   Default "0"   Automatic
 
Field GROUPFIELDNORPSPREFIX   Type DECIMAL   Size 1
   Prompt "Don't use repository group field prefix"   Checkbox
   Default "0"   Automatic
 
Field BUTTON_LOOP_OVERRIDE   Type ALPHA   Size 1
   Long Description
      "<SYMPHONY_SELWND_LENGTH=400>"
   Prompt "Default button loop processing"
   Selection List 0 0 0  Entries "None<O>",
         "Always use the default buttons defined in DefaultButtons.xml<A>",
         "Never use the default buttons defined in DefaultButtons.xml<D>",
         "Never load any buttons (DefaultButtons.xml or window script)<N>"
 
Field MAIN_ALIAS   Type ALPHA   Size 32
   Description "main structure alias"
   Prompt "Structure alias"
 
Field CHARACTER_HIEGHT   Type DECIMAL   Size 3
   Description "character height"
   Prompt "Character Height"
 
Field OVERRIDE_KEY_NUM   Type DECIMAL   Size 3
   Description "override key number"
   Prompt "Override key number"
 
Field MULTI_WRITE   Type DECIMAL   Size 1
   Prompt "Multi-write files"   Checkbox
 
Field WSC_SELECTION_FILE   Type ALPHA   Size 255
   Description "WSC (selection) folder/file name"
   Long Description
      "<SYMPHONY_ALPHA_SIZE=500>"
      "<SYMPHONY_SEARCHBOX_COMMAND=DataContext.FindFileCommand>"
      "<SYMPHONY_UPDATE_TRIGGER=PropertyChanged>"
   Prompt "Selection window WSC file"
   Drill Method "FindWSCSELECT"
 
Group ADDITIONAL_STRUCTURES   Type ALPHA   Dimension 20   Script Noview
   Description "additional structures"
   Long Description
      "<CUSTOM_NOT_SYMPHONY_ARRAY_FIELD>"
 
   Field STRUCTURE_NAME   Type ALPHA   Size 32
 
   Field ALIAS_NAME   Type ALPHA   Size 50
 
Endgroup
 
Field INPUT_WINDOW_NUMBER   Type DECIMAL   Size 4
   Prompt "Input window number"
 
Field INPUT_WINDOW_NAME   Type ALPHA   Size 30
   Prompt "Input window name"
 
Field USER_TOKEN_FILE   Type ALPHA   Size 255
   Description "user toke file"
   Long Description
      "<SYMPHONY_ALPHA_SIZE=500>"
      "<SYMPHONY_SEARCHBOX_COMMAND=DataContext.FindFileCommand>"
      "<SYMPHONY_UPDATE_TRIGGER=PropertyChanged>"
   Prompt "User token file"
   Drill Method "FindUSERTOKEN"
 
Structure CODEGEN_STRUCTURES   DBL ISAM
   Description "additional structures and alias"
 
Field STRUCTURE_NAME   Type ALPHA   Size 32
   Description "structure name"
   Prompt "Structure name"
   Uppercase
   Selection Window 0 0 "Repository"
 
Field ALIAS_NAME   Type ALPHA   Size 50
   Prompt "Alias name"
 
Structure CODEGEN_USER_TOKEN   DBL ISAM
   Description "user tokens values for codegen"
 
Field TOKEN_NAME   Type ALPHA   Size 100
   Description "token name"
   Prompt "Token name"
 
Field TOKEN_VALUE   Type ALPHA   Size 100
   Description "supplied token value"
   Prompt "Value"
   Required
 
Field TOKEN_TYPE   Type DECIMAL   Size 1
 
Structure EXECUTION_RESULTS   DBL ISAM
   Description "results of the command execution"
 
Field STATUS   Type DECIMAL   Size 1
 
Field TITLE   Type ALPHA   Size 100
   Description "command title"
 
Field RESPONSE   Type ALPHA   Size 1000
   Description "command response"
 
Structure ORCHESTRATOR_DEFAULTS   DBL ISAM
   Description "default options"
 
Field RPS_MAIN_FILE   Type ALPHA   Size 255
   Description "repository main file"
   Long Description
      "<SYMPHONY_ALPHA_SIZE=500>"
      "<SYMPHONY_SEARCHBOX_COMMAND=DataContext.FindFileCommand>"
      "<SYMPHONY_UPDATE_TRIGGER=PropertyChanged>"
   Prompt "RPS Main file"
   Drill Method "FindDEFRPSMAIN"
 
Field RPS_TEXT_FILE   Type ALPHA   Size 255
   Description "repository text file"
   Long Description
      "<SYMPHONY_ALPHA_SIZE=500>"
      "<SYMPHONY_SEARCHBOX_COMMAND=DataContext.FindFileCommand>"
      "<SYMPHONY_UPDATE_TRIGGER=PropertyChanged>"
   Prompt "RPS Text file"
   Drill Method "FindDEFRPSTEXT"
 
Field TEMPLATE_FOLDER   Type ALPHA   Size 255
   Description "default template folder"
   Long Description
      "<SYMPHONY_ALPHA_SIZE=500>"
      "<SYMPHONY_SEARCHBOX_COMMAND=DataContext.FindFolderCommand>"
      "<SYMPHONY_UPDATE_TRIGGER=PropertyChanged>"
   Prompt "Template folder"
   Drill Method "FindDEFTemplate"
 
Field OUTPUT_FOLDER   Type ALPHA   Size 255
   Description "default output folder"
   Long Description
      "<SYMPHONY_ALPHA_SIZE=500>"
      "<SYMPHONY_SEARCHBOX_COMMAND=DataContext.FindFolderCommand>"
      "<SYMPHONY_UPDATE_TRIGGER=PropertyChanged>"
   Prompt "Output folder"
   Drill Method "FindDEFOutput"
 
Field ADD_FOLDER_TO_NAMESPACE   Type DECIMAL   Size 1
   Description "add folder name to namespace"
   Prompt "Add folder name to namespace?"   Checkbox
 
Field REPLACE_FILE   Type DECIMAL   Size 1
   Description "repalce existing file"
   Prompt "Replace exiting file?"
   Default "1"   Automatic
   Selection List 0 0 0  Entries "No", "Yes"
   Enumerated 3 0 1
 
Field NAMESPACE   Type ALPHA   Size 100
   Description "namespace"
   Long Description
      "<SYMPHONY_ALPHA_SIZE=300>"
   Prompt "Namespace"
 
Field CHARACTER_WIDTH   Type DECIMAL   Size 3
   Description "character width"
   Prompt "Character width"
 
Field PREFIX   Type ALPHA   Size 30
   Description "field previf value"
   Prompt "Field prefix value"
   Default "m"   Automatic
 
Field SHOW_VERBOSE   Type DECIMAL   Size 1
   Description "show verbose codegen output"
   Prompt "Show verbose CodeGen output"   Checkbox
 
Field USE_COMMAND_LINE   Type DECIMAL   Size 1
   Description "Use command line interface"
   Prompt "Use command line interface?"   Checkbox
 
Field CREATE_COMMAND_SCRIPT   Type DECIMAL   Size 1
   Description "create a command script"
   Prompt "Create CodeGen input script?"   Checkbox
 
Field COMMAND_SCRIPT_NAME   Type ALPHA   Size 255
   Description "command script file name"
   Long Description
      "<SYMPHONY_ALPHA_SIZE=500>"
      "<SYMPHONY_SEARCHBOX_COMMAND=DataContext.FindFileCommand>"
      "<SYMPHONY_UPDATE_TRIGGER=Default>"
   Prompt "Command script name"
   Required
   Drill Method "FindCommandScript"
 
Field DATA_MAPPING_FILENAME   Type ALPHA   Size 255
   Long Description
      "<SYMPHONY_ALPHA_SIZE=500>"
      "<SYMPHONY_SEARCHBOX_COMMAND=DataContext.FindFileCommand>"
      "<SYMPHONY_UPDATE_TRIGGER=Default>"
   Prompt "Data mapping filename"
   Drill Method "FindMappingFile"
 
Field SHOW_COLUMN_DISPLAY   Type DECIMAL   Size 1
   Prompt "Show column display"   Checkbox
 
Field PROJECT_RELATIVE_PATH_ROOT   Type ALPHA   Size 255
   Description "root of the relative path"
   Long Description
      "<SYMPHONY_ALPHA_SIZE=500>"
   Prompt "Root folder path"
 
Field USE_PROJECT_FOLDER_AS_ROOT   Type DECIMAL   Size 1
   Prompt "Use project folder?"   Checkbox
 
Field CUSTOM_DATA_MAPPING   Type ALPHA   Size 255
   Description "custom data mapping file"
   Long Description
      "<SYMPHONY_ALPHA_SIZE=500>"
      "<SYMPHONY_SEARCHBOX_COMMAND=DataContext.FindFileCommand>"
      "<SYMPHONY_UPDATE_TRIGGER=PropertyChanged>"
   Prompt "Custom mapping"
   Drill Method "FindCUSTOMMAP"
 
Structure ORCHESTRATOR_PROJECT   DBL ISAM
   Description "Project details"
 
Field PROJECT_FILE   Type ALPHA   Size 255
   Description "Project file"
   Prompt "Project file"
   Required
 
Field BUILD_FILE_NAME   Type ALPHA   Size 255
   Description "build/generate file name"
   Prompt "Generate file name"
   Required
 
Field RPS_MAIN_FILE   Type ALPHA   Size 255
   Description "repository nmain file"
   Long Description
      "<SYMPHONY_ALPHA_SIZE=500>"
      "<SYMPHONY_SEARCHBOX_COMMAND=DataContext.FindFileCommand>"
      "<SYMPHONY_UPDATE_TRIGGER=PropertyChanged>"
   Prompt "Repository main file"
   Required
   Drill Method "FindPRJRPSMAIN"
 
Field RPS_TEXT_FILE   Type ALPHA   Size 255
   Description "Repository text file"
   Long Description
      "<SYMPHONY_ALPHA_SIZE=500>"
      "<SYMPHONY_SEARCHBOX_COMMAND=DataContext.FindFileCommand>"
      "<SYMPHONY_UPDATE_TRIGGER=PropertyChanged>"
   Prompt "Repository text file"
   Required
   Drill Method "FindPRJRPSMAIN"
 

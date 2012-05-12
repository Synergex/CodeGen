
Building CodeGen on Unix or Linux
=================================

IMPORTANT NOTES

1. Files downloaded from CodePlex have a Windows format wich must be converted
   to a Unix format before use. The "build" script will change most files for you, but
   you must manually change the format of the "build" script as noted below.

2. All CodeGen scripts assume you have already configured a Synergy/DE environment

To build CodeGen

1. Log in to an administrative account
2. Open a BASH shell
2. Move to the "TraditionalSynergy\Unix" folder
3. Change the "build" script to a Unix format (dos2unix build)
4. Execute the "build" script

To execute CodeGen:

1. Add the "Unix\exe" folder to your PATH
2. Execute the "Unix\setup" script (created by build)
3. Execute CodeGen using the "codegen" command

You should consider setting the following environment variables from your login
script before executing the setup script

	CODEGEN_TPLDIR		Default location of template files
	CODEGEN_OUTDIR		Default location for output (generated) files
	CODEGEN_AUTHOR		Your name (inserted by the <AUTHOR> token)
	CODEGEN_COMPANY		Your company name (inserted by the <COMPANY> token)


Using CodeGen on OpenVMS
===============================================================================

To build CodeGen on OpenVMS, execute the BUILD.COM command procedure.

To execute CodeGen on OpenVMS, execute the SETUP.COM command procedure and then
execute CodeGen using the CODEGEN global symbol that it creates.

You should consider setting the following logical names from your login.com,
or system wide, before executing SETUP.COM.

CODEGEN_TPLDIR		Default location of template files
CODEGEN_OUTDIR		Default location for output (generated) files
CODEGEN_AUTHOR		Your name (inserted by the <AUTHOR> token)
CODEGEN_COMPANY		Your company name (inserted by the <COMPANY> token)


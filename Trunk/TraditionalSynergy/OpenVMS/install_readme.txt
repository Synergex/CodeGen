To install CodeGen for OpenVMS:

1. Create a directory where you would like the CodeGen files to reside.

2. Extract the codegen files to that directory. For example, to extract the
   files to DKA0:[CODEGEN] use the following command:

   $ BACKUP/LOG CODEGEN.BCK/SAVE DKA0:[CODEGEN]

3. Call the CODEGEN_SETUP.COM command procedure from your LOGIN.COM or
   SYLOGIN.COM command procedure:

   $ @DKA0:[CODEGEN]CODEGEN_SETUP.COM

4. To confirm that you can run CodeGen, try typing the following command:

   $ codegen -version

5. Use the CODEGEN global symbol to execute CodeGen

   $ codegen -options


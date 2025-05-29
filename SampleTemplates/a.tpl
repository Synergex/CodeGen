;//This template is for development testing. It is not shipped by the installer.
<CODEGEN_FILENAME>a.dbl</CODEGEN_FILENAME>
namespace <NAMESPACE>

    public class <StructureName>

<FIELD_LOOP>
        public readwrite property <FieldSqlName>, <FIELD_SNTYPE> 

  <IF GROUP_EXPLICIT AND NOT GROUP_OVERLAY>
        public class <STRUCTURE_NAME>_<FIELD_NAME> ;Explicit group

        <FIELD_GROUP_EXPAND>
        endclass

  </IF>
</FIELD_LOOP>
    endclass

endnamespace

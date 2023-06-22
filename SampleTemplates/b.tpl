;//This template is for development testing. It is not shipped by the installer.
<CODEGEN_FILENAME><structure_name>_b.txt</CODEGEN_FILENAME>
<COUNTER_1_RESET>
<FIELD_LOOP>
  <IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
    <COUNTER_1_INCREMENT>
    <IF COUNTER_1_EQ_1>
    if (ok && openAndBind)
    begin
        if (%ssc_bind(a_dbchn,c1<StructureName>,<REPLICATION_REMAINING_INCLUSIVE_MAX_250>,
    </IF COUNTER_1_EQ_1>
    <IF CUSTOM_DBL_TYPE>
        &    tmp<FieldSqlName><IF REPLICATION_NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF>
    <ELSE ALPHA>
        &    <structure_name>.<field_original_name_modified><IF REPLICATION_NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF>
    <ELSE DECIMAL>
        &    <structure_name>.<field_original_name_modified><IF REPLICATION_NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF>
    <ELSE INTEGER>
        &    <structure_name>.<field_original_name_modified><IF REPLICATION_NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF>
    <ELSE DATE>
        &    ^a(<structure_name>.<field_original_name_modified>)<IF REPLICATION_NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF>
    <ELSE TIME>
        &    tmp<FieldSqlName><IF REPLICATION_NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF>
    <ELSE USER AND USERTIMESTAMP>
        &    tmp<FieldSqlName><IF REPLICATION_NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF>
    <ELSE USER AND NOT USERTIMESTAMP>
      <IF DEFINED_ASA_TIREMAX>
        &    tmp<FieldSqlName><IF REPLICATION_NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF>
      <ELSE>
        &    <structure_name>.<field_original_name_modified><IF REPLICATION_NOMORE>)==SSQL_FAILURE)<ELSE><IF COUNTER_1_LT_250>,<ELSE>)==SSQL_FAILURE)</IF COUNTER_1_LT_250></IF>
      </IF DEFINED_ASA_TIREMAX>
    </IF CUSTOM_DBL_TYPE>
    <IF COUNTER_1_EQ_250>
        begin
            ok = false
            sts = 0
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
                errtxt="Failed to bind variables"
        end
    end
      <COUNTER_1_RESET>
    <ELSE NOMORE>
        begin
            ok = false
            sts = 0
            if (%ssc_getemsg(a_dbchn,errtxt,length,,dberror)==SSQL_FAILURE)
                errtxt="Failed to bind variables"
        end
    end
    </IF COUNTER_1_EQ_250>
  </IF CUSTOM_NOT_REPLICATOR_EXCLUDE>
</FIELD_LOOP>

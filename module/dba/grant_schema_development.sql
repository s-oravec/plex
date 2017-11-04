define l_schema_name = &1
undefine 1

prompt .. Granting privileges to package &&g_package_name in schema &&l_schema_name

prompt .. Granting CREATE PROCEDURE to &&l_schema_name
grant create procedure to &&l_schema_name;

prompt .. Granting CREATE TYPE to &&l_schema_name
grant create type to &&l_schema_name;

prompt .. Granting CREATE SESSION to &&l_schema_name
grant create session to &&l_schema_name;

prompt .. Granting DEBUG CONNECT SESSION to &&l_schema_name
grant debug connect session to &&l_schema_name;

undefine l_schema_name

set trimspool on
set serveroutput on size unlimited
set linesize 4000
set pages 0
set feedback off
set verify off
set echo off

clear screen

prompt .. Creating package UT_PLEX_INTEGER_STACK
@test/implementation/type/ut_plex_integer_stack.pkg

prompt .. Creating package UT_PLEX_MATCHTEXTLITERAL
@test/implementation/type/ut_plex_matchtextliteral.pkg

prompt .. Creating package UT_PLEX_MATCHLABEL
@test/implementation/type/ut_plex_matchlabel.pkg

prompt .. Creating package UT_PLEX_MATCHKEYWORD
@test/implementation/type/ut_plex_matchkeyword.pkg

prompt .. Creating package UT_PLEX_MATCHMULTILINECOMMENT
@test/implementation/type/ut_plex_matchmultilinecomment.pkg

prompt .. Creating package UT_PLEX_MATCHNUMBERLITERAL
@test/implementation/type/ut_plex_matchnumberliteral.pkg

prompt .. Creating package UT_PLEX_MATCHSNGLLINECOMMENT
@test/implementation/type/ut_plex_matchsngllinecomment.pkg

prompt .. Creating package UT_PLEX_MATCHWHITESPACE
@test/implementation/type/ut_plex_matchwhitespace.pkg

prompt .. Creating package UT_PLEX_MATCHWORD
@test/implementation/type/ut_plex_matchword.pkg

prompt .. Creating package UT_PLEX_LEXER
@test/implementation/package/ut_plex_lexer.pkg
prompt done

define utplsql_user=ceos_utplsql
prompt granting execute on test packages to &&utplsql_user user
begin
    for ii in (select *
                 from user_objects
                where object_name like 'TEST%'
                  and object_type = 'PACKAGE') loop
        execute immediate 'grant execute on ' || ii.object_name || ' to &&utplsql_user';
    end loop;
end;
/
prompt done

prompt .. Resetting packages
exec dbms_session.reset_package;

prompt .. Re-enabling DBMS_OUTPUT
exec dbms_output.enable;

set termout on
set serveroutput on size unlimited

prompt utPLSQL test reported as JUnit
spool test/report/test-report-core.xml
begin
    ut.run(ut_junit_reporter());
end;
/
spool off

prompt done

prompt Code Coverage Report
spool test/report/coverage-report-core.html
begin
    ut.run(ut_coverage_html_reporter());
end;
/
spool off

select * from table(ut.run());
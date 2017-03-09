set serveroutput on
set feedback off 
whenever oserror exit failure;
whenever sqlerror exit SQL.SQLCODE;


declare
  procedure exec_ddl(p_strStatement varchar2) as
  begin
    execute immediate  p_strStatement;
    exception when others then null;
  end;
begin
    exec_ddl('drop package body hr_utils');
    exec_ddl('drop package hr_utils');
    exec_ddl('drop type employee_set_t');
    exec_ddl('drop type department_descr_t');
    exec_ddl('drop type employee_descr_t');
    exec_ddl('drop type employee_short_descr_t');
    exec_ddl('drop synonym string_list_t');
    exec_ddl('drop synonym number_list_t');
    exec_ddl('drop view employees_consolidated_view');
end;
/

disconnect
exit
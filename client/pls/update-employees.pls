declare
-- *************************************************************************** --
-- updates the employees added by script "add-employees.pls"
---
-- warning:
-- in case you launch this script twice then you'll get the reject:
--   - ORA-00001: unique constraint (HR.JHIST_EMP_ID_ST_DATE_PK) violated
--   - ORA-02290: check constraint (HR.JHIST_DATE_INTERVAL) violated 
-- "ORA-06512: at "HR.ADD_JOB_HISTORY" because there's trigger "UPDATE_JOB_HISTORY";
-- to avoid a such effect, it's possibly to swith this trigger off by command 
-- 'alter trigger update_job_history disable' (it'll cause "JOB_HISTORY" table
-- isn't populated after that')
-- *************************************************************************** --

  DEP_NAME_ADMIN constant departments.department_name%type := 'Administration';
  DEP_NAME_EXECUTIVE constant departments.department_name%type := 'Executive';
  DEP_NAME_FINANCE constant departments.department_name%type := 'Finance';
  DEP_NAME_IT constant departments.department_name%type := 'IT';
  DEP_NAME_PR constant departments.department_name%type := 'Public Relations';
  DEP_NAME_RECRUITING constant departments.department_name%type := 'Recruiting';
  
  EMPL_NAME_FG constant varchar2(50) := 'Forrest Gump';
  EMPL_NAME_IJ constant varchar2(50) := 'Indiana Jones';
  EMPL_NAME_FG_IDX constant pls_integer := 1;
  EMPL_NAME_IJ_IDX constant pls_integer := 2;
  
  v_dep_names string_list_t := string_list_t(DEP_NAME_ADMIN, DEP_NAME_EXECUTIVE, 
                                             DEP_NAME_FINANCE, DEP_NAME_IT, DEP_NAME_IT,
                                             DEP_NAME_PR, DEP_NAME_RECRUITING);
  v_empl_names string_list_t := string_list_t(EMPL_NAME_FG, EMPL_NAME_IJ);
  v_deps hr_utils.departments_map_t;
  v_ids number_list_t;
  v_employees employee_set_t;
  
  v_err_code number;
  v_err_msg varchar(1000);
  
  unknown_employee exception;
  pragma exception_init(unknown_employee, -20300); -- hr_utils.E_UNKNOWN_EMPLOYEE
  
  procedure trace_employees(p_empls in employee_set_t)
    is
    begin
          if ( p_empls is null ) then
            dbms_output.put_line('collection is null-value');
          elsif (p_empls is null) then
             dbms_output.put_line('collection is emptyt');
          else
              for v_i in p_empls.first..p_empls.last loop
                 dbms_output.put_line(p_empls(v_i).empl_id || ', ' || p_empls(v_i).first_name || '    ' || p_empls(v_i).last_name ||
                                      ', ' || p_empls(v_i).job_id || ', ' || p_empls(v_i).dep_id || ', ' || p_empls(v_i).salary || ', ' || p_empls(v_i).commission);
               end loop;
          end if;
    end trace_employees;

begin
   dbms_output.put_line('--- update employee job:');  
   -- execute immediate 'alter trigger update_job_history disable';
   execute immediate 'alter session set isolation_level = READ COMMITTED';

   hr_utils.get_employees_by_full_name(v_empl_names, v_ids);
   
   if ( v_ids.count < 2 ) then
      dbms_output.put_line('employees for updating are not found!' || chr(13) || chr(10) || 
                           '(hint: launch "add_employees.sql" script at firt)');    
   else
      dbms_output.put_line('--- ' || v_ids.count || ' employees are found:');  
      
      dbms_output.put_line('--- before updating:');  
      hr_utils.get_employees(v_ids, v_employees);
      trace_employees(v_employees);
      
      hr_utils.update_employee_job(v_employees(EMPL_NAME_FG_IDX).empl_id, v_employees(EMPL_NAME_IJ_IDX).job_id, 
                                               v_employees(EMPL_NAME_IJ_IDX).dep_id, v_employees(EMPL_NAME_IJ_IDX).mngr_id );
      hr_utils.update_employee_job(v_employees(EMPL_NAME_IJ_IDX).empl_id, v_employees(EMPL_NAME_FG_IDX).job_id, 
                                               v_employees(EMPL_NAME_FG_IDX).dep_id, v_employees(EMPL_NAME_FG_IDX).mngr_id );                                               
      hr_utils.update_employee_reward(v_employees(EMPL_NAME_FG_IDX).empl_id,  
                                                  v_employees(EMPL_NAME_IJ_IDX).salary, v_employees(EMPL_NAME_IJ_IDX).commission);
      hr_utils.update_employee_reward(v_employees(EMPL_NAME_IJ_IDX).empl_id,  
                                                  v_employees(EMPL_NAME_FG_IDX).salary, v_employees(EMPL_NAME_FG_IDX).commission);

      commit;                                              

      dbms_output.put_line('--- after updating:');                                                 
      hr_utils.get_employees(v_ids, v_employees);
      trace_employees(v_employees);
      
      dbms_output.put_line('--- Done! Check "job history" for new entries ("get-job-history.sql" script)');                                                 
   
   end if;
   
   exception when unknown_employee then
                  v_err_code := SQLCODE;
                  v_err_msg := substr(SQLERRM, 1, 200);
                  dbms_output.put_line('"Unknown employee" exception! (error code: '||  v_err_code ||  ' description: ' || v_err_msg);
                  rollback;
             when others then       
                  v_err_code := SQLCODE;
                  v_err_msg := substr(SQLERRM, 1, 600);
                  dbms_output.put_line(v_err_msg);
                  if ( (v_err_code = -1) or (v_err_code = -2290))  then
                      dbms_output.put_line(' * tip: see comments at the top of this script file');
                  end if;    
                  rollback;
end;
/
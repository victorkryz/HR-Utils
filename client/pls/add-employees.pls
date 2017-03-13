declare
  DEP_NAME_ADMIN constant departments.department_name%type := 'Administration';
  DEP_NAME_EXECUTIVE constant departments.department_name%type := 'Executive';
  DEP_NAME_FINANCE constant departments.department_name%type := 'Finance';
  DEP_NAME_IT constant departments.department_name%type := 'IT';
  DEP_NAME_PR constant departments.department_name%type := 'Public Relations';
  DEP_NAME_RECRUITING constant departments.department_name%type := 'Recruiting';

  v_names string_list_t := string_list_t(DEP_NAME_ADMIN, DEP_NAME_EXECUTIVE, 
                                         DEP_NAME_FINANCE, DEP_NAME_IT, DEP_NAME_IT,
                                         DEP_NAME_PR, DEP_NAME_RECRUITING);
  v_deps hr_utils.departments_map_t;                                          
  v_employees employee_set_t := employee_set_t();

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

   dbms_output.put_line('--- add new employees and report ther id(s) (id, first_name, last_name, job_id, department id, slary, commission):');  
   execute immediate 'alter session set isolation_level = READ COMMITTED';

   hr_utils.get_departments(v_names, v_deps);
    
    v_employees := employee_set_t(
              employee_descr_t(null, 'Forrest', 'Gump', 'fgumb', '575.111.222', v_deps(DEP_NAME_IT).department.dep_id, 
                               null, 'IT_PROG', null, 25520, v_deps(DEP_NAME_IT).manager_id),
              employee_descr_t(null, 'Darth', 'Vader', 'dvader', '575.222.333', v_deps(DEP_NAME_EXECUTIVE).department.dep_id, 
                               null, 'FI_MGR',  0.35, 250000, v_deps(DEP_NAME_EXECUTIVE).manager_id),
              employee_descr_t(null, 'James', 'Bond', 'jbond', '575.333.444', v_deps(DEP_NAME_PR).department.dep_id, 
                               null, 'MK_MAN',  null, 120750, v_deps(DEP_NAME_PR).manager_id),
              employee_descr_t(null, 'Indiana', 'Jones', 'ijones', '575.444.555', v_deps(DEP_NAME_PR).department.dep_id, 
                               null, 'HR_REP',  null, 120550, v_deps(DEP_NAME_PR).manager_id),
              employee_descr_t(null, 'Rocky', 'Balboa', 'rbalboa', '575.555.666', v_deps(DEP_NAME_RECRUITING).department.dep_id, 
                               null, 'IT_PROG',  null, 95530, v_deps(DEP_NAME_RECRUITING).manager_id)
              );
              
              hr_utils.add_employees(v_employees);
              
              trace_employees(v_employees);

              commit;
end;
/
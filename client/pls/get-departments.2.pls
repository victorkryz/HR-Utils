declare
  
    v_deps hr_utils.departments_map_t;
    v_employees employee_set_t;
    v_name departments.department_name%type;
    v_names string_list_t := string_list_t('Administration', 'Finance', 'IT', 
                                            'Public Relations', 'Recruiting');

    procedure trace_deps(p_deps in hr_utils.departments_map_t)
    is
      v_key departments.department_name%type;
      v_dep hr_utils.departments_entry_t;
    begin
        v_key := p_deps.first;
        
        while v_key is not null loop
          v_dep := p_deps(v_key);
          dbms_output.put_line('department name: ' || v_dep.department.dep_name || 
                               ', id: ' || v_dep.department.dep_id  || ' mngr id: ' || v_dep.manager_id);
          v_key := p_deps.next(v_key);
        end loop;
    end trace_deps;

begin
      dbms_output.put_line('--- find deparments by name(s) (id, name, manager id):'); 
      hr_utils.get_departments(v_names, v_deps);
      trace_deps(v_deps);
end;
/
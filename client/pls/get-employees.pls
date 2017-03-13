declare
  DEPARTMENT_NAME constant departments.department_name%type := 'Executive';
  
  c_empl hr_utils.empl_cursor_t;
  v_empl c_empl%rowtype;
  v_deps hr_utils.departments_map_t;
  v_dep_id employees.employee_id%type;
begin
     dbms_output.put_line('--- report employees of department "' || DEPARTMENT_NAME ||'" (id, first name, last name):'); 
     
     hr_utils.get_departments(string_list_t(DEPARTMENT_NAME), v_deps);
     if ( v_deps.count = 1 ) then
      
         v_dep_id := v_deps(DEPARTMENT_NAME).department.dep_id;
         c_empl := hr_utils.get_employees(v_dep_id);
    
         loop
            fetch c_empl into v_empl;
            exit when c_empl%notfound;
    
            dbms_output.put_line(v_empl.employee_id || ', ' || v_empl.first_name || '    ' || v_empl.last_name);
          end loop;
          
          close c_empl;
   end if;       

  exception when hr_utils.unknown_department then
          dbms_output.put_line('unknown deprtment id - ' || v_dep_id);
          raise;

end;
/
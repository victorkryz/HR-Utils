set linesize 32000;

declare
  type c_empl is ref cursor;
  
  v_curs sys_refcursor;
  v_row hr_utils.employee_composite_entry_t;

procedure trace_dep_desr(p_dep in department_descr_t) 
   is
   begin
     dbms_output.put('id: ' || p_dep.dep_id || ', name: ' || p_dep.dep_name);
   end;
  
   procedure trace_empl_desr(p_empl in employee_descr_t) 
   is
   begin
     dbms_output.put('id: ' ||p_empl.empl_id || ', job id: ' || p_empl.job_id || ', salary: ' || p_empl.salary || ', comission: ' || p_empl.commission);
   end;
   
   procedure trace_employee(p_empl in hr_utils.employee_composite_entry_t)
   is
   begin
        dbms_output.put(p_empl.empl_decorated_name); 
        dbms_output.put(' (');
        trace_empl_desr(p_empl.empl_descr);
        dbms_output.put('), ');
        dbms_output.put('department(');
        trace_dep_desr(p_empl.dep_descr);
        dbms_output.put('), ');
        dbms_output.put('job: '||p_empl.job_title);
        dbms_output.put(' , ');
        
        dbms_output.put(' manager: ');
        if ( p_empl.is_manager != 0) then 
           dbms_output.put('yes');
        else   
           dbms_output.put('no');
        end if;   
        dbms_output.put(', ');
        
        dbms_output.put('location(');
        dbms_output.put('country: '|| p_empl.country_name);
        dbms_output.put(' , ');
        dbms_output.put('state: '|| p_empl.state_province);
        dbms_output.put(' , ');
        dbms_output.put('region: '|| p_empl.region_name);
        dbms_output.put(')');
        dbms_output.put_line(';');
   end trace_employee;
   
   procedure walk_empl(p_curs in sys_refcursor)
   is
    v_curs sys_refcursor := p_curs;
    v_row hr_utils.employee_composite_entry_t;
   begin
    loop                               
         fetch v_curs into v_row;
         exit when v_curs%notfound;                               
         trace_employee(v_row);
      end loop;
         
    close v_curs;
   end walk_empl;
  
begin
    dbms_output.enable(NULL);
    
    open v_curs for 
            select * from 
                    TABLE(hr_utils.composite_employees(
                                   CURSOR(select * from employees_consolidated_view 
                                                    where department_name = 'Executive')))a;
     walk_empl(v_curs);                              
     
     
    open v_curs for 
            select * from 
                    TABLE(hr_utils.composite_employees(
                                   CURSOR(select * from employees_consolidated_view 
                                                        where state_province = 'California' 
                                                        order by department_id)))a;
     walk_empl(v_curs);                              
     
     open v_curs for 
            select * from 
                    TABLE(hr_utils.composite_employees(
                                   CURSOR(select * from employees_consolidated_view 
                                                        where job_id = 'IT_PROG' 
                                                        order by department_id)))a;
     walk_empl(v_curs);                              
     
    open v_curs for 
            select * from 
                    TABLE(hr_utils.composite_employees(
                                   CURSOR(select * from employees_consolidated_view)))a;
     walk_empl(v_curs);                              
    
end;
/
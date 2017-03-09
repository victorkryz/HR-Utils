declare
  c_stat hr_utils.department_stat_cursor_t;
  v_stat c_stat%rowtype;
begin
     dbms_output.put_line('--- report statistic by departments (dep. id, dep. name, empl number, total, min, avg, max salary values):'); 
     
     c_stat := hr_utils.get_department_stat;
     loop
        fetch c_stat into v_stat;
        exit when c_stat%notfound;
        dbms_output.put_line(v_stat.department.dep_id || ', ' || v_stat.department.dep_name || ', '  || v_stat.empl_number || ', '  || v_stat.sal_total || ', ' || v_stat.sal_min_val || ', ' || v_stat.sal_avg_val || ', ' ||  v_stat.sal_max_val);
      end loop;
          
      close c_stat;
end;
/

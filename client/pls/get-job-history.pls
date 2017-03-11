declare
  c_empl hr_utils.empl_breaf_cursor_t;
  v_empl c_empl%rowtype;

    procedure report_job_history(p_empl_id  employees.employee_id%type)
    is
      v_table hr_utils.job_history_t;
      v_tab_entry hr_utils.job_history_entry_t;
     begin
        hr_utils.get_job_history(p_empl_id, v_table);

        for v_i in v_table.first .. v_table.last loop
            v_tab_entry := v_table(v_i);
           dbms_output.put_line(v_tab_entry.job_id || ', ' || v_tab_entry.job_title || ', ' || v_tab_entry.start_date);
        end loop;

     end report_job_history;

 begin

    c_empl := hr_utils.get_employees_with_job_history();

     loop
        fetch c_empl into v_empl;
        exit when c_empl%notfound;

         dbms_output.put_line('--- Job history of ' || v_empl.first_name  || ' ' || v_empl.last_name || ' (id:' || v_empl.empl_id || '):');
         report_job_history(v_empl.empl_id);
         dbms_output.put_line(chr(13) || chr(10));
      end loop;

      close c_empl;
end;
/

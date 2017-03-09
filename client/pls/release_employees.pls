declare
 v_ids number_list_t;
 v_removed_count pls_integer;

begin
  dbms_output.put_line('--- remove employees added by "add_employees.sql" script:');  
  execute immediate 'alter session set isolation_level = READ COMMITTED';

  hr_utils.get_employees_by_full_name(string_list_t('Forrest Gump', 'Darth Vader', 'James Bond', 
                                                     'Indiana Jones', 'Rocky Balboa'), v_ids);
  v_removed_count := hr_utils.remove_employees(v_ids);   
  
  commit;

  dbms_output.put_line('--- ' || v_removed_count || ' employee(s) have been removed.');  
end;
/

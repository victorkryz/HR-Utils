declare

  v_locs hr_utils.locations_t;
  v_table hr_utils.departments_t;
  v_tab_entry hr_utils.departments_entry_t;
  v_loc_id locations.location_id%type;
  v_i pls_integer;
begin
    dbms_output.put_line('--- report deparments by location (state "Washington") (id, name):'); 
    
    hr_utils.get_locations(string_list_t('Washington'), v_locs);
    if ( v_locs.count = 1 ) then
        v_loc_id := v_locs(1).id;
        hr_utils.get_departments(v_loc_id, v_table);
        
        v_i := v_table.first;
        while v_i is not null loop
          v_tab_entry := v_table(v_i);
          dbms_output.put_line(v_tab_entry.department.dep_id || ', '  || v_tab_entry.department.dep_name);
          v_i := v_table.next(v_i );
        end loop;
    end if;

  exception when hr_utils.unknown_location then
          dbms_output.put_line('unknown location id - ' || v_loc_id);
          raise;

end;
/
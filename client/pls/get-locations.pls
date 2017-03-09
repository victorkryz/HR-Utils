declare
  -- get locations
  v_table hr_utils.locations_t;
  v_tab_entry hr_utils.locations_entry_t;
  v_country_id countries.country_id%type := 'UK';
  v_i pls_integer;
begin
    hr_utils.get_locations(v_country_id, v_table);

    for v_i in v_table.first .. v_table.last loop
      v_tab_entry := v_table(v_i);
      dbms_output.put_line(v_tab_entry.id || ', ' || v_tab_entry.street_address);
    end loop;

   exception when hr_utils.unknown_country then
          dbms_output.put_line('unknown country id: ' || v_country_id);

end;
/
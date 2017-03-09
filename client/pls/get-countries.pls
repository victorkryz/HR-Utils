declare
  v_regions hr_utils.regions_t;  
  v_table hr_utils.countries_t;
  v_tab_entry hr_utils.countries_entry_t;
  v_reg_id regions.region_id%type := 1;
begin
    dbms_output.put_line('--- report countries of region "Europe"" (id, name):'); 
    
    hr_utils.get_regions(v_regions, string_list_t('Europe'));
    if ( v_regions.count = 1 ) then
        hr_utils.get_countries(v_regions(1).region_id, v_table);
    
        for v_i in v_table.first .. v_table.last loop
          v_tab_entry := v_table(v_i);
           dbms_output.put_line(v_tab_entry.id || ', ' || v_tab_entry.name);
       end loop;
    end if;   

   exception when hr_utils.unknown_region then
          dbms_output.put_line('unknown region id: ' || v_reg_id);
end;
/
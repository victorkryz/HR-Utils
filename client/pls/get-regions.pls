declare
   -- get regions
  v_table hr_utils.regions_t;
  v_reg   hr_utils.regions_entry_t;
  v_i pls_integer;
begin
    hr_utils.get_regions(v_table);

    v_i := v_table.first;
    while v_i is not null loop

      v_reg := v_table(v_i);

      dbms_output.put_line(v_reg.region_id || ', ' || v_reg.region_name);

      v_i := v_table.next(v_i );

    end loop;
end;
/
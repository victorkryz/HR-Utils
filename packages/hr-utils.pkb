create or replace package body hr_utils is

  procedure check_region(p_reg_id in regions.region_id%type);
  procedure check_department(p_dep_id in departments.department_id%type);
  procedure check_country(p_country_id in countries.country_id%type);
  procedure check_location(p_loc_id in locations.location_id%type);
  procedure check_after_empl_updating(p_employee_id in employees.employee_id%type);

  E_UNKNOWN_EMPLOYEE_msg constant varchar2(200) := 'Unknown employee (id: %1)';

  procedure get_regions(p_regions out nocopy regions_t, p_names_filter in string_list_t)
  is
    type c_regions is ref cursor return regions%rowtype;
    v_curs c_regions;
  begin
       p_regions := regions_t();

       if ( p_names_filter is not null ) then
         open v_curs for
           select region_id, region_name from regions
                      where region_name in
                            (select value(a) from table(p_names_filter)a)
                      order by region_name;
       else
         open v_curs for
              select region_id, region_name from regions order by region_name;
       end if;

       fetch v_curs bulk collect into p_regions;
       close v_curs;

  end get_regions;


  procedure get_countries(p_region_id in regions.region_id%type, p_countries out countries_t)
  is
      type c_countries is ref cursor return countries_entry_t;
      v_curs c_countries;
   begin
       check_region(p_region_id);

       p_countries := countries_t();
       open v_curs for
          select country_id, country_name from countries
                  where region_id = p_region_id
                      order by country_name;
       fetch v_curs bulk collect into p_countries;
       close v_curs;

  end get_countries;


  procedure get_locations(p_country_id in countries.country_id%type, p_locations out locations_t)
  is
      cursor c_locations(cp_country_id  countries.country_id%type) return locations_entry_t is
              select location_id, country_id, street_address, postal_code, city, state_province
                      from locations where country_id = cp_country_id order by location_id;
   begin
       check_country(p_country_id);

       p_locations := locations_t();
       open c_locations(p_country_id);
       fetch c_locations bulk collect into p_locations;
       close c_locations;

  end get_locations;

  procedure get_locations(p_names_filter in string_list_t, p_locations out locations_t)
  is
      type c_locations is ref cursor return locations_entry_t;
      v_curs c_locations;

  begin
     if ( p_names_filter is not null ) then
         open v_curs for
            select location_id, country_id, street_address, postal_code,
                    city, state_province  from locations
                    where state_province in
                          (select value(a) from table(p_names_filter)a)
                     order by country_id;
       else
         open v_curs for
              select location_id, country_id, street_address, postal_code,
                     city, state_province from locations order by country_id;
       end if;

       p_locations := locations_t();
       fetch v_curs bulk collect into p_locations;
       close v_curs;

  end get_locations;

  procedure get_departments(p_location_id in locations.location_id%type, p_departments out departments_t)
  is
      cursor c_departments(cp_location_id locations.location_id%type) return departments_entry_t is
              select department_descr_t(department_id, department_name), manager_id
                      from departments where location_id = cp_location_id order by department_name;
   begin
       check_location(p_location_id);

       p_departments := departments_t();
       open c_departments(p_location_id);
       fetch c_departments bulk collect into p_departments;
       close c_departments;

  end get_departments;

  procedure get_departments(p_names_filter in string_list_t, p_departments out departments_map_t)
  is
    v_curs sys_refcursor;
    v_dep departments_entry_t;
  begin
      open v_curs for
          select department_descr_t(department_id, department_name), manager_id from departments
                            where department_name in
                                  (select value(a) from table(p_names_filter)a);
           loop
             fetch v_curs into v_dep.department, v_dep.manager_id;
             exit when v_curs%notfound;
             p_departments(v_dep.department.dep_name) := v_dep;
           end loop;
        close v_curs;
  end get_departments;


  procedure get_job_history(p_employee_id in employees.employee_id%type, p_history out job_history_t)
  is
      type c_hist is ref cursor;
      v_cur c_hist;
  begin

    p_history := job_history_t();

    open v_cur for
        select job_id, job_title, start_date, end_date,
               department_descr_t(d.department_id, d.department_name) from job_history jh
                                                            inner join jobs using (job_id)
                                                            inner join departments d on (d.department_id = jh.department_id)
                                                                  where EMPLOYEE_ID = p_employee_id
                                                                  order by start_date desc;
        fetch v_cur bulk collect into p_history;
        close v_cur;

  end get_job_history;


  function get_employees(p_dep_id in departments.department_id%type)
                                          return empl_cursor_t
  as
     c_empl empl_cursor_t;
  begin
      check_department(p_dep_id);

      open c_empl for
        select * from employees where department_id = p_dep_id
                                      order by last_name, first_name;
     return c_empl;

  end get_employees;

  function get_employees_with_job_history(p_dep_id in departments.department_id%type)
                                                                return empl_breaf_cursor_t
  as
     c_empl empl_breaf_cursor_t;
  begin

    case
      when p_dep_id is not null
          then
              check_department(p_dep_id);
              open c_empl for
                    select js.employee_id, e.first_name, e.last_name, js.department_id from
                          (select count(job_id), employee_id, department_id from job_history
                                                                            where department_id = p_dep_id
                                                                            group by employee_id, department_id) js
                                                                            inner join employees e on (js.employee_id = e.employee_id);
          else
              open c_empl for
                  select js.employee_id, e.first_name, e.last_name, js.department_id from
                        (select count(job_id), employee_id, department_id from job_history
                                                                           group by employee_id, department_id) js
                                                                           inner join employees e on (js.employee_id = e.employee_id);
     end case;

     return c_empl;

  end get_employees_with_job_history;

  procedure get_employees_by_full_name(p_names in string_list_t, p_ids out number_list_t)
  is
  begin
    select cast (multiset
      (select id from
          (select employee_id as id, first_name ||' ' || last_name as full_name from employees) a
                  where a.full_name in
                          (select value(a) from table(p_names)a))
                                         as number_list_t) into p_ids from dual;
  end get_employees_by_full_name;


  procedure get_employees(p_ids in number_list_t, p_employees out employee_set_t, b_for_update in boolean)
  is
    v_stmt varchar2(500) :=
        'select cast (multiset
          (select employee_descr_t(employee_id, first_name, last_name, email, phone_number, department_id,
                  hire_date, job_id, commission_pct, salary, manager_id)   from
              (select * from employees) a
                        where a.employee_id in
                              (select value(a) from table(:1)a))
                                             as employee_set_t) from dual';
  begin
    if ( b_for_update ) then
      v_stmt := v_stmt || ' for update';
    end if;

    execute immediate v_stmt into p_employees using p_ids;

  end get_employees;

  function  get_department_stat(p_dep_id in departments.department_id%type)
                                                 return department_stat_cursor_t
  as
     c_stat department_stat_cursor_t;
  begin
    if ( p_dep_id is null ) then
      open c_stat for
        select department_descr_t(department_id, a.department_name), count(employee_id),
              sum(salary), max(salary), min(salary), avg(salary)
                    from employees inner join departments a using (department_id)
                    group by department_id, a.department_name;
     else
       open c_stat for
         select department_descr_t(department_id, a.department_name),  count(employee_id),
                sum(salary), max(salary), min(salary), avg(salary)
                    from employees inner join departments a using (department_id)
                    group by department_id, a.department_name
                    having department_id = p_dep_id;

     end if;

     return c_stat;

  end get_department_stat;

  function composite_employees(p_src_sel in employee_consolidated_cursor_t)
                                            return employee_composite_set_t pipelined
  is
    v_srow  employees_consolidated_t;
    v_drow employee_composite_entry_t;
  begin

  loop
      fetch p_src_sel into v_srow;
      exit when p_src_sel%notfound;

      v_drow.empl_descr :=
          employee_descr_t(v_srow.employee_id, v_srow.first_name, v_srow.last_name, v_srow.email, v_srow.phone,
                           v_srow.department_id, v_srow.hire_date, v_srow.job_id, v_srow.commission, v_srow.salary, v_srow.manager_id);
      v_drow.dep_descr := department_descr_t(v_srow.department_id, v_srow.department_name);
      v_drow.empl_decorated_name := v_srow.rank_decorator || ' '|| v_srow.full_name;
      v_drow.job_title := v_srow.job_title;
      v_drow.is_manager := v_srow.is_manager;
      v_drow.country_name := v_srow.country;
      v_drow.state_province := v_srow.state_province;
      v_drow.region_id := v_srow.region_id;
      v_drow.region_name := v_srow.region_name;

      pipe row(v_drow);

    end loop;

    close p_src_sel;

  end composite_employees;


  procedure add_employees(p_employees in out nocopy employee_set_t)
  is
    v_tmp number_list_t;
  begin

  forall i in p_employees.first..p_employees.last
      insert into employees (employee_id, first_name, last_name, email, phone_number,
                             hire_date, job_id, salary, commission_pct, manager_id, department_id)
                            values(employees_seq.nextval, p_employees(i).first_name, p_employees(i).last_name,
                                   p_employees(i).email, p_employees(i).phone,
                                   nvl(p_employees(i).hire_date, (select current_date from dual)),
                                   p_employees(i).job_id, p_employees(i).salary,  p_employees(i).commission,
                                   p_employees(i).mngr_id, p_employees(i).dep_id)
      returning employee_id bulk collect into v_tmp;

    for i in v_tmp.first..v_tmp.last loop
      p_employees(i).empl_id := v_tmp(i);
    end loop;

  end add_employees;


  procedure update_employee_job(p_employee_id in employees.employee_id%type, p_job_id in employees.job_id%type,
                                 p_department_id in employees.department_id%type, p_manager_id in employees.manager_id%type)
  is
    v_msg varchar2(100);
  begin
    update employees set job_id = p_job_id, department_id = p_department_id, manager_id = p_manager_id
                                                                        where employee_id = p_employee_id;
    check_after_empl_updating(p_employee_id);
  end update_employee_job;

  procedure update_employee_reward(p_employee_id in employees.employee_id%type, p_salary in employees.salary%type, p_commission in commission_t)
  is
  begin
    update employees set salary = p_salary, commission_pct = p_commission
                                                    where employee_id = p_employee_id;
    check_after_empl_updating(p_employee_id);
  end update_employee_reward;

  function remove_employees(p_employees in number_list_t)
                                          return number
  is
   v_removed_count number := 0;
  begin
    if ( p_employees.count = 0) then
        return 0;
    end if;

    forall  i in p_employees.first..p_employees.last
        delete from departments where manager_id = p_employees(i);
    forall  i in p_employees.first..p_employees.last
        delete from job_history where employee_id = p_employees(i);
    forall  i in p_employees.first..p_employees.last
      delete from employees where employee_id = p_employees(i);

    v_removed_count := sql%rowcount; -- rowcount of the latest DML

    return v_removed_count;

  end remove_employees;


  procedure check_region(p_reg_id in regions.region_id%type)
  is
      v_tag number(1) default null;
  begin
       select 1 into v_tag from regions where region_id = p_reg_id;
       exception when no_data_found then raise unknown_region;
  end check_region;


  procedure check_country(p_country_id in countries.country_id%type)
  is
      v_tag number(1) default null;
  begin
       select 1 into v_tag from countries where country_id = p_country_id;
       exception when no_data_found then raise unknown_country;
  end check_country;


  procedure check_location(p_loc_id in locations.location_id%type)
  is
      v_tag number(1) default null;
  begin
       select 1 into v_tag from locations where location_id = p_loc_id;
       exception when no_data_found then raise unknown_location;
  end check_location;

  procedure check_department(p_dep_id in departments.department_id%type)
  is
      v_tag number(1) default null;
  begin
       select 1 into v_tag from departments where department_id = p_dep_id;
       exception when no_data_found then raise unknown_department;
  end check_department;


procedure check_after_empl_updating(p_employee_id in employees.employee_id%type)
  is
  begin
    if (  Sql%Rowcount = 0 ) then
      raise_application_error(E_UNKNOWN_EMPLOYEE,
                              replace(E_UNKNOWN_EMPLOYEE_msg, '%1', to_char(p_employee_id)), false);
    end if;
end check_after_empl_updating;

begin
    null;
end hr_utils;
/
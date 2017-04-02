set serveroutput on
set feedback off 
whenever oserror exit failure;
whenever sqlerror exit SQL.SQLCODE;

prompt "HR-Utils" installing ...

prompt  ... - checking server version ...

declare
  -- check server version :
 SUITABLE_MIN_VERSION constant int := 11;
 SUITABLE_MIN_RELEASE constant int := 2;
 E_UNSUITABLE_SERVER_VERSION constant int := -20100;
 
     function to_ver_str(p_ver in pls_integer, p_release in pls_integer) 
                                                       return varchar2 as
      v_str varchar2(20) := p_ver || '.' || p_release;                                       
     begin
      return v_str;
     end to_ver_str;
begin
    if ( (DBMS_DB_VERSION.VERSION < SUITABLE_MIN_VERSION) or 
         ((DBMS_DB_VERSION.VERSION = SUITABLE_MIN_VERSION) and (DBMS_DB_VERSION.RELEASE < SUITABLE_MIN_RELEASE)) ) then
       raise_application_error(E_UNSUITABLE_SERVER_VERSION, 
                               'Oracle server version (' || to_ver_str(DBMS_DB_VERSION.VERSION, DBMS_DB_VERSION.VERSION) || 
                               ') lower than minimal suitable (' || to_ver_str(SUITABLE_MIN_VERSION, SUITABLE_MIN_RELEASE) || ')');
    end if;
end;
/

prompt  ... - synonyms ...

create or replace synonym string_list_t for sys.ODCIVarchar2List;
/

prompt   ... - types ...

create or replace synonym number_list_t for sys.odcinumberlist;
/

create or replace type employee_short_descr_t as object
(
  empl_id    number(6, 0),
  first_name varchar2(20),
  last_name  varchar2(25),
  email      varchar2(25),
  phone      varchar2(20),
  dep_id     number(4, 0)
) not final;
/


create or replace type employee_descr_t under employee_short_descr_t
(
  hire_date  date,
  job_id     varchar2(10),
  commission number(2, 2),
  salary     number(8, 2),
  mngr_id    number(6, 0)
);
/

create or replace type employee_set_t as table of employee_descr_t;
/

create or replace type department_descr_t as object
(
    dep_id      number(4,0) ,
    dep_name    varchar2(30)
);
/

prompt   ... - views...

create or replace view employees_consolidated_view as
  with sq as (select * from
       (select level l, employee_id,  first_name ||' ' || last_name as full_name,
               first_name, last_name, phone_number, email, salary, commission_pct, 
               job_id, hire_date, department_id
               from employees e
                  start with e.manager_id is null
                  connect by prior e.employee_id = e.manager_id) xa
                  left join (select distinct manager_id from employees) m on (xa.employee_id = m.manager_id))
        select ea.employee_id as employee_id, first_name, last_name, ea.job_id as job_id, j.job_title as job_title, ea.phone_number as phone, 
               ea.email as email, hire_date, ea.salary as salary , nvl(ea.commission_pct, 0) as commission,
               ea.manager_id as manager_id, nvl2(ea.manager_id, 1, 0) as is_manager, d.department_id as department_id, department_name,
               l.state_province as state_province, l.city as city, c.country_name as country, r.region_id as region_id,
               r.region_name as region_name, l as rank, full_name, lpad(' ',2+(l-1)) || '-' as rank_decorator
               from sq ea
                    left join departments d on (ea.department_id = d.department_id)
                    left join locations l on (d.location_id = l.location_id)
                    left join countries c on (l.country_id = c.country_id)
                    left join regions r on (c.region_id = r.region_id)
                    left join jobs j on (ea.job_id = j.job_id);
/                    


prompt  ... - packages ...

-- create packages:
@./packages/hr-utils.pks
@./packages/hr-utils.pkb


prompt "HR-Utils" installation completed!

disconnect

exit
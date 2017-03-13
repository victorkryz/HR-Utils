create or replace package hr_utils as

    -- defintion of user types:
    subtype commission_t is pls_integer range 0..1;

    -- defintion of structured types:
    subtype regions_entry_t is regions%rowtype;

    type countries_entry_t is record
      (id countries.country_id%type,
       name countries.country_name%type);

    subtype employees_consolidated_t is employees_consolidated_view%rowtype;

    type department_stat_t is record
        (department department_descr_t,
         empl_number number(4),
         sal_total employees.salary%type,
         sal_max_val employees.salary%type,
         sal_min_val employees.salary%type,
         sal_avg_val employees.salary%type);

    type locations_entry_t is record
        (id locations.location_id%type,
         country_id  locations.country_id%type,
         street_address locations.street_address%type,
         postal_code locations.postal_code%type,
         city locations.city%type,
         state_province locations.state_province%type);

    type departments_entry_t is record
        (department department_descr_t,
         manager_id departments.manager_id%type);

    type job_history_entry_t is record
        (job_id jobs.job_id%type,
         job_title jobs.job_title%type,
         start_date job_history.start_date%type,
         end_date job_history.end_date%type,
         department department_descr_t);

    type employee_brief_entry_t is record
    (
        empl_id employees.employee_id%type,
        first_name employees.first_name%type,
        last_name employees.last_name%type,
        dep_id departments.department_id%type
    );

    type employee_composite_entry_t is record
    (
        empl_decorated_name varchar2(150),
        empl_descr employee_descr_t,
        dep_descr department_descr_t,
        job_title jobs.job_title%type,
        is_manager number(1),
        country_name countries.country_name%type,
        state_province locations.state_province%type,
        region_id regions.region_id%type,
        region_name regions.region_name%type
    );

    -- defintion of collection types:
    type employee_composite_set_t is table of employee_composite_entry_t;
    type regions_t is table of regions_entry_t;
    type countries_t is table of countries_entry_t;
    type locations_t is table of locations_entry_t;
    type departments_t is table of departments_entry_t;
    type job_history_t is table of job_history_entry_t;
    type departments_map_t is table of departments_entry_t index by departments.department_name%type;

    -- defintion of cursor types:
    type empl_cursor_t is ref cursor return employees%rowtype;
    type dep_cursor_t is ref cursor return departments%rowtype;
    type empl_breaf_cursor_t is ref cursor return employee_brief_entry_t;
    type employee_consolidated_cursor_t is ref cursor return employees_consolidated_t;
    type department_stat_cursor_t is ref cursor return department_stat_t;

     -- defintion of exception types:
    unknown_region exception;
    unknown_location exception;
    unknown_country exception;
    unknown_department exception;

    -- defintion of app. error codes:
    E_UNKNOWN_EMPLOYEE constant int := -20300;

   /**
    *   selects regions. 
    *
    *      p_regions - (output) collection to put list of regions_entry_t elements;
    *      p_names_filter - (optional) list of region names 
    */
    procedure get_regions(p_regions out regions_t, p_names_filter in string_list_t := null);

   /**
    *   selects countries by region id.
    *
    *       p_region_id - region id; 
    *       p_countries - (output) collection to put list of  countries_entry_t elements
    */
    procedure get_countries(p_region_id in regions.region_id%type, p_countries out countries_t);

   /**
    *   selects locations by country id.
    *
    *      p_country_id - country id; 
    *      p_locations - (output) collection to put list of locations_entry_t elements
    */
    procedure get_locations(p_country_id in countries.country_id%type, p_locations out locations_t);

   /**
    *   selects locations by names.
    *
    *       p_names_filter - list of location names;
    *       p_locations - (output) collection to put list of locations_entry_t elements;
    */
    procedure get_locations(p_names_filter in string_list_t, p_locations out locations_t);

   /**
    *   selects departments by location id.
    *
    *       p_location_id - location id; 
    *       p_departments - (output) collection to put list of departments_entry_t elements;
    */
    procedure get_departments(p_location_id in locations.location_id%type, p_departments out departments_t);

   /**
    *   selects departments by names.
    *
    *       p_names_filter - list of separtment names;
    *       p_departments - (output) collection to put list of departments_entry_t elements;
    */
    procedure get_departments(p_names_filter in string_list_t, p_departments out departments_map_t);

   /**
    *   selects department's statistics.
    *
    *       p_dep_id - (optional) department id;
    *       returns  -  open cursor with department_stat_t elements,
    *                   (client should close cursor after data fetching);
    */
    function  get_department_stat(p_dep_id in departments.department_id%type default null) return department_stat_cursor_t;

    /**
    *   selects employees by department:
    *
    *       p_dep_id - department id;
    *       returns -  open cursor with empl_cursor_t elements
    *                   (client should close cursor after data fetching);
    */
    function  get_employees(p_dep_id in departments.department_id%type) return empl_cursor_t;

    /**
    *   selects employees by their id(s):
    *
    *       p_ids - list of employee id(s);
    *       p_employees - (output) collection to put list of employee_descr_t elements;
    *       b_for_update - (optional) indicates to lock selected elements for subsequent modification
    *                                 (elements will be locked up to the end of current transaction) 
    */
    procedure get_employees(p_ids in number_list_t, p_employees out employee_set_t, b_for_update in boolean := false);

    /**
    *   selects only employees with provided their job history:
    *
    *       p_dep_id - (optional) department id;
    *       returns -  open cursor with empl_breaf_cursor_t elements
    *                   (client should close cursor after data fetching);
    */
    function  get_employees_with_job_history(p_dep_id in departments.department_id%type := null) return  empl_breaf_cursor_t;

    /**
    *   selects employee id(s) by provided employee's full names
    *   ("full name" is a string built by template: "first name" + "space" + "last name"):
    *
    *       p_names_filter - list employee's full names;
    *       p_ids - (output) list of selected employee id(s);
    */
    procedure get_employees_by_full_name(p_names in string_list_t, p_ids out number_list_t);

    /**
    *   get job history of specified employee:
    *
    *       p_employee_id - employee id;
    *       p_history - (output) param to put job_history_t
    */
    procedure get_job_history(p_employee_id in employees.employee_id%type, p_history out job_history_t);

    /**
    *   Table-function that composites input records of cursor 
    *   with type employee_consolidated_cursor_t into cursor 
    *   of type employee_composite_set_t
    *
    *       p_src_sel - cursor of type employee_consolidated_cursor_t
    *       returns - cursor with type employee_composite_set_t
    *                   (client should close cursor after data fetching);
    */
    function  composite_employees(p_src_sel in employee_consolidated_cursor_t) return employee_composite_set_t pipelined;

    /**
    *   Adds new employees 
    *
    *       p_employees - (input, output) set of the employee_descr_t structures;
    *       returns - id(s) of each employee into field "empl_id" of each 
    *                  provided employee descriptor;  
    */
    procedure add_employees(p_employees in out nocopy employee_set_t);

    /**
    *   Removes specified employees 
    *
    *       p_employees - (input) list of the employee id(s) to remove;
    *       returns - number of removed employees;
    */
    function  remove_employees(p_employees in number_list_t) return number;

    /**
    *   Updates job, manager and department of the specified employee 
    *
    *       p_employee_id - target employee id;
    *       p_job_id - job id;
    *       p_department_id - department id;
    *       p_manager_id - manager id;
    */
    procedure update_employee_job(p_employee_id in employees.employee_id%type, p_job_id in employees.job_id%type, p_department_id in employees.department_id%type, p_manager_id in employees.manager_id%type);

    /**
    *   Updates salary and commission of the specified employee 
    *
    *       p_employee_id - target employee id;
    *       p_salary - salary value;
    *       p_commission - commission value;
    */
    procedure update_employee_reward(p_employee_id in employees.employee_id%type, p_salary in employees.salary%type, p_commission in commission_t);

end hr_utils;
/
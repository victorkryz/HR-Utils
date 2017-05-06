# HR-Utils
HR-Utils is a Pl/SQL package enables operating on HR schema entities
using packages API (Pl/SQL procedures, user types, oracle object types, collections) 
as an alternative of a direct querying/modifying HR's tables.

## Project directory structure
The repository consists of:
- *"packages"* directory:
     + "HR-Utils" Pl/SQl package  
- *"client"* directory:
     + "pls":  PL/SQL scripts as samples/tests of using HR-Utils API;
     + "py": starters of these scripts;
 - *"install"* directory:     
     - SQL scripts for installing/uninstalling HR-Utils on Oracle server;
 - *"py.aux"* directory:        
     -  auxiliary py-scripts for internal using on the installing/uninstalling/testing phases;

HR-Utils API is declared in package specification (*package/hr-utils.pks*).


## Prerequisites
- Oracle Server (version 11.2 or higher) with installed HR schema
- Oracle client (at list sqlplus)
- Python 2 (used as an launcher for sql scripts on the installing/uninstalling/testing phases )

(see bellow detailed version info)

## Configuration
At the core of configuration there's a single file "config.json"
intended to provide the next kind of information:

- Oracle server connection info;
- "sqlplus" utility access way

```json
        {
            "connection": {
                "service": "xe", 
                "user": "hr",
                "password": "hr"
            },
            "sqlplusPath": "sqlplus"
        }
```        

A such approach supposes the oracle service local naming exists in the system configured with *tnsnames.ora*
file (located in folder *$ORACLE_HOME/network/admin*).

Parameters:

    - "service" - oracle service (local name);
    - "user" and "password" - user (schema) name (usually "hr") and password respectively;
    - "sqlplusPath" - defines "sqlplus" utility path
            - full path to the sqlplus (recommended) 
              (e.g. */u01/app/oracle/product/11.2.0/xe/bin/sqlplus*)  
            - in case sqlplus path is included in the environment variable %PATH%, possible to assign utility name (e.g. "sqlplus")


To check configuration is correct use connection check procedure:
  *"python client/py/connection-check.py"*


## Installing/uninstalling

Before installing, be sure configuration file is correct and connection check passes successfully!

- for launch installing procedure, execute install.py script (*"python install.py"* )
- for uninstalling, launch uninstall.py script (*"python install.py*")


## Testing

In the directory "client/pls" there're a set of different Pl/SQL procedures
that use HR-Utils API. 
They can be executed directly by "sqlplus" utility. 
It's possibly to copy/past a content of any of them into some SQL-plus worksheet  
for executing in GUI mode (e.g. - Oracle SQL Developer, JDeveloper)

In the directory "client/py" a set of py-scripts that executes these tests respectively
in convenient command-line manner.

For example:

- *run a single tests by steps:*

        python client/py/get-department-stat.py
        python client/py/get-employees.py
        python client/py/get-job-history.py
        ...

 - *run all tests:*       

        python client/py/run-all-tests.py

**Pay attention:** *the working (current) python's directory has to be always a root of the repo!*


#### Project tested on the follow configurations:

 1. Windows 7 (64-bit):
    - Oracle Database 11g Express Edition Release 11.2.0.2.0 
    - sqlplus Release 11.2.0.2
    - Python 2.7.10
 2. Oracle Linux Server 7.2 (64-bit):
    - Oracle Database 12c Enterprise Edition Release 12.1.0.2.0    
    - sqlplus Release 12.1.0.2
    - Python 2.7.5
3.  Red Hat 7.2 (64-bit):
    -  Oracle Database 11g Express Edition Release 11.2.0.2.0
    -  sqlplus Release 11.2.0.2
    - Python 2.7.5
 4. Windows client (see item 1) and remote Oracle server (see item 2)       



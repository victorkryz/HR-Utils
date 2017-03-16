# HR-Utils
HR-Utils is a Pl/SQL package(s) enables operating on HR schema's entities
using its API (Pl/SQL user types, oracle object types, collections) insted of 
direct access to HR's tables.

# Common
The package consists of:
- *"package"* directory:
     + HR-Utils Pl/SQl package  
- *"client"* directory:
     + "pls":  PL/SQL scripts as a samples (tests) of using HR-Utils API;
     + "py": starters of these scripts;
 - *"install"* directory:     
     - SQL scripts for installing/uninstalling HR-Utils on Oracle server
 - *"py.aux"* directory:        
     -  auxiliary py-scripts for internal using

HR-Utils API is specified in package specification (*package/hr-utils.pks*).


# Prerequisits
- Oracle Server with installed HR schema (*)
- Oracle client (at list sqlplus)
- Python 2 

# Configuration
At the core of configuration there's a single file "config.json"
intended to provide the next kind of iformation:

- Oracle server connection info;
- "sqlplus" utility access way


        {
            "connection": {
                "service": "xe", 
                "user": "hr",
                "password": "hr"
            },
            "sqlplusPath": "sqlplus"
        }

A such approach supposes the oracle service local naming exists in the system configured with *tnsnames.ora*
file (located in folder *$ORACLE_HOME/network/admin*).

Prameters:

    - "service" - oracle service (local name);
    - "user" and "password" - user (schema) name (usually "hr") and password respectively;
    - "sqlplusPath" - defines "sqlplus" utility path
            - full path to the sqlplus (recommended)
            - in case sqlplus path is registered in the environment variable %PATH%, possible to assign just utility name (e.g. "sqlplus")
            - "empty value" (launcher tries try to deduct path to utility basing on "ORACLE_HOME" env. variable)


To check configuration is correct use connection check procedure:
  *"python client/py/connection-check.py"*


# Installing/uninstalling

Before installing, be sure congigureation file is correct and connection check passes successfuly!

- for launch installing procedure, execute instal.py script (*"python install.py"* )
- for uninstalling, launch uninstall.py script (*"python install.py*")


# Testing

In the directory "client/pls" there're a set of different Pl/SQL procedures
that use HR-Utils API. 
They can be executed directly by "sqlplus" utility. 
It's possibly to copy/past a content of any of them into some SQL-plus workbanch  
for executing in GUI mode (e.g. - Oracle SQL Developer, JDeveloper)

In the directory "client/py" a set of py-scripts thet executes these tests respectively
in conivinient command-line manner.

For example:

- *run an each single tests by steps:*

        python client/py/get-department-stat.py
        python client/py/get-employees.py
        python client/py/get-job-history.py
        ...

 - *run all tests:*       

        python client/py/run-all-tests.py

Pay attention: the working (current) directory python has to be a root of the package.

It was tested on the follow configurations:
 -  Windows 7 (64-bit):
    -  Oracle Database 11g Express Edition Release 11.2.0.2.0 
    -  Python 2.7.10




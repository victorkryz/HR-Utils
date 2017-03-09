
set serveroutput on
set feedback off 
whenever oserror exit failure;
whenever sqlerror exit SQL.SQLCODE;

@@&1


 

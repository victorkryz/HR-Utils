

SET SERVEROUTPUT ON
SET FEEDBACK OFF 
SET LINESIZE 240
SET AUTOCOMMIT OFF
whenever oserror exit failure;
whenever sqlerror exit SQL.SQLCODE;

@@&1


 

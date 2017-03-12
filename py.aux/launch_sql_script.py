import sys
import os
from run_sqlplus import execSqlPlus

def launchScriptOnTemplate(connStr, sqlFile):
   paramStr = "@./py.aux/sqlp-template.sql" + " " + "client/pls/" + sqlFile
   return launchScript(connStr, paramStr)

def launchScript(connStr, sqlFile):
    return execSqlPlus(connStr, sqlFile)


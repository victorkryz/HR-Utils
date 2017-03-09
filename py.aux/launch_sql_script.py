import sys
import os
from run_sqlplus import execSqlPlus

def launchScriptOnTemplate(connStr, sqlFile):
   paramStr = "@./py.aux/sqlp-template.sql" + " " + "client/pls/" + sqlFile
   launchScript(connStr, paramStr)

def launchScript(connStr, sqlFile):
    execSqlPlus(connStr, sqlFile)

if __name__ == "__main__":
    launchScript(sys.argv[1])


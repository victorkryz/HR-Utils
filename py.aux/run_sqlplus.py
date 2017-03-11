import os
from subprocess import Popen, PIPE
from config import getSqlPlusPath

def execSqlPlus(connStr, sqlCommand):
    sqlplusPath = getSqlPlusPath('config.json')
    
    if not sqlplusPath:
       sqlplusPath = os.environ.get('ORACLE_HOME') + '/bin/sqlplus'

    session = Popen([sqlplusPath, connStr], stdin=PIPE)
    session.stdin.write(sqlCommand)
    session.communicate()

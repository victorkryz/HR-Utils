import os
from subprocess import Popen, PIPE
from config import getSqlPlusPath

def execSqlPlus(connStr, sqlCommand):
    sqlplusPath = getSqlPlusPath('config.json')
    
    if not sqlplusPath:
       sqlplusPath = os.environ.get('ORACLE_HOME') + '/bin/sqlplus'

    pipe = Popen([sqlplusPath, connStr], stdin=PIPE, stdout=None, stderr=None)
    pipe.stdin.write(sqlCommand)
    out, err = pipe.communicate()
    return pipe.returncode

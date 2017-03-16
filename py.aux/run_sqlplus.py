import sys
import os
import subprocess
from subprocess import Popen, PIPE
from config import getSqlPlusPath

def execSqlPlus(connStr, sqlCommand):
    sqlplusPath = getSqlPlusPath('config.json')
    
    if not sqlplusPath:
       oraHome = os.environ.get('ORACLE_HOME'); 
       if ( oraHome):
          sqlplusPath = os.path.join(oraHome, 'bin', 'sqlplus')

    retcode = 55
    if ( not sqlplusPath):
        print 'Cannot deduct "sqlplus" utility calling method\n' \
              '("sqlplusPath" parameter is empty in "config.json" and \n' \
              '"ORACLE_HOME" environment variable is not defined!\n' \
              'Hint: to avoid this, fill "sqlplusPath" parameter with full path to "sqlplus" utility)' 
        return retcode;

    try:
        pipe = Popen([sqlplusPath, connStr], stdin=PIPE, stdout=None, stderr=None)
        pipe.stdin.write(sqlCommand)
        out, err = pipe.communicate()
        retcode = pipe.returncode;
    except:
        print 'Exception ocurred!\n(check "config.json" file ("sqlplusPath" parameter is defined as "' + sqlplusPath + '")\n'        
        raise   

    return retcode

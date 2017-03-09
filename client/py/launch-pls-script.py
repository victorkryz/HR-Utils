import sys
sys.path.append('../../')
sys.path.append('./py.aux')

from config import getConnectionString
from launch_sql_script import launchScriptOnTemplate

if __name__ == "__main__":
    connStr = getConnectionString('config.json')
    print sys.argv[1] 
    launchScriptOnTemplate(connStr, sys.argv[1])
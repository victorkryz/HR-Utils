import sys
sys.path.append('../../')
sys.path.append('./py.aux')

from config import getConnectionString
from launch_sql_script import launchScriptOnTemplate

if __name__ == "__main__":
   connStr = getConnectionString('config.json')
   exit(launchScriptOnTemplate(connStr, "get-departments.pls"))

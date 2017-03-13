import sys
sys.path.append('../../')
sys.path.append('./py.aux')

from config import getConnectionString
from launch_sql_script import launchScriptOnTemplate

def launchScript(strScript):
   connStr = getConnectionString('config.json')
   return launchScriptOnTemplate(connStr, strScript);

if __name__ == "__main__":
   launchScript("get-countries.pls")

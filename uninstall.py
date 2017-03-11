import sys
sys.path.append('./py.aux')

from config import getConnectionString
from launch_sql_script import launchScript

def main(argv):
    connStr = getConnectionString('config.json')
    launchScript(connStr, "@./install/uninstall.sql")

if __name__ == "__main__":
   main(sys.argv[1:])


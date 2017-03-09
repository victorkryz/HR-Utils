import sys
from py.launch_sql_script import launchScript
from py.config import Config

def main(argv):
    cfg = Config('config.json')
    launchScript(cfg, "@./install/install.sql")

if __name__ == "__main__":
   main(sys.argv[1:])


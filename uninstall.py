import sys
from py.launch_sql_script import launchScript

def main(argv):
    launchScript("@./install/uninstall.sql")

if __name__ == "__main__":
   main(sys.argv[1:])


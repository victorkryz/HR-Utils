from subprocess import Popen, PIPE

def execSqlPlus(connStr, sqlCommand):
    session = Popen(['sqlplus', connStr], stdin=PIPE)
    session.stdin.write(sqlCommand)
    session.communicate()

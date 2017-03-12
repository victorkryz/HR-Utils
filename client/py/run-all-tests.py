import os
import subprocess
import sys
sys.path.append('../../')
sys.path.append('./client/py/')

testCount = 0
passedTestCount = 0

def execSiblingScript(strScript):
    curScripPath = os.path.dirname(os.path.realpath(__file__))
    return subprocess.call(curScripPath + '/' + strScript + ".py", shell=True)


def checkExecResult(strScript):        
    global testCount
    global passedTestCount

    rcode = execSiblingScript(strScript)
    testCount += 1
    if rcode == 0:
        passedTestCount += 1
        print '"' + strScript + '"' + " succeeded!"
    else:
        print '"' + strScript + '"' + " failed :( (error code: " + str(rcode) + ")"
    return rcode
     

if __name__ == "__main__":
    rcode = checkExecResult("connection-check")
    if (rcode != 0):
       print "Connection check failed!" 
       print "(tip: check \"config.json\" for correctness of Oracle server connection parameters)" 
    else:   
        checkExecResult("add-employees")
        checkExecResult("update-employees")
        checkExecResult("get-regions")
        checkExecResult("get-locations")
        checkExecResult("get-countries")
        checkExecResult("get-departments")
        checkExecResult("get-departments.2")
        checkExecResult("get-department-stat")
        checkExecResult("get-employees")
        checkExecResult("get-job-history")
        checkExecResult("get-consolidated-report")
        checkExecResult("release-employees")
        print "statistic:"   
        print str(passedTestCount) + " tests passed of " + str(testCount) + " launched."
        if ( testCount > passedTestCount):
            print str(testCount - passedTestCount)   + " failed :("

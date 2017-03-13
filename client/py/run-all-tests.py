from launch_script import launchScript

testCount = 0
passedTestCount = 0

def execScript(strScript):
    return launchScript(strScript + ".pls")

def execScriptWithDiag(strScript):    
    rcode = execScript(strScript)
    if rcode == 0:
        print '"' + strScript + '"' + " succeeded!"
    else:
        print '"' + strScript + '"' + " failed :( (error code: " + str(rcode) + ")"
    return rcode


def execScriptWithStat(strScript):        
    global testCount
    global passedTestCount

    rcode = execScriptWithDiag(strScript)
    testCount += 1
    if rcode == 0:
        passedTestCount += 1
    return rcode
     

if __name__ == "__main__":
    rcode = execScriptWithDiag("connection-check")
    if (rcode != 0):
       print "Connection check failed!" 
       print "(tip: check \"config.json\" for correctness of Oracle server connection parameters)" 
    else:   
        execScriptWithStat("add-employees")
        execScriptWithStat("get-regions")
        execScriptWithStat("get-locations")
        execScriptWithStat("get-countries")
        execScriptWithStat("get-departments")
        execScriptWithStat("get-departments.2")
        execScriptWithStat("get-department-stat")
        execScriptWithStat("update-employees")
        execScriptWithStat("get-employees")
        execScriptWithStat("get-job-history")
        execScriptWithStat("get-consolidated-report")
        execScriptWithStat("release-employees")
        print "statistic:"   
        print str(passedTestCount) + " tests passed of " + str(testCount) + " launched."
        if ( testCount > passedTestCount):
            print str(testCount - passedTestCount)   + " failed :("

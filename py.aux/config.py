import json

def getCfg(cfgFile):
    jsf = open(cfgFile, "r")
    js_data = jsf.read();
    jsf.close();
    cfg = json.loads(js_data)
    return cfg

def getSqlPlusPath(cfgFile):
    cfg = getCfg(cfgFile)
    return cfg["sqlplusPath"]

def getConnectionString(cfgFile):
    cfg = getCfg(cfgFile)
    cfgConnSec = cfg["connection"]
    return cfgConnSec["user"] + '/' + cfgConnSec["password"] + '@' + cfgConnSec["service"]    

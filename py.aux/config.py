import json

def getConnectionString(cfgFile):
    jsf = open(cfgFile, "r")
    js_data = jsf.read();
    jsf.close();
    cfg = json.loads(js_data)
    cfgConnSec = cfg["connection"]
    return cfgConnSec["user"] + '/' + cfgConnSec["password"] + '@' + cfgConnSec["service"]

#!/usr/bin/env python

import requests
import sys
import os
import time
from pprint import pprint
from zapv2 import ZAPv2

api_base = 'http://127.0.0.1:8080/JSON/'
target = 'https://login.fr.cloud.gov/login'
zap = ZAPv2()

script = os.path.abspath('uaa-auth.js')
print(script)
payload = {
    'scriptName': 'uaa-auth',
    'fileName': script,
    'scriptType': 'authentication',
    # for some reason Nashorn is installed for Mac, but Rhino is installed in Docker
    'scriptEngine': 'ECMAScript : Rhino',
    'scriptDescription': '',
    'zapapiformat': 'JSON'
}
resp = requests.get(api_base + 'script/action/load/', params=payload)
print(resp.json())

resp = requests.get(api_base + 'script/view/listScripts/?zapapiformat=JSON')
print(resp.json())
sys.exit()


# do stuff
print 'Accessing target %s' % target
# try have a unique enough session...
zap.urlopen(target)
# Give the sites tree a chance to get updated
time.sleep(2)

print 'Spidering target %s' % target
scanid = zap.spider.scan(target)
# Give the Spider a chance to start
time.sleep(2)
while (int(zap.spider.status(scanid)) < 100):
    print 'Spider progress %: ' + zap.spider.status(scanid)
    time.sleep(2)

print 'Spider completed'
# Give the passive scanner a chance to finish
time.sleep(5)

print 'Scanning target %s' % target
scanid = zap.ascan.scan(target)
while (int(zap.ascan.status(scanid)) < 100):
    print 'Scan progress %: ' + zap.ascan.status(scanid)
    time.sleep(5)

print 'Scan completed'

# Report the results

print 'Hosts: ' + ', '.join(zap.core.hosts)
print 'Alerts: '
pprint (zap.core.alerts())

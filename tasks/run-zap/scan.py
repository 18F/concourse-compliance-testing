#!/usr/bin/env python

import requests
import sys
import os
import time
from pprint import pprint
from zapv2 import ZAPv2

target = 'https://login.fr.cloud.gov/login'
API_BASE = 'http://127.0.0.1:8080/JSON/'

def call_zap_api(endpoint, params={}):
    params['zapapiformat'] = 'JSON'
    resp = requests.get(API_BASE + endpoint, params=params)
    print(resp.json())
    return resp

zap = ZAPv2()

script = os.path.abspath('uaa-auth.js')
call_zap_api('script/action/load/', {
    'scriptName': 'uaa-auth',
    'fileName': script,
    'scriptType': 'authentication',
    # for some reason Nashorn is installed for Mac, but Rhino is installed in Docker
    'scriptEngine': 'ECMAScript : Rhino',
    'scriptDescription': ''
})

call_zap_api('script/view/listScripts/')
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

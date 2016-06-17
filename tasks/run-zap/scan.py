#!/usr/bin/env python

import requests
import sys
import os
import time
import json
import urllib
from pprint import pprint
from zapv2 import ZAPv2

target = 'https://login.fr.cloud.gov/login'
username = os.environ['USER']
password = os.environ['PASS']
API_BASE = 'http://127.0.0.1:8080/JSON/'

def call_zap_api(endpoint, params={}):
    params['zapapiformat'] = 'JSON'
    resp = requests.get(API_BASE + endpoint, params=params)
    print('%s:' % endpoint)
    print json.dumps(resp.json(), indent=4)
    resp.raise_for_status()
    return resp

def get_context_id():
    resp = call_zap_api('context/view/context/', {
        'contextName': 'Default Context'
    })
    return int(resp.json()['context']['id'])

def add_auth_script(abs_path):
    filename = os.path.basename(abs_path)
    name = os.path.splitext(filename)[0]

    call_zap_api('script/action/load/', {
        'scriptName': name,
        'fileName': abs_path,
        'scriptType': 'authentication',
        # for some reason Nashorn is installed for Mac, but Rhino is installed in Docker
        'scriptEngine': 'ECMAScript : Rhino',
        # BUG: required, even though the API page says it isn't
        'scriptDescription': ''
    })

def create_user(context_id, username, password):
    resp = call_zap_api('users/action/newUser/', {
        'contextId': context_id,
        'name': username
    })
    user_id = resp.json()['userId']

    params = urllib.urlencode({
        'Username': username,
        'Password': password,
        'sessionName': 'Session 0' # BUG
    })
    call_zap_api('users/action/setAuthenticationCredentials/', {
        'contextId': context_id,
        'userId': user_id,
        'authCredentialsConfigParams': params
    })

    return user_id


zap = ZAPv2()

context_id = get_context_id()

# add auth script
script_path = os.path.abspath('uaa-auth.js')
add_auth_script(script_path)

# add the UAA's CSRF tag `name`
call_zap_api('acsrf/action/addOptionToken/', {
    'String': 'X-Uaa-Csrf'
})

print 'Accessing target %s' % target
# try have a unique enough session...
zap.urlopen(target)
# Give the sites tree a chance to get updated
time.sleep(2)

user_id = create_user(context_id, username, password)

print 'Spidering target %s' % target
scanid = zap.spider.scan_as_user(context_id=context_id, userid=user_id, url=target)
# Give the Spider a chance to start
time.sleep(2)
while (int(zap.spider.status(scanid)) < 100):
    print 'Spider progress %: ' + zap.spider.status(scanid)
    time.sleep(2)

print 'Spider completed'

call_zap_api('core/view/urls/')

print '----------------------'
sys.exit()

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

#!/usr/bin/env python

import requests
import sys
import os
import time
import json
import urllib
from bs4 import BeautifulSoup
from pprint import pprint
from zapv2 import ZAPv2

target = 'https://login.fr.cloud.gov/login'

LOGIN_FORM_URL = 'https://login.fr.cloud.gov/login'
LOGIN_ACTION_URL = 'https://login.fr.cloud.gov/login.do'
CSRF_ATTR = 'X-Uaa-Csrf'
USERNAME = os.environ['USER']
PASSWORD = os.environ['PASS']

ZAP_BASE = 'http://127.0.0.1:8080'
API_BASE = ZAP_BASE + '/JSON/'
PROXIES = {
    'http': ZAP_BASE,
    'https': ZAP_BASE,
}

def call_zap_api(endpoint, params={}):
    params['zapapiformat'] = 'JSON'
    resp = requests.get(API_BASE + endpoint, params=params)
    print('%s:' % endpoint)
    print json.dumps(resp.json(), indent=4)
    resp.raise_for_status()
    return resp

# needs the site to exist within ZAP first
def initialize_session(site):
    call_zap_api('httpSessions/action/setActiveSession/', {
        'site': site,
        'session': 'Session 0'
    })

def register_csrf_tag(name):
    call_zap_api('acsrf/action/addOptionToken/', {
        'String': name
    })

def get_context_id():
    resp = call_zap_api('context/view/context/', {
        'contextName': 'Default Context'
    })
    return int(resp.json()['context']['id'])

def set_auth_indicators(context_id):
    call_zap_api('authentication/action/setLoggedInIndicator/', {
        'contextId': context_id,
        'loggedInIndicatorRegex': 'logout\.do'
    })
    call_zap_api('authentication/action/setLoggedOutIndicator/', {
        'contextId': context_id,
        'loggedOutIndicatorRegex': 'login\.do'
    })

# private
def get_csrf_val(session, form_url):
    resp = session.get(form_url, proxies=PROXIES.copy(), verify=False)
    resp.raise_for_status()

    soup = BeautifulSoup(resp.text, 'html.parser')
    csrf_tag = soup.find('input', {'name': CSRF_ATTR})
    return csrf_tag['value']

def log_in(username, password):
    # login request requires a cookie
    session = requests.Session()
    csrf_val = get_csrf_val(session, LOGIN_FORM_URL)

    data = {
        CSRF_ATTR: csrf_val,
        'username': username,
        'password': password
    }
    print(data)
    resp = session.post(LOGIN_ACTION_URL, proxies=PROXIES.copy(), verify=False, data=data)
    resp.raise_for_status()

zap = ZAPv2()

context_id = get_context_id()
set_auth_indicators(context_id)
register_csrf_tag(CSRF_ATTR)

log_in(USERNAME, PASSWORD)
time.sleep(2)
initialize_session(target)
time.sleep(2)

print 'Spidering target %s' % target
scanid = zap.spider.scan(target)
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

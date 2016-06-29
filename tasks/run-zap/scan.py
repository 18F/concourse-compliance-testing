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

# TODO read from project.json
target = 'https://invite.fr.cloud.gov'

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
CONTEXT_NAME = 'Default Context'

def call_zap_api(endpoint, params={}):
    params['zapapiformat'] = 'JSON'
    resp = requests.get(API_BASE + endpoint, params=params)
    print('%s:' % endpoint)
    print json.dumps(resp.json(), indent=4)
    resp.raise_for_status()
    return resp

def default_session_name(site):
    resp = call_zap_api('httpSessions/view/sessions/', {
        'site': site,
        'session': '' # BUG
    })
    resp.raise_for_status()
    return resp.json()['sessions'][0]['session'][0]

# needs the site to exist within ZAP first
def initialize_session(site):
    session_name = default_session_name(site)
    call_zap_api('httpSessions/action/setActiveSession/', {
        'site': site,
        'session': session_name
    })

def register_csrf_tag(name):
    call_zap_api('acsrf/action/addOptionToken/', {
        'String': name
    })

def include_in_context(url):
    call_zap_api('context/action/includeInContext/', {
        'contextName': CONTEXT_NAME,
        'regex': target + '.*'
    })

def add_session_token(site, name):
    call_zap_api('httpSessions/action/addSessionToken/', {
        'site': site,
        'sessionToken': name
    })

def get_context_id():
    resp = call_zap_api('context/view/context/', {
        'contextName': CONTEXT_NAME
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
def get_csrf_val(client, form_url):
    resp = client.get(form_url, proxies=PROXIES.copy(), verify=False)
    resp.raise_for_status()

    soup = BeautifulSoup(resp.text, 'html.parser')
    csrf_tag = soup.find('input', {'name': CSRF_ATTR})
    return csrf_tag['value']

def log_in(username, password):
    # login request requires a cookie
    client = requests.Session()
    csrf_val = get_csrf_val(client, LOGIN_FORM_URL)

    data = {
        CSRF_ATTR: csrf_val,
        'username': username,
        'password': password
    }
    resp = client.post(LOGIN_ACTION_URL, proxies=PROXIES.copy(), verify=False, data=data)
    resp.raise_for_status()

zap = ZAPv2()

context_id = get_context_id()
set_auth_indicators(context_id)
register_csrf_tag(CSRF_ATTR)
include_in_context(target)
include_in_context('https://login.fr.cloud.gov') # TODO remove hard-coding

zap.urlopen(target)
time.sleep(5)
# TODO read from project.json, if specified
add_session_token(target, 'session')

# TODO do this conditionally
log_in(USERNAME, PASSWORD)
time.sleep(5)
initialize_session(LOGIN_FORM_URL)

zap.urlopen(target)
time.sleep(5)
initialize_session(target)
time.sleep(2)

print 'Spidering target %s' % target
scanid = zap.spider.scan(url=target, recurse=True, contextname=CONTEXT_NAME, subtreeonly=False)
# Give the Spider a chance to start
time.sleep(2)
while (int(zap.spider.status(scanid)) < 100):
    print 'Spider progress %: ' + zap.spider.status(scanid)
    time.sleep(2)

print 'Spider completed'

call_zap_api('core/view/urls/')
call_zap_api('spider/view/fullResults/', {'scanId': scanid})

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

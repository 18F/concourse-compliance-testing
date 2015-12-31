import requests
import json
import time
import sys
import csv
import os

url = os.environ.get('NESSUS_SERVER', '')
username = os.environ.get('NESSUS_USER', '')
password = os.environ.get('NESSUS_PASSWORD', '')
live_target = os.environ.get('LIVE_TARGET', '')

class NessusApi:
    "Provide an API to the Nessus REST API"
    _url = ''
    _verify = False
    _token = ''
    _username = ''
    _password = ''

    def __init__(self, url, username, password, verify=False):
        self._url = url
        self._username = username
        self._password = password
        self._verify = verify

    def build_url(self, resource):
        return '{0}{1}'.format(self._url, resource)

    def connect(self, method, resource, data=None):
        """
        Send a request

        Send a request to Nessus based on the specified data. If the session
        token is available add it to the request. Specify the content type as
        JSON and convert the data to JSON format.
        """
        headers = {'X-Cookie': 'token={0}'.format(self._token),
                   'content-type': 'application/json'}

        data = json.dumps(data)

        if method == 'POST':
            r = requests.post(self.build_url(resource),
                              data=data, headers=headers, verify=self._verify)
        elif method == 'PUT':
            r = requests.put(self.build_url(resource),
                             data=data, headers=headers, verify=self._verify)
        elif method == 'DELETE':
            r = requests.delete(self.build_url(resource),
                                data=data, headers=headers,
                                verify=self._verify)
        else:
            r = requests.get(self.build_url(resource),
                             params=data, headers=headers, verify=self._verify)

        # Exit if there is an error.
        if r.status_code != 200:
            e = r.json()
            print(r.status_code, e['error'])
            sys.exit()

        # When downloading a scan we need the raw contents not the JSON data.
        if 'download' in resource or method == 'DELETE':
            return r.content
        else:
            return r.json()

    def login(self):
        """
        Login to nessus.
        """

        login = {'username': self._username, 'password': self._password}
        data = self.connect('POST', '/session', data=login)

        self._token = data['token']
        return data['token']

    def logout(self):
        """
        Logout of nessus.
        """

        self.connect('DELETE', '/session')

    def get_policies(self):
        """
        Get scan policies

        Get all of the scan policies but return only the title and the uuid of
        each policy.
        """

        data = self.connect('GET', '/editor/policy/templates')

        return dict((p['title'], p['uuid']) for p in data['templates'])

    def get_history_ids(self, sid):
        """
        Get history ids

        Create a dictionary of scan uuids and history ids so we can lookup the
        history id by uuid.
        """
        data = self.connect('GET', '/scans/{0}'.format(sid))

        return dict((h['uuid'], h['history_id']) for h in data['history'])

    def get_scan_history(self, sid, hid):
        """
        Scan history details

        Get the details of a particular run of a scan.
        """
        params = {'history_id': hid}
        data = self.connect('GET', '/scans/{0}'.format(sid), params)

        return data['info']

    def add(self, name, desc, targets, pid):
        """
        Add a new scan

        Create a new scan using the policy_id, name, description and targets.
        The scan will be created in the default folder for the user. Return
        the id of the newly created scan.
        """

        scan = {'uuid': pid,
                'settings': {
                    'name': name,
                    'description': desc,
                    'text_targets': targets}
                }

        data = self.connect('POST', '/scans', data=scan)

        return data['scan']

    def update(self, scan_id, name, desc, targets, pid=None):
        """
        Update a scan

        Update the name, description, targets, or policy of the specified scan.
        If the name and description are not set, then the policy name and
        description will be set to None after the update. In addition the
        targets value must be set or you will get an
        "Invalid 'targets' field" error.
        """

        scan = {}
        scan['settings'] = {}
        scan['settings']['name'] = name
        scan['settings']['desc'] = desc
        scan['settings']['text_targets'] = targets

        if pid is not None:
            scan['uuid'] = pid

        data = self.connect('PUT', '/scans/{0}'.format(scan_id), data=scan)

        return data

    def launch(self, sid):
        """
        Launch a scan

        Launch the scan specified by the sid.
        """

        data = self.connect('POST', '/scans/{0}/launch'.format(sid))

        return data['scan_uuid']

    def status(self, sid, hid):
        """
        Check the status of a scan run

        Get the historical information for the particular scan and hid. Return
        the status if available. If not return unknown.
        """

        d = self.get_scan_history(sid, hid)
        return d['status']

    def export_status(self, sid, fid):
        """
        Check export status

        Check to see if the export is ready for download.
        """

        data = self.connect('GET',
                            '/scans/{0}/export/{1}/status'.format(sid, fid))

        return data['status'] == 'ready'

    def export(self, sid, hid, data_format='csv'):
        """
        Make an export request

        Request an export of the scan results for the specified scan and
        historical run. In this case the format is hard coded as nessus but
        the format can be any one of nessus, html, pdf, csv, or db. Once the
        request is made, we have to wait for the export to be ready.
        """

        data = {'history_id': hid,
                'format': data_format}

        data = self.connect('POST', '/scans/{0}/export'.format(sid), data=data)

        fid = data['file']

        while self.export_status(sid, fid) is False:
            time.sleep(5)

        return fid

    def download(self, sid, fid):
        """
        Download the scan results

        Download the scan results stored in the export file specified by fid
        for the scan specified by sid.
        """

        data = self.connect('GET',
                            '/scans/{0}/export/{1}/download'.format(sid, fid))
        return data
        # filename = 'nessus_{0}_{1}.nessus'.format(sid, fid)

        # print('Saving scan results to {0}.'.format(filename))
        # with open(filename, 'w') as f:
        #     f.write(data)

    def minion_severity(self, risk):
        if risk == 'None':
            return 'Info'
        else:
            return risk

    def _get_plugin_name(self, plugin_info):
        name = None
        for attribute in plugin_info['attributes']:
            if attribute['attribute_name'] == 'plugin_name':
                name = attribute['attribute_value']
        return name

    def _build_description(self, row, plugin_name):
        return plugin_name + ' ' + row[8] + ' ' + row[9] + ' ' + \
            row[10] + ' ' + row[12]

    def create_issue(self, row, plugin_info):
        """
        0  Plugin ID
        1  CVE
        2  CVSS
        3  Risk
        4  Host
        5  Protocol
        6  Port
        7  Name
        8  Synopsis
        9  Description
        10 Solution
        11 See Also
        12 Plugin Output
        """
        plugin_name = self._get_plugin_name(plugin_info)
        return {
            'Severity': self.minion_severity(row[3]),
            'Summary': row[8],
            'Description': self._build_description(row, plugin_name),
            'URLs': [{'URL': '{h}:{p}'.format(h=row[4], p=row[6])}],
            'Ports': [row[6]],
        }

    def parse_csv_data(self, data):
        """
        Parses CSV data into a data structure for Minion
        From
            Plugin ID, CVE, CVSS, Risk, Host, Protocol, Port, Name, Synopsis,
              Description Solution, See Also, Plugin Output
        To
        {
            'Severity': 'High',
            'Summary': '10.0.1.1: open port (88), running: Heimdal Kerberos' \
                       ' (unrecognized software)',
            'Description': '10.0.1.1: open port (88), running: Heimdal' \
                           ' Kerberos (unrecognized software)',
            'URLs': [{'URL': '10.0.1.1:88'}],
            'Ports': [88],
            'Classification': {
                'cwe_id': '200',
                'cwe_url': 'http://cwe.mitre.org/data/definitions/200.html'
            }
        }
        """
        plugins = dict()
        brows = data.splitlines()
        issues = []
        rows = []
        for row in brows:
          rows.append(bytes.decode(row))
        #print('xxx', rows)
        for row in csv.reader(rows):
            if row[0] == 'Plugin ID':
                continue
            if row[0] not in plugins:
                plugins[row[0]] = self.get_plugin_info(row[0])
                #print(plugins)
            issues.append(self.create_issue(row, plugins[row[0]]))
        return issues

    def delete(self, sid):
        """
        Delete a scan

        This deletes a scan and all of its associated history. The scan is
        not moved to the trash folder, it is deleted.
        """

        self.connect('DELETE', '/scans/{0}'.format(scan_id))

    def history_delete(self, sid, hid):
        """
        Delete a historical scan.

        This deletes a particular run of the scan and not the scan itself.
        The scan run is defined by the history id.
        """

        self.connect('DELETE', '/scans/{0}/history/{1}'.format(sid, hid))

    def get_plugin_info(self, pid):
        return self.connect('GET', '/plugins/plugin/{0}'.format(pid))

if __name__ == '__main__':
    api = NessusApi(url, username, password)
    #print('Login')
    api.login()

    #print('Adding new scan.')
    policies = api.get_policies()
    # print policies
    policy_id = policies['Basic Network Scan']
    scan_data = api.add('Test Scan', 'Create a new scan with API',
                        live_target, policy_id)
    scan_id = scan_data['id']

    # print('Updating scan with new targets.')
    # api.update(scan_id, scan_data['name'], scan_data['description'],
    #           '192.168.2.2')

    #print('Launching new scan.')
    scan_uuid = api.launch(scan_id)
    history_ids = api.get_history_ids(scan_id)
    history_id = history_ids[scan_uuid]
    while api.status(scan_id, history_id) != 'completed':
        time.sleep(5)

    file_id = api.export(scan_id, history_id)
    data = api.download(scan_id, file_id)
    issues = api.parse_csv_data(data)
    print(issues)

    # print('Deleting the scan.')
    # api.history_delete(scan_id, history_id)
    # api.delete(scan_id)

    #print('Logout')
    api.logout()

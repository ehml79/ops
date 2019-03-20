#!/usr/bin/env python3.6

import requests
import json

zabbix_user = "admin"
zabbix_password = "your_password"

headers = {'Content-Type': 'application/json'}
api_url = "http://company.com/api_jsonrpc.php"

def msg():
    data = {
        "jsonrpc": "2.0",
        "method": "user.login",
        "params": {
            "user": zabbix_user,
            "password": zabbix_password
        },
        "id": 1,
        "auth": None,
    }

    response = requests.post(api_url, data=json.dumps(data), headers=headers)
    print(response.text)
    return

if __name__ == '__main__':
    msg()

#!/usr/bin/env python3.6

import requests
import json

headers = {'Content-Type': 'application/json'}
api_url = "http://company.com/api_jsonrpc.php"
token = "your_token"

def msg():
    data = {
    "jsonrpc": "2.0",
    "method": "host.get",
    "params": {
        "output": [
            "hostid",
            "host"
        ],
        "selectInterfaces": [
            "interfaceid",
            "ip"
        ]
    },
    "id": 2,
    "auth": token
}

    response = requests.post(api_url, data=json.dumps(data), headers=headers)
    print(response.text)
    return

if __name__ == '__main__':
    msg()

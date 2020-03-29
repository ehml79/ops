#!/usr/bin/env python3.6

import requests
import json

host_name = "hk-test-192.168.1.1"
host_ip = "192.168.1.1"

headers = {'Content-Type': 'application/json'}
api_url = "http://company.com/api_jsonrpc.php"
token = "your_token"

def msg():
    data = {
    "jsonrpc": "2.0",
    "method": "host.create",
    "params": {
        "host": host_name,
        "interfaces": [
            {
                "type": 1,
                "main": 1,
                "useip": 1,
                "ip": host_ip,
                "dns": "",
                "port": "10050"
            }
        ],
        "groups": [
            {
                "groupid": "2"
            }
        ],
        "templates": [
                {
                    "templateid":"10001",
                    "name":"Template OS Linux"
                },
                {
                    "templateid":"10170",
                    "name":"Template DB MySQL"
                }
                     ]

    },
    "auth": token,
    "id": 1
    }


    response = requests.post(api_url, data=json.dumps(data), headers=headers)
    print(response.text)
    return

if __name__ == '__main__':
    msg()

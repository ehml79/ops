#!/usr/bin/env python3

import flask
from flask import jsonify
import os



app = flask.Flask(__name__)
@app.route('/update', methods=['get','post'])
def update():
    os.system('/bin/bash /root/update.sh')
    res = {'code': 200, 'message': 'Success'}
    return jsonify(res)


if __name__ == '__main__':

    app.run(debug=True, port=5000, host='0.0.0.0')


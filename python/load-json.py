#!/usr/bin/env python

import json

def load_json():

    with open('topics.json', 'r') as myfile:
        data=myfile.read()

    # parse file
    obj = json.loads(data)

    # show values
    print(obj["topics"])

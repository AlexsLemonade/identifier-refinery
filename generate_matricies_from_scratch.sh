#! /bin/bash

virtualenv env
source env/bin/activate
pip install -r requirements.txt
python acquire_cels.py

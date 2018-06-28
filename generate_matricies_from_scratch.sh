#! /bin/bash

# Fetch the CELS
virtualenv env
source env/bin/activate
pip install -r requirements.txt
python acquire_cels.py

# Build the base image
docker build -t "convert/base" -f Dockerfile.base .


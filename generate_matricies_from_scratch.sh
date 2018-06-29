#! /bin/bash

# Fetch the CELS
virtualenv env
source env/bin/activate
pip install -r requirements.txt
python acquire_cels.py $1

# Build the base image
docker build -t "convert/base" -f Dockerfile.base .

# Build the image and build a conversion matrix for each cel
python build_and_convert.py $1

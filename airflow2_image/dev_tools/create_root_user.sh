#!/bin/bash

# use this script to create the root user (only to be used in local)

cp -f /tmp/webserver_config.py ${AIRFLOW_USER_HOME}/

/entrypoint.sh airflow create_user \
    -r Admin \
    -u "root" \
    -e "data-team@earnest.com" \
    -f "don" \
    -l "root" \
    -p password

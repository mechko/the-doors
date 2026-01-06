#!/bin/bash

# Updating the timestamp of a test booking for user admin:admin to the current hour. 

source .env

START=$(date +%s)
END=$((START+(60*60)))

mysql --host=127.0.0.1 --port 3306 --password=$MYSQL_PASSWORD -u $MYSQL_USER $MYSQL_DATABASE -e "update mrbs_entry set start_time = $START, end_time = $END where id = 8;"

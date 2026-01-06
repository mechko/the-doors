#!/bin/bash

source .env

mysql --host=127.0.0.1 --port 3306 --password=$MYSQL_PASSWORD -u $MYSQL_USER $MYSQL_DATABASE

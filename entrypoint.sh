#!/bin/bash

# Start MySQL safely (skip if user already exists)
service mysql start
mysql -e "CREATE DATABASE IF NOT EXISTS tododb;" || true
mysql -e "CREATE USER IF NOT EXISTS 'todouser'@'%' IDENTIFIED BY 'password';" || true
mysql -e "GRANT ALL PRIVILEGES ON tododb.* TO 'todouser'@'%';" || true
mysql -e "FLUSH PRIVILEGES;" || true

# Start Tomcat
/opt/tomcat/bin/startup.sh

# Keep container running
tail -f /opt/tomcat/logs/catalina.out
#!/bin/bash

echo -e "cQube Status... \n"

function checkport() {

if sudo lsof -i -P -n | grep $2 > /dev/null 2>&1; 
 	then
		echo "$1 : Ok"
	else
		echo "$1 : Not Ok"
	fi
}

checkport 'createdb' 5432
checkport 'python_flask' 5000
checkport 'kong' 8001
checkport 'keycloak' 8080
checkport 'prometheus' 9090
checkport 'grafana' 9000
checkport 'nifi' 8080
checkport 'angular' 3000
checkport 'angular_admin' 3001


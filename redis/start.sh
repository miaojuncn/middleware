#!/bin/bash

passwd=$1

if [[ -z "$passwd" ]]; then
	echo "start redis without password"
	docker run --name redis-5.0 -d -p 6379:6379 redis:5.0 
else
	echo "start redis with password"
	docker run --name redis-5.0 -d -p 6379:6379 redis:5.0 --requirepass "$passwd"
fi

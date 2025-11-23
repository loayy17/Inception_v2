#!/bin/bash

#1) validate redis environment variables
redis_env=(
	"$REDIS_PORT"
	"$REDIS_PASSWORD"
)
for var in "${redis_env[@]}"; do
	if [ -z "$var" ]; then
		echo "Error: One or more required environment variables are not set."
		exit 1
	fi
done

#2) configure redis
# sed -i "s/^# requirepass .*/requirepass $REDIS_PASSWORD/" /etc/redis/redis.conf
# sed -i "s/^bind .*/bind 0.0.0.0/" /etc/redis/redis.conf	
# sed -i "s/^port .*/port $REDIS_PORT/" /etc/redis/redis.conf
#3) start redis server
exec redis-server --port $REDIS_PORT --requirepass $REDIS_PASSWORD --bind 0.0.0.0

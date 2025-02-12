#!/bin/bash
#
#********************************************************************
#Author:		loong
#FileName：		redis.sh
#********************************************************************

NUM=100
PASS=123456
HOST=127.0.0.1
PORT=6379
DATABASE=0


for i in `seq $NUM`;do
    redis-cli -h ${HOST}  -a "$PASS" -p ${PORT} -n ${DATABASE} --no-auth-warning  set key${i} value${i}
    #redis-cli -h ${HOST} -p ${PORT} -n ${DATABASE} --no-auth-warning  set key${i} value${i}
    echo "key${i} value${i} 写入完成"
done
echo "$NUM个key写入到Redis完成"  

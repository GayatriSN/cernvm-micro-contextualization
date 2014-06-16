#!/bin/sh

file /tmp/user-data* | grep "compressed" | cat > com.txt

if [ -s com.txt ]
then
        gzip -d /tmp/user-data* 
else
        echo "File not compressed"
fi

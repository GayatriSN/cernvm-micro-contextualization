#!/bin/sh

while read line
do
	#Displaying key-value pairs on STD_OUT
	#Added an intermediate grep to prevent displaying any input in invalid key=value format

	echo "${line}" | grep "=" |  awk -F'[=]' '{print $1 "=" $2}' 

done < /tmp/ucernvm-data

echo "Extracted key value pairs"

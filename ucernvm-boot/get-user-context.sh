#!/bin/sh

USER_DATA='/tmp/newfile'

grep "contextualization_key" ${USER_DATA} | cat > contextfile.sh

if [ -s contextfile.sh ]
then
	echo "Downloading context information from CernVM Online..."
	UUID=$(cat contextfile.sh | awk -F'[=]' '{print $2}')

	#echo "$UUID"
	#Need fix for CACERT issue to prevent redirection page as curl output
	#Need to merge this with get-user-data.sh when resolved

	curl -o /tmp/new-user-data https://cernvm-online.cern.ch/context/view/${UUID}/raw
	cat /tmp/new-user-data
	rm contextfile.sh
else
	echo "Using context information from user data..."
fi

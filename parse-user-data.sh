#!/bin/sh

USER_DATA=~/ud

grep "MIME" ${USER_DATA} | cat > mimetest.txt

if [ -s mimetest.txt ]
then
	echo "New Syntax Found"
	sed -n '/^Content-Type: text\/ucernvm; charset="us-ascii"$/,/^--===============1341993424==$/p' ud | head -n -1 | tail -n +4 | cat > /tmp/ucernvm-data
else
	echo "Old Syntax Found"
	#Extracting portion of ucernvm data
	sed -n '/^\[ucernvm-begin\]$/,/^\[ucernvm-end\]$/p' ud | head -n -1 | tail -n +1 | cat > /tmp/ucernvm-data
fi


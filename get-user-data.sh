#!/bin/sh

USER_DATA="/tmp/user-data" 

dmesg | cat > dmesg.txt

for PROVIDER in provider.d/*; do

   . "$PROVIDER"

   PROVIDER=${PROVIDER##*/}

   echo -n "Checking for $PROVIDER..."

   if ${PROVIDER}_detect; then
      echo "yes"
      ${PROVIDER}_download ${USER_DATA}
      ${PROVIDER}_cleanup
      break
   else
      echo "no"
      ${PROVIDER}_cleanup
   fi
done

file /tmp/user-data* | grep "compressed" | cat > com.txt

if [ -s com.txt ]
then
        gzip -d /tmp/user-data* 
else
        echo "File not compressed"
fi

rm com.txt

cat $USER_DATA

rm dmesg.txt

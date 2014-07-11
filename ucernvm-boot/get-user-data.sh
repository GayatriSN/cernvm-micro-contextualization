#!/bin/sh

USER_DATA="/tmp/user-data" 
CONTEXT_TIMEOUT=10

dmesg | cat > dmesg.txt

for PROVIDER in provider.d/*; do

   . "$PROVIDER"

   PROVIDER=${PROVIDER##*/}

   echo -n "Checking for $PROVIDER..."

   if ${PROVIDER}_detect; then
      echo "yes"
	  echo $PROVIDER | cat > /tmp/cloud-provider
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

#Check if the User Data are base 64 encoded. If yes, decode.

grep "MIME-Version" $USER_DATA | cat > testnew64

if [ -s testnew64 ]
then
	echo "User Data in New Syntax and not base64 encoded"
	rm testnew64
else
	grep "ucernvm" $USER_DATA | cat > test64
	if [ ! -s test64 ]
	then
		grep "amiconfig" $USER_DATA | cat > test64
        fi
	if [ ! -s test64 ]
        then
                grep "cloud-config" $USER_DATA | cat > test64
        fi
	if [ ! -s test64 ]
        then
                grep "#\!/bin" $USER_DATA | cat > test64
	fi

        if [ ! -s test64 ]
        then
		echo "Input could be base64 encoded"
		echo "Decoding user-data..."
		base64 -d $USER_DATA | cat > new-user-data
		if [ -s new-user-data ] 
		then
			echo "Data decoded successfully"
			cp new-user-data $USER_DATA
			rm new-user-data
		else
			echo "Error in decoding data"
		fi
	else
		echo "User-Data in Old Syntax and not base64 encoded"
	fi
	rm test64
fi
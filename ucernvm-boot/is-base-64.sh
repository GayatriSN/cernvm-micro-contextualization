#!/bin/sh

#This script can be integrated with the get-user-data.sh script
#or the parse-user-data.sh script

USER_DATA=/home/gayatri/ucernvm-data

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

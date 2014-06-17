#!/bin/sh

USER_DATA=~/ud

grep "MIME" ${USER_DATA} | cat > mimetest.txt

#We create temporary copy of user-data file
cp ${USER_DATA} ud

if [ -s mimetest.txt ]
then
	echo "New Syntax Found"
	sed -n '/^Content-Type: text\/ucernvm; charset="us-ascii"$/,/^--===============1341993424==$/p' ud | head -n -1 | tail -n +4 | cat > /tmp/ucernvm-data
	#Saving the uncompressed data as is
	cp ${USER_DATA} /var/lib/user-data
	#Writing to scratch disk
	cp ${USER_DATA} /root.rw/user-data
	#removing temporary user-data
	rm ud
else
	echo "Old Syntax Found"
	#Extracting portion of ucernvm data
	sed -n '/^\[ucernvm-begin\]$/,/^\[ucernvm-end\]$/p' ud | head -n -1 | tail -n +1 | cat > /tmp/ucernvm-data

	#Generating a cloud-init compatible MIME-Multipart

	#Since the boundary value and the header is of no interest to us or cloud-init,
	#we statically generate this to avoid any additional dependencies or use of python
	#These static files are stored in the mime-files folder

	cp mime-files/main-mime-header mime-user-data

	#UCERNVM SECTION
	if [ -s /tmp/ucernvm-data ]
	then
		echo "--===============1341993424==" >> mime-user-data
		cat mime-files/ucernvm-mime-header >> mime-user-data
		cat /tmp/ucernvm-data >> mime-user-data
	fi

	#AMICONFIG SECTION
	sed -n '/^\[amiconfig\]$/,/^#cloud-config\|\[ucernvm-begin\]$/p' ud | head -n -1 | tail -n +2 >> /tmp/amiconfig-data
	if [ -s /tmp/amiconfig-data ]
	then
		echo "--===============1341993424==" >> mime-user-data
		cat mime-files/amiconfig-mime-header >> mime-user-data
		cat /tmp/amiconfig-data >> mime-user-data
	fi
	rm /tmp/amiconfig-data

	#CLOUD-CONFIG SECTION
	sed -n '/^#cloud-config$/,/^\[amiconfig\]\|\[ucernvm-begin\]$/p' ud | head -n -1 | tail -n +2 >> /tmp/cloud-config-data
	if [ -s /tmp/cloud-config-data ]
	then
		echo "--===============1341993424==" >> mime-user-data
		cat mime-files/cloud-config-mime-header >> mime-user-data
		cat /tmp/cloud-config-data >> mime-user-data
	fi
	rm /tmp/cloud-config-data

	#ENDING BOUNDARY
	echo "--===============1341993424==--" >> mime-user-data

	#Removing temporary user-data file
	rm ud

	#Saving new cloud-init MIME-compatible user-data
	cp mime-user-data /var/lib/user-data

        #Writing to scratch disk
        cp mime-user-data /root.rw/user-data
fi


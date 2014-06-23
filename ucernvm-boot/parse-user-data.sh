#!/bin/sh

grep "MIME" ${USER_DATA} | cat > mimetest.txt

#We create temporary copy of user-data file
cp ${USER_DATA} ud

if [ -s mimetest.txt ]
then
	echo "New Syntax Found"
	sed -n '/^Content-Type: text\/ucernvm; charset="us-ascii"$/,/^MIME-Version: 1.0$/p' ud | head -n -2 | tail -n +4 | cat > /tmp/ucernvm-data
	#Leaving the uncompressed data as it is in /tmp/user-data
	
	#Removing temporary user-data
	rm ud
else
	echo "Old Syntax Found"
	#Extracting portion of ucernvm data
	sed -n '/^\[ucernvm-begin\]$/,/^\[ucernvm-end\]$/p' ud | head -n -1 | tail -n +1 | cat > /tmp/ucernvm-data

	#Generating a cloud-init compatible MIME-Multipart

	#Since the source our mime file will always be cernvm the boundary value and the header
	#in mime could be statically generated to avoid any additional dependencies or use of python
	#These static files are stored in the mime-files folder

	cp mime-files/main-mime-header mime-user-data

	#STARTUP SCRIPT SECTION
	sed -n '/^#!\/bin\/sh$/,/^\[ucernvm-begin\]\|\[amiconfig\]\|#cloud-config$/p' ud | head -n -1 >> /tmp/startup-script
	if [ -s /tmp/startup-script ]
	then
		echo "--===============1341993424==" >> mime-user-data
                cat mime-files/startup-script-mime-header >> mime-user-data
                cat /tmp/startup-script >> mime-user-data
	fi
	rm /tmp/startup-script

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
	\cp mime-user-data /tmp/user-data
	
	#Removing the generated mime-user-data file
	#since it is already copied to /tmp/user-data
	rm mime-user-data

	
fi


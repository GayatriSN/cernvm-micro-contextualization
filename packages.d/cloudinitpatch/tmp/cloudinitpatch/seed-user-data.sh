#!/bin/sh

providerfile="/var/lib/cloud-provider"
PROVIDER=$(cat $providerfile)

cat supported-providers-list | grep ${PROVIDER} | cat > provider-check.txt

if [ -s provider-check.txt ]
then
	echo "Provider supported by both cloud-init and micro-bootloader"
else
	PROVIDER="nocloud-net"
	echo "Cloud Provider not supported by both"
	echo "Setting provider to nocloud-net..."
fi

rm provider-check.txt

SEED_DIR="/var/lib/cloud/seed/${PROVIDER}"

mkdir -p ${SEED_DIR} 

cp /var/lib/micro-user-data ${SEED_DIR}/user-data

cat ${SEED_DIR}/user-data

#Creating a dummy meta-data file until a proper meta-data fetching utility is implemented

echo "Sample meta-data" | cat > ${SEED_DIR}/meta-data

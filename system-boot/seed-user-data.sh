#!/bin/sh

providerfile="/var/lib/cloud-provider"
PROVIDER=$(cat $providerfile)

cat supported-providers-list | grep $PROVIDER | cat > provider-check.txt

if [ -s provider-check.txt ]
then
	echo "Provider supported by cloud-init"
else
	PROVIDER="nocloud-net"
	echo "Cloud Provider not supported by CloudInit"
	echo "Setting provider to nocloud-net"
fi

rm provider-check.txt

SEED_DIR="/var/lib/cloud/seed/$PROVIDER"

mkdir -p $SEED_DIR 

cp /var/lib/micro-user-data ${SEED_DIR}/user-data

cat ${SEED_DIR}/user-data

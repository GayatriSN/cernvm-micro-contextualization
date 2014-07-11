#!/bin/sh

# This file applies cloud-provider specific extra configuration

if [ "$PROVIDER" = "openstack" ];
then
	#echo "NOZEROCONF=yes" >> /etc/sysconfig/network
fi

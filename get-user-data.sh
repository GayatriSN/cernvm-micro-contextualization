#!/bin/sh

vmware_detect() {
   # VMware uses CD-ROM contextualization
   # Need to modify this function for VMware
   if grep -q "VMware" dmesg.txt; then
      curl -o /tmp/vmware-user-data http://1.2.3.4/user-data
      if [ -f /tmp/vmware-user-data ]; then
         return 0
      else
         return 1
      fi
   else
      return 1
   fi
}

vmware_download() {
   local USER_DATA=$1
   mv /tmp/vmware-user-data $USER_DATA
}

vmware_cleanup() {
   rm /tmp/vmware-user-data
}

gce_detect() {
   if grep -q "Google" dmesg.txt; then
	  
	  # We need to request cernvm users to provide their startup script using the "startup-script" as key and the entire script as the value
	  # in the custom meta-data section while launching the instance. This way we can use the URL below since the format is
	  # http://metadata.google.internal/computeMetadata/v1/instance/attributes/key and it return the corresponding value
	  
      curl -o /tmp/gce-user-data -H "Metadata-Flavor:Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/startup-script
      if [ -f /tmp/gce-user-data ]; then
         return 0
      else
         return 1
      fi
   else
      return 1
   fi
}

gce_download() {
   local USER_DATA=$1
   mv /tmp/gce-user-data $USER_DATA
}

gce_cleanup() {
   rm /tmp/gce-user-data
}

amazon_detect() {
   if grep -q "amazon" dmesg.txt; then
      curl -o /tmp/amazon-user-data http://169.254.169.254/latest/user-data
      if [ -f /tmp/amazon-user-data ]; then
         return 0
      else
         return 1
      fi
   else
      return 1
   fi
}

amazon_download() {
   local USER_DATA=$1
   mv /tmp/amazon-user-data $USER_DATA
}

amazon_cleanup() {
   rm /tmp/amazon-user-data
}

azure_detect() {

   if grep -q "Microsoft" dmesg.txt; then

      # The custom data is placed by the Azure Linux Agent in the /var/lib/waagent/
      # at the time of VM creation. The Azure Linux Agent is installed at the time 
      # of creation of VHD for deploying to Azure. The Data is in base 64 encoded
      # format. 

      mv /tmp/azure-user-data /var/lib/waagent/CustomData
      if [ -f /tmp/azure-user-data ]; then
         return 0
      else
         return 1
      fi
   else
      return 1
   fi
}

azure_download() {
   local USER_DATA=$1
   mv /tmp/azure-user-data $USER_DATA
}

azure_cleanup() {
   rm /tmp/azure-user-data
}

opennebula_detect() {
	# grep command here..
	# User Data fetch here..
	return 1
}

opennebula_download() {
   local USER_DATA=$1
   mv /tmp/opennebula-user-data $USER_DATA
}

opennebula_cleanup() {
	rm /tmp/opennebula-user-data
}

openstack_detect() { 
	
	#grep command here..
	
	#Added from 06context script: 
	
	local default_gateway=$(route | grep ^default | awk '{print $2}')
	curl -o /tmp/openstack-user-data http://${default_gateway}/latest/user-data
    if [ -f /tmp/openstack-user-data ]; then
		return 0
    else
        return 1
    fi 
}

openstack_download() {
	local USER_DATA=$1
    mv /tmp/openstack-user-data $USER_DATA
}

openstack_cleanup() {
	rm /tmp/openstack-user-data
}

cloudstack_detect() {
	#grep command here..
	# To use curl we need to find out virtual router ip address
	# this command is documented by cloudstack
	# cat /var/lib/dhclient/dhclient-eth0.leases | grep dhcp-server-identifier | tail -1
	# but this the dchp lease file in a vm is found empty so we neet
	# to find out alternative way
	return 1
}

cloudstack_download() {
   local USER_DATA=$1
   mv /tmp/cloudstack-user-data $USER_DATA
}

cloudstack_cleanup() {
	rm /tmp/cloudstack-user-data
}

rhevm_detect() {
	#Method to detect RHE-V will be added here.. 
	return 1
}

rhevm_download() {
   local USER_DATA=$1
   mv /tmp/rhevm-user-data $USER_DATA
}

rhevm_cleanup() {
	rm /tmp/rhevm-user-data
}

USER_DATA="/tmp/user-data" 
PROVIDERS="amazon gce vmware azure openstack cloudstack opennebula rhevm" 

dmesg | cat > dmesg.txt 

for PROVIDER in $PROVIDERS; do
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

cat $USER_DATA

rm dmesg.txt

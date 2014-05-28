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
      curl -o /tmp/gce-user-data http://169.254.169.254/computeMetaData/v1/
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

USER_DATA="/tmp/user-data"
PROVIDERS="amazon gce vmware azure"

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

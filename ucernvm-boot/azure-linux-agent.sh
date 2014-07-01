#!/bin/sh

#This script provides the same functionality as the azure linux agent's user data handling
#It downloads the xml file containing the context information for azure linux agent and then
#extracts the user-data portion from it. This user-data is saved to /tmp/azure-user-data

#This script can be integrated into the azure_detect script

curl -o /tmp/temp-azure-data http://schemas.microsoft.com/windowsazure

grep "CustomData" /tmp/temp-azure-data | awk -F'CustomData' '{print $2}' | cut -d'<' -f 1 | cut -d'>' -f 2 | cat > /tmp/azure-user-data

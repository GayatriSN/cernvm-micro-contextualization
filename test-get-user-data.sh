#!/bin/sh
#Script to identify source and get user data

dmesg | cat > output.txt

if grep -q "VMware" output.txt; then
        echo "found VMware"
elif grep -q "amazon" output.txt; then
        echo "found amazon"
        curl -o user-data http://169.254.169.254/latest/user-data
        cat user-data
        if [ -f user-data ]; then
                echo "user-data downloaded from amazon"
        else
                echo "user-data download failed"
        fi
fi

rm output.txt

# existing download_userdata function can be
# used here from the 06context script since
# it is covering many other possibilities like
# request timeout and extra headers
#
# for testing the script for the time-being,
# a simple fetch is done using curl

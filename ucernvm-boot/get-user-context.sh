#!/bin/sh

# ADDED FROM /usr/sbin/cernvm-online.sh

VM_CONFIG_FILE="/etc/cernvm/online.conf"
VM_CA_PATH="/etc/cernvm/keys/CAs"
VM_URL_CONTEXT="https://cernvm-online.cern.ch/api/context"

# Prepare some advanced info
VM_VERSION=$(cat /etc/issue.net | grep version | sed 's/.* //' | tr -d '\n')
CERT_CHECK="--cacert ${VM_CA_PATH}/all.pem --capath $VM_CA_PATH"

# Platform-specific flags for the various tools (Mac: -E / linux: -r)
F_SED="-r"
F_GREP="-E"
F_MKTEMP="/tmp/tmp.XXXXXXXX"
F_CURL=""

contextualize() {
    local REQ_MODE="$1"
    local CONTEXT_ID="$2"
    local CONTEXT_KEY="$3"
    local TMP_FILE=$(mktemp ${F_MKTEMP})
    ## Step 1) Download context file

    context_download "${REQ_MODE}" "${CONTEXT_ID}" "${CONTEXT_KEY}" > "$TMP_FILE"
    if [ ! $? -eq 0 ]; then
        [ $SILENT -eq 0 ] && echo "Unable to contextualize the VM!" 1>&2
        rm "$TMP_FILE"
        return 1
    fi
}


fetch_salt() {
    # Fetch ONLY digits from the input
    local PIN=$(echo "$1" | sed s/[^0-9]//g)
    local PIN_LENGTH=${#PIN}
    # Set default values if we found less than 4 digits
    local DEFAULT="1234"
    [ $PIN_LENGTH -lt 4 ] && PIN="${PIN}${DEFAULT:$PIN_LENGTH}"
    # Calculate and run SUM expression
    local EXPR=$(echo "${PIN:0:4}" | sed ${F_SED} 's/(.)(.)(.)(.)/\1+\2+\3+\4/')
    local SALT=$(eval "echo \$(($EXPR))")
    # Make sure its padded with zeroes
    printf "%02.f" ${SALT}
}

download() {
    local URL="$1"
    local FILE="$2"
    [ -z "$FILE" ] && FILE="-"

    # Download checking certificates
    curl --connect-timeout 10 ${F_CURL} ${CERT_CHECK} -o tempdatafile "$URL"
    # Check for errors
    ANS=$?
    if [ $ANS -ne 0 ] && [ $SILENT -eq 0 ]; then
        echo -n "Error while downloading information! " 1>&2
        if [ $ANS -eq 2 ]; then
            echo "Failed to initialize cURL!" 1>&2
        elif [ $ANS -eq 6 ]; then
            echo "Failed to resolve host!" 1>&2
        elif [ $ANS -eq 7 ]; then
            echo "Failed to connect to host!" 1>&2
        elif [ $ANS -eq 23 ]; then
            echo "Could not write the output file!" 1>&2
        elif [ $ANS -eq 28 ]; then
            echo "Operation timed out!" 1>&2
        elif [ $ANS -eq 35 ]; then
            echo "SSL Handshake failed!" 1>&2
        elif [ $ANS -eq 51 ]; then
            echo "Remote server's SSL fingerprint was invalid!" 1>&2
        elif [ $ANS -eq 55 ]; then
            echo "Unable to send data!" 1>&2
        elif [ $ANS -eq 56 ]; then
            echo "Unable to receive data!" 1>&2
        elif [ $ANS -eq 60 ]; then
            echo "Server certificate cannot be authenticated!" 1>&2
        elif [ $ANS -eq 66 ]; then
            echo "Failed to initialize SSL engine!" 1>&2
        elif [ $ANS -eq 67 ]; then
            echo "The user credentials were not accepted!" 1>&2
        elif [ $ANS -eq 77 ]; then
            echo "Error reading CA certificate!" 1>&2
        else
            echo "An unknown cURL error #${ANS} occured!" 1>&2
        fi
    fi
    return $ANS
}

context_download() {
    local REQ_MODE="$1"
    local CONTEXT_ID="$2"
    local CONTEXT_KEY="$3"
    # Calculate salted password checksum
    local SALT=$(fetch_salt "${CONTEXT_ID}")
    local CHECKSUM=$(echo -n "${SALT}${CONTEXT_KEY}${SALT}" | sha1sum | awk '{print $1 }' | tr -d '\n')
    # Prepare URL
    local URL="${VM_URL_CONTEXT}?uuid=${VM_UUID}&ver=${VM_VERSION}&${REQ_MODE}=${CONTEXT_ID}&checksum=${CHECKSUM}"

    # Try to download that URL (to STDOUT)
    download "$URL"
    # Return the error code
    return $?
}

#MAIN SCRIPT

[ -z "$2" ] && echo "Please specify a pairing pin!" 1>&2 && exit 1
PIN=$2
SECRET="$3"

contextualize "pin" "$PIN" "$SECRET"

#Additional Code

USER_DATA="/tmp/user-data"

grep "EC2_USER_DATA" tempdatafile | awk -F'[=]' '{print $2}' | base64 -d | cat > ${USER_DATA}

rm tempdatafile

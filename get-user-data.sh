#!/bin/sh
#===========================
#FOR:BUILD
#===========================

#require_versioned_package curl ${CURL_STRONG_VERSION}

#===========================
#FOR:RUN
#===========================

USER_DATA=/user-data
UCONTEXT_TMP=/ucontext
UCONTEXT_SRC="(none)"
UCONTEXT_TIMEOUT=2
UCONTEXT_TIMEOUT_DATA=10
UCONTEXT_RETRIES=2

fetch_vsphere() {
  mkdir -p /context_mount
  for P in $(cat /proc/partitions | tail -n+3 | awk '{print $4}' | sort); do
    filesystem=$(blkid /dev/$P | grep -o TYPE=[^\ ]* | tr -d '"' | cut -d= -f2)
    if [ "x$filesystem" = "xiso9660" ]; then
      mount -o ro -t $filesystem /dev/$P /context_mount >/dev/null 2>&1
      if [ $? -eq 0 ]; then
        if cp /context_mount/user-data.txt ${USER_DATA} 2>/dev/null; then
          UCONTEXT_SRC="vSphere"
          umount /context_mount
          break
        fi
        umount /context_mount
      fi
    fi
  done
  rmdir /context_mount
}

download_userdata() {
  local server=$1
  local url=$2
  local meta_url=$3
  local extra_header="$4"
  local extra_header_opt=
  [ "x${extra_header}" != "x" ] && extra_header_opt="-H"
  local retval

  nc -w ${UCONTEXT_TIMEOUT} $server 80 -e /bin/true > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    if [ "x${extra_header}" != "x" ]; then
      curl -f -s -o ${USER_DATA} ${extra_header_opt} "${extra_header}" --connect-timeout ${UCONTEXT_TIMEOUT_DATA} $url
      retval=$?
    else
      curl -f -s -o ${USER_DATA} --connect-timeout ${UCONTEXT_TIMEOUT_DATA} $url
      retval=$?
    fi
    if [ $retval -eq 0 ]; then
      return 0
    else
      rm -f ${USER_DATA}
    fi

    # Check if there are meta-data but no user data
    if [ "x$meta_url" != "x" ]; then
      if [ "x${extra_header}" != "x" ]; then
        curl -f -s -o ${USER_DATA} ${extra_header_opt} "${extra_header}" --connect-timeout ${UCONTEXT_TIMEOUT_DATA} $meta_url
        retval=$?
      else
        curl -f -s -o ${USER_DATA} --connect-timeout ${UCONTEXT_TIMEOUT_DATA} $meta_url
        retval=$?
      fi
      if [ $retval -eq 0 ]; then
        cat /dev/null > ${USER_DATA}
        return 0
      else
        rm -f ${USER_DATA}
      fi
    fi
  fi
  
  # Failure
  return 1
}

fetch_ec2() {
  download_userdata 169.254.169.254 \
    http://169.254.169.254/latest/user-data \
    http://169.254.169.254/latest/meta-data/ami-id
  [ $? -eq 0 ] && UCONTEXT_SRC="EC2"
}


if [ ! -b "${ROOT_DEV}" ]; then
	echo "Contextualizing VM..."
	
	#detecting environment using dmesg command
	
	dmesg | cat > output.txt
	
	if grep -q "VMware" output.txt; then
        fetch_vsphere
	elif grep -q "amazon" output.txt; then
		fetch_ec2
	fi

	rm output.txt	
	
	if [ -f ${USER_DATA} ]; then
		echo "Detected environment using command."
	else
		echo "Detection by command failed... Detecting using user-data availability..."
		for data_source in vsphere ec2; do
		[ -f ${USER_DATA} ] && break
		fetch_${data_source}
		done
	fi
  
	echo ${UCONTEXT_SRC}
fi


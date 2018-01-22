#!/bin/bash -e

RETRY_TIME=20
DELAY_TIME=10
GIT_URL=https://raw.githubusercontent.com/onlymellb/tidb-cluster/master/scripts/functional.sh
QINIU_URL=http://download.pingcap.org/pingcap/functional.sh

function download_file() {
	local ret=0
	wget $1 -O functional.sh || ret=$?
	if [[ $ret -ne 0 ]]
	then
		echo "download functional.sh from $1 failed.">&2
	else
		echo "download functional.sh from $1 succeed.">&2
	fi
	echo $ret
}

for i in `seq 0 $RETRY_TIME`
do
	ret=`download_file $GIT_URL`
	[[ $ret -eq 0 ]] && break
	ret=`download_file $QINIU_URL`
	[[ $ret -eq 0 ]] && break
	sleep ${DELAY_TIME}
done

source ./functional.sh

function print_help() {
echo "\
${1:-TiDB cluster install script.}

Usage:
  ./tidb-cluster-install.sh [OPTIONS] [ARG]

Options:
   -u              Username for tidb cluster vms
   -p              Password for tidb cluster vms
   -v              TiDB install package verison
   -d              The numble of pd instances
   -D              The virtual machine ip address prefix of pd, e.g. (10.0.240.)
   -b              The numble of tidb instances
   -B              The virtual machine ip address prefix of tidb
   -k              The numble of tikv instances
   -K              The virtual machine ip address prefix of tikv
   -m              The virtual machine ip address of monitor
   -h              Display the help message
"
}

if [[ $# -eq 0 ]]
then
    print_help
    exit 1
fi

optstring=":u:p:v:d:D:b:B:k:K:m:h"

while getopts "$optstring" opt; do
	case $opt in
		u)
			USERNAME=${OPTARG}
			;;
		p)
			PASSWORD=${OPTARG}
			;;
		v)
			TIDB_VERSION=${OPTARG}
			;;
		d)
			PD_NUMBLES=${OPTARG}
			;;
		D)
			PD_IP_PREFIX=${OPTARG}
			;;
		b)
			TIDB_NUMBLES=${OPTARG}
			;;
		B)
			TIDB_IP_PREFIX=${OPTARG}
			;;
		k)
			TIKV_NUMBLES=${OPTARG}
			;;
		K)
			TIKV_IP_PREFIX=${OPTARG}
			;;
		m)
			MONITOR_IP_ADDR=${OPTARG}
			;;
		h)
			print_help
			exit 1
			;;
		\?)
			fatal "Invalid option: -$OPTARG" >&2
			;;
		:)
			fatal "Option -$OPTARG requires an argument" >&2
			;;
	esac
done

init_env
change_workspace
generate_inventory
deploy_tidb_cluster

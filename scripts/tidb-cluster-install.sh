#!/bin/bash -xe

wget https://raw.githubusercontent.com/onlymellb/tidb-cluster/master/scripts/functional.sh -O functional.sh

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

#!/bin/bash


##########################variable define##################################
WORK_DIR=$(cd $(dirname $0);pwd)
TIDB_ANSIBLE="https://github.com/pingcap/tidb-ansible.git"
TMP_INVENTORY="inventory.tmp"
INVENTORY="inventory.ini"

###########################################################################

#* --------------------------------------------------------------------- */
#*                         log configure                                 */
#* --------------------------------------------------------------------- */
### Define logging color
COLOR_ORIGIN="\033[0m"
COLOR_GREEN="\033[32m"
COLOR_YELLOW="\033[33m"
COLOR_RED="\033[31m"

### Define logging level
LOGGER_LEVEL="3"

### Define common logger
function logger() {
   cur_level=$1
   cur_type=$2
   cur_color=$3
   shift && shift && shift
   cur_msg=$*

   [[ ${LOGGER_LEVEL} -lt ${cur_level} ]] && return 0 #|| mkdir -p ${LOGGER_PATH}

   pre_fix="${cur_color}[${cur_type}][$(date +%F)][$(date +%T)]"
   pos_fix="${COLOR_ORIGIN}"
   echo -e "${pre_fix} ${cur_msg} ${pos_fix}"
}

### Define notice logger
function notice() {
   logger 3 "NOTICE" ${COLOR_GREEN} $*
}

### Define warning logger
function warning() {
   logger 2 "WARNING" ${COLOR_YELLOW} $*
}

### Define fatal logger
function fatal() {
   logger 1 "FATAL" ${COLOR_RED} $*
   exit 1
}
###########################################################################

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
   -h              Display the help message
"
}

if [[ $# -eq 0 ]]
then
    print_help
    exit 1
fi

optstring=":u:p:v:d:D:b:B:k:K:h"

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

### Initialize the environment
function init_env() {
	yum install -y git
	git clone ${TIDB_ANSIBLE}
}

### Generate ansible's inventory
function generate_inventory() {
	# clear the tmp inventory file
	:>${TMP_INVENTORY}

	# start to generate tidb inventory
	notice "start to generate tidb inventory, nums: ${TIDB_NUMBLES}, ip_prefix: ${TIDB_IP_PREFIX}"
	generate_part_inventory ${TIDB_NUMBLES} ${TIDB_IP_PREFIX} "[tidb_servers]"

	# start to generate tikv inventory
	notice "start to generate tikv inventory, nums: ${TIKV_NUMBLES}, ip_prefix: ${TIKV_IP_PREFIX}"
	generate_part_inventory ${TIKV_NUMBLES} ${TIKV_IP_PREFIX} "[tikv_servers]"

	# start to generate pd inventory
	notice "start to generate pd inventory, nums: ${PD_NUMBLES}, ip_prefix: ${PD_IP_PREFIX}"
	generate_part_inventory ${PD_NUMBLES} ${PD_IP_PREFIX} "[pd_servers]"

	# start to generate global variables
	notice "start to generate global variables"
	local start_point=`grep -n "\[all:vars\]" ${INVENTORY}|cut -d: -f1`
	local end_point=`cat ${INVENTORY}|wc -l`
	sed -n "${start_point},${end_point}p" ${INVENTORY} >> ${TMP_INVENTORY}

	# start to adjust some variables
	notice "start to adjust some variables"
	sed -i "s/deploy_dir\(.*\)/deploy_dir = \/home\/${USERNAME}\/deploy/g" ${TMP_INVENTORY}

	# turn off the time zone setting
	sed -i "s/set_timezone\(.*\)/# set_timezone\1/g" ${TMP_INVENTORY}
}

function generate_part_inventory() {
	local vm_nums=$1
	local ip_prefix=$2
	local group_name=$3

	echo "${group_name}" >> ${TMP_INVENTORY}
	for i in `seq 1 ${vm_nums}`
	do
		echo "${ip_prefix}${i}" >> ${TMP_INVENTORY}
	done
	printf "\n\n" >>  ${TMP_INVENTORY}
}

init_env
generate_inventory
echo "username: ${USERNAME}"
echo "password: ${PASSWORD}"
echo "tidb version: ${TIDB_VERSION}"
echo "pd numles: ${PD_NUMBLES}"
echo "pd ip prefix: ${PD_IP_PREFIX}"
echo "tidb numbles: ${TIDB_NUMBLES}"
echo "tidb ip prefix: ${TIDB_IP_PREFIX}"
echo "tikv numbles: ${TIKV_NUMBLES}"
echo "tikv ip prefix: ${TIKV_IP_PREFIX}"
# ansible-playbook -i ./hosts site.yml -e target=azure -e role=test -e ansible_become_pass='PingCAP!23'

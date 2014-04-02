#!/usr/bin/env bash
#

environments=(lcl dev hlg prod);

function add_host(){
	ADD_HOST="$3";

	define_ip $2;

	handle_env_options $4;
}

function define_ip(){
	ADD_IP="$1";

	if valid_ip $ADD_IP; then stat='good'; else stat='bad'; fi
	printf "%-20s: %s\n" "$ADD_IP" "$stat";

	if [ $stat == "bad" ]; then die "INVALID IP"; fi
}

function host_add(){
	cmd_set_environment $ENVIRONMENT;
	echo "$ADD_IP $ADD_HOST";
	echo "$TOP_LEVEL_FOLDER/$FILE";
	echo "$ADD_IP $ADD_HOST" >> "$TOP_LEVEL_FOLDER/$FILE";
}

function list_host(){
	handle_env_options $2;
}


function hosts_list(){
	case $ENVIRONMENT in
      "all")  for environment in "${environments[@]}"; do
				ACTUAL_ENVIRONMENT="$environment";
				list;
			  done
       ;;
       *) ACTUAL_ENVIRONMENT="$ENVIRONMENT";
			list;
    esac
}

function list(){
	printf 	"################### $ACTUAL_ENVIRONMENT ################### \n";
	cmd_set_environment $ACTUAL_ENVIRONMENT;
	run_cmd "cat $TOP_LEVEL_FOLDER/$FILE" "silent";
	printf "\n"
}

function hosts_init(){
	FOLDER=$(pwd);
	HOSTS_FOLDER="$FOLDER/$HOST_DEFAULT_FOLDER";

	if [ ! -d "$HOSTS_FOLDER" ]; then
		initialize_hosts $HOSTS_FOLDER;
	else
		reinitialize_hosts $HOSTS_FOLDER;
	fi
}

function initialize_hosts(){
	echo "Initialized empty Hosts repository in $HOSTS_FOLDER" >&2
	run_cmd "mkdir $HOSTS_FOLDER" "silent";
	run_cmd "touch $HOSTS_FOLDER/hosts.lcl $HOSTS_FOLDER/hosts.dev $HOSTS_FOLDER/hosts.hml $HOSTS_FOLDER/hosts.prd" "silent";
}

function reinitialize_hosts(){
	echo "Reinitialized Hosts repository in $HOSTS_FOLDER" >&2
}

function edit_host(){
	handle_env_options $2;
}

function hosts_edit(){
	cmd_set_environment $ENVIRONMENT;
	run_cmd "$DEFAULT_IDE $TOP_LEVEL_FOLDER/$FILE" "silent";
}

function valid_ip(){
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

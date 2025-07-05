#!/usr/bin/env bash

set -euo pipefail

readonly _ARGS=("$@")

# used for loging
readonly green="\e[32m"
readonly yellow="\e[33m"
readonly red="\e[31m"
readonly purple="\033[95m"
readonly reset="\e[0m"

log() {
	local msg="$2"
	[[ ! -z "$msg" ]]

	local timestamp="[$(date +%H:%M:%S)]"

	local label=""
	local color=""
	case "$1" in
		e) label="[ERROR]" ; color="$red" ;;
		x) label="[EXIT]" ; color="$yellow" ;;
		d) label="[DEBUG]" ; color="$purple" ;;
		i) label="[INFO]" ; color="$green" ;;
	esac

	local log="$timestamp$color$label$reset $msg "
	echo -e "$log"

	log="$timestamp$label $msg "

	# if [[ -f ${_LOGFILE} ]]; then
	# 	echo "$log" >> ${_LOGFILE}
	# fi
}

usage() {
		cat <<EOF
NAME : arch-deploy
SYNOPSIS :
	arch-deploy [--config <CONFIG> ] [--help]

DESCRIPTION
	Deploy and configure any customized linux environment.

	--help
		display this screen

	--config <CONFIG>
		Set the config file to use (required)

	-c, --check
		Check the config file for valid format

AUTHOR
	Clément de la Genière
	2025
EOF
}

# convert_to_array() {
# 	local value="${1#*=}"
#
# 	readarray -t _CURRENT_ARRAY < <( printf "%s" "$value" | tr ":" "\n")
# }

arg_exists() {
	query="$1"

	if (( ${#_ARGS[@]} == 0 )); then
		return 1
	fi

	for i in "${!_ARGS[@]}"; do
		if [[ "${_ARGS[$i]}" == "$query" ]]; then
			return 0
		fi
		return 1
	done
}

get_next_arg() {
	query="$1"

	for i in "${!_ARGS[@]}"; do
		if [[ "${_ARGS[$i]}" == "$query" ]] && (( ${#_ARGS[@]} > $i + 1 )); then
			echo "${_ARGS[$i + 1]}"
			return
		fi
		return
	done
}

main() {

	# show help
	if arg_exists "--help" || (( ${#_ARGS[@]} == 0 )) ; then
		usage
		exit 0
	fi

	# get config
	if ! arg_exists "--config"; then
		log e "You must provide a config using --config"
		exit 1
	fi

	_CONFIG_FILE="$(get_next_arg "--config")"

	if ! [[ -f "$_CONFIG_FILE" ]]; then 
		log e "Not a config file : '$_CONFIG_FILE'"
		exit 1
	fi

	log i "Found config file '$_CONFIG_FILE'"

	checkConfig
	
	if arg_exists "--check" || arg_exists "-c"; then
		exit 0
	fi

	# while IFS= read -r current_line; do
	# 	# ignore comments
	#
	# 	_CURRENT_ARRAY=()
	# 	convert_to_array "$current_line"
	#
	# 	declare -p _CURRENT_ARRAY
	#
	# done < "$_CONFIG_FILE"
}

main

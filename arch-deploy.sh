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
		w) label="[WARNING]" ; color="$yellow" ;;
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

is_in_array() {
	query="$1"
	shift
	array=("$@")

	for item in "${array[@]}"; do
		[[ "$item" == "$query" ]] && return
	done
	return 1
}

get_next_arg() {
	query="$1"

	for ((i = 0; i < ${#_ARGS[@]} - 1; i++)); do
		if [[ "${_ARGS[$i]}" == "$query" ]]; then
			echo "${_ARGS[$i + 1]}"
			return
		fi
	done
}

check_config_syntax() {
	local current_line=""
	local line_nr=0
	seen_keys=()

	while IFS= read -r current_line; do
		line_nr=$(( line_nr + 1 ))

		local trimmed_line="$( echo "$current_line" | xargs)"

		# skip comments and blank lines
		if [[ "$trimmed_line" =~ ^# || -z "$trimmed_line" ]]; then
			continue;
		fi

		# check format
		if ! [[ "$trimmed_line" =~ ^[a-z][a-z_\ ]+=.*$ ]]; then
			log e "Config l${line_nr}: Invalid key/value pair"
			exit 1
		fi

		local trimmed_key="$(echo "$trimmed_line" | cut -d= -f1 | xargs)"
		local trimmed_value="$(echo "$trimmed_line" | cut -d= -f2 | xargs)"

		# check for duplicate
		if is_in_array "$trimmed_key" "${seen_keys[@]}"; then
			log w "Config l${line_nr}: Found duplicate key '$trimmed_key'"
		else
			seen_keys+=("$trimmed_key")
		fi

		if [[ "$trimmed_value" == *"::"* || "$trimmed_value" == *":" ]]; then
			log w "Config l${line_nr}: Extra separator in value"
		fi

		# log d "Config l${line_nr}: passing | k=${trimmed_key} v=${trimmed_value}"

	done < "$_CONFIG_FILE"
}

main() {

	# show help
	if (( ${#_ARGS[@]} == 0 )) || is_in_array "--help" "${_ARGS[@]}" ; then
		usage
		exit 0
	fi

	# get config
	if ! is_in_array "--config" "${_ARGS[@]}"; then
		log e "You must provide a config using --config"
		exit 1
	fi

	_CONFIG_FILE="$(get_next_arg "--config")"

	if ! [[ -f "$_CONFIG_FILE" ]]; then 
		log e "Not a config file : '$_CONFIG_FILE'"
		exit 1
	fi

	log i "Found config file '$_CONFIG_FILE'"

	check_config_syntax
	
	if is_in_array "--check" "${_ARGS[@]}" || is_in_array "-c" "${_ARGS[@]}"; then
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

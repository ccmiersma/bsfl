#!/bin/bash
# -*- tab-width: 4; encoding: utf-8 -*-

## @file
## @author Louwrentius <louwrentius@gmail.com>
## @author Jani Hurskainen
## @author Paul-Emmanuel Raoul <skyper@skyplabs.net>
## @copyright New BSD
## @brief Bash Shell Function Library
## @version 0.1.0

#
# Do not edit this file. Just source it into your script
# and override the variables to change their value.
#

## @par Purpose
## The Bash Shell Function Library (BSFL) is a small Bash script that acts as a library
## for bash scripts. It provides a couple of functions that makes the lives of most
## people using shell scripts a bit easier.


# Variables
# --------------------------------------------------------------#

## @var BSFL_VERSION
## @brief bsfl version number
declare -r BSFL_VERSION="0.1.0"

## @var DEBUG
## @brief Enables / disables debug mode.
## @details Debug mode shows more verbose output to screen and log files.
## Value: yes or no (y / n).
declare DEBUG="no"

## @var LOGDATEFORMAT
## @brief Sets the log data format (syslog style).
declare LOGDATEFORMAT="%b %e %H:%M:%S"

## @var LOG_FILE
## @brief Sets the log file to use when log are enabled.
declare LOG_FILE="$0.log"

## @var LOG_ENABLED
## @brief Enables / disables logging to a file.
## @details Value: yes or no (y / n).
declare LOG_ENABLED="no"

## @var SYSLOG_ENABLED
## @brief Enables / disables logging to syslog.
## @details Value: yes or no (y / n).
declare SYSLOG_ENABLED="no"

## @var SYSLOG_TAG
## @brief Tag to use with syslog.
## @details Value: yes or no (y / n).
declare SYSLOG_TAG="$0"

## @var START_WATCH
## @brief Internal use.
## @private
declare START_WATCH=""

## @var STACK
## @brief Internal use.
## @private
declare STACK

## @var TMP_STACK
## @brief Internal use.
## @private
declare TMP_STACK

## @var RED
## @brief Internal use.
## @private
declare -r RED="tput setaf 1"

## @var GREEN
## @brief Internal use.
## @private
declare -r GREEN="tput setaf 2"

## @var YELLOW
## @brief Internal use.
## @private
declare -r YELLOW="tput setaf 3"

## @var BLUE
## @brief Internal use.
## @private
declare -r BLUE="tput setaf 4"

## @var MAGENTA
## @brief Internal use.
## @private
declare -r MAGENTA="tput setaf 5"

## @var CYAN
## @brief Internal use.
## @private
declare -r CYAN="tput setaf 6"

## @var BOLD
## @brief Internal use.
## @private
declare -r BOLD="tput bold"

## @var DEFAULT
## @brief Internal use.
## @private
declare -r DEFAULT="tput sgr0"

## @var RED_BG
## @brief Internal use.
## @private
declare -r RED_BG="tput setab 1"

## @var GREEN_BG
## @brief Internal use.
## @private
declare -r GREEN_BG="tput setab 2"

## @var YELLOW_BG
## @brief Internal use.
## @private
declare -r YELLOW_BG="tput setab 3"

## @var BLUE_BG
## @brief Internal use.
## @private
declare -r BLUE_BG="tput setab 4"

## @var MAGENTA_BG
## @brief Internal use.
## @private
declare -r MAGENTA_BG="tput setab 5"

## @var CYAN_BG
## @brief Internal use.
## @private
declare -r CYAN_BG="tput setab 6"

# Configuration
# --------------------------------------------------------------#

# Bug fix for Bash, parsing exclamation mark.
set +o histexpand

# Functions
# --------------------------------------------------------------#

## @fn defined()
## @brief Tests if a variable is defined.
## @param variable Variable to test.
## @retval 0 if the variable is defined.
## @retval 1 in others cases.
defined() {
	[[ ${!1-X} == ${!1-Y} ]]
}

## @fn has_value()
## @brief Tests if a variable has a value.
## @param variable Variable to operate on.
## @retval 0 if the variable is defined (set) and value's length > 0.
## @retval 1 in others cases.
has_value() {
	if defined $1; then
		if [[ -n ${!1} ]]; then
			return 0
		fi
	fi
	return 1
}

## @fn directory_exists()
## @brief Tests if a directory exists.
## @param directory Directory to operate on.
## @retval 0 if a directory exists.
## @retval 1 in others cases.
directory_exists() {
	if [[ -d "$1" ]]; then
		return 0
	fi
	return 1
}

## @fn file_exists()
## @brief Tests if a file exists.
## @param file File to operate on.
## @retval 0 if a (regular) file exists.
## @retval 1 in others cases.
file_exists() {
	if [[ -f "$1" ]]; then
		return 0
	fi
	return 1
}

## @fn tolower()
## @brief Returns lowercase string.
## @param string String to operate on.
tolower() {
	echo "$1" | tr '[:upper:]' '[:lower:]'
}

## @fn toupper()
## @brief Returns uppercase string.
## @param string String to operate on.
toupper() {
	echo "$1" | tr '[:lower:]' '[:upper:]'
}

## @fn trim()
## @brief Returns the first part of a string, delimited by tabs or spaces.
## @param string String to operate on.
trim() {
	echo $1
}

## @fn show_usage()
## @brief Dummy function to provide usage instructions.
## Override this function if required.
## @param message Message to display.
## @retval 1 in all cases.
show_usage() {
	MESSAGE="$1"
	echo "$MESSAGE"
	exit 1
}

## @fn option_enabled()
## @brief Checks if a variable is set to "y" or "yes".
## Usefull for detecting if a configurable option is set or not.
## @param variable Variable to test.
## @retval 0 if the variable is set to "y" or "yes".
## @retval 1 in others cases.
option_enabled() {
	VAR="$1"
	VAR_VALUE=$(eval echo \$$VAR)
	if [[ "$VAR_VALUE" == "y" ]] || [[ "$VAR_VALUE" == "yes" ]]
	then
		return 0
	else
		return 1
	fi
}

## @fn log2syslog()
## @brief Logs a message with syslog.
## @param message Message that has to be logged.
log2syslog() {
	if option_enabled  SYSLOG_ENABLED
	then
		MESSAGE="$1"
		logger -t "$SYSLOG_TAG" " $MESSAGE" # The space is not a typo!
	fi
}

## @fn log()
## @brief Writes messages to a log file and/or syslog.
## @param message Message that has to be logged.
## @param status Message's status.
log() {
	if option_enabled LOG_ENABLED || option_enabled SYSLOG_ENABLED
	then
		LOG_MESSAGE="$1"
		STATE="$2"
		DATE=`date +"$LOGDATEFORMAT"`
		
		if has_value LOG_MESSAGE
		then
			LOG_STRING="$DATE $STATE - $LOG_MESSAGE"
		else
			LOG_STRING="$DATE -- empty log message, no input received --"
		fi
		
		if option_enabled LOG_ENABLED
		then
			echo "$LOG_STRING" >> "$LOG_FILE"
		fi
		
		if option_enabled SYSLOG_ENABLED
		then
			# Syslog already prepends a date/time stamp so only the message
			# is logged.
			log2syslog "$LOG_MESSAGE"
		fi
	fi
}

## @fn msg()
## @brief Replaces the 'echo' function in bash scripts.
## @details This function basically replaces the 'echo' function in bash scripts.
## The added functionality over echo is logging and using colors.
## @param string String / message that must be displayed.
## @param color Text color.
msg() {
	MESSAGE="$1"
	COLOR="$2"
	
	if ! has_value COLOR
	then
		COLOR="$DEFAULT"
	fi
	
	if has_value "MESSAGE"
	then
		$COLOR
		echo "$MESSAGE"
		$DEFAULT
		if ! option_enabled "DONOTLOG"
		then
			log "$MESSAGE"
		else
			echo "DONOTLOG is $DONOTLOG"
		fi
	else
		echo "-- no message received --"
		if ! option_enabled "DONOTLOG"
		then
			log "$MESSAGE"
		fi
	fi
}

## @fn log_status()
## @brief Logs a message with status.
## @details The log message is formatted with the status preceding the message.
## @param message Message that has to be logged.
## @param status Message's status.
log_status() {
	if option_enabled LOG_ENABLED
	then 
		MESSAGE="$1"
		STATUS="$2"
		
		log "$MESSAGE" "$STATUS"
	fi
}

## @fn log_emergency()
## @brief Logs a message with 'emergency' status.
## @param message Message that has to be logged.
log_emergency() {
	MESSAGE="$1"
	STATUS="EMERGENCY"
	log_status "$MESSAGE" "$STATUS"
}

## @fn log_alert()
## @brief Logs a message with 'alert' status.
## @param message Message that has to be logged.
log_alert() {
	MESSAGE="$1"
	STATUS="ALERT"
	log_status "$MESSAGE" "$STATUS"
}

## @fn log_critical()
## @brief Logs a message with 'critical' status.
## @param message Message that has to be logged.
log_critical() {
	MESSAGE="$1"
	STATUS="CRITICAL"
	log_status "$MESSAGE" "$STATUS"
}

## @fn log_error()
## @brief Logs a message with 'error' status.
## @param message Message that has to be logged.
log_error() {
	MESSAGE="$1"
	STATUS="ERROR"
	log_status "$MESSAGE" "$STATUS"
}

## @fn log_warning()
## @brief Logs a message with 'warning' status.
## @param message Message that has to be logged.
log_warning() {
	MESSAGE="$1"
	STATUS="WARNING"
	log_status "$MESSAGE" "$STATUS"
}

## @fn log_notice()
## @brief Logs a message with 'notice' status.
## @param message Message that has to be logged.
log_notice() {
	MESSAGE="$1"
	STATUS="NOTICE"
	log_status "$MESSAGE" "$STATUS"
}

## @fn log_info()
## @brief Logs a message with 'info' status.
## @param message Message that has to be logged.
log_info() {
	MESSAGE="$1"
	STATUS="INFO"
	log_status "$MESSAGE" "$STATUS"
}

## @fn log_debug()
## @brief Logs a message with 'debug' status.
## @param message Message that has to be logged.
log_debug() {
	MESSAGE="$1"
	STATUS="DEBUG"
	log_status "$MESSAGE" "$STATUS"
}

## @fn log_ok()
## @brief Logs a message with 'ok' status.
## @param message Message that has to be logged.
log_ok() {
	MESSAGE="$1"
	STATUS="OK"
	log_status "$MESSAGE" "$STATUS"
}

## @fn log_not_ok()
## @brief Logs a message with 'not ok' status.
## @param message Message that has to be logged.
log_not_ok() {
	MESSAGE="$1"
	STATUS="NOT_OK"
	log_status "$MESSAGE" "$STATUS"
}

## @fn log_failed()
## @brief Logs a message with 'failed' status.
## @param message Message that has to be logged.
log_failed() {
	MESSAGE="$1"
	STATUS="FAILED"
	log_status "$MESSAGE" "$STATUS"
}

## @fn log_success()
## @brief Logs a message with 'success' status.
## @param message Message that has to be logged.
log_success() {
	MESSAGE="$1"
	STATUS="SUCCESS"
	log_status "$MESSAGE" "$STATUS"
}

## @fn log_passed()
## @brief Logs a message with 'passed' status.
## @param message Message that has to be logged.
log_passed() {
	MESSAGE="$1"
	STATUS="PASSED"
	log_status "$MESSAGE" "$STATUS"
}

## @fn msg_status()
## @brief Displays a message with its status at the end of the line.
## @details It can be used to create status messages other
## than the default messages available such as OK or FAIL.
## @param message Message to display.
## @param status Message's status.
msg_status() {
	MESSAGE="$1"
	STATUS="$2"
	
	export DONOTLOG="yes"
	log_status "$MESSAGE" "$STATUS"
	msg "$MESSAGE"
	display_status "$STATUS"
	export DONOTLOG="no"
}

## @fn msg_emergency()
## @brief Displays a message with 'emergency' status.
## @param message Message that has to be displayed.
msg_emergency() {
	MESSAGE="$1"
	STATUS="EMERGENCY"
	msg_status "$MESSAGE" "$STATUS"
}

## @fn msg_alert()
## @brief Displays a message with 'alert' status.
## @param message Message that has to be displayed.
msg_alert() {
	MESSAGE="$1"
	STATUS="ALERT"
	msg_status "$MESSAGE" "$STATUS"
}

## @fn msg_critical()
## @brief Displays a message with 'critical' status.
## @param message Message that has to be displayed.
msg_critical() {
	MESSAGE="$1"
	STATUS="CRITICAL"
	msg_status "$MESSAGE" "$STATUS"
}

## @fn msg_error()
## @brief Displays a message with 'error' status.
## @param message Message that has to be displayed.
msg_error() {
	MESSAGE="$1"
	STATUS="ERROR"
	msg_status "$MESSAGE" "$STATUS"
}

## @fn msg_warning()
## @brief Displays a message with 'warning' status.
## @param message Message that has to be displayed.
msg_warning() {
	MESSAGE="$1"
	STATUS="WARNING"
	msg_status "$MESSAGE" "$STATUS"
}

## @fn msg_notice()
## @brief Displays a message with 'notice' status.
## @param message Message that has to be displayed.
msg_notice() {
	MESSAGE="$1"
	STATUS="NOTICE"
	msg_status "$MESSAGE" "$STATUS"
}

## @fn msg_info()
## @brief Displays a message with 'info' status.
## @param message Message that has to be displayed.
msg_info() {
	MESSAGE="$1"
	STATUS="INFO"
	msg_status "$MESSAGE" "$STATUS"
}

## @fn msg_debug()
## @brief Displays a message with 'debug' status.
## @param message Message that has to be displayed.
msg_debug() {
	MESSAGE="$1"
	STATUS="DEBUG"
	msg_status "$MESSAGE" "$STATUS"
}

## @fn msg_ok()
## @brief Displays a message with 'ok' status.
## @param message Message that has to be displayed.
msg_ok() {
	MESSAGE="$1"
	STATUS="OK"
	msg_status "$MESSAGE" "$STATUS"
}

## @fn msg_not_ok()
## @brief Displays a message with 'not ok' status.
## @param message Message that has to be displayed.
msg_not_ok() {
	MESSAGE="$1"
	STATUS="NOT_OK"
	msg_status "$MESSAGE" "$STATUS"
}

## @fn msg_failed()
## @brief Displays a message with 'failed' status.
## @param message Message that has to be displayed.
msg_failed() {
	MESSAGE="$1"
	STATUS="FAILED"
	msg_status "$MESSAGE" "$STATUS"
}

## @fn msg_success()
## @brief Displays a message with 'success' status.
## @param message Message that has to be displayed.
msg_success() {
	MESSAGE="$1"
	STATUS="SUCCESS"
	msg_status "$MESSAGE" "$STATUS"
}

## @fn msg_passed()
## @brief Displays a message with 'passed' status.
## @param message Message that has to be displayed.
msg_passed() {
	MESSAGE="$1"
	STATUS="PASSED"
	msg_status "$MESSAGE" "$STATUS"
}

## @fn check_status()
## @brief Checks the command's status and displays it.
## @param command
## @param status
check_status() {
	CMD="$1"
	STATUS="$2"
	
	if [ "$STATUS" == "0" ]
	then
		msg_ok "$CMD"
	else
		msg_failed "$CMD"
	fi
}

## @fn raw_status()
## @brief Internal use.
## @private
## @details This is a function that just positions
## the cursor one row up and to the right.
## It then prints a message with specified color.
## It is used for displaying colored status messages on the
## right side of the screen.
## @param status Status message (OK / FAIL).
## @param color The color in which the status is displayed.
raw_status() {
	STATUS="$1"
	COLOR="$2"
	
	position_cursor () {
		let RES_COL=`tput cols`-12
		tput cuf $RES_COL
		tput cuu1
    }
	
	position_cursor
	echo -n "["
	$DEFAULT
	$BOLD
	$COLOR
	echo -n "$STATUS"
	$DEFAULT
	echo "]"
}

## @fn display_status()
## @brief Converts a status message to a particular color.
## @param status Status message.
display_status() {
	STATUS="$1"
	
	case $STATUS in
		EMERGENCY )
			STATUS="EMERGENCY"
			COLOR="$RED"
			;;
		ALERT )
			STATUS="  ALERT  "
			COLOR="$RED"
			;;
		CRITICAL )
			STATUS="CRITICAL "
			COLOR="$RED"
			;;
		ERROR )
			STATUS="  ERROR  " 
			COLOR="$RED"
			;;
		WARNING )
			STATUS=" WARNING "  
			COLOR="$YELLOW"
			;;
		NOTICE )
			STATUS=" NOTICE  "  
			COLOR="$BLUE"
			;;
		INFO )
			STATUS="  INFO   "  
			COLOR="$CYAN"
			;;
		DEBUG )
			STATUS="  DEBUG  "
			COLOR="$DEFAULT"
			;;    
		OK  ) 
			STATUS="   OK    "  
			COLOR="$GREEN"
			;;
		NOT_OK)
			STATUS=" NOT OK  "
			COLOR="$RED"
			;;
		PASSED ) 
			STATUS=" PASSED  "  
			COLOR="$GREEN"
			;;
		SUCCESS ) 
			STATUS=" SUCCESS "  
			COLOR="$GREEN"
			;;
		FAILURE | FAILED )
			STATUS=" FAILED  "  
			COLOR="$RED"
			;;
		*)
			STATUS="UNDEFINED"
			COLOR="$YELLOW"
	esac
	
	raw_status "$STATUS" "$COLOR"
}

## @fn bail()
## @brief Exits with error status.
## @param message Error message.
## @return Error status.
bail() {
	ERROR="$?"
	MSG="$1"
	if [ ! "$ERROR" = "0" ]
	then
		msg_failed "$MSG"
		exit "$ERROR"
	fi
}

## @fn cmd()
## @brief Executes a command and displays if it succeeded or not.
## @param command Command to execute.
## @return Error status.
cmd() {
	COMMAND="$1"
	msg "Executing: $COMMAND"
	
	RESULT=`$COMMAND 2>&1`
	ERROR="$?"
	
	MSG="Command: ${COMMAND:0:29}..."
    
	tput cuu1
	
	if [ "$ERROR" == "0" ]
	then
		msg_ok "$MSG"
		if option_enabled DEBUG
		then
			msg "$RESULT"
		fi
	else
		msg_failed "$MSG"
		log "$RESULT"
	fi
	
	return "$ERROR"
}

## @fn now()
## @brief Displays current timestamp.
now() {
	echo $(date +%s)
}

## @fn elapsed()
## @brief Displays the time elapsed between start and stop parameters.
## @param start Start timestamp.
## @param stop Stop timestamp.
elapsed() {
	START="$1"
	STOP="$2"
	
	ELAPSED=$(( STOP - START ))
	echo $ELAPSED
}

## @fn start_watch()
## @brief Starts the watch.
start_watch() {
	START_WATCH=`now`
}

## @fn stop_watch()
## @brief Stops the watch and displays the time elapsed.
## @retval 0 if succeed.
## @retval 1 if the watch has not been started.
stop_watch() {
	if has_value START_WATCH
	then
		STOP_WATCH=`now`
		elapsed "$START_WATCH" "$STOP_WATCH"
		return 0
	else
		return 1
	fi
}

## @fn die()
## @brief Prints an error message to stderr and exits
## with the return code. The message is also logged.
## @param errcode Error code.
## @param errmsg Error message.
## @return Error code given as parameter.
die() {
	local -r err_code="$1"
	local -r err_msg="$2"
	local -r err_caller="${3:-$(caller 0)}"
	
	msg_failed "ERROR: $err_msg"
	msg_failed "ERROR: At line $err_caller"
	msg_failed "ERROR: Error code = $err_code"
	exit "$err_code"
} >&2 # function writes to stderr

## @fn die_if_false()
## @brief If error code is not '0', displays an error
## message and exits.
## @details Checks if a return code indicates an error
## and prints an error message to stderr and exits with
## the return code. The error is also logged.
## Die if error code is false.
## @param errcode Error code.
## @param errmsg Error message.
## @return Error code given as parameter.
die_if_false() {
	local -r err_code=$1
	local -r err_msg=$2
	local -r err_caller=$(caller 0)
	
	if [[ "$err_code" != "0" ]]
	then
		die $err_code "$err_msg" "$err_caller"
	fi
} >&2 # function writes to stderr

## @fn die_if_true()
## @brief If error code is '0', displays an error
## message and exits.
## @details Checks if a return code is '0' and prints
## an error message to stderr and exits with the
## return code. The error is also logged.
## Die if error code is false.
## @param errcode Error code.
## @param errmsg Error message.
## @return Error code given as parameter.
die_if_true() {
	local -r err_code=$1
	local -r err_msg=$2
	local -r err_caller=$(caller 0)
	
	if [[ "$err_code" == "0" ]]
	then
		die $err_code "$err_msg" "$err_caller"
	fi
} >&2 # function writes to stderr

## @fn __bsfl_array_append()
## @brief Internal use.
## @private
## @param name Array name.
## @param item Item to append.
__bsfl_array_append() {
	echo -n 'eval '
	echo -n "$1" # array name
	echo -n '=( "${'
	echo -n "$1"
	echo -n '[@]}" "'
	echo -n "$2" # item to append
	echo -n '" )'
}

## @fn __bsfl_array_append_first()
## @brief Internal use.
## @private
## @param name Array name.
## @param item Item to append.
__bsfl_array_append_first() {
    echo -n 'eval '
    echo -n "$1" # array name
    echo -n '=( '
    echo -n "$2" # item to append
    echo -n ' )'
}

## @fn __bsfl_array_len()
## @brief Internal use.
## @private
## @param name Array name.
## @param item Item to append.
__bsfl_array_len() {
	echo -n 'eval local '
	echo -n "$1" # variable name
	echo -n '=${#'
	echo -n "$2" # array name
	echo -n '[@]}'
}

## @fn array_append()
## @brief Appends one or more items to an array.
## @details If the array does not exist, this function will create it.
## @param array Array to operate on.
array_append() {
	local array=$1; shift 1
	
	$(__bsfl_array_len len $array)
	
	if (( len == 0 )); then
		$(__bsfl_array_append_first $array "$1" )
		shift 1
	fi
	
	local i
	for i in "$@"; do
		$(__bsfl_array_append $array "$i")
	done
}

## @fn array_size()
## @brief Returns the size of an array.
## @param array Array to operate on.
array_size() {
	$(__bsfl_array_len size $1)
	echo "$size"
}

## @fn array_print()
## @brief Prints the contents of an array.
## @param array Array to operate on.
array_print() {
	eval "printf '%s\n' \"\${$1[@]}\""
}

## @fn str_replace()
## @brief Replaces some text inside a string.
## @param origin String to be matched.
## @param destination New string that replaces matched string.
## @param data Data to operate on.
str_replace() {
	local ORIG="$1"
	local DEST="$2"
	local DATA="$3"
	
	echo "$DATA" | sed "s/$ORIG/$DEST/g"
}

## @fn __stack_push_tmp()
## @brief Internal use.
## @private
## @param item Item to add on the temporary stack.
__stack_push_tmp() {
	local TMP="$1"
	
	if has_value TMP_STACK
	then
		TMP_STACK="$TMP"
	else
		TMP_STACK="$TMP_STACK"$'\n'"$TMP"
	fi
}

## @fn stack_push()
## @brief Adds item on the stack.
## @param item Item to add on the stack.
stack_push() {
	line="$1"
	
	if has_value $STACK
	then
		STACK="$line"
	else
		STACK="$line"$'\n'"$STACK"
	fi
}

## @fn stack_pop()
## @brief Moves the highest item of the stack in REGISTER variable
## and deletes it from the stack.
## @retval 0 if succeed.
## @retval 1 in others cases.
stack_pop() {
	TMP_STACK=""
	i=0
	tmp=""
	for x in $STACK
	do
		if [ "$i" == "0" ]
		then
			tmp="$x"
		else
			__stack_push_tmp "$x"
		fi
		((i++))
	done
	STACK="$TMP_STACK"
	REGISTER="$tmp"
	if [ -z "$REGISTER" ]
	then
		return 1
	else
		return 0
	fi
}

## @fn str_replace_in_file()
## @brief Replaces string of text in file.
## @param origin String to be matched.
## @param destination New string that replaces matched string.
## @param file File to operate on.
## @retval 0 if succeed.
str_replace_in_file() {
	local ORIG="$1"
	local DEST="$2"
	local FILE="$3"
	
	has_value FILE
	die_if_false $? "Empty argument 'file'"
	file_exists "$FILE"
	die_if_false $? "File does not exist"
	
	printf ",s/$ORIG/$DEST/g\nw\nQ" | ed -s "$FILE" > /dev/null 2>&1
	return "$?"
}
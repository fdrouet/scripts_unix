#!/bin/bash
### Utilities functions for Logging ###
# 
### FUNCTIONS LIST
#> log_trace (<Str to log>)
#> log_info (<Str to log>)
#> log_error (<Str to log>)
### LOG OUTPUT FORMAT
#> # <YYYYMMDD-HHMMSS> # <[TRACE|INFO|ERROR]> # <the log message>

## main function for logging
#> $1 : level of the log
#> $2 : the string to log
function _internal_log { echo "# "$(date +%Y%m%d-%H%M%S)" # "$1" # "$2; }
## TRACE LOGGING
#> $1 : the string to log
function log_trace { _internal_log "TRACE" "$1"; }
## INFO LOGGING
#> $1 : the string to log
function log_info { _internal_log "INFO " "$1"; }
## ERROR LOGGING
#> $1 : the string to log
function log_error { _internal_log "ERROR" "$1"; }

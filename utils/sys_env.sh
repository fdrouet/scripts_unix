#!/bin/bash
### Utilities functions for System ###
# 
### FUNCTIONS LIST
#> log_trace (<Str to log>)
#> log_info (<Str to log>)
#> log_error (<Str to log>)
### LOG OUTPUT FORMAT
#> # <YYYYMMDD-HHMMSS> # <[TRACE|INFO|ERROR]> # <the log message>

# OS specific support.  $var _must_ be set to either true or false.
cygwin=false
os400=false
darwin=false
case "`uname`" in
CYGWIN*) cygwin=true;;
OS400*) os400=true;;
Darwin*) darwin=true;;
esac

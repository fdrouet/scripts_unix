#!/bin/sh
#
# $Id$
#
# Copyright (C) 2003-2010 eXo Platform SAS.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see<http://www.gnu.org/licenses/>.
#
#
# Purpose : launch dacapo benchmarks
#

COLORIZED=false

usage() {
cat << EOF
usage: $0 options

This script launch DaCapo Benchmarks with a predifined test configuration
and print the result on the stdout.

OPTIONS:
   -h      Show this message
   -j      Path to the JAVA_HOME directory to use
           (ex: /app/runtimes/java/JAVA_6)
   -c      add color to the output of the script (default=$COLORIZED)
           
   
EOF
}

red='\E[31;40m'
green='\E[32;40m'
yellow='\E[33;40m'
cecho () {
  local default_msg="No message passed."
  message=${1:-$default_msg}   # Defaults to default message.
  color=${2:-$black}           # Defaults to black, if not specified.
  if [ "$COLORIZED" == "true" ]; then
    printf "$color$message\n"; tput sgr0
  else
    printf "$message\n"
  fi
#  echo "$message"; tput sgr0
#  return
}
echo_red () {
  cecho "$1" $red
}
echo_green () {
  cecho "$1" $green
}
echo_yellow () {
  cecho "$1" $yellow
}


while getopts "cj:" OPTION
do
    case $OPTION in
        h)
            usage
            exit 1
            ;;
        c)
            COLORIZED=true
            ;;
        j)
            if [ -x "$OPTARG/bin/java" ]; then
              JAVA_HOME=$OPTARG
            else
              echo_red "#ERROR# the -j parameter value is not a valid JAVA_HOME path"
              echo_red "        $OPTARG"
              exit 1
            fi
            ;;
        *)
            echo_red "#ERROR# unknow argument : ($OPTIND) - $OPTION = $OPTARG"
            exit 1
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done

if [ ! -z "$WORKSPACE" ]; then
  BASE_DIR=$WORKSPACE
else
  BASE_DIR=`dirname $0`
fi


if [ ! -z "$JAVA_HOME" ]; then
  JAVA_PATH=$JAVA_HOME"/bin/java"
else
  JAVA_PATH=`which java`
fi

# which Java version
#JAVA_VERSION="`$JAVA_PATH -version 2>&1`"
JAVA_VERSION=$(java -version 2>&1 | awk 'NR==1{print $3}')
JAVA_VERSION=$(java -version 2>&1 | awk 'NR==1{print $3}')


echo_yellow "######################################################################################"
echo_yellow "# DaCapo Benchmark 9.12 ...                                                          #"
echo_yellow "######################################################################################"
echo_yellow "# "
echo_yellow "# JAVA VERSION = "$($JAVA_PATH -version 2>&1 | awk 'NR==1{print $3}')
echo_yellow "#                 $($JAVA_PATH -version 2>&1 | awk 'NR==3{print $0}')"
echo_yellow "# JAVA_HOME    = "$JAVA_HOME
echo_yellow "# JAVA PATH    = "$JAVA_PATH
echo_yellow "# WORKSPACE    = "$BASE_DIR
echo_yellow "# "
echo_yellow "######################################################################################"

if [ ! -f $BASE_DIR/dacapo-9.12-bach.jar ]; then
  echo_yellow "Downloading dacapo-9.12 bench..."
  curl -L http://downloads.sourceforge.net/project/dacapobench/9.12-bach/dacapo-9.12-bach.jar -o $BASE_DIR/dacapo-9.12-bach.jar
fi


benchme() {
  local COUNT=$1
  local BENCH=$2

  rm -f dacapo-bench-$BENCH.log
#  echo "benching dacapo-9.12 - $BENCH - $COUNT iterations at `date`"
  $JAVA_PATH $JAVA_OPTS -jar $BASE_DIR/dacapo-9.12-bach.jar -n $COUNT $BENCH >>dacapo-bench-$BENCH.log 2>&1
  cat dacapo-bench-$BENCH.log | grep PASSED
}

benchme 10 avrora
benchme  2 eclipse
benchme 10 fop
benchme  2 h2
benchme  2 jython
benchme 10 luindex
benchme 10 lusearch
benchme 10 pmd
benchme 10 sunflow
benchme  5 tomcat
benchme  5 tradebeans
benchme  5 tradesoap
benchme 10 xalan

echo_yellow "# "
echo_yellow "######################################################################################"

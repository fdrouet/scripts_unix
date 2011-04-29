#!/bin/sh
#
# $Id$
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

# Default settings
JAVA_OPTS="-Xms128m -Xmx512m"
COLORIZED=false
WORKSPACE=`dirname $0`

usage() {
cat << EOF
usage: $0 options

This script launch DaCapo benchmarks with a predifined test configuration
and print the result on the stdout.

More infos about DaCapo benchmark suite : http://www.dacapobench.org/

OPTIONS:
   -h      Show this message

   -j      Path to the JAVA_HOME directory to use
           (ex: /app/runtimes/java/JAVA_6)

   -o      the JAVA_OPTS you want to use for the bench 
           (default: "$JAVA_OPTS")
           (ex: "-server -Xms128m -Xmx512m")

   -c      add color to the output of the script 
           (default: "$COLORIZED")

   -w      specify the working directory for the script
           the directory must exist and writable.
           (default: "$WORKSPACE")
   
EOF
}

red='\E[31;40m'
green='\E[32;40m'
yellow='\E[33;40m'
cecho () {
  local default_msg="No message passed."
  message=${1:-$default_msg}   # Defaults to default message.
  color=${2:-$black}           # Defaults to black, if not specified.
  if [ "$COLORIZED" = "true" ]; then
    printf "$color$message\n"; tput sgr0
  else
    printf "$message\n"
  fi
# echo "$message"; tput sgr0
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


while getopts "hcj:w:o:" OPTION
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
        o)
            JAVA_OPTS="$OPTARG"
            ;;
        w)
            WORKSPACE="$OPTARG"
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

# Check the workspace
if [ ! -d "$WORKSPACE" ]; then
	echo_red "#ERROR# the workspace directory must exist"
	echo_red "        $WORKSPACE"
	exit 1
elif [ ! -w "$WORKSPACE" ]; then
	echo_red "#ERROR# the workspace directory must be writable"
	echo_red "        $WORKSPACE"
	exit 1
fi

# Check the java settings
if [ ! -z "$JAVA_HOME" ]; then
  JAVA_PATH=$JAVA_HOME"/bin/java"
else
  JAVA_PATH=`which java`
fi

JVM_VERSION_STR=$($JAVA_PATH $JAVA_OPTS -version 2>&1)

echo_yellow "######################################################################################"
echo_yellow "# DaCapo Benchmark 9.12 ...                                                          #"
echo_yellow "######################################################################################"
echo_yellow "# "
echo_yellow "# HOSTNAME     = $(hostname -s)"
echo_yellow "# SYSTEM       = $(uname -a)"
echo_yellow "# "
echo_yellow "# JAVA VERSION = $(echo "$JVM_VERSION_STR" | awk 'NR==1{print $3}')"
echo_yellow "#                $(echo "$JVM_VERSION_STR" | awk 'NR==2{print $0}')"
echo_yellow "#                $(echo "$JVM_VERSION_STR" | awk 'NR==3{print $0}')"
echo_yellow "# JAVA_HOME    = $JAVA_HOME"
echo_yellow "# JAVA PATH    = $JAVA_PATH"
echo_yellow "# JAVA OPTS    = $JAVA_OPTS"
echo_yellow "# "
echo_yellow "# WORKSPACE    = $WORKSPACE"
echo_yellow "# "
echo_yellow "######################################################################################"
#exit 1

if [ ! -f $WORKSPACE/dacapo-9.12-bach.jar ]; then
  echo_yellow "Downloading dacapo-9.12 bench..."
  curl -L http://downloads.sourceforge.net/project/dacapobench/9.12-bach/dacapo-9.12-bach.jar -o $WORKSPACE/dacapo-9.12-bach.jar
fi


benchme() {
  local COUNT=$1
  local BENCH=$2

  rm -f $WORKSPACE/dacapo-bench-$BENCH.log
#  echo "benching dacapo-9.12 - $BENCH - $COUNT iterations at `date`"
  $JAVA_PATH $JAVA_OPTS -jar $WORKSPACE/dacapo-9.12-bach.jar -n $COUNT $BENCH >> $WORKSPACE/dacapo-bench-$BENCH.log 2>&1
  cat $WORKSPACE/dacapo-bench-$BENCH.log | grep PASSED
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

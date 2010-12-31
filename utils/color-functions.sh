#!/bin/bash
# This script give some functions to color the output of your shell script
## echo_r "message" (Text RED    + Background black)
## echo_g "message" (Text GREEN  + Background black)
## echo_y "message" (Text YELLOW + Background black)

# Color the script output
BLACK='\E[30;40m'            # Text white + Background black
RED='\E[31;40m'              # Text red + Background black
GREEN='\E[32;40m'            # Text green + Background black
YELLOW='\E[33;40m'           # Text yellow + Background black
# $1 : the message
# $2 : the color
colored_echo () {
  local default_msg="ERROR: No message passed."
  message=${1:-$default_msg}   # Defaults to default message.
  color=${2:-$BLACK}           # Defaults to black, if not specified.
  #echo -e "$color"
  printf "$color"
  printf "$message\n"; tput sgr0   # echo the message and reset the terminal color
  return
}

echo_r () {
  colored_echo "$1" $RED
}
echo_g () {
  colored_echo "$1" $GREEN
}
echo_y () {
  colored_echo "$1" $YELLOW
}


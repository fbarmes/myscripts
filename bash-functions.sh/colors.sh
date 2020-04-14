#!/usr/bin/env bash


#-------------------------------------------------------------------------------
# COLORS
#-------------------------------------------------------------------------------
declare -r NC='\033[0m'

declare -r BOLD='\033[1m'
declare -r DIM='\033[2m'
declare -r UNDERLINED='\033[4m'
declare -r BLINK='\033[5m'
declare -r INVERT='\033[7m'
declare -r HIDDEN='\033[8m'

declare -r RED='\033[0;31m'
declare -r GREEN='\033[0;32m'
declare -r BLACK='\033[0;30m'
declare -r YELLOW='\033[0;33m'
declare -r BLUE='\033[0;34m'
declare -r MAGENTA='\033[0;35m'
declare -r CYAN='\033[0;36m'



cat << 'EOM'

_               _                 _
| |             | |               | |
| |__   __ _ ___| |__     ___ ___ | | ___  _ __ ___
| '_ \ / _` / __| '_ \   / __/ _ \| |/ _ \| '__/ __|
| |_) | (_| \__ \ | | | | (_| (_) | | (_) | |  \__ \
|_.__/ \__,_|___/_| |_|  \___\___/|_|\___/|_|  |___/



EOM


# FORMATTING
echo -e "\n\n"
echo -e "=========================="
echo -e "FORMATTING"
echo -e "=========================="
for format in BOLD DIM UNDERLINED BLINK INVERT HIDDEN ; do
  echo -e "${format} : ${!format}lorem ipsum dolor Sit amet${NC}"
done


# COLORS
echo -e "\n\n"
echo -e "=========================="
echo -e "COLORS"
echo -e "=========================="

for format in RED GREEN BLACK YELLOW BLUE MAGENTA CYAN ; do
  echo -e "${format} : ${!format}lorem ipsum dolor Sit amet${NC}"
done

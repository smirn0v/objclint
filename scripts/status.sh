#!/bin/sh

red=1
white=7
green=2
ACTION_SYMBOL="*"
ACTION_COLOR=$green
DESCRIPTION_COLOR=$white
INDENT=0

argv=("$@")
i=0
while test $i -lt $# ; do

    arg="${argv[$i]}"
    case "$arg" in
        -e|--error) ACTION_SYMBOL="-"; ACTION_COLOR=$red; DESCRIPTION_COLOR=$red;;
        -i|--indent) i=$((i+1)); INDENT=${argv[$i]};;
    esac

    i=$((i + 1))
done

# [*] Description
tput bold
printf "["
tput setaf ${ACTION_COLOR}
printf "${ACTION_SYMBOL}"
tput init; tput bold
printf "] "
tput init; tput setaf ${DESCRIPTION_COLOR}

if [ $INDENT -ne 0 ]; then 
    printf '=%.0s' $(eval echo {1..$INDENT}); 
    printf " "
fi

echo "${argv[$# - 1]}"

tput init

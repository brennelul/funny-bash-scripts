#!/bin/bash

function sort_by_code {
    awk '{print $9 " " $4 "|" $0}' $1 | sort -n -k1,2 | cut -d'|' -f2-
}

function get_unique_ip {
    awk '!seen[$1]++ {print $1}' $1
}

function error_codes {
    awk '$9 ~ /4[0-9][0-9]|[5][0-9][0-9]/ {print $0}' $1
}

function get_unique_ip_with_error {
    awk '$9 ~ /4[0-9][0-9]|[5][0-9][0-9]/ && !seen[$1]++ {print $1}' $1
}

flag=1

if [ $# -ne 1 ]; then
    echo "script requires an argument"
elif ! [[ $1 =~ ^-?[0-9]+$ ]] || [ $1 -le 0 ] || [ $1 -gt 4 ]; then
    echo "option between 1 to 4"
    echo "1. show every record sorted by return code"
    echo "2. show every unique IP"
    echo "3. show every record with errors (4xx/5xx)"
    echo "4. show every unique IP with error request"
else
    flag=0
fi

if [ $flag -gt 0 ]; then
    exit 1
fi

read -p "Enter path to the log file: " path

if ! [ -f "$path" ]; then
    echo "file not found"
    exit 1
fi

if [ $1 -eq 1 ]; then
    sort_by_code $path
elif [ $1 -eq 2 ]; then
    get_unique_ip $path
elif [ $1 -eq 3 ]; then
    error_codes $path
else
    get_unique_ip_with_error $path
fi
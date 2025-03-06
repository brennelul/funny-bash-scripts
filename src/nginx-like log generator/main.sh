#!/bin/bash

. ./rand.sh

function generate_log {
    date=$1
    logfile="$(echo ${date//"/"/"_"} | cut -d ':' -f 1).log"

    touch $logfile
    
    numoflines=$((RANDOM % 900 + 100))

    generate_date_n_time_list $date $numoflines

    for((i = 0; i < $numoflines; i++)); do
        return_code=$(get_random_return_code)
        if [[ "$return_code" =~ ^(500|501|502|503)$ ]]; then
            bytes=0
        else
            bytes=$(generate_bytes)
        fi
        echo "$(generate_ip_address) - - [${sorted_dates[$i]}] \"$(get_random_method) $(get_random_location) HTTP/1.1\" $return_code $bytes \"$(get_random_agent)\"" >> $logfile
    done
}

gen_date=$(generate_date)

for((j = 0; j < 5; j++)); do
    generate_log $gen_date
    gen_date_seconds=$(date -d "${gen_date//"/"/""}" +%s)
    gen_date=$(date "+%d/%b/%Y" -d "@$((gen_date_seconds + 86400))")
done

echo "Done!"
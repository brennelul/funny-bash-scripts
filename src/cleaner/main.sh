#!/bin/bash

writable_dirs=()

function get_all_paths {
    local dirs=()
    mapfile -t dirs < <(find / -maxdepth 5 -type d ! -path "/"  \( -path "/dev" -o -path "/wsl*"  -o -path "/boot" -o -path "/root" -o -path "*/bin" -o -path "*/sbin" -o -path "/proc" -o -path "/lost+found" -o -path "/mnt" -o -path "/sys" -o -path "/run" -o -path "/etc" -o -path "/var" -o -path "/opt" -o -path "/tmp" \) -prune -o -print)

    for dir in "${dirs[@]}"; do
        if [ -w "$dir" ] && [ -d "$dir" ] ; then
            writable_dirs+=("$dir")
        fi
    done
}

flag=1

if [[ ! $1 =~ ^[1-3]$ ]]; then
    echo "first argument requires option between 1 to 3"
    echo "1. clean by log file"
    echo "2. clean by creation date (example: $(date '+%Y-%m-%d %H:%M') $(date '+%Y-%m-%d %H:%M'))"
    echo "3. clean by name wildcard (example: az_291224)"
elif [ $1 -ne 2 ] && [ $# -ne 2 ]; then
    echo "script requires 2 args in this mode"
elif [ $1 -eq 2 ] && [ $# -ne 5 ]; then
    echo "script requires 5 args in this mode"
else
    flag=0
fi

if [ $flag -gt 0 ]; then
    exit 1
fi

if [ $1 -eq 1 ]; then
    if [ -f $2 ]; then
        while IFS= read -r line; do
            dir=$(echo "$line" | grep "DIR" | awk '{print $NF"/"$(NF-2)}')
            if [ -d "$dir" ]; then
                rm -rf "$dir"
                echo "$dir and its contents deleted" 
            fi
        done < "$2"
    else
        echo "this is not a file"
        exit 1
    fi
elif [ $1 -eq 2 ]; then
    if [[ $2 =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && [[ $3 =~ ^[0-9]{2}:[0-9]{2}$ ]] && [[ $4 =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && [[ $5 =~ ^[0-9]{2}:[0-9]{2}$ ]]; then
        date1=$(date -d "$2 $3" +"%s")
        date2=$(date -d "$4 $5" +"%s")
        get_all_paths
        for dir in "${writable_dirs[@]}"; do
            dirdate=$(stat -c %W $dir)
            if [[ $dirdate -ge $date1 && $dirdate -le $date2 ]]; then
                rm -rf $dir
                echo "$dir and its contents deleted" 
            fi
        done
    else 
        echo "wrong format"
        exit 1
    fi
elif [ $1 -eq 3 ]; then
    if [[ $2 =~ ^[a-zA-Z]{1,7}_[0-9]{6}$ ]]; then
        get_all_paths
        part1=$(echo $2 | cut -d '_' -f 1)
        part2=$(echo $2 | cut -d '_' -f 2)
        for dir in "${writable_dirs[@]}"; do
            if [[ ${dir##*/} =~ ^[$part1]+_$part2$ ]]; then
                rm -rf $dir
                echo "$dir and its contents deleted" 
            fi
        done
    else
        echo "wrong format"
        exit 1
    fi
fi
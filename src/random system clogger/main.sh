#!/bin/bash

execdate=$(date "+%d%m%y")
start_time=$(date +%s)

flag=1

if [ $# -ne 3 ]; then
    echo "script requires 3 args"
elif [ ${#1} -gt 7 ] || [[ $1 =~ [0-9] ]]; then
    echo "first argument requires 7 or less chars without digits for folders name"
elif [ ${#2} -gt 11 ] || [[ $2 =~ [0-9] ]] || [[ ! ${2:${#2}-4:4} =~ \. ]] || [[ ! ${2:0:8} =~ \. ]] || [[ ! $2 =~ ^[^.]*\.[^.]*$ ]]; then
    echo "second argument requires 7 or less chars without digits for files name and 3 chars without digits for file extension"
elif [ ${#3} -lt 2 ] || [ ${#3} -gt 4 ] || [[ ! $3 =~ [0-9] ]] || [[ ! $3 =~ (MB|Mb|mB|mb) ]]; then
    echo "third argument requires size of the files (in mb, but less than 100)"
else
    flag=0
fi

if [ $flag -gt 0 ]; then
    exit 1
fi

logfile="filegen$(date "+_%T_%F").log"

filesize=$3
fileext=$(echo $2 | cut -d '.' -f 2)
fileabc=$(echo $2 | cut -d '.' -f 1)
filecount=

dirabc=$1
dirdepth=99

writable_dirs=()

function get_all_paths {
    local dirs=()
    mapfile -t dirs < <(find / -maxdepth 4 -type d ! -path "/"  \( -path "/dev" -o -path "/wsl*" -o -path "/boot" -o -path "/root" -o -path "*/bin" -o -path "*/sbin" -o -path "/proc" -o -path "/lost+found" -o -path "/mnt" -o -path "/sys" -o -path "/run" -o -path "/etc" -o -path "/var" -o -path "/opt" -o -path "/tmp" \) -prune -o -print)

    for dir in "${dirs[@]}"; do
        if [ -w "$dir" ] && [ -d "$dir" ] ; then
            writable_dirs+=("$dir")
        fi
    done
}

# file and directory name generator
function generate_name {
    newname=""
    while [ ${#newname} -lt 4 ]; do
    newname=""
        for (( i=0; i<${#1}; i++ )); do
            for(( j=0; j<$((RANDOM%15+1)); j++ )); do
                newname+=${1:$i:1}
            done
        done
    done
    echo $newname"_"$execdate
}

# recursive func that creates directories and files
function process { 
    path=$2
    subdirs=$1
    ((subdirs--))
    while [ -d $path ]; do
        dirname=$(generate_name $dirabc)
        path=$path"/"$dirname
    done
    
    $(mkdir $path -p)
    echo "[DIR][$(date "+%T_%F")] created directory $dirname in $2" >> $logfile

    return_value=$(create_files $path)

    if [ ! $1 -eq 1 ] && [ $return_value -eq 0 ]; then
        $(process $subdirs $path)
    fi
}

# creates files in directory
function create_files {
    for(( i=0; i<$((RANDOM%30+1)); i++ )); do
        if [ $(df / | awk 'NR==2 {print $4}') -le 1048576 ]; then
            echo "[INF][$(date "+%T_%F")] 1 GB Left in /" >> $logfile
            echo 1
            exit 1
        fi

        filename=$(generate_name $fileabc)
        while [ -f $1"/"$filename ]; do
            filename=$(generate_name $fileabc)
        done

        fallocate -l $filesize $1"/"$filename"."$fileext
        echo "[FILE(SIZE:$filesize)][$(date "+%T_%F")] created file $filename.$ext in $1" >> $logfile
    done
    echo 0
}

touch $logfile
echo "$logfile created in $(pwd)"


get_all_paths

# echo "${writable_dirs[@]}"
# echo "${#writable_dirs[@]}"
while [ $(df / | awk 'NR==2 {print $4}') -ge 1048576 ]; do
    index=$((RANDOM%${#writable_dirs[@]}))
    $(process $dirdepth ${writable_dirs[$index]})
done
end_time=$(date +%s)

echo "[STAT] start time: $(date -d @$start_time)" | tee -a $logfile
echo "[STAT] end time: $(date -d @$end_time)" | tee -a $logfile
echo "[STAT] script execution time (in seconds): $(( $end_time - $start_time ))" | tee -a $logfile

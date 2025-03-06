#!/bin/bash

execdate=$(date "+%d%m%y")

flag=1

if [ $# -ne 6 ]; then
    echo "script requires 6 args"
elif [ ${1:0:1} != "/" ] ; then
    echo "first argument requires absolute path"
elif ! [[ $2 =~ ^-?[0-9]+$ ]]; then
    echo "second argument requires number of subfolders"
elif [ ${#3} -gt 7 ] || [[ $3 =~ [0-9] ]]; then
    echo "third argument requires 7 or less chars without digits for folders name"
elif ! [[ $4 =~ ^-?[0-9]+$ ]]; then
    echo "fourth argument requires number of files created in each folder"
elif [ ${#5} -gt 11 ] || [[ $5 =~ [0-9] ]] || [[ ! ${5:${#5}-4:4} =~ \. ]] || [[ ! ${5:0:8} =~ \. ]] || [[ ! $5 =~ ^[^.]*\.[^.]*$ ]]; then
    echo "fifth argument requires 7 or less chars without digits for files name and 3 chars without digits for file extension"
elif [ ${#6} -lt 2 ] || [ ${#6} -gt 4 ] || [[ ! $6 =~ [0-9] ]] || [[ ! $6 =~ (KB|Kb|kB|kb) ]]; then
    echo "sixth argument requires size of the files (in kb, but less than 100)"
else
    flag=0
fi

if [ $flag -gt 0 ]; then
    exit 1
fi

logfile="filegen$(date "+_%T_%F").log"

filesize=$6
fileext=$(echo $5 | cut -d '.' -f 2)
fileabc=$(echo $5 | cut -d '.' -f 1)
filecount=$4

dirabc=$3
dirdepth=$2

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
    if [ -d $path ]; then
        echo "[DIR][$(date "+%T_%F")] created directory $dirname in $2" >> $logfile
    else
        echo "[ERROR][DIR][$(date "+%T_%F")] cant create directory $dirname in $2" >> $logfile
    fi
    return_value=$(create_files $path)

    if [ ! $1 -eq 1 ] && [ $return_value -eq 0 ]; then
        $(process $subdirs $path)
    fi
}

# creates files in directory
function create_files {
    for(( i=0; i<$filecount; i++ )); do
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
        
        if [ -f $1"/"$filename"."$fileext ]; then
            echo "[FILE(SIZE:$filesize)][$(date "+%T_%F")] created file $filename.$ext in $1" >> $logfile
        else
            echo "[ERROR][FILE][$(date "+%T_%F")] cant create file $filename.$ext in $1" >> $logfile
        fi
    done
    echo 0
}

touch $logfile
echo "$logfile created in $(pwd)"
mkdir $1 -pv

while [ $(df / | awk 'NR==2 {print $4}') -ge 1048576 ]; do
    $(process $dirdepth $1)
done

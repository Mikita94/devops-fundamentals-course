#!/usr/bin/env bash

treshold="${1:-90}"

df -h | grep -v '^[Filesystem|tmpfs|devfs|map]' | awk '{ print $5, $1 }' | while read -r output;
do
    used=$(echo "$output" | awk '{ print $1 }' | sed 's/%//g')
    partition=$(echo "$output" | awk '{ print $2 }')
    if [ "$used" -ge "$treshold" ]
    then
        echo "Running out of space on partition \"$partition\"! Used $used% of the space."
    fi
done
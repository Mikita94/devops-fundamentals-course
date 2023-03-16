#!/usr/bin/env bash

directory=$1

if [ -z "$directory" ]
then
    echo "You must provide a path."
    exit 1;
fi

find "$directory" -type f | wc -l | sed 's/ //g'

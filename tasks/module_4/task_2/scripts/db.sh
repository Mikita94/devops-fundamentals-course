#!/usr/bin/env bash

arg=$1
shift
storagePath="../data"
userDBPath="${storagePath}/users.db"

help() {
    echo -e "$0 <command>\n"
    echo -e "Usage:\n"
    echo -e "$0 add             add a new line to the users.db"
    echo -e "$0 backup          create a copy of users.db, named %date%-users.db.backup"
    echo -e "$0 find            find the user in users.db"
    echo -e "$0 help            display instructions on how to use this script"
    echo -e "$0 list            display the users"
    echo -e "$0 list -i         users will be displayed in the opposite order"
    echo -e "$0 restore         take the latest backup file and replace users.db with it\n"
    echo -e "All commands:\n"
    echo -e "add backup find help list restore\n"
}

createDB() {
    if ! [ -f "$userDBPath" ]
    then
        read -r -p "The required users.db file is missing, do you want to create it to proceed? [Y/n]: " answer
        case "$answer" in
            [Nn]*) exit 0;;
            [Yy]*|*) mkdir "$storagePath"; touch "$userDBPath";;
        esac
    fi
}

addUser() {
    createDB
    while [ -z "$username" ]
    do
        read -r -p "Please enter a user name (latin letters only): " answer
        username=$(echo "$answer" | grep -E '^[a-zA-Z]+$')
    done
    while [ -z "$role" ]
    do
        read -r -p "Please enter $username's role (latin letters only): " answer
        role=$(echo "$answer" | grep -E '^[a-zA-Z]+$')
    done
    echo "$username,$role" >> "$userDBPath"
    echo "You have successfully added user \"$username\" with role \"$role\""
}

backupDB() {
    createDB
    dateTime=$(date +"%y-%m-%d-%T")
    cp "$userDBPath" "$storagePath/$dateTime-users.db.backup"
    echo "You have successfully created a backup"
}

findUser() {
    createDB
    while [ -z "$username" ]
    do
        read -r -p "Please enter the user name of the user that you want to find (latin letters only): " answer
        username=$(echo "$answer" | grep -E '^[a-zA-Z]+$')
    done
    users=$(grep -E "^$username,.*$" "$userDBPath" | sed -E "s/,/, /g")
    if [ -z "$users" ]
    then
        echo "User not found"
        exit 0
    fi
    echo "$users"
}

listUsers() {
    createDB
    if [ "$1" ]
    then
        cat -n "$userDBPath" | sed -E "s/([0-9]+)(.*)(,)/\1.\2\3 /g" | sort -r
    else
        cat -n "$userDBPath" | sed -E "s/([0-9]+)(.*)(,)/\1.\2\3 /g"
    fi
}

restoreDB() {
    createDB
    backupFiles=($(find "$storagePath" -iname "*.backup" | sort -r))
    if [ -z "${backupFiles[0]}" ]
    then
        echo "No backup file found"
        exit 0
    fi
    cp "${backupFiles[0]}" "$userDBPath"
    echo "You have successfully used the latest backup to restore the users"
}

while getopts ":i" option
do
    case "$option" in
        i) inverse=true;;
        *) ;;
    esac
done

case "$arg" in
    add) addUser;;
    backup) backupDB;;
    find) findUser;;
    list) listUsers "$inverse";;
    restore) restoreDB;;
    help|*) help;;
esac

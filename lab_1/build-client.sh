#!/usr/bin/env bash

APP_PATH="$1"
BUILD_PATH="$APP_PATH/dist/app"
ZIP_PATH="$APP_PATH/dist/client-app.zip"
FILE_COUNT_SCRIPT="$(pwd)/../tasks/module_4/task_1/file_counter.sh"

cd "$APP_PATH" || exit
npm install
npm run build -- --configuration="$ENV_CONFIGURATION"
if [ -f $ZIP_PATH ]
then
    rm $ZIP_PATH
fi
zip -j -r $ZIP_PATH $BUILD_PATH

source $FILE_COUNT_SCRIPT $BUILD_PATH
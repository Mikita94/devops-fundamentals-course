#!/usr/bin/env bash

APP_PATH="$1"
BUILD_PATH="./dist"
ZIP_PATH="./dist/backend-app.zip"

cd "$APP_PATH" || exit
npm install
npm run build
if [ -f $ZIP_PATH ]
then
    rm $ZIP_PATH
fi
zip -j -r $ZIP_PATH $BUILD_PATH

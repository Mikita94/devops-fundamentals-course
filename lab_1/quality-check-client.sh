#!/usr/bin/env bash

APP_PATH="$1"

cd "$APP_PATH" || exit
npm run lint
npm run test -- --watch=false
npm audit
npm run e2e

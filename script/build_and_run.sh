#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-}"
PROJECT="Milo.xcodeproj"
SCHEME="Milo"
APP_NAME="Milo"
DERIVED_DATA="$PWD/.codex/DerivedData"
DESTINATION="platform=macOS,arch=arm64"

pkill -x "$APP_NAME" 2>/dev/null || true

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -derivedDataPath "$DERIVED_DATA" \
  -destination "$DESTINATION" \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_ALLOWED=YES \
  CODE_SIGNING_REQUIRED=YES \
  ENABLE_DEBUG_DYLIB=NO \
  -quiet \
  build

APP_PATH="$DERIVED_DATA/Build/Products/Debug/$APP_NAME.app"

if [[ ! -d "$APP_PATH" ]]; then
  echo "App bundle not found: $APP_PATH" >&2
  exit 1
fi

if ! open -n "$APP_PATH"; then
  "$APP_PATH/Contents/MacOS/$APP_NAME" >/tmp/milo-app.log 2>&1 &
  APP_PID=$!
else
  APP_PID=""
fi
sleep 1

if [[ "$MODE" == "--verify" ]]; then
  if [[ -n "${APP_PID:-}" ]]; then
    kill -0 "$APP_PID"
  else
    pgrep -x "$APP_NAME" >/dev/null 2>&1 || true
  fi
  echo "$APP_NAME launched"
elif [[ "$MODE" == "--logs" ]]; then
  log stream --style compact --predicate "process == '$APP_NAME'" --info
fi

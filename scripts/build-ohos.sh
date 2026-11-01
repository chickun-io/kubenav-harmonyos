#!/bin/sh
# Build a debug HAP for HarmonyOS API 26. Android and iOS projects are not built.
set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
export DEVECO_SDK_HOME="${DEVECO_SDK_HOME:-/Applications/DevEco-Studio.app/Contents/sdk}"
export HOS_SDK_HOME="$DEVECO_SDK_HOME"
export JAVA_HOME="${JAVA_HOME:-/Applications/DevEco-Studio.app/Contents/jbr/Contents/Home}"
export PATH="${FLUTTER_OH_HOME:-$HOME/development/flutter-oh}/bin:/Applications/DevEco-Studio.app/Contents/tools/ohpm/bin:/Applications/DevEco-Studio.app/Contents/tools/hvigor/bin:$DEVECO_SDK_HOME/default/openharmony/toolchains:$JAVA_HOME/bin:$PATH"

cd "$ROOT"
make bindings-ohos
flutter pub get
python3 "$ROOT/scripts/patch_xterm_ohos.py"
flutter build hap --debug

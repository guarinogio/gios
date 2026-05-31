#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
GODOT_DIR="$ROOT_DIR/godot"
ANDROID_DIR="$GODOT_DIR/android"
BUILD_DIR="$ANDROID_DIR/build"
TEMPLATE_VERSION="4.6.3.stable"
ANDROID_SOURCE="${GODOT_ANDROID_SOURCE:-$HOME/.local/share/godot/export_templates/$TEMPLATE_VERSION/android_source.zip}"
VERSION_FILE="$ANDROID_DIR/.build_version"

echo "== Ensuring Android build template =="

if [ ! -f "$ANDROID_SOURCE" ]; then
  echo "Missing android_source.zip:"
  echo "  $ANDROID_SOURCE"
  echo "Install Godot Android export templates for $TEMPLATE_VERSION."
  exit 1
fi

needs_install=false

if [ ! -d "$BUILD_DIR" ]; then
  needs_install=true
fi

for required in \
  "$BUILD_DIR/build.gradle" \
  "$BUILD_DIR/config.gradle" \
  "$BUILD_DIR/settings.gradle" \
  "$BUILD_DIR/gradle.properties" \
  "$BUILD_DIR/gradlew" \
  "$BUILD_DIR/assetPackInstallTime/build.gradle"
do
  if [ ! -f "$required" ]; then
    needs_install=true
  fi
done

if [ ! -f "$VERSION_FILE" ]; then
  needs_install=true
elif ! grep -q "$TEMPLATE_VERSION" "$VERSION_FILE"; then
  needs_install=true
fi

if [ "$needs_install" = true ]; then
  echo "Installing Android build template from:"
  echo "  $ANDROID_SOURCE"

  rm -rf "$ANDROID_DIR"
  mkdir -p "$BUILD_DIR"

  unzip -q "$ANDROID_SOURCE" -d "$BUILD_DIR"

  cat > "$VERSION_FILE" <<EOF_VERSION
$TEMPLATE_VERSION
EOF_VERSION

  touch "$BUILD_DIR/.gdignore"
else
  echo "Android build template OK"
fi

# Clean generated Gradle/export artifacts that can confuse Godot scans.
rm -rf "$BUILD_DIR/build"
rm -rf "$BUILD_DIR/.gradle"

echo "Template files:"
find "$BUILD_DIR" -maxdepth 1 -type f | sort

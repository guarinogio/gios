#!/usr/bin/env bash
set -euo pipefail

GODOT_VERSION="4.6.3"
ANDROID_HOME_DIR="$HOME/Android/Sdk"

echo "== Installing system packages =="
sudo apt update
sudo apt install -y \
  curl wget unzip zip git git-lfs \
  openjdk-17-jdk \
  ca-certificates xz-utils \
  libfontconfig1 libxkbcommon0 libx11-6 libxcursor1 libxinerama1 libxi6 libxrandr2 libxrender1 libgl1 libglu1-mesa \
  adb

echo "== Preparing directories =="
mkdir -p "$HOME/.local/bin"
mkdir -p "$ANDROID_HOME_DIR/cmdline-tools"
mkdir -p tools vendor/godot android-sdk engine games docs assets

echo "== Installing Godot ${GODOT_VERSION} =="
cd vendor/godot
GODOT_ZIP="Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip"
GODOT_URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/${GODOT_ZIP}"

if [ ! -f "$GODOT_ZIP" ]; then
  wget -O "$GODOT_ZIP" "$GODOT_URL"
fi

unzip -o "$GODOT_ZIP"
chmod +x "Godot_v${GODOT_VERSION}-stable_linux.x86_64"

ln -sf "$PWD/Godot_v${GODOT_VERSION}-stable_linux.x86_64" "$HOME/.local/bin/godot"

cd ../..

echo "== Installing Android command-line tools =="
cd /tmp
CMDLINE_ZIP="commandlinetools-linux-13114758_latest.zip"
CMDLINE_URL="https://dl.google.com/android/repository/${CMDLINE_ZIP}"

if [ ! -f "$CMDLINE_ZIP" ]; then
  wget -O "$CMDLINE_ZIP" "$CMDLINE_URL"
fi

rm -rf /tmp/android-cmdline-tools
mkdir -p /tmp/android-cmdline-tools
unzip -q -o "$CMDLINE_ZIP" -d /tmp/android-cmdline-tools

rm -rf "$ANDROID_HOME_DIR/cmdline-tools/latest"
mkdir -p "$ANDROID_HOME_DIR/cmdline-tools/latest"
mv /tmp/android-cmdline-tools/cmdline-tools/* "$ANDROID_HOME_DIR/cmdline-tools/latest/"

echo "== Installing Android SDK packages =="
export ANDROID_HOME="$ANDROID_HOME_DIR"
export ANDROID_SDK_ROOT="$ANDROID_HOME_DIR"
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

yes | sdkmanager --licenses >/dev/null

sdkmanager --sdk_root="$ANDROID_HOME" \
  "platform-tools" \
  "build-tools;35.0.1" \
  "platforms;android-35" \
  "cmdline-tools;latest" \
  "cmake;3.10.2.4988404" \
  "ndk;28.1.13356709"

echo "== Writing local environment helper =="
cd /home/gioguarino/repos/azunain/gios

cat > .envrc.example <<ENVEOF
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export ANDROID_HOME=\$HOME/Android/Sdk
export ANDROID_SDK_ROOT=\$ANDROID_HOME
export PATH=\$HOME/.local/bin:\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH
ENVEOF

cat > scripts/env.sh <<ENVEOF
#!/usr/bin/env bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export ANDROID_HOME=\$HOME/Android/Sdk
export ANDROID_SDK_ROOT=\$ANDROID_HOME
export PATH=\$HOME/.local/bin:\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH
ENVEOF

chmod +x scripts/env.sh

echo "== Done =="
echo "Run:"
echo "source scripts/env.sh"
echo "godot --version"
echo "sdkmanager --version"
echo "adb version"

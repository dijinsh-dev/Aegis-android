#!/usr/bin/env bash
# Builds an installable APK. Needs: JDK 17, Android SDK+NDK (ANDROID_HOME, ANDROID_NDK_HOME),
# Rust + cargo-ndk, Node, Gradle 8.9+ (or a ./gradlew).
set -euo pipefail
cd "$(dirname "$0")"

if [ ! -s rust/keys/release.pub ]; then
  echo "!! No rust/keys/release.pub: generating a DEV keypair in ./dev-keys (do NOT ship this)."
  bash scripts/gen-keys.sh dev-keys
  cp dev-keys/release.pub rust/keys/release.pub
fi

rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android
(cd rust && cargo ndk -t arm64-v8a -t armeabi-v7a -t x86_64 -o ../app/src/main/jniLibs build --release)

npx --yes esbuild web/android-entry.ts --bundle --minify --format=iife --outfile=app/src/main/assets/consent.js

if [ -x ./gradlew ]; then ./gradlew --no-daemon assembleRelease; else gradle --no-daemon assembleRelease; fi
echo "APK: $(pwd)/app/build/outputs/apk/release/app-release.apk"

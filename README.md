# Aegis (Android): build an installable APK

I couldn't compile in my sandbox (no Android SDK or network), so this is a complete project that builds the APK for you.

## Option A: GitHub Actions (no local setup)
1. Create a private GitHub repo and push this folder (`git init && git add -A && git commit -m init`, then push to `main`).
2. Actions → **build-apk** → Run workflow. Download the `aegis-apk` artifact → `app-release.apk`.

## Option B: Local
Install JDK 17, Android SDK + NDK 26, Rust, `cargo install cargo-ndk`, Node, Gradle 8.9. Then `./build.sh`.
Output: `app/build/outputs/apk/release/app-release.apk`.

## Install
- On the phone: copy the APK over, open it, and allow "Install unknown apps" for your file manager.
- USB: `adb install -r app-release.apk`

## Before real use
- **Update key:** `build.sh` makes a throwaway DEV key if `rust/keys/release.pub` is missing. For real use run `scripts/gen-keys.sh keys`, keep `release.key` offline, commit only `release.pub`.
- **Update server:** set your CDN URL in `UpdateWorker.kt` (`manifestUrl`). Until then rule updates fail quietly, and the built-in blocklists are EMPTY, so nothing is blocked until you publish a signed rule bundle.
- **App signing:** without secrets the APK is signed with a debug key. For stable updates create one keystore (`keytool -genkeypair -v -keystore aegis.jks -alias aegis -keyalg RSA -keysize 4096 -validity 10000`) and set secrets `AEGIS_KEYSTORE_B64` (base64 of the jks), `AEGIS_KS_PASS`, `AEGIS_KEY_ALIAS`. Always reuse the same keystore, or phones must uninstall before updating.

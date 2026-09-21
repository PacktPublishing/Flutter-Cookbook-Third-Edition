# margin

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Setup for readers

This repo is companion code for the book. Anything tied to a personal developer
account has been removed or replaced with a placeholder, so you will need to
supply your own values before building. Nothing here is required just to read
the code — only to run or ship it.

### 1. Choose your own bundle / application ID

Every platform currently uses the placeholder `com.example.margin`. Replace it
with an identifier you control (e.g. `com.yourname.margin`) in:

| Platform | File | Setting |
| --- | --- | --- |
| Android | `android/app/build.gradle.kts` | `namespace`, `applicationId` |
| Android | `android/app/src/main/kotlin/com/example/margin/MainActivity.kt` | `package` (and move the folder to match) |
| iOS | `ios/Runner.xcodeproj/project.pbxproj` | `PRODUCT_BUNDLE_IDENTIFIER` |
| macOS | `macos/Runner/Configs/AppInfo.xcconfig` | `PRODUCT_BUNDLE_IDENTIFIER` |
| Linux | `linux/CMakeLists.txt` | `APPLICATION_ID` |
| Windows | `windows/runner/Runner.rc` | `CompanyName`, `LegalCopyright` |

### 2. iOS / macOS code signing

`DEVELOPMENT_TEAM` is intentionally left empty. Open `ios/Runner.xcworkspace`
in Xcode and pick your own team under **Signing & Capabilities**, or leave it
empty to build for the simulator only.

### 3. Android release signing

Debug builds (`flutter run`) work with no setup. For a **release** build you
need your own upload keystore:

```sh
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload

cp android/key.properties.example android/key.properties
# then edit android/key.properties with your own passwords and keystore path
```

`android/key.properties` and `*.jks` / `*.keystore` are gitignored — never
commit them. See https://docs.flutter.dev/deployment/android#signing-the-app

### 4. Shorebird

`shorebird.yaml` **is** committed so you can see how it fits into the project
(it is also referenced from `pubspec.yaml` under `flutter: assets:`). Its
`app_id` is a placeholder — `YOUR_SHOREBIRD_APP_ID` — because an `app_id` is
tied to one Shorebird account.

Replace it with your own:

```sh
shorebird init
```

That rewrites `app_id` in place. The app builds and runs fine with the
placeholder; only `shorebird release` / `shorebird patch` need a real value.

### 5. Firebase (if you add it)

`google-services.json`, `GoogleService-Info.plist` and `firebase_options.dart`
are gitignored. Generate your own with `flutterfire configure`.

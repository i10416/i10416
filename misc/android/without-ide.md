# Note on Android development without IDE

## Android Emulator

The Android emulator tool is located at `ANDROID_SDK_ROOT/emulator/emulator`

```sh
# List AVDs
emulator -list-avds
# Run Emulator using AVD
emulator -avd <avd name>
```

## Android Debug Bridge(ADB)

Android debug bridge can be found at `ANDROID_SDK_ROOT/platform-tools/adb`

### Login to the emulator shell

```sh
adb -s <device/emulator name> shell
```

### Install APK to device/emulator

```sh
adb -s <device/emulator name> install path/to/your.apk
```

### Kill emulator

```sh
adb -s <emulator name> emu kill
```

## Gradle

### List All Tasks

```sh
./gradlew tasks --all
```
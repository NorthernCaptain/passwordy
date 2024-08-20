# Passwordy

Passwordy is a free, open-source, multi-platform offline password manager designed to keep your sensitive information secure and easily accessible across all your devices.

## Features

- **Offline-first**: Your data is stored locally, ensuring maximum privacy and security.
- **Multi-platform support**: Available on Android, iOS, macOS, Linux, and Windows.
- **Local encryption**: All your data is encrypted on your device using strong encryption algorithms.
- **Google Drive sync**: Optionally sync your encrypted data across devices using your personal Google Drive account, without involving any external servers.
- **User-friendly interface**: Intuitive design for easy management of your passwords and sensitive information.
- **Open-source**: Passwordy is released under the GPLv3 license, allowing for community contributions and audits.

## Building and Running Passwordy

Passwordy is written in Flutter, which allows it to run on multiple platforms from a single codebase. Follow these instructions to build and run the app on your preferred platform:

### Prerequisites

1. Install [Flutter](https://flutter.dev/docs/get-started/install) on your development machine.
2. Set up your preferred IDE (e.g., Android Studio, VS Code) with Flutter and Dart plugins.

### Building for Android

1. Clone the repository: `git clone https://github.com/yourusername/passwordy.git`
2. Navigate to the project directory: `cd passwordy`
3. Run `flutter pub get` to fetch dependencies.
4. Connect an Android device or start an emulator.
5. Run `flutter run` to build and run the app on your Android device/emulator.

### Building for iOS

1. Follow steps 1-3 from the Android instructions.
2. Ensure you have Xcode installed on your Mac.
3. Open the iOS project in Xcode: `open ios/Runner.xcworkspace`
4. Set up your provisioning profile and signing certificate in Xcode.
5. Run `flutter run` to build and run the app on your iOS device/simulator.

### Building for macOS

1. Follow steps 1-3 from the Android instructions.
2. Ensure you have Xcode installed on your Mac.
3. Run `flutter config --enable-macos-desktop`
4. Run `flutter run -d macos` to build and run the app on macOS.

### Building for Linux

1. Follow steps 1-3 from the Android instructions.
2. Ensure you have the required Linux dependencies installed.
3. Run `flutter config --enable-linux-desktop`
4. Run `flutter run -d linux` to build and run the app on Linux.

### Building for Windows

1. Follow steps 1-3 from the Android instructions.
2. Ensure you have Visual Studio installed with the "Desktop development with C++" workload.
3. Run `flutter config --enable-windows-desktop`
4. Run `flutter run -d windows` to build and run the app on Windows.

## Contributing

We welcome contributions to Passwordy! Please feel free to submit issues, feature requests, or pull requests on our GitHub repository.

## License

Passwordy is released under the GNU General Public License v3.0 (GPLv3). See the [LICENSE](LICENSE.txt) file for details.


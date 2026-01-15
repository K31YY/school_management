# ungthoung_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase Configuration

This project uses Firebase for backend services. To configure the project, you need to generate a `firebase_options.dart` file.

1.  Install the Firebase CLI by following the instructions here: [https://firebase.google.com/docs/cli#install-cli-windows](https://firebase.google.com/docs/cli#install-cli-windows)
2.  Install the FlutterFire CLI by running the following command:

    ```bash
    dart pub global activate flutterfire_cli
    ```

3.  Login to Firebase:

    ```bash
    firebase login
    ```

4.  Configure your project:

    ```bash
    flutterfire configure
    ```

    This command will walk you through selecting your Firebase project and generating the `lib/firebase_options.dart` file.

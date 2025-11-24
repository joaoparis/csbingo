# csbingo

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase deployment

This project includes a `firebase.json` configuration and can be deployed to Firebase Hosting.

Prerequisites:

- Install the Firebase CLI if you don't have it already:

```bash
npm install -g firebase-tools
```

- Log in to Firebase from the CLI:

```bash
firebase login
```

Deploy the Flutter web build to Firebase Hosting:

1. Build the web output (from the project root):

```bash
flutter build web --release
```

2. Deploy the hosting site:

```bash
firebase deploy
```

Notes:

- On Windows using WSL/Git Bash, run these commands in your preferred bash shell (the default shell for this workspace is `bash.exe`).
- If you haven't initialized Firebase Hosting locally, run `firebase init hosting` and follow the prompts before the first deploy.


# Harari Prosperity App

## Overview
The Harari Prosperity App is a cross-platform mobile application built with Flutter. It is designed to provide users with secure authentication, profile management, reporting features, FAQ/help resources, and more, all styled with a modern and user-friendly interface.

## Features
- **Authentication**: Login, signup, password reset, and PIN management.
- **Profile Management**: Edit user profile, change username, and view user details.
- **Security**: Change password and PIN, with success feedback screens.
- **Reporting**: Submit and view reports, including report history and attachments.
- **Navigation**: Bottom navigation bar and side drawer for easy access to main sections (Home, History, FAQ, Profile, Settings).
- **FAQ & Help**: Tabbed FAQ and contact information, accessible from both the bottom bar and profile screen.
- **Settings**: Language selection, app settings, and more.
- **Custom Widgets**: Reusable UI components for buttons, dialogs, and profile items.

## Project Structure
- `lib/`
  - `features/` — Main app features, grouped by domain (authentication, navigation, security, etc.)
  - `shared/` — Shared widgets and constants
  - `routes/` — App route definitions and navigation logic
  - `main.dart` — App entry point
- `assets/` — Images and fonts
- `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/` — Platform-specific code

## How to Run
1. Install [Flutter](https://flutter.dev/docs/get-started/install) and set up your environment.
2. Get dependencies:
   ```
   flutter pub get
   ```
3. Run the app:
   ```
   flutter run
   ```

## Customization
- Update app colors and fonts in `lib/shared/constants.dart`.
- Add or modify features in the `lib/features/` directory.
- Manage navigation in `lib/routes/app_routes.dart`.

## Contribution
1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Make your changes and commit with clear messages.
4. Open a pull request for review.

## License
This project is licensed under the MIT License.

---
For more information, see the in-code documentation and comments throughout the project.
# prosperity_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

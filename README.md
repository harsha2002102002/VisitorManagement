# Visitor Management Application

## Project Overview
A Flutter application for visitor registration, QR-based identification, check-in/check-out, and visitor tracking.

## Flutter / Dart Version
- Flutter: **3.29.0**
- Dart: **3.7.0**

## Setup and Execution
1. Install Flutter and configure an Android device or emulator.
2. Clone the repository and open it in VS Code or Android Studio.
3. Run `flutter pub get`.
4. Run `flutter run`.
5. Allow camera access when prompted to scan QR codes.

## Packages and Dependencies
- `provider` — state management (`ChangeNotifier`, `Consumer`).
- `http` — REST API requests.
- `qr_flutter` — QR code generation.
- `mobile_scanner` — camera-based QR scanning and scanner-level camera permission handling.
- `google_fonts` — Poppins typography.
- `curved_navigation_bar` — bottom navigation.

Exact package versions are in `pubspec.yaml`. **`permission_handler` is not used.** Camera permission is handled by `mobile_scanner` through Android/iOS platform camera APIs; declare `android.permission.CAMERA` in `AndroidManifest.xml` and `NSCameraUsageDescription` in iOS `Info.plist` when targeting iOS. If access is denied, the scanner must show a permission/error message and allow the user to retry or enable access in device settings; repeated system permission prompts are not guaranteed.

## State Management
Uses **Provider** with `ChangeNotifier`:
- `VisitorModel` represents visitor data and JSON conversion.
- `VisitorService` performs HTTP operations with MockAPI.
- `VisitorProvider` holds visitor records, loading/error states, and notifies screens when data changes.

## Mock API Details
- **Base URL:** `https://6ae0d1f6be3bc8fead97f727.mockapi.io`
- **Resource:** `/sendVisitorDetails`
- **GET:** List visitors or fetch a visitor by ID.
- **POST:** Register a visitor.
- **PUT/PATCH:** Update visitor details or check-in/check-out status.
- **DELETE:** Remove a visitor.

## Application Features
- Dashboard with total, checked-in, and checked-out visitor counts.
- Register, search, view, edit, and delete visitors.
- Generate a unique visitor QR code and scan it to retrieve visitor details.
- Check in/out with timestamps and status updates.
- Empty-list, no-results, loading, network-error, and retry states.

## Known Limitations
- Uses **MockAPI**, not a production backend; no authentication or role-based access control.
- QR codes contain visitor IDs, so production access should be authenticated and authorized.
- Check-in/out timestamps currently depend on the device clock; production systems should use server-generated timestamps.
- Camera scanning requires device permission; permanently denied access must be changed in system settings.
- Dashboard counts assume the API returns the full visitor list.

# path_manager_example

A Flutter application demonstrating the usage and capabilities of the `path_manager` plugin.

## Features Demonstrated

This example project provides a hands-on implementation of the core `path_manager` APIs:
- **Unified Path Resolution**: Displays paths resolved at runtime for:
  - Temporary Directory
  - Application Support Directory
  - Documents Directory
  - Caches Directory
  - Excluded No-Backup Directory (`__no_backup__`)
- **Interactive Backup Exclusion Test**: Includes a testing card that allows you to trigger a manual backup exclusion request programmatically. This highlights how:
  - iOS and macOS successfully apply the exclusion attributes.
  - Android catches and logs the expected `UnsupportedError`, showing how to safely design fallback logic.

## Getting Started

### Prerequisites

Ensure you have a configured Flutter environment on your development machine.

### Running the Example

1. Navigate to the example directory:
   ```bash
   cd example
   ```
2. Retrieve the project dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   - For macOS desktop target:
     ```bash
     flutter run -d macos
     ```
   - For Android (requires a running emulator or connected device):
     ```bash
     flutter run -d android
     ```
   - For iOS (requires Xcode and a running simulator):
     ```bash
     flutter run -d ios
     ```

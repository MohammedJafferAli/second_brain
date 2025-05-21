# Flutter iOS Simulator Automation Script

This Bash script automates the process of setting up and launching a Flutter application on an iOS simulator. It handles Git operations, dependency management, simulator selection and booting, environment configuration, and log monitoring.

---

## 📋 Features

- Checkout and update a specified Git branch
- Optional `flutter clean` and `flutter pub get`
- Automatically detect and boot an iOS simulator by name
- Choose from predefined environment configurations
- Launch the Flutter app with appropriate arguments
- Open a local development URL in Google Chrome
- Monitor logs for a specific `Tracking-Header` value

---

## 🛠️ Prerequisites

- macOS with Xcode and iOS simulators installed
- Flutter SDK installed and configured
- Google Chrome installed
- Log directory path and environment file paths properly set in the script

---

## 🚀 Usage

```bash
./your_script_name.sh <branch_name> <arg_choice: env1|env2|prod> <device_name>
```

### Example

```bash
./run_flutter_ios.sh feature/login env1 "iPhone 14"
```

---

## 🧩 Argument Details

- `<branch_name>`: Git branch to checkout and pull
- `<arg_choice>`: One of `env1`, `env2`, or `prod` (used to select environment-specific build arguments)
- `<device_name>`: Name of the iOS simulator (e.g., `"iPhone 14"`)

---

## 🧪 Environment Configuration

The script supports three environments:

- **env1**: Uses `env1_file` for configuration
- **env2**: Uses `env2_file` for configuration
- **prod**: Uses `prod_file` for configuration

Update the placeholders `<env1_file>`, `<env2_file>`, and `<prod_file>` in the script with actual file paths.

---

## 📄 Log Monitoring

The script monitors a log file for the appearance of a `Tracking-Header`. Once detected, it prints and stores the value for further use.

Make sure to update `<path-to-mylog>` in the script to the actual log directory.

---

## 🧼 Optional Cleanup

You will be prompted to run:

```bash
flutter clean
flutter pub get
```

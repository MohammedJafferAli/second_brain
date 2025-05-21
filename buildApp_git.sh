#!/bin/bash

cd <project_location> || exit

# Check if the correct number of arguments is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <branch_name> [device_name]"
    exit 1
fi

BRANCH_NAME=$1
DEVICE_NAME=${2:-"iPhone 15 Pro"}  # Default to iPhone 15 Pro if not provided
FLAVOR="appstore"

# Fetch and checkout the branch
git fetch origin "$BRANCH_NAME"
git checkout "$BRANCH_NAME"
git pull origin "$BRANCH_NAME"

# Ask user if they want to clean and get dependencies
read -p "Do you want to run 'flutter clean' and 'flutter pub get'? (Y/N): " USER_INPUT
if [[ "$USER_INPUT" == "Y" || "$USER_INPUT" == "y" ]]; then
    echo "Running flutter clean and flutter pub get..."
    flutter clean
    flutter pub get
else
    echo "Skipping flutter clean and pub get."
fi

# Build the app for iOS Simulator
flutter build ios --simulator --flavor "$FLAVOR"

# Check if build succeeded
APP_PATH="build/ios/iphonesimulator/Runner.app"
if [ ! -d "$APP_PATH" ]; then
    echo "❌ Build failed: $APP_PATH not found."
    exit 1
fi


# List available iOS simulators matching the device name
echo "Available iOS simulators matching: $DEVICE_NAME"
xcrun simctl list devices available | grep -E "$DEVICE_NAME" | awk -F '[()]' '{print $2 " - " $1}'

# Select the first available simulator matching the device name
SIMULATOR_ID=$(xcrun simctl list devices available | grep -E "$DEVICE_NAME" | awk -F '[()]' '{print $2}' | head -n 1)

if [ -z "$SIMULATOR_ID" ]; then
    echo "❌ No available iOS 17.5 simulators found."
    exit 1
fi

# Boot the simulator if not already booted
SIMULATOR_STATE=$(xcrun simctl list devices | grep "$SIMULATOR_ID" | awk '{print $NF}')
if [ "$SIMULATOR_STATE" != "(Booted)" ]; then
    echo "🔄 Booting simulator $SIMULATOR_ID..."
    xcrun simctl boot "$SIMULATOR_ID"
    sleep 10
fi

# Install and launch the app
echo "📱 Installing app on simulator..."
xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"

echo "🚀 Launching app..."
xcrun simctl launch "$SIMULATOR_ID" <app-uri>
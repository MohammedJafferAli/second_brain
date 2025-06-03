#!/bin/bash

# Select project folder
PROJECT_FOLDER=$(zenity --file-selection --directory --title="Select Project Folder")
if [ -z "$PROJECT_FOLDER" ]; then
    zenity --error --text="No folder selected. Exiting."
    exit 1
fi
cd "$PROJECT_FOLDER" || exit

# Input branch name
BRANCH_NAME=$(zenity --entry --title="Branch Name" --text="Enter the branch name:")
if [ -z "$BRANCH_NAME" ]; then
    zenity --error --text="Branch name is required."
    exit 1
fi

# Choose environment
ARG_CHOICE=$(zenity --list --radiolist \
    --title="Select Environment" \
    --column="Select" --column="Environment" \
    TRUE "env1" FALSE "env2" FALSE "prod")

if [ -z "$ARG_CHOICE" ]; then
    zenity --error --text="No environment selected."
    exit 1
fi

# Input device name
DEVICE_NAME=$(zenity --entry --title="Device Name" --text="Enter the iOS device name:")
if [ -z "$DEVICE_NAME" ]; then
    zenity --error --text="Device name is required."
    exit 1
fi

# Git operations
git fetch origin "$BRANCH_NAME"
git checkout "$BRANCH_NAME"
git pull origin "$BRANCH_NAME"

# Ask to run flutter clean and pub get
zenity --question --text="Do you want to run 'flutter clean' and 'flutter pub get'?"
if [ $? -eq 0 ]; then
    flutter clean
    flutter pub get
fi

# Find simulator
SIMULATOR_ID=$(xcrun simctl list devices available | grep -E "$DEVICE_NAME" | awk -F '[()]' '{print $2}' | head -n 1)
if [ -z "$SIMULATOR_ID" ]; then
    zenity --error --text="No available iOS $DEVICE_NAME simulators found."
    exit 1
fi

# Boot the simulator if not already booted
SIMULATOR_STATE=$(xcrun simctl list devices | grep "$SIMULATOR_ID" | awk '{print $NF}')
if [ "$SIMULATOR_STATE" != "(Booted)" ]; then
    echo "🔄 Booting simulator $SIMULATOR_ID..."
    xcrun simctl boot "$SIMULATOR_ID"
    sleep 10
fi

# Function to run flutter app with additional arguments
run_flutter_app() {
    local simulator_id=$1
    shift
    local additional_args="$@"

    echo "🚀 Running app on simulator $simulator_id with additional arguments: $additional_args"
    flutter run -d "$simulator_id" $additional_args
}

# Set flutter args
case $ARG_CHOICE in
    env1)
        ARGS="--dart-define=BUILD_TYPE=enterprise --dart-define=FLAVOR_NAME=env1 --dart-define=AUTH_CUSTOM_SCHEME=eeflutter --dart-define-from-file=<env1_file>"
        ;;
    env2)
        ARGS="--dart-define=BUILD_TYPE=enterprise --dart-define=FLAVOR_NAME=env2 --dart-define=AUTH_CUSTOM_SCHEME=eeflutter --dart-define-from-file=<env2_file>"
        ;;
    prod)
        ARGS="--dart-define=BUILD_TYPE=appstore --dart-define-from-file=<prod_file>"
        ;;
esac

# Run the app
zenity --info --text="Launching app on simulator..."
flutter run -d "$SIMULATOR_ID" $ARGS

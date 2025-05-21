#!/bin/bash

cd <project-folder> || exit


# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <branch_name> <arg_choice: env1|env2|prod> <device_name>"
    exit 1
fi

BRANCH_NAME=$1
ARG_CHOICE=$2
DEVICE_NAME=$3


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

# List available iOS simulators matching the device name
echo "Available iOS simulators matching: $DEVICE_NAME"
xcrun simctl list devices available | grep -E "$DEVICE_NAME" | awk -F '[()]' '{print $2 " - " $1}'

# Select the first available simulator matching the device name
SIMULATOR_ID=$(xcrun simctl list devices available | grep -E "$DEVICE_NAME" | awk -F '[()]' '{print $2}' | head -n 1)

if [ -z "$SIMULATOR_ID" ]; then
    echo "❌ No available iOS $DEVICE_NAME simulators found."
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

# Prompt user to select one of three predefined argument sets
echo "Select the argument set to use:"
echo "1) env1"
echo "2) env2"
echo "3) Prod"
read -p "Enter the number of your choice: " ARG_CHOICE

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
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Run the app on the selected simulator with the chosen arguments
run_flutter_app "$SIMULATOR_ID" $ARGS
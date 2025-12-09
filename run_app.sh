#!/bin/bash
# Helper script to run Flutter app with environment variables

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if local.env exists
if [ ! -f "local.env" ]; then
    echo -e "${RED}Error: local.env not found!${NC}"
    echo "Please copy local.env.example to local.env and configure your Google client IDs"
    exit 1
fi

# Function to display usage
usage() {
    echo -e "${BLUE}Usage: $0 [platform]${NC}"
    echo ""
    echo "Platforms:"
    echo "  web       - Run on Chrome (port 58072)"
    echo "  android   - Run on Android device/emulator"
    echo "  ios       - Run on iOS simulator"
    echo "  macos     - Run on macOS"
    echo "  windows   - Run on Windows"
    echo "  linux     - Run on Linux"
    echo ""
    echo "Example: $0 web"
    exit 1
}

# Check if platform argument is provided
if [ -z "$1" ]; then
    usage
fi

PLATFORM=$1

# Run based on platform
case $PLATFORM in
    web)
        echo -e "${GREEN}Running on Web (Chrome, port 58072)...${NC}"
        flutter run -d chrome --web-port 58072 --dart-define-from-file local.env
        ;;
    android)
        echo -e "${GREEN}Running on Android...${NC}"
        flutter run -d android --dart-define-from-file local.env
        ;;
    ios)
        echo -e "${GREEN}Running on iOS...${NC}"
        flutter run -d ios --dart-define-from-file local.env
        ;;
    macos)
        echo -e "${GREEN}Running on macOS...${NC}"
        flutter run -d macos --dart-define-from-file local.env
        ;;
    windows)
        echo -e "${GREEN}Running on Windows...${NC}"
        flutter run -d windows --dart-define-from-file local.env
        ;;
    linux)
        echo -e "${GREEN}Running on Linux...${NC}"
        flutter run -d linux --dart-define-from-file local.env
        ;;
    *)
        echo -e "${RED}Error: Unknown platform '$PLATFORM'${NC}"
        usage
        ;;
esac

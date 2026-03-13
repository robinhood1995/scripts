#!/bin/bash

#===============================================================================
# SCRIPT HEADER TEMPLATE
#============================
# Script Name: cleanupMovieDirectories.sh
# Description: Cleanup up directories and sub directories that does not have movies related files.
# 
# Created By: Robinhood1995
# Created On: 2025-10-05
# 
# Modified By: robinhood1995@yahoo.com
# Modified On: 
# Modification Notes:
# 
# Version: 1.0.0
# License: MIT License
# 
# Dependencies: Bash Shell
# Usage: ./cleanupMovieDirectories.sh <directory_path>
# 
# WARNING:
# 
# Changelog:
# - [YYYY-MM-DD]: [VERSION] - [SUMMARY OF CHANGES]
# - [YYYY-MM-DD]: [VERSION] - [INITIAL CREATION]
#===============================================================================

# Global Variables
# ----------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

# Colors for output (optional)
# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Function to print header info (optional utility)
print_header() {
    echo -e "${GREEN}Running ${SCRIPT_NAME}${NC}"
    echo -e "${YELLOW}Description: ${DESCRIPTION}${NC}"
    echo -e "${YELLOW}Version: ${VERSION}${NC}"
}

# Main script logic starts here
# -----------------------------
DESCRIPTION="Cleanup up directories and sub directories that does not have movies related files."
VERSION="1.0.0"

# Example: print_header  # Uncomment to use

if [ $# -eq 0 ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

TARGET_DIR="$1"
EXTENSIONS="*.mkv *.mp4 *.m4v *.avi *.wmv"

echo "Scanning $TARGET_DIR for directories without video files..."
declare -A has_video

# Function to check if a dir (and subs) has videos
check_videos() {
    local dir="$1"
    if [ -n "${has_video[$dir]}" ]; then
        return ${has_video[$dir]}
    fi
    if [ $(find "$dir" -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.m4v" -o -name "*.avi" -o -name "*.wmv" -o -name "*.srt" \) | wc -l) -gt 0 ]; then
        has_video[$dir]=1
        return 1
    else
        has_video[$dir]=0
        return 0
    fi
}

# Collect dirs to delete (bottom-up)
to_delete=()
while IFS= read -r -d '' dir; do
    if ! check_videos "$dir"; then
        to_delete+=("$dir")
    fi
done < <(find "$TARGET_DIR" -depth -type d -print0)

if [ ${#to_delete[@]} -eq 0 ]; then
    echo "No directories without videos found."
    exit 0
fi

echo "Found ${#to_delete[@]} directories without videos:"
printf '%s\n' "${to_delete[@]}"

echo -n "Proceed with deletion? (y/N): "
read -r confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    for dir in "${to_delete[@]}"; do
        rmdir "$dir" 2>/dev/null || rm -rf "$dir"  # rmdir for empty, fallback to rm -rf
        echo "Removed: $dir"
    done
    echo "Cleanup complete."
else
    echo "Aborted."
fi

exit 0
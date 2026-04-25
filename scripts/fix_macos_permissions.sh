#!/bin/bash

# Fix macOS Executable Permissions for Cataclysm Games
# This script fixes the binary permissions for downloaded Cataclysm game executables on macOS

echo "🔧 Fixing macOS executable permissions for Cataclysm games..."

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Look for game directory (usually in parent directory)
GAME_DIR=""
if [ -d "$SCRIPT_DIR/../game" ]; then
    GAME_DIR="$SCRIPT_DIR/../game"
elif [ -d "$SCRIPT_DIR/game" ]; then
    GAME_DIR="$SCRIPT_DIR/game"
else
    echo "❓ Please specify the path to your game directory:"
    read -p "Game directory path: " GAME_DIR
fi

if [ ! -d "$GAME_DIR" ]; then
    echo "❌ Game directory not found: $GAME_DIR"
    exit 1
fi

echo "📁 Checking game directory: $GAME_DIR"

# List of common Cataclysm executable names
EXECUTABLES=(
    "cataclysm-tiles"
    "cataclysm-bn-tiles" 
    "cataclysm-tlg-tiles"
    "cataclysm-tiles-tlg"
    "cataclysm-eod-tiles"
    "cataclysm-tish-tiles"
    "cataclysm-launcher"
)

# Function to fix permissions for a file
fix_permissions() {
    local file="$1"
    if [ -f "$file" ]; then
        echo "🔨 Setting executable permissions for: $(basename "$file")"
        chmod u+x "$file"
        if [ $? -eq 0 ]; then
            echo "✅ Successfully set permissions for: $(basename "$file")"
        else
            echo "❌ Failed to set permissions for: $(basename "$file")"
        fi
    fi
}

# Fix permissions for direct executables
for exe in "${EXECUTABLES[@]}"; do
    exe_path="$GAME_DIR/$exe"
    fix_permissions "$exe_path"
done

# Fix permissions for .app bundles on macOS
echo "🍎 Checking for macOS .app bundles..."
for app_bundle in "$GAME_DIR"/*.app; do
    if [ -d "$app_bundle" ]; then
        echo "📦 Found app bundle: $(basename "$app_bundle")"
        
        # Check both Contents/MacOS and Contents/Resources
        for bundle_dir in "MacOS" "Resources"; do
            target_dir="$app_bundle/Contents/$bundle_dir"
            if [ -d "$target_dir" ]; then
                echo "  🔍 Checking $bundle_dir directory..."
                for exe_file in "$target_dir"/*; do
                    if [ -f "$exe_file" ]; then
                        fix_permissions "$exe_file"
                    fi
                done
            fi
        done
    fi
done

echo ""
echo "🎉 Permission fixing complete!"
echo "💡 Tip: Lacapult Doobdab should automatically fix permissions when downloading games,"
echo "   but you can run this script manually if needed."
echo ""
echo "🚀 You should now be able to run your Cataclysm game executable." 
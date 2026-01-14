#!/bin/bash
#
# Resets Picker app to fresh install state
# Removes all preferences, cached data, and system permissions
#

BUNDLE_ID="net.domzilla.picker"
CONTAINER_DATA=~/Library/Containers/${BUNDLE_ID}/Data

echo "Resetting Picker to fresh install state..."

# Reset Screen Recording permission (TCC database)
# This will trigger the permission dialog again on next launch
tccutil reset ScreenCapture ${BUNDLE_ID} 2>/dev/null && \
    echo "  Reset Screen Recording permission" || \
    echo "  Screen Recording permission not found (already reset)"

# Remove sandboxed data (if app is sandboxed)
# Note: Cannot delete the container itself, only its contents
if [ -d "$CONTAINER_DATA/Library/Preferences" ]; then
    rm -f "$CONTAINER_DATA/Library/Preferences/${BUNDLE_ID}.plist" 2>/dev/null && \
        echo "  Removed sandboxed preferences" || true
fi
if [ -d "$CONTAINER_DATA/Library/Caches/${BUNDLE_ID}" ]; then
    rm -rf "$CONTAINER_DATA/Library/Caches/${BUNDLE_ID}" 2>/dev/null && \
        echo "  Removed sandboxed cache" || true
fi

# Remove UserDefaults preferences (non-sandboxed)
if [ -f ~/Library/Preferences/${BUNDLE_ID}.plist ]; then
    rm ~/Library/Preferences/${BUNDLE_ID}.plist
    echo "  Removed preferences"
fi

# Remove cached data (non-sandboxed)
if [ -d ~/Library/Caches/${BUNDLE_ID} ]; then
    rm -rf ~/Library/Caches/${BUNDLE_ID}
    echo "  Removed cache"
fi

# Clear defaults database directly (catches any edge cases)
defaults delete ${BUNDLE_ID} 2>/dev/null && echo "  Cleared defaults" || true

# Kill cfprefsd to ensure preferences are reloaded
killall cfprefsd 2>/dev/null || true

echo "Done. Restart Picker for a fresh start."

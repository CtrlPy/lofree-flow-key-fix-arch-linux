#!/bin/bash
#
# lofree_fn_fix.sh - Apply hid_apple fnmode=2 for Lofree Flow keyboard
#
# Usage:
#   Interactive (manual run): ./lofree_fn_fix.sh
#   Non-interactive (udev):   ./lofree_fn_fix.sh --udev
#
# The Lofree Flow keyboard must be in MacOS/iOS mode (Fn + M) for the
# hid_apple kernel module to attach to it and for this fix to work.

SYSFS_FNMODE="/sys/module/hid_apple/parameters/fnmode"

set_fnmode() {
    # Ensure hid_apple module is loaded
    if ! lsmod | grep -q "^hid_apple"; then
        modprobe hid_apple 2>/dev/null || {
            echo "ERROR: hid_apple module not found. Cannot apply fix." >&2
            exit 1
        }
    fi

    # Ensure sysfs path exists
    if [ ! -f "$SYSFS_FNMODE" ]; then
        echo "ERROR: $SYSFS_FNMODE not found. Is hid_apple loaded?" >&2
        exit 1
    fi

    echo 2 > "$SYSFS_FNMODE" || {
        echo "ERROR: Failed to write fnmode. Are you running as root?" >&2
        exit 1
    }
}

# --- Non-interactive mode (called by udev, already runs as root) ---
if [ "$1" = "--udev" ]; then
    set_fnmode
    exit 0
fi

# --- Interactive mode (manual run by user) ---
echo "Lofree Flow - F-key fix"
echo "========================"
echo
echo "Make sure your keyboard is in MacOS/iOS mode."
echo "If it is in Windows/Android mode, press Fn + M to switch."
echo
printf "Press Enter to apply fix (or Ctrl+C to cancel)... "
read -r _

# Interactive mode: check if running as root, use sudo if not
if [ "$(id -u)" -ne 0 ]; then
    echo
    echo "Applying fnmode=2 (will prompt for sudo password)..."
    sudo bash -c "
        if ! lsmod | grep -q '^hid_apple'; then
            modprobe hid_apple 2>/dev/null || { echo 'ERROR: hid_apple not found' >&2; exit 1; }
        fi
        if [ ! -f '$SYSFS_FNMODE' ]; then
            echo 'ERROR: $SYSFS_FNMODE not found' >&2; exit 1
        fi
        echo 2 > '$SYSFS_FNMODE'
    "
else
    set_fnmode
fi

echo
echo "Done! F1-F12 now send standard function key codes."
echo "To use media functions (volume, brightness), hold Fn + F-key."
echo
echo "Note: This setting resets on reboot unless you have"
echo "      /etc/modprobe.d/hid_apple.conf with 'options hid_apple fnmode=2'"
echo "      (install.sh sets this up automatically)."

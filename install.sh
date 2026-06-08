#!/bin/bash
#
# install.sh - Install Lofree Flow F-key fix for Fedora Linux
#
# Tested on: Fedora 38/39/40, ThinkPad X1 Carbon Gen7
# Also works on: Arch Linux, Ubuntu, Debian, and any distro with udev + hid_apple
#
# What this script does:
#   1. Copies lofree_fn_fix.sh to /usr/local/bin/ (SELinux-safe path)
#   2. Sets correct SELinux context (Fedora/RHEL)
#   3. Creates /etc/modprobe.d/hid_apple.conf for permanent fnmode=2 across reboots
#   4. Installs /etc/udev/rules.d/99-lofree.rules for automatic re-apply on reconnect
#   5. Reloads udev rules

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_PATH="/usr/local/bin/lofree_fn_fix.sh"
UDEV_RULE="/etc/udev/rules.d/99-lofree.rules"
MODPROBE_CONF="/etc/modprobe.d/hid_apple.conf"

# --- Check root ---
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use: sudo ./install.sh"
    exit 1
fi

echo "Lofree Flow F-key fix - Installer"
echo "==================================="
echo

# --- Step 1: Install the fix script ---
echo "[1/4] Installing lofree_fn_fix.sh -> $INSTALL_PATH"
cp "$SCRIPT_DIR/lofree_fn_fix.sh" "$INSTALL_PATH"
chmod 755 "$INSTALL_PATH"

# --- Step 2: Fix SELinux context (Fedora/RHEL only) ---
if command -v restorecon &>/dev/null; then
    echo "[2/4] Restoring SELinux context for $INSTALL_PATH"
    restorecon -v "$INSTALL_PATH"
else
    echo "[2/4] SELinux tools not found - skipping (not Fedora/RHEL)"
fi

# --- Step 3: Persist fnmode=2 across reboots via modprobe.d ---
echo "[3/4] Creating $MODPROBE_CONF (persistent fnmode=2 across reboots)"
cat > "$MODPROBE_CONF" << 'EOF'
# Lofree Flow keyboard fix
# Sets hid_apple fnmode=2: F1-F12 send standard function keys by default.
# Use Fn + F-key for media functions (volume, brightness, etc.)
# Without this, Lofree Flow sends media keycodes instead of F1-F12.
options hid_apple fnmode=2
EOF

# Apply immediately without reboot (if module already loaded)
if lsmod | grep -q "^hid_apple"; then
    echo "   hid_apple already loaded - applying fnmode=2 now..."
    echo 2 > /sys/module/hid_apple/parameters/fnmode 2>/dev/null || true
else
    echo "   hid_apple not loaded yet - will apply on next keyboard connect."
fi

# --- Step 4: Install udev rule ---
echo "[4/4] Installing udev rule -> $UDEV_RULE"
cp "$SCRIPT_DIR/99-lofree.rules" "$UDEV_RULE"
chmod 644 "$UDEV_RULE"

# Reload udev
echo "   Reloading udev rules..."
udevadm control --reload-rules
udevadm trigger

echo
echo "Installation complete!"
echo "======================"
echo
echo "Next steps:"
echo "  1. Make sure your Lofree Flow is in MacOS/iOS mode: press Fn + M"
echo "     (The light indicator should change. In Windows mode, hid_apple"
echo "      won't attach to the keyboard and the fix won't work.)"
echo
echo "  2. Reconnect the keyboard via Bluetooth."
echo "     The udev rule will automatically re-apply fnmode=2 on each reconnect."
echo
echo "  3. To verify the fix is active:"
echo "     cat /sys/module/hid_apple/parameters/fnmode"
echo "     (Should output: 2)"
echo
echo "  4. To find your keyboard's exact udev name (if the rule doesn't trigger):"
echo "     Check with: sudo udevadm monitor --property --udev &"
echo "     Then reconnect the keyboard and look for ATTRS{name}"
echo "     Update 99-lofree.rules with the correct name if needed."
echo
echo "  To switch back to Windows/Android mode: press Fn + N"
echo "  The modprobe.d setting ensures F-keys stay functional on reconnect."

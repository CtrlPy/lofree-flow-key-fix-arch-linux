# lofree-flow-key-fix

Fix F1–F12 keys for the **Lofree Flow** keyboard on Linux.

By default the Lofree Flow sends multimedia keycodes (volume, brightness) instead of standard F1–F12. This repo provides a script and udev rule that fix this by setting `fnmode=2` in the `hid_apple` kernel module.

**Tested on:** Fedora 38/39/40, Arch Linux  
**Connection:** Bluetooth  
**Keyboard mode required:** MacOS/iOS mode (`Fn + M`)

---

## How it works

The Lofree Flow uses Apple's HID descriptor, so Linux attaches the `hid_apple` kernel module to it — but only when the keyboard is in **MacOS/iOS mode** (`Fn + M`). That module defaults to `fnmode=1` (media keys first). Setting `fnmode=2` inverts this: F1–F12 are standard by default, media functions require `Fn + F-key`.

---

## Quick Install (recommended)

```sh
git clone https://github.com/CtrlPy/lofree-flow-key-fix-arch-linux.git
cd lofree-flow-key-fix-arch-linux
sudo ./install.sh
```

The installer:
1. Copies `lofree_fn_fix.sh` to `/usr/local/bin/` (SELinux-safe path)
2. Sets correct SELinux context on Fedora/RHEL via `restorecon`
3. Creates `/etc/modprobe.d/hid_apple.conf` — persists `fnmode=2` across reboots
4. Installs `/etc/udev/rules.d/99-lofree.rules` — re-applies on each BT reconnect
5. Reloads udev rules

---

## Requirements

- Linux with udev and the `hid_apple` kernel module
- Keyboard must be in **MacOS/iOS mode**: press `Fn + M`  
  *(In Windows/Android mode, `hid_apple` won't attach and the fix won't work)*

---

## Manual Setup

If you prefer to set things up yourself:

### 1. Check/load the hid_apple module

```sh
lsmod | grep hid_apple
# If not loaded:
sudo modprobe hid_apple
```

### 2. Persist fnmode=2 across reboots

```sh
echo 'options hid_apple fnmode=2' | sudo tee /etc/modprobe.d/hid_apple.conf
```

### 3. Install the fix script

```sh
sudo cp lofree_fn_fix.sh /usr/local/bin/
sudo chmod 755 /usr/local/bin/lofree_fn_fix.sh

# Fedora/RHEL only - fix SELinux context:
sudo restorecon -v /usr/local/bin/lofree_fn_fix.sh
```

### 4. Install the udev rule

```sh
sudo cp 99-lofree.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger
```

### 5. Apply immediately (without reconnecting)

```sh
# Apply right now (no reboot needed):
sudo modprobe hid_apple
echo 2 | sudo tee /sys/module/hid_apple/parameters/fnmode
```

---

## Verify

```sh
cat /sys/module/hid_apple/parameters/fnmode
# Expected output: 2
```

---

## Troubleshooting

**F-keys still act as media keys after install:**
- Make sure the keyboard is in MacOS/iOS mode: press `Fn + M`
- Check fnmode: `cat /sys/module/hid_apple/parameters/fnmode` (should be `2`)
- If it's not `2`, apply manually: `echo 2 | sudo tee /sys/module/hid_apple/parameters/fnmode`

**udev rule doesn't trigger on reconnect (Fedora):**
- SELinux may be blocking execution. Verify the script context:  
  `ls -Z /usr/local/bin/lofree_fn_fix.sh`  
  Should show `bin_t` (not `user_home_t`). If wrong, run: `sudo restorecon -v /usr/local/bin/lofree_fn_fix.sh`

**Wrong keyboard name in udev rule:**
- The name `Flow84@Lofree` in `99-lofree.rules` may differ by firmware version.  
  To find your keyboard's exact name:
  ```sh
  sudo udevadm monitor --property --udev &
  # Then reconnect the keyboard and look for ATTRS{name}=
  ```
  Update `99-lofree.rules` with the correct name and reinstall.

---

## Files

| File | Description |
|------|-------------|
| `lofree_fn_fix.sh` | Fix script. Interactive when run manually, non-interactive (`--udev`) for udev |
| `99-lofree.rules` | udev rule — triggers fix on every Bluetooth reconnect |
| `install.sh` | Automated installer (Fedora + Arch + other distros) |

---

## Manual run (without udev)

```sh
./lofree_fn_fix.sh
```

---

[Reddit post about the Lofree Flow keyboard](https://www.reddit.com/r/MechanicalKeyboards/comments/1gi4nsy/lofree_flow_first_impressions_pros_and_cons_my/)

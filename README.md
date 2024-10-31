# lofree-flow-key-fix-arch-linux

Description: This repository contains a script and udev rule for configuring the Fn keys on the Lofree Flow keyboard in Arch Linux. The setup allows F-keys to be used by default, while multimedia functions can be activated with Fn + F.

1. Requirements
Arch Linux (or any system supporting udev)
The hid_apple module should be loaded

2. Setup Steps
Step 1: Check for hid_apple Module
Ensure the hid_apple module is loaded by running:

bash
Copy code
`lsmod | grep hid_apple`
If hid_apple isn’t loaded, activate it with:

bash
Copy code 
`sudo modprobe hid_apple`
*Step 2*: Create the Fn Key Configuration Script
Create a script file:

bash
Copy code
`nano ~/lofree_fn_fix.sh`
Add the following code: 

bash
Copy code
`chmod +x ~/lofree_fn_fix.sh` 

*Step 3*: Create a udev Rule to Automate Script Execution
Create the udev rule:

bash
Copy code
`sudo nano /etc/udev/rules.d/99-lofree.rules`
Add the following line, replacing your_username with your actual username:

plaintext
Copy code
```zsh
ACTION=="add", ATTRS{name}=="Flow84@Lofree", RUN+="/home/your_username/lofree_fn_fix.sh"
```
Ensure ATTRS{name} matches the name of your keyboard as seen in bluetoothctl.

Save the rule and reload udev:

bash
Copy code
`sudo udevadm control --reload-rules`
`sudo udevadm trigger`

*Step 4*: Verify Fn Key Functionality
After following these steps, the F1–F12 keys should function as standard F keys, and multimedia controls should be accessible with Fn + F.

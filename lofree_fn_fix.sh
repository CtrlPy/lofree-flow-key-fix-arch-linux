#!/bin/sh

echo "Setting default F-key mode for Lofree Flow"
echo
echo "Please switch keyboard to MacOS/iOS mode: press Fn + M"
read -p "Press any key to continue..." PRESSKEY
echo
echo "Setting Fn Mode to 2"
sudo sh -c 'echo 2 > /sys/module/hid_apple/parameters/fnmode'
echo "Done! You can switch back to Windows/Android mode by pressing Fn + N"

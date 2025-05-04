#!/bin/sh

#######################################################################
#
# This script is used to revert the changes made by fuyujitaku.sh.
#
#######################################################################
BACKUPDIR=backup

# Check if the original swap size file exists
if [ ! -f "$BACKUPDIR"/swap_size ]; then
    echo "Original swap size file not found."
    echo "Aborted."
    exit 1
fi
# Read the original swap size
ORIGINAL_SWAP_SIZE=$(cat "$BACKUPDIR"/swap_size)
echo "Original swap size: $ORIGINAL_SWAP_SIZE MB"

#-----------------------------------------------------------------------    
# Resize the swap file back to the original size

echo "----------- Reverting swap file size -----------"
# Get the swap file name
SWAPFILE=$(swapon --show=NAME --noheadings)
if [ -f "$SWAPFILE" ]; then
    echo "Swap file: $SWAPFILE"
else
    echo "!!!!! Swap file not found."
    echo "!!!!! Aborted."
    exit 1
fi
sudo swapoff "$SWAPFILE"
if [ $? -ne 0 ]; then
    echo "Failed to turn off swap file."
    echo "Aborted."
    exit 1
fi
sudo dd if=/dev/zero of="$SWAPFILE" bs=1M count="$ORIGINAL_SWAP_SIZE" status=progress
if [ $? -ne 0 ]; then
    echo "!!!!! Failed to resize swap file."
    echo "!!!!! Swap region is recovered with original size."
    echo "!!!!! Aborted."
    exit 1
fi
sudo mkswap "$SWAPFILE"
if [ $? -ne 0 ]; then
    echo "!!!!! Failed to create swap file."
    echo "!!!!! This is fatal and could be unrecoverable."
    echo "!!!!! Please check the swap file."
    echo "!!!!! Aborted."
    exit 1
fi
sudo swapon "$SWAPFILE"
if [ $? -ne 0 ]; then
    echo "!!!!! Failed to turn on swap file."
    echo "!!!!! Please check the swap file."    
    echo "!!!!! Aborted."
    exit 1
fi
#-----------------------------------------------------------------------
# Retrieve the grub file.
sudo cp "$BACKUPDIR"/grub /etc/default/grub
if [ $? -ne 0 ]; then
    echo "!!!!! Failed to copy grub file."
    echo "!!!!! Aborted."
    exit 1
fi
#-----------------------------------------------------------------------
# Update the grub configuration
echo "----------- Updating GRUB configuration -----------"
sudo update-grub
if [ $? -ne 0 ]; then
    echo "!!!!! Failed to update GRUB configuration."
    echo "!!!!! Aborted."
    exit 1
fi
#-----------------------------------------------------------------------
# Remove the custom sleep configuration
echo "----------- Removing sleep configuration -----------"
sudo rm -f /etc/systemd/sleep.conf.d/sleep.conf
if [ $? -ne 0 ]; then
    echo "!!!!! Failed to remove hibernation configuration."
    echo "!!!!! Aborted."
    exit 1
fi

#-----------------------------------------------------------------------
# Remove the custom policykit configuration
echo "----------- Removing policykit configuration -----------"
sudo rm -f /etc/polkit-1/rules.d/50-hibernate.rules
if [ $? -ne 0 ]; then
    echo "!!!!! Failed to remove policykit configuration."
    echo "!!!!! Aborted."
    exit 1
fi
#-----------------------------------------------------------------------
# Reload the systemd daemon
echo "----------- Reloading systemd daemon -----------"
sudo systemctl daemon-reload
if [ $? -ne 0 ]; then
    echo "!!!!! Failed to reload systemd daemon."
    echo "!!!!! Aborted."
    exit 1
fi
#-----------------------------------------------------------------------
# All done
echo "----------- Revert completed -----------"
echo "Swap file size reverted to original size: $ORIGINAL_SWAP_SIZE MB"
echo "GRUB configuration reverted to original."
echo "Sleep configuration reverted to original."
echo "Policykit configuration reverted to original."
echo "Systemd daemon reloaded."
echo "All done."
echo "Please reboot your system to apply the changes."


#!/bin/sh


. ./lib/functions.sh

#######################################################################
#
# This script is used to revert the changes made by fuyujitaku.sh.
#
#######################################################################
BACKUPDIR=$(get_backup_dir_name)
SIZEFILE=$(get_original_swap_size_file_name)
GRUBFILE=$(get_original_grub_file_name)

# Check if the original swap size file exists
if [ ! -f "$BACKUPDIR"/"$SIZEFILE" ]; then
    echo "Original swap size file not found."
    echo "Aborted."
    exit 1
fi
# Read the original swap size
ORIGINAL_SWAP_SIZE=$(cat "$BACKUPDIR"/"$SIZEFILE")
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
sudo cp "$BACKUPDIR"/"$GRUBFILE" /etc/default/grub
if [ $? -ne 0 ]; then
    echo "!!!!! Failed to copy grub file."
    echo "!!!!! Aborted."
    exit 1
fi
#-----------------------------------------------------------------------
# Update the grub configuration
echo "----------- Reverting GRUB configuration -----------"
sudo update-grub
if [ $? -ne 0 ]; then
    echo "!!!!! Failed to update GRUB configuration."
    echo "!!!!! Aborted."
    exit 1
fi
#-----------------------------------------------------------------------
# Update initramfs
# This is necessary to apply the changes in the GRUB configuration,
# from Ubuntu 26.04. 
echo "----------- Updating initramfs -----------"
sudo update-initramfs -u
if [ $? -ne 0 ]; then
    echo "!!!!! Failed to update initramfs."
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
# Remove the backup files
echo "----------- Removing backup files -----------"
sudo rm -rf "$BACKUPDIR"

#-----------------------------------------------------------------------
# All done
echo "----------- Revert completed -----------"
echo "Reverted swap file size to original size: $ORIGINAL_SWAP_SIZE MB"
echo "Reverted GRUB configuration to original."
echo "Reverted sleep configuration to original."
echo "Reverted policykit configuration to original."
echo "Systemd daemon reloaded."
echo "Original files removed."
echo "All done."
echo "Please reboot your system to apply the changes."


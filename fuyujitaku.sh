#! /bin/sh

#######################################################################
#
# This script is used to enable hibernation.
#
#######################################################################

# if TARGET_SWAP_SIZE is not set, it will be calculated as 2 times the RAM size.
if [ -z "$TARGET_SWAP_SIZE" ]; then
    # Required swap size is 2 times the RAM size.
    # Get the current main memory size by free command.
    # Extract the size only and then, times 2.
    TARGET_SWAP_SIZE=$(free --giga | awk '/Mem:/{print $2*2 "G"}')
fi
echo "Target swap size: $TARGET_SWAP_SIZE"
# convert target swap size to MB
TARGET_SWAP_SIZE=$(echo "$TARGET_SWAP_SIZE" | awk '{print $1*1024}')

# save original swap size
BACKUPDIR=backup
mkdir -p "$BACKUPDIR"
ORIGINAL_SWAP_SIZE=$(free --mega | awk '/Swap:/{print $2}')
echo "$ORIGINAL_SWAP_SIZE" > "$BACKUPDIR"/swap_size

#----------------------------------------------------------------------
#
# Resize the swap file.
#
echo "----------- Resizing swap file -----------"

# Get the swap file name.
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

sudo dd if=/dev/zero of="$SWAPFILE" bs=1M count="$TARGET_SWAP_SIZE" status=progress
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

#----------------------------------------------------------------------
#
# Inform swap location to the kernel.
#
echo "----------- Editing GRUB configuration -----------"


# Get the UUID of the root filesystem (where the swap file stays).
UUID=$(findmnt / -o UUID --noheadings)

# Get the offset of the swap file.
OFFSET=$(sudo filefrag -v "$SWAPFILE" | awk '/ 0:/{print substr($4, 1, length($4)-2)}')

# Construct the resume option for kernel parameters.
OPTION="resume=UUID=${UUID} resume_offset=${OFFSET}"

# Save the current GRUB configuration to a temporary file.
SAVED_GRUB=$(mktemp)
sudo cp /etc/default/grub "$SAVED_GRUB"

# If the grub configuration contains resume/resume_offset, remove them first.
sudo sed -i /^GRUB_CMDLINE_LINUX_DEFAULT/s/resume[_=a-zA-Z0-9-]*//g /etc/default/grub

# Add the resume option to the GRUB_CMDLINE_LINUX_DEFAULT line in /etc/default/grub.
sudo sed -i "s|^\(GRUB_CMDLINE_LINUX_DEFAULT=.*['\"].*\)\(['\"]\).*$|\1 ${OPTION}\2|" /etc/default/grub
if [ $? -ne 0 ]; then
    echo "!!!!! Failed to update GRUB configuration."
    echo "!!!!! Aborted."
    # remove the temporary file.
    rm "$SAVED_GRUB"
    exit 1
fi

echo "----------- Updating GRUB configuration -----------"
# Update the GRUB configuration.
sudo update-grub
if [ $? -ne 0 ]; then
    echo "!!!!! Failed to update GRUB configuration."
    # Restore the original GRUB configuration.
    echo "!!!!! Restoring original GRUB configuration."
    sudo mv "$SAVED_GRUB" /etc/default/grub
    echo "!!!!! Aborted."
    exit 1
else
    # Save the original file.
    cp "$SAVED_GRUB" "$BACKUPDIR"/grub
fi

#----------------------------------------------------------------------
#
# Configure the HibernateDelaySec parameter in the systemd.
# THis allow the suspend-then-hibernate feature to work.
#
echo "----------- Configuring HibernateDelaySec parameter -----------"

sudo mkdir -p /etc/systemd/sleep.conf.d
cat /etc/systemd/sleep.conf | sed 's|^.*HibernateDelaySec=.*$|HibernateDelaySec=900|'| sudo tee /etc/systemd/sleep.conf.d/hibernate.conf

if [ $? -ne 0 ]; then
    echo "!!!!! Failed to update /etc/systemd/sleep.conf.d/hibernate.conf."
    echo "!!!!! Aborted."
    exit 1
fi

#----------------------------------------------------------------------
#
# Configure the Hibernation policy in the systemd.
#
echo "----------- Configuring Hibernation policy -----------"

# Write rule to allow hibernation for all users.
cat <<EOF | sudo tee /etc/polkit-1/rules.d/50-hibernate.rules
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.login1.hibernate" ||
        action.id == "org.freedesktop.login1.hibernate-multiple-sessions" ||
        action.id == "org.freedesktop.upower.hibernate" ||
        action.id == "org.freedesktop.login1.handle-hibernate-key" ||
        action.id == "org.freedesktop.login1.hibernate-ignore-inhibit")
    {
        return polkit.Result.YES;
    }
});
EOF
if  [ $? -ne 0 ]; then
    echo "!!!!! Failed to update /etc/polkit-1/rules.d/50-hibernate.rules."
    echo "!!!!! Aborted."
    exit 1
fi

#----------------------------------------------------------------------
#
# End of script.
#
echo "************************************************************"
echo "All done."
echo "Please reboot your system to apply the changes."
echo "After reboot, you can use the following command to hibernate your system:"
echo "  sudo systemctl hibernate"
echo "or"
echo "You can hibernate from the GUI."


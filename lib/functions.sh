#!/bin/sh

# Write a stream to a file.
# This is a helper function to make test easier.
# Usage:
#  write_stream STREAM FILENAME 
write_stream() {
    local FILENAME="$2"
    local STREAM="$1"

    echo "$STREAM" > "$FILENAME"
}


# Write a source file to a destination file.
# This is a helper function to make test easier.
# Usage:
#  write_file SOURCE_FILENAME DESTINATION_FILENAME 
write_file() {
    local SOURCE_FILENAME="$1"
    local DESTINATION_FILENAME="$2"

    cp "$SOURCE_FILENAME" "$DESTINATION_FILENAME"
}



# Check if the root filesystem is ext4.
# If it is ext4, return 0.
# If it is not ext4, return 1.
check_root_filesystem() {
    ROOT_FS_TYPE=$(findmnt / -o FSTYPE --noheadings)
    if [ "$ROOT_FS_TYPE" != "ext4" ]; then
        echo "!!!!! Root filesystem is not ext4."
        echo "!!!!! This script supports only ext4 filesystem."
        echo "!!!!! Aborted."
        return 1
    fi
    return 0
}


# Print usage information.
print_usage() {
    echo "Usage:"
    echo "./fuyujitaku.sh [OPTIONS]"
    echo "   OPTIONS: -s SIZE  : Target swap size. SIZE is NNNG or NNNM format."
    echo "                       Where G is GigaByte and M is MegaByte."
    echo "                       If not specified, it will be set to 2 times the RAM size."
    echo "            -d DELAY : Hibernate delay time. DELAY isNNNs, NNNm format."    
    echo "                       Where s is seconds and m is minutes."
    echo "                       If not specified, it will be set to 15m."

    return 0
}

# Parse command line arguments.
# If unkown options are given, return with 1.
parse_arguments() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -s)
                TARGET_SWAP_SIZE="$2"
                shift 2
                ;;
            -d)
                HIBERNATE_DELAY_SEC="$2"
                shift 2
                ;;
            -h|--help)
                print_usage
                return 1
                ;;
            *)
                echo "Unknown option: $1"
                print_usage
                return 1
                ;;
        esac
    done

    return 0
}

# Set default value to the TARGET_SWAP_SIZE variable.
# The default value is 2 times the RAM size by Megabyte.
# The value must have 'M' suffix.
set_default_target_swap_size() {
    TARGET_SWAP_SIZE=$(free --mega | awk '/Mem:/{print $2*2 "M"}')

    return 0
}

# Set default value to the HIBERNATE_DELAY_SEC variable.
# The default value is 15 minutes.
# The value must have 'm' suffix.
set_default_hibernate_delay_sec() {
    HIBERNATE_DELAY_SEC="15m"

    return 0
}


# Validate and normalize the TARGET_SWAP_SIZE.
# 1G must be times 1024M.
# Finally, we remove the unit and keep only the size in MB.
# If the format is invalid, the function return with 1.
validate_and_normalize_target_swap_size() {
    if echo "$TARGET_SWAP_SIZE" | grep -qE '^[0-9]+G$'; then
        # G format
        SIZE_IN_G=$(echo "$TARGET_SWAP_SIZE" | sed 's/G//')
        # Remove the 'G' suffix and convert to M.
        TARGET_SWAP_SIZE=$(echo "$SIZE_IN_G" | awk '{print $1*1024}')
    elif echo "$TARGET_SWAP_SIZE" | grep -qE '^[0-9]+M$'; then
        # M format
        # Remove the 'M' suffix.
        TARGET_SWAP_SIZE=$(echo "$TARGET_SWAP_SIZE" | sed 's/M//')
    else
        echo "!!!!! TARGET_SWAP_SIZE format is invalid."
        echo "!!!!! Please set TARGET_SWAP_SIZE in NNNG or NNNM format."
        echo "!!!!! Aborted."
        return 1
    fi

    return 0
}

# Validate and normalize the HIBERNATE_DELAY_SEC.
# 1min must be times 60 sec.
# Finally, we remove the unit and keep only the size in sec.
# If the format is invalid, the funciton return with 1.
validate_and_normalize_hibernate_delay_sec() {
    if echo "$HIBERNATE_DELAY_SEC" | grep -qE '^[0-9]+s$'; then
        # sec format
        HIBERNATE_DELAY_SEC=$(echo "$HIBERNATE_DELAY_SEC" | sed 's/s//')
    elif echo "$HIBERNATE_DELAY_SEC" | grep -qE '^[0-9]+m$'; then
        # min format
        SIZE_IN_MIN=$(echo "$HIBERNATE_DELAY_SEC" | sed 's/m//')
        HIBERNATE_DELAY_SEC=$(echo "$SIZE_IN_MIN" | awk '{print $1*60}')
    else
        echo "!!!!! HIBERNATE_DELAY_SEC format is invalid."
        echo "!!!!! Please set HIBERNATE_DELAY_SEC in NNNs or NNNm format."
        echo "!!!!! Aborted."
        return 1
    fi

    return 0
}


# Print the parameters for confirmation.
print_parameters() {
    echo "----------- Parameters -----------"
    echo "TARGET_SWAP_SIZE   : ${TARGET_SWAP_SIZE}MByte"
    echo "HIBERNATE_DELAY_SEC: ${HIBERNATE_DELAY_SEC}sec"
    echo "---------------------------------"
    
    return 0
}   

# Save original swap size
save_original_swap_size() {
    # This directory is shared with inform_swap_location_to_kernel() function.
    BACKUPDIR=backup

    mkdir -p "$BACKUPDIR"
    ORIGINAL_SWAP_SIZE=$(free --mega | awk '/Swap:/{print $2}')
    write_stream "$ORIGINAL_SWAP_SIZE" "$BACKUPDIR/original_swap_size" 

    return 0
}


#----------------------------------------------------------------------
#
# Resize the swap file.
# Use TARGET_SWAP_SIZE variable for the target size in MByte.
#
resize_swap_file() {
    echo "----------- Resizing swap file -----------"

    # Get the swap file name.
    local SWAPFILE=$(swapon --show=NAME --noheadings)
    if [ -f "$SWAPFILE" ]; then
        echo "Swap file: $SWAPFILE"
    else
        echo "!!!!! Swap file not found."
        echo "!!!!! Aborted."
        return 1
    fi

    sudo swapoff "$SWAPFILE"
    if [ $? -ne 0 ]; then
        echo "Failed to turn off swap file."
        echo "Aborted."
        return 1
    fi

    sudo dd if=/dev/zero of="$SWAPFILE" bs=1M count="$TARGET_SWAP_SIZE" status=progress
    if [ $? -ne 0 ]; then
        echo "!!!!! Failed to resize swap file."
        echo "!!!!! Swap region is recovered with original size."
        echo "!!!!! Aborted."
        return 1
    fi

    sudo mkswap "$SWAPFILE"
    if [ $? -ne 0 ]; then
        echo "!!!!! Failed to create swap file."
        echo "!!!!! This is fatal and could be unrecoverable."
        echo "!!!!! Please check the swap file."
        echo "!!!!! Aborted."
        return 1
    fi
    sudo swapon "$SWAPFILE"
    if [ $? -ne 0 ]; then
        echo "!!!!! Failed to turn on swap file."
        echo "!!!!! Please check the swap file."    
        echo "!!!!! Aborted."
        return 1
    fi
    echo "----------- Resize completed -----------"

    return 0
}

#----------------------------------------------------------------------
#
# Inform swap location to the kernel.
# Edit /etc/default/grub to add resume and resume_offset parameters.
# These parameter tell the volume and offset of the swap file to the kernel.
#
inform_swap_location_to_kernel() {
    echo "----------- Editing GRUB configuration -----------"


    # Get the UUID of the root filesystem (where the swap file stays).
    local UUID=$(findmnt / -o UUID --noheadings)

    # Get the offset of the swap file.
    local OFFSET=$(sudo filefrag -v "$SWAPFILE" | awk '/ 0:/{print substr($4, 1, length($4)-2)}')

    # Construct the resume option for kernel parameters.
    local OPTION="resume=UUID=${UUID} resume_offset=${OFFSET}"

    # Save the current GRUB configuration to a temporary file.
    local TEMP_GRUB=$(mktemp)
    local SAVED_GRUB=$(mktemp)
    sudo cp /etc/default/grub "$TEMP_GRUB"
    sudo cp /etc/default/grub "$SAVED_GRUB"

    # If the grub configuration contains resume/resume_offset, remove them first.
    sudo sed -i /^GRUB_CMDLINE_LINUX_DEFAULT/s/resume[_=a-zA-Z0-9-]*//g $TEMP_GRUB

    # Add the resume option to the GRUB_CMDLINE_LINUX_DEFAULT line in /etc/default/grub.
    sudo sed -i "s|^\(GRUB_CMDLINE_LINUX_DEFAULT=.*['\"].*\)\(['\"]\).*$|\1 ${OPTION}\2|" $TEMP_GRUB
    if [ $? -ne 0 ]; then
        echo "!!!!! Failed to update GRUB configuration."
        echo "!!!!! Aborted."
        return 1
    fi

    sudo write_file "$TEMP_GRUB" /etc/default/grub

    # Update the GRUB configuration.
    sudo update-grub
    if [ $? -ne 0 ]; then
        echo "!!!!! Failed to update GRUB configuration."
        # Restore the original GRUB configuration.
        echo "!!!!! Restoring original GRUB configuration."
        sudo write_file "$SAVED_GRUB" /etc/default/grub
        echo "!!!!! Aborted."
        return 1
    else
        # Save the original file.
        write_file "$SAVED_GRUB" "$BACKUPDIR/original_grub_config"
    fi

    echo "----------- GRUB configuration updated -----------"

    return 0
}

#----------------------------------------------------------------------
#
# Configure the HibernateDelaySec parameter in the systemd.
# THis allow the suspend-then-hibernate feature to work.
# Using HIBERNATE_DELAY_SEC variable for the delay time in seconds.
# Note that the  hibernate.conf file is "drop-in" file.
# So, it will be not overwritten by system updates.
#
configure_hibernate_delay_sec() {
    echo "----------- Configuring HibernateDelaySec parameter -----------"

    sudo mkdir -p /etc/systemd/sleep.conf.d
    cat /etc/systemd/sleep.conf | sed "s|^.*HibernateDelaySec=.*$|HibernateDelaySec=${HIBERNATE_DELAY_SEC}|"| sudo tee /etc/systemd/sleep.conf.d/hibernate.conf

    if [ $? -ne 0 ]; then
        echo "!!!!! Failed to update /etc/systemd/sleep.conf.d/hibernate.conf."
        echo "!!!!! Aborted."
        return 1
    fi

    return 0
}

#----------------------------------------------------------------------
#
# Configure the Hibernation policy in the systemd.
# This policy allows all users to hibernate the system.
# Note that the 50-hibernate.rules file is "drop-in" file.
# So, it will be not overwritten by system updates. 
#
configure_hibernation_policy() {
    echo "----------- Configuring Hibernation policy -----------"

    # Write rule to allow hibernation for all users.
    cat <<- EOF | sudo tee /etc/polkit-1/rules.d/50-hibernate.rules
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
        return 1
    fi

    return 0
}

#----------------------------------------------------------------------
#
# End of script.
#

print_end_message() {
    echo "************************************************************"
    echo "All done."
    echo "Please reboot your system to apply the changes."
    echo "After reboot, you can use the following command to hibernate your system:"
    echo "  sudo systemctl hibernate"
    echo "or"
    echo "You can hibernate from the GUI."

    return 0
}
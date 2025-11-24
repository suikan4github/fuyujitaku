#! /bin/sh

. ./lib/functions.sh

#######################################################################
#
# This script is used to enable hibernation.
#
#######################################################################


# ----------------------------------------------------------------------
# Main script starts here.
#

# If it return non zero, abort the script.
check_root_filesystem
if [ $? -ne 0 ]; then
    exit 1
fi

set_default_target_swap_size
set_default_hibernate_delay_sec

# If it returns non zeor, abort the script
parse_arguments "$@"
if [ $? -ne 0 ]; then
    exit 1
fi

# If it returns non zeor, abort the script
validate_and_normalize_hibernate_delay_sec
if [ $? -ne 0 ]; then
    exit 1
fi

# If it returns non zeor, abort the script
validate_and_normalize_target_swap_size
if [ $? -ne 0 ]; then
    exit 1
fi

# print_parameters

# Ask user for confirmation before proceeding
echo ""
echo "This script will modify your system configuration to enable hibernation."
echo "The following changes will be made:"
echo "  - Resize swap file to ${TARGET_SWAP_SIZE}MB."
echo "  - Update GRUB configuration."
echo "  - Configure hibernation delay to ${HIBERNATE_DELAY_SEC} seconds."
echo "  - Set hibernation policy to allow hibernation from menu."
echo ""
printf "Do you want to continue? (y/N): "
read -r RESPONSE
case "$RESPONSE" in
    [yY]|[yY][eE][sS])
        echo "Proceeding with hibernation configuration..."
        ;;
    *)
        echo "Aborted by user."
        exit 0
        ;;
esac
echo ""

save_original_swap_size

# If it returns non zero, abort the script.
resize_swap_file
if [ $? -ne 0 ]; then
    exit 1
fi

# If it returns non zero, abort the script.
inform_swap_location_to_kernel
if [ $? -ne 0 ]; then
    exit 1
fi

# If it returns non zero, abort the script.
configure_hibernate_delay_sec
if [ $? -ne 0 ]; then
    exit 1
fi

# If it returns non zero, abort the script.
configure_hibernation_policy
if [ $? -ne 0 ]; then
    exit 1
fi

print_end_message

exit 0

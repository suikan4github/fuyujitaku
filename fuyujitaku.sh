#! /bin/sh

include 'lib/functions.sh'

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

parse_arguments "$@"

validate_and_normalize_hibernate_delay_sec
validate_and_normalize_target_swap_size

print_parameters

save_original_swap_size

resize_swap_file

inform_swap_location_to_kernel

configure_hibernate_delay_sec

configure_hibernation_policy

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


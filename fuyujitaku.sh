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

print_parameters

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

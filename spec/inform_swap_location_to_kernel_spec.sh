#!/bin/sh

Include 'lib/functions.sh'

Describe 'inform_swap_location_to_kernel function'

    # Declare the global variable to capture the data.
    WRITE_GRUB_SOURCE_FILENAME=

    sudo() {
        # Simulate sudo by calling the command directly.
        "$@"
    }

    findmnt() {
        echo "53735f87-6540-406e-8f61-722d0a4eb48a"
        return 0
    }

    filefrag() {
        cat << 'EOF'
Filesystem type is: ef53
File size of /swapfile is 4294967296 (1048576 blocks of 4096 bytes)
 ext:     logical_offset:        physical_offset: length:   expected: flags:
   0:        0..    4095:    2427392..   2431487:   4096:            
   1:     4096..    6143:    2521088..   2523135:   2048:    2431488:
   2:     6144..   16383:    2525184..   2535423:  10240:    2523136:
   3:    16384..   28671:    2557952..   2570239:  12288:    2535424:
EOF
        return 0
    }

    write_file() {
        _SOURCE_FILENAME="$1"
        _DESTINATION_FILENAME="$2"
        return 0
    }

    write_grub() {
        WRITE_GRUB_SOURCE_FILENAME="$1"
        return 0
    }   

    # shellcheck disable=SC3033
    update_grub() {
        return 0
    }

    Context "When successful" 
        It "should inform swap location to kernel and return 0" 
            When call inform_swap_location_to_kernel 
            The output should include "----------- Editing GRUB configuration -----------"

            The file ${WRITE_GRUB_SOURCE_FILENAME} should include "resume=UUID=53735f87-6540-406e-8f61-722d0a4eb48a"
            The file ${WRITE_GRUB_SOURCE_FILENAME} should include "resume_offset=2427392"

            The output should include "----------- GRUB configuration updated -----------"
            The status should be success
        End
    End

End
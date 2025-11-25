#!/bin/sh

Include 'lib/functions.sh'

Describe 'inform_swap_location_to_kernel function'

    df() {
        echo "Filesystem       1M-blocks  Used Available Use% Mounted on"
        echo "/dev/mapper/root    240083 22426    215989  10% /"
    }

    free() {
        echo "              total        used        free      shared  buff/cache   available"
        echo "Mem:          15926        2345       11234         123        2345       13245"
        echo "Swap:         15892           0       15892"
    }

    Context 'When the storage is enough for the new swap file'
        # shellcheck disable=SC2034
        TARGET_SWAP_SIZE="25000"

    # 215989+15892 > 25000+1024  => 231881 > 26024
        It 'should return 0 when there is enough space'
            When call validate_swap_file_size
            The status should be success
        End
    End

    Context 'When the storage is not enough for the new swap file'
        # shellcheck disable=SC2034
        TARGET_SWAP_SIZE="300000"

    # 215989+15892 < 300000+1024  => 231881 < 301024
        It 'should return 1 when there is not enough space'
            When call validate_swap_file_size
            The output should include "Not enough space in root filesystem to resize swap file."
            The status should be failure
        End
    End
End
#!/bin/sh

Include 'lib/functions.sh'

Describe 'print_parameters function'
    Before 'HIBERNATE_DELAY_SEC=127 
            TARGET_SWAP_SIZE=31'

    It "should print HIBERNATE_DELAY_SEC to 127 and  TARGET_SWAP_SIZE to 31" 
        When call print_parameters 
        The output should include "TARGET_SWAP_SIZE   : 31MByte"
        The output should include "HIBERNATE_DELAY_SEC: 127sec"
    End    
End

#!/bin/sh

Include 'lib/functions.sh'

Describe 'validate_and_normalize_target_swap_size function'
  Context 'When TARGET_SWAP_SIZE is 1024M'
    Before 'TARGET_SWAP_SIZE=1024M'

    It "should set TARGET_SWAP_SIZE to 1024 and return 0" 
      When call validate_and_normalize_target_swap_size
      The variable TARGET_SWAP_SIZE should equal '1024'
      The status should be success
    End
  End

  Context 'When TARGET_SWAP_SIZE is 4G'
    Before 'TARGET_SWAP_SIZE=4G'

    It "should set TARGET_SWAP_SIZE to 4096 and return 0" 
      When call validate_and_normalize_target_swap_size
      The variable TARGET_SWAP_SIZE should equal '4096'
      The status should be success
    End
  End

  Context 'When TARGET_SWAP_SIZE is 1024MB'
    Before 'TARGET_SWAP_SIZE=1024MB'

    It "should should print error message and  return 1" 
      When call validate_and_normalize_target_swap_size
      The output should include "!!!!! TARGET_SWAP_SIZE format is invalid."

      The status should be failure
    End
  End

  Context 'When TARGET_SWAP_SIZE is 1024M2'
    Before 'TARGET_SWAP_SIZE=1024M2'

    It "should should print error message and  return 1" 
      When call validate_and_normalize_target_swap_size
      The output should include "!!!!! TARGET_SWAP_SIZE format is invalid."

      The status should be failure
    End
  End

  Context 'When TARGET_SWAP_SIZE is 1024'
    Before 'TARGET_SWAP_SIZE=1024'

    It "should should print error message and  return 1" 
      When call validate_and_normalize_target_swap_size
      The output should include "!!!!! TARGET_SWAP_SIZE format is invalid."

      The status should be failure
    End
  End

  Context 'When TARGET_SWAP_SIZE is M'
    Before 'TARGET_SWAP_SIZE=M'

    It "should should print error message and  return 1" 
      When call validate_and_normalize_target_swap_size
      The output should include "!!!!! TARGET_SWAP_SIZE format is invalid."

      The status should be failure
    End
  End


End
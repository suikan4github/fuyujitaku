#!/bin/sh

# Test the check_root_filesystem function

Include 'lib/functions.sh'

Describe 'check_root_filesystem function'

  Context 'When findmnt returns ext4 for root filesystem'

    Before 'findmnt() 
    {
      echo "ext4"
      return 0
    }'

    It "should not output anything and return 0" 
      When call check_root_filesystem
      The output should not be present
      The error should not be present
      The status should be success
    End
  End

  Context 'When findmnt returns btrfs for root filesystem'

    Before 'findmnt() 
    {
      echo "btrfs"
      return 0
    }'

    It "should print error message and return 1" 
      When call check_root_filesystem
      The output should include "!!!!! Root filesystem is not ext4."
      The error should not be present
      The status should be failure
    End
  End



End

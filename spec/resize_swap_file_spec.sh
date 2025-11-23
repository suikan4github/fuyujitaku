#!/bin/sh

Include 'lib/functions.sh'

Describe 'resize_swap_file function'
  # Mock functions 
  swapon() {
    SWAPON_PARAM="$1"
    echo "spec/dummy_files/swapfile"
    return 0
  }

  swapoff() {
    SWAPOFF_PARAM="$1"
    return 0
  }

  dd() {
    DD_PARAM_IF="$1"
    DD_PARAM_OF="$2"
    DD_PARAM_BS="$3"
    DD_PARAM_COUNT="$4"
    DD_PARAM_STATUS="$5"
    return 0
  }

  mkswap() {
    MKSWAP_PARAM="$1"
    return 0
  }

  sudo() {
    "$@"
  }

  TARGET_SWAP_SIZE="1024"

  # Test
  Context 'When all goes OK'
    It 'should call all command correctly and return 0'
      When call resize_swap_file
      The output should include "----------- Resizing swap file -----------"
      The variable SWAPOFF_PARAM should equal "spec/dummy_files/swapfile"
      The variable DD_PARAM_IF should equal "if=/dev/zero"
      The variable DD_PARAM_OF should equal "of=spec/dummy_files/swapfile"
      The variable DD_PARAM_BS should equal "bs=1M"
      The variable DD_PARAM_COUNT should equal "count=1024"
      The variable DD_PARAM_STATUS should equal "status=progress"
      The variable MKSWAP_PARAM should equal "spec/dummy_files/swapfile"
      The variable SWAPON_PARAM should equal "spec/dummy_files/swapfile"
      The status should be success
    End
  End


  Context 'When the mkswap fails'
    mkswap() {
      MKSWAP_PARAM="$1"
      return 1
    }
    It 'should call all command correctly and return 0'
      When call resize_swap_file
      The output should include "----------- Resizing swap file -----------"
      The variable SWAPOFF_PARAM should equal "spec/dummy_files/swapfile"
      The variable DD_PARAM_IF should equal "if=/dev/zero"
      The variable DD_PARAM_OF should equal "of=spec/dummy_files/swapfile"
      The variable DD_PARAM_BS should equal "bs=1M"
      The variable DD_PARAM_COUNT should equal "count=1024"
      The variable DD_PARAM_STATUS should equal "status=progress"
      The variable MKSWAP_PARAM should equal "spec/dummy_files/swapfile"
      The output should include "!!!!! Failed to create swap file."
      The status should be failure
    End
  End

  Context 'When the 2nd swapon fails'
    swapon() {
        SWAPON_PARAM="$1"
        echo "spec/dummy_files/swapfile"
        return 1
    }
    It 'should call all command correctly and return 0'
      When call resize_swap_file
      The output should include "----------- Resizing swap file -----------"
      The variable SWAPOFF_PARAM should equal "spec/dummy_files/swapfile"
      The variable DD_PARAM_IF should equal "if=/dev/zero"
      The variable DD_PARAM_OF should equal "of=spec/dummy_files/swapfile"
      The variable DD_PARAM_BS should equal "bs=1M"
      The variable DD_PARAM_COUNT should equal "count=1024"
      The variable DD_PARAM_STATUS should equal "status=progress"
      The variable MKSWAP_PARAM should equal "spec/dummy_files/swapfile"
      The variable SWAPON_PARAM should equal "spec/dummy_files/swapfile"
      The output should include "!!!!! Failed to turn on swap file."
      The status should be failure
    End
  End

  Context 'When the dd fails'
    dd() {
        DD_PARAM_IF="$1"
        DD_PARAM_OF="$2"
        DD_PARAM_BS="$3"
        DD_PARAM_COUNT="$4"
        DD_PARAM_STATUS="$5"
        return 1
    }
    It 'should call all command correctly and return 0'
      When call resize_swap_file
      The output should include "----------- Resizing swap file -----------"
      The variable SWAPOFF_PARAM should equal "spec/dummy_files/swapfile"
      The variable DD_PARAM_IF should equal "if=/dev/zero"
      The variable DD_PARAM_OF should equal "of=spec/dummy_files/swapfile"
      The variable DD_PARAM_BS should equal "bs=1M"
      The variable DD_PARAM_COUNT should equal "count=1024"
      The variable DD_PARAM_STATUS should equal "status=progress"
      The output should include "!!!!! Failed to resize swap file."
      The status should be failure
    End
  End

  Context 'When the swapoff fails'
    swapoff() {
        SWAPOFF_PARAM="$1"
        return 1
    }
    It 'should call all command correctly and return 0'
      When call resize_swap_file
      The output should include "----------- Resizing swap file -----------"
      The variable SWAPOFF_PARAM should equal "spec/dummy_files/swapfile"
      The output should include "Failed to turn off swap file."
      The status should be failure
    End
  End

  Context 'When the swapon fails'
    swapon() {
        SWAPON_PARAM="$1"
        echo "spec/dummy_files/swapfile2"
        return 0
    }
    It 'should call all command correctly and return 0'
      When call resize_swap_file
      The output should include "----------- Resizing swap file -----------"
      The output should include "!!!!! Swap file not found."
      The status should be failure
    End
  End

End